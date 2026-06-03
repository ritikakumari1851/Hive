<%@ page import="java.sql.*,com.mycompany.minigram.dao.DBConnection" %>
<%@ page session="true" %>

<%
    // --- JSP LOGIC START ---
    Integer loggedInUserId = (Integer) session.getAttribute("user_id");
    if (loggedInUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userIdParam = request.getParameter("user_id");
    // Determine which profile to view (defaults to logged-in user if no parameter)
    int profileUserId = (userIdParam != null && !userIdParam.isEmpty()) ? Integer.parseInt(userIdParam) : loggedInUserId;
    
    Connection conn = null;
    PreparedStatement userPs = null;
    ResultSet userRs = null;
    PreparedStatement countPs = null;
    ResultSet countRs = null;
    
    // Default values in case of DB error
    String profileUsername = "User";
    String profileEmail = "";
    String profilePic = "uploads/default_profile.png";
    int postCount = 0;
    int followerCount = 0;
    int followingCount = 0;
    boolean isFollowing = false;
    
    try {
        conn = DBConnection.getConnection();
        
        // 1. Fetch user info
        userPs = conn.prepareStatement("SELECT username, email, profile_pic FROM users WHERE user_id=?");
        userPs.setInt(1, profileUserId);
        userRs = userPs.executeQuery();
        if (!userRs.next()) {
            out.println("User not found.");
            // We must close connection before returning
            if (conn != null) conn.close(); 
            return;
        }

        profileUsername = userRs.getString("username");
        profileEmail = userRs.getString("email");
        String dbProfilePic = userRs.getString("profile_pic");
        profilePic = (dbProfilePic != null && !dbProfilePic.isEmpty()) ? dbProfilePic : "uploads/default_profile.png";

        // 2. Fetch counts (Followers, Following, Posts)
        countPs = conn.prepareStatement(
            "SELECT " +
            "(SELECT COUNT(*) FROM follows WHERE following_id=?) AS followers, " +
            "(SELECT COUNT(*) FROM follows WHERE follower_id=?) AS following, " +
            "(SELECT COUNT(*) FROM posts WHERE user_id=?) AS posts"
        );
        countPs.setInt(1, profileUserId);
        countPs.setInt(2, profileUserId);
        countPs.setInt(3, profileUserId);
        countRs = countPs.executeQuery();
        
        if (countRs.next()) {
            followerCount = countRs.getInt("followers");
            followingCount = countRs.getInt("following");
            postCount = countRs.getInt("posts");
        }

        // 3. Check follow status (only if viewing another user)
        if (loggedInUserId.intValue() != profileUserId) {
            PreparedStatement checkPs = conn.prepareStatement(
                "SELECT * FROM follows WHERE follower_id=? AND following_id=?"
            );
            checkPs.setInt(1, loggedInUserId);
            checkPs.setInt(2, profileUserId);
            ResultSet checkRs = checkPs.executeQuery();
            isFollowing = checkRs.next();
            checkRs.close();
            checkPs.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("Database error occurred.");
        return;
    } finally {
        // Close resources in a proper manner
        if (userRs != null) userRs.close();
        if (userPs != null) userPs.close();
        if (countRs != null) countRs.close();
        if (countPs != null) countPs.close();
    }
    // --- JSP LOGIC END ---
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title><%= profileUsername %> - Hive</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Pacifico&display=swap" rel="stylesheet">
<style>
:root {
    --primary-blue: #0095f6;
    --secondary-text: #8e8e8e;
    --border-color: #dbdbdb;
    --background-color: #fafafa;
    --card-background: #fff;
    --success-color: #3897f0;
    --error-color: #ed4956;
    --warning-color: #ff9900;
}

body {
    margin:0;
    font-family: -apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
    background: var(--background-color);
}
a {
    text-decoration: none;
    color: #333;
    font-weight: 500;
}
.header {
    background: var(--card-background);
    border-bottom:1px solid var(--border-color);
    padding:10px 20px;
    display:flex;
    justify-content:space-between;
    align-items:center;
}
.header-logo {
    font-family:'Pacifico', cursive;
    font-size:24px;
    color:#333;
}
.nav-links a {
    margin-left:15px;
    color:#333;
    font-size: 14px;
    font-weight: 600;
}
.main-container {
    max-width:935px;
    margin:40px auto;
    padding:0 20px;
}

/* --- Profile Header Section --- */
.profile-header {
    display:flex;
    align-items:center;
    padding-bottom:40px;
    border-bottom:1px solid var(--border-color);
    margin-bottom:40px;
}
.profile-pic-wrapper {
    width: 150px;
    height: 150px;
    border-radius: 50%;
    margin-right: 50px;
    border: 3px solid transparent; /* Gradient border setup */
    background: linear-gradient(to right, #cc2366, #f09433) border-box;
    display: flex;
    padding: 2px;
}

.profile-pic-wrapper img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 50%;
    border: 3px solid var(--card-background); /* White inner border */
}

.profile-info-details {
    flex-grow: 1;
}
.profile-info-details strong {
    font-size:32px;
    font-weight: 300;
    display:flex;
    align-items:center;
    margin-bottom:15px;
}
.profile-stats {
    display: flex;
    gap: 40px;
    margin-bottom: 20px;
    font-size: 16px;
}
.profile-stats span {
    color: #333;
}
.profile-stats strong {
    font-size: 16px;
    font-weight: 600;
    margin-right: 5px;
    display: inline;
}

.follow-btn {
    background:var(--primary-blue);
    color:white;
    padding:8px 24px;
    border-radius:8px;
    border:none;
    cursor:pointer;
    font-weight:bold;
    font-size: 14px;
    transition: opacity 0.2s;
}
.follow-btn.unfollow {
    background: var(--card-background);
    color: #333;
    border: 1px solid var(--border-color);
}
.follow-btn:hover {
    opacity: 0.8;
}

/* --- Messages, Edit Form, and Posts --- */
.card {
    background:var(--card-background);
    padding:20px;
    border-radius:8px;
    box-shadow:0 1px 3px rgba(0,0,0,0.05);
    margin-bottom:30px;
}
.message {
    padding: 10px;
    border-radius: 4px;
    margin-bottom: 15px;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 14px;
}
.msg-success { background-color: #e6f7ff; color: var(--success-color); border: 1px solid var(--success-color); }
.msg-error { background-color: #fcebeb; color: var(--error-color); border: 1px solid var(--error-color); }
.msg-warning { background-color: #fffbe6; color: var(--warning-color); border: 1px solid var(--warning-color); }

.edit-form label {
    display:block;
    font-weight:600;
    margin-top:10px;
    margin-bottom:5px;
}
.edit-form input[type="text"], .edit-form input[type="email"] {
    width:100%;
    padding:10px;
    border:1px solid var(--border-color);
    border-radius:4px;
    box-sizing:border-box;
}
.edit-form button {
    background: var(--primary-blue);
    color:#fff;
    border:none;
    padding:10px 15px;
    border-radius:4px;
    margin-top:20px;
    font-weight:bold;
    cursor:pointer;
    display: flex;
    align-items: center;
    gap: 8px;
}
.edit-form button:hover {
    background:#0077c2;
}

/* --- NEW EDIT PROFILE STYLES --- */
.edit-profile-container {
    display: flex;
    gap: 30px;
    align-items: flex-start;
    padding-top: 15px;
}

.pic-upload-section {
    flex: 0 0 200px; /* Fixed width for profile picture area */
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-right: 20px;
    /* Separator line for visual grouping */
    border-right: 1px solid var(--border-color); 
}

.current-profile-pic {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    object-fit: cover;
    margin-bottom: 15px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.file-input-wrapper input[type="file"] {
    display: none;
}

.file-input-wrapper label {
    background-color: var(--primary-blue);
    color: white;
    padding: 8px 15px;
    border-radius: 4px;
    cursor: pointer;
    font-weight: bold;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: background-color 0.2s;
    font-size: 14px;
}

.file-input-wrapper label:hover {
    background-color: #0077c2;
}

.text-edit-section {
    flex-grow: 1;
}
/* --- END NEW EDIT PROFILE STYLES --- */


/* --- Post Grid --- */
.post-grid-header {
    text-align: center;
    border-top: 1px solid var(--border-color);
    padding-top: 20px;
    margin-bottom: 20px;
}
.post-grid-header h3 {
    color: var(--secondary-text);
    font-size: 14px;
    margin: 0;
}
.post-grid {
    display:grid;
    grid-template-columns:repeat(3,1fr);
    gap:28px;
}
.grid-post-item {
    position: relative;
    overflow: hidden;
    cursor: pointer;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}
.grid-post-image {
    width:100%;
    aspect-ratio:1/1;
    object-fit:cover;
    display:block;
    transition: opacity 0.3s;
}
.grid-post-item:hover .grid-post-image {
    opacity: 0.7; 
}
.delete-form {
    position: absolute;
    top: 5px;
    right: 5px;
    opacity: 0;
    transition: opacity 0.3s;
}
.grid-post-item:hover .delete-form {
    opacity: 1;
}
.delete-button {
    background: var(--error-color);
    color:white;
    border:none;
    padding: 5px 10px;
    border-radius:4px;
    cursor:pointer;
    font-size:12px;
    display: flex;
    align-items: center;
    gap: 5px;
}

</style>
</head>
<body>

<header class="header">
<div class="header-logo">Hive</div>
<div class="nav-links">
    <a href="home.jsp"><i class="fa-solid fa-house"></i> Home</a>
    <a href="feed.jsp"><i class="fa-solid fa-list-ul"></i> Feed</a>
    <a href="logout"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
</div>
</header>

<div class="main-container">

    <div class="profile-header">
        <div class="profile-pic-wrapper">
            <img src="<%= profilePic %>" alt="<%= profileUsername %> Profile Picture">
        </div>
        
        <div class="profile-info-details">
            <strong>
                <%= profileUsername %>
                <% if (loggedInUserId.intValue() != profileUserId) { %>
                    <form action="followUnfollow" method="post" style="margin-left: 20px;">
                        <input type="hidden" name="following_id" value="<%= profileUserId %>">
                        <button class="follow-btn <%= isFollowing ? "unfollow" : "" %>" type="submit">
                            <%= isFollowing ? "Unfollow" : "Follow" %>
                        </button>
                    </form>
                <% } else { %>
                    <a href="#edit-section" class="follow-btn unfollow" style="text-decoration: none; margin-left: 20px;">
                        <i class="fa-solid fa-gear"></i> Edit Profile
                    </a>
                <% } %>
            </strong>
            
            <div class="profile-stats">
                <span><strong><%= postCount %></strong> posts</span>
                <span><strong><%= followerCount %></strong> followers</span>
                <span><strong><%= followingCount %></strong> following</span>
            </div>
            
            <p style="font-weight: 600; font-size: 16px;">
                <%= profileUsername %>'s Public Info
                <span style="font-weight: normal; display: block; margin-top: 5px; font-size: 14px;">Email: <%= profileEmail %></span>
            </p>
        </div>
    </div>

    <% if (loggedInUserId.intValue() == profileUserId) { %>
    <div class="card" id="edit-section">
        <h3><i class="fa-solid fa-user-pen"></i> Edit Profile</h3>
        
        <% 
            String msg = request.getParameter("m");
            if (msg != null) {
                if ("updated".equals(msg)) { %>
                    <p class="message msg-success"><i class="fa-solid fa-check-circle"></i> Profile updated successfully!</p>
                <% } else if ("error".equals(msg)) { %>
                    <p class="message msg-error"><i class="fa-solid fa-circle-xmark"></i> Error updating profile. Please try again.</p>
                <% } else if ("deleted".equals(msg)) { %>
                    <p class="message msg-success"><i class="fa-solid fa-check-circle"></i> Post deleted successfully!</p>
                <% } else if ("notallowed".equals(msg)) { %>
                    <p class="message msg-error"><i class="fa-solid fa-circle-xmark"></i> Permission denied. Invalid action.</p>
                <% } 
            }
        %>

        <form class="edit-form" action="editProfile" method="post" enctype="multipart/form-data">
            <div class="edit-profile-container">
                
                <div class="pic-upload-section">
                    <label style="font-weight: 600; margin-bottom: 10px;">Current Picture</label>
                    <img src="<%= profilePic %>" class="current-profile-pic" alt="Current Profile Picture">
                    
                    <div class="file-input-wrapper">
                        <input type="file" name="profile_pic" id="profile_pic_upload" accept="image/*">
                        <label for="profile_pic_upload"><i class="fa-solid fa-cloud-arrow-up"></i> Change Photo</label>
                    </div>
                </div>

                <div class="text-edit-section">
                    <label>Username:</label>
                    <input type="text" name="username" value="<%= profileUsername %>" required>
                    
                    <label>Email:</label>
                    <input type="email" name="email" value="<%= profileEmail %>" required>
                    
                    <button type="submit"><i class="fa-solid fa-floppy-disk"></i> Save Changes</button>
                </div>
            </div>
        </form>
    </div>
    <% } %>

    <div class="post-grid-header">
        <h3><i class="fa-solid fa-table-cells"></i> POSTS</h3>
    </div>

    <div class="post-grid">
    <%
        try {
            if (conn == null || conn.isClosed()) conn = DBConnection.getConnection();
        
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM posts WHERE user_id=? ORDER BY created_at DESC");
            ps.setInt(1, profileUserId);
            ResultSet rs = ps.executeQuery();
            boolean hasPosts = false;
            while (rs.next()) {
                hasPosts = true;
    %>
        <div class="grid-post-item">
            <img src="<%= rs.getString("image_path") %>" class="grid-post-image" alt="Post">
            
            <% if (loggedInUserId.intValue() == profileUserId) { %>
            <form action="deletePost" method="post" class="delete-form">
                <input type="hidden" name="post_id" value="<%= rs.getInt("post_id") %>">
                <button type="submit" class="delete-button" onclick="return confirm('Are you sure you want to delete this post?');">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </form>
            <% } %>
        </div>
    <%
            }
            if (!hasPosts) { %>
                <p style="grid-column:1/-1; text-align:center; color:var(--secondary-text);">
                    <%= (loggedInUserId.intValue() == profileUserId) ? "You haven't posted anything yet." : profileUsername + " has no posts yet." %>
                </p>
            <%
            }
            rs.close();
            ps.close();
        } finally {
            if (conn != null) conn.close();
        }
    %>
    </div>

</div>

</body>
</html>
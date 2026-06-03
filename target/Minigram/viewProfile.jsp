<%@ page import="java.sql.*, com.mycompany.minigram.dao.DBConnection" %>
<%@ page session="true" %>

<%
    // --- JSP LOGIC START ---
    Integer loggedInUserId = (Integer) session.getAttribute("user_id");
    if (loggedInUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userIdParam = request.getParameter("user_id");
    if (userIdParam == null || userIdParam.isEmpty()) {
        // Handle case where no user ID is provided (e.g., redirect to home/feed or show error)
        response.sendRedirect("feed.jsp"); 
        return;
    }

    int profileUserId = Integer.parseInt(userIdParam);
    
    Connection conn = null;
    PreparedStatement userPs = null;
    ResultSet userRs = null;
    PreparedStatement countPs = null;
    ResultSet countRs = null;
    
    // Default values
    String profileUsername = "User";
    String profileEmail = "";
    String profilePic = "uploads/default_profile.png";
    int postCount = 0;
    int followerCount = 0;
    int followingCount = 0;
    boolean isFollowing = false;
    
    try {
        conn = DBConnection.getConnection();

        // 1. Get user info
        userPs = conn.prepareStatement("SELECT username, email, profile_pic FROM users WHERE user_id=?");
        userPs.setInt(1, profileUserId);
        userRs = userPs.executeQuery();

        if (!userRs.next()) {
            out.println("User not found.");
            return;
        }

        profileUsername = userRs.getString("username");
        profileEmail = userRs.getString("email");
        String dbProfilePic = userRs.getString("profile_pic");
        profilePic = (dbProfilePic != null && !dbProfilePic.isEmpty()) ? dbProfilePic : "uploads/default_profile.png";

        // 2. Get counts (Followers, Following, Posts)
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

        // 3. Check if logged-in user already follows this profile
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
    } 
    // We will close resources at the end of the page body
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
    --brand-gradient-start: #cc2366; 
    --brand-gradient-end: #f09433;
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
    position: sticky;
    top: 0;
    z-index: 100;
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
    border: 3px solid transparent; 
    background: linear-gradient(to right, var(--brand-gradient-start), var(--brand-gradient-end)) border-box;
    display: flex;
    padding: 2px;
}

.profile-pic-wrapper img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 50%;
    border: 3px solid var(--card-background); 
}

.profile-info-details {
    flex-grow: 1;
}
.profile-info-details strong.username {
    font-size:32px;
    font-weight: 300;
    display:flex;
    align-items:center;
    margin-bottom:15px;
    color: #333;
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
.profile-email-info {
    font-weight: 600;
    font-size: 16px;
    color: #333;
    margin-top: 10px;
}

/* --- Posts Grid --- */
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
    border-radius: 4px; /* Soft corners for images */
}

/* Message Handling (copied from previous refined designs) */
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
.msg-info { background-color: #e6f7ff; color: var(--primary-blue); border: 1px solid var(--primary-blue); }

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
            <strong class="username">
                <%= profileUsername %>
                <% if (loggedInUserId.intValue() != profileUserId) { %>
                    <form action="followUnfollow" method="post" style="margin-left: 20px;">
                        <input type="hidden" name="following_id" value="<%= profileUserId %>">
                        <button class="follow-btn <%= isFollowing ? "unfollow" : "" %>" type="submit">
                            <i class="fa-solid <%= isFollowing ? "fa-user-check" : "fa-user-plus" %>"></i> 
                            <%= isFollowing ? "following" : "Follow" %>
                        </button>
                    </form>
                <% } %>
            </strong>
            
            <div class="profile-stats">
                <span><strong><%= postCount %></strong> posts</span>
                <span><strong><%= followerCount %></strong> followers</span>
                <span><strong><%= followingCount %></strong> following</span>
            </div>
            
            <p class="profile-email-info">
                Email: <span style="font-weight: normal;"><%= profileEmail %></span>
            </p>
            
            <% 
                String message = request.getParameter("m");
                if (message != null) {
                    String text = "";
                    String icon = "";
                    if ("followed".equals(message)) {
                        text = "You are now following " + profileUsername + "!";
                        icon = "fa-check-circle";
                    } else if ("unfollowed".equals(message)) {
                        text = "You unfollowed " + profileUsername + ".";
                        icon = "fa-circle-check";
                    } else if ("error".equals(message)) {
                        text = "Action failed. Please try again.";
                        icon = "fa-triangle-exclamation";
                    }
                    if (!text.isEmpty()) { %>
                        <p class="message msg-info" style="margin-top: 20px;">
                            <i class="fa-solid <%= icon %>"></i> <%= text %>
                        </p>
                    <% } 
                }
            %>

        </div>
    </div>

    <div class="post-grid-header">
        <h3><i class="fa-solid fa-table-cells"></i> POSTS</h3>
    </div>

    <div class="post-grid">
    <%
        // Fetch and display posts
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean hasPosts = false;
        try {
            ps = conn.prepareStatement("SELECT * FROM posts WHERE user_id=? ORDER BY created_at DESC");
            ps.setInt(1, profileUserId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                hasPosts = true;
    %>
        <div class="grid-post-item">
            <img src="<%= rs.getString("image_path") %>" class="grid-post-image" alt="Post">
            </div>
    <%
            }
            if (!hasPosts) { %>
                <p style="grid-column:1/-1; text-align:center; color:var(--secondary-text);">
                    <%= profileUsername %> hasn't posted anything yet.
                </p>
            <%
            }
        } finally {
            // Close resources from the post fetch
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        }
    %>
    </div>

</div>

<%
    try {
        if (conn != null) conn.close();
    } catch (SQLException se) {
        se.printStackTrace();
    }
%>

</body>
</html>
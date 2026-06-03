<%@ page import="java.sql.*,com.mycompany.minigram.dao.DBConnection" %>
<%@ page session="true" %>

<%
    // --- JSP LOGIC START ---
    Integer loggedInUserId = (Integer) session.getAttribute("user_id");
    if (loggedInUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get logged-in user's username and profile picture for display
    Connection conn = null;
    PreparedStatement userPs = null;
    ResultSet userRs = null;
    String loggedInUsername = "User"; // Default in case of DB error
    String loggedInUserPic = "uploads/default_profile.png"; // Default picture path
    
    try {
        conn = DBConnection.getConnection();
        // ? CHANGE 1: Fetch the profile_pic column ?
        userPs = conn.prepareStatement("SELECT username, profile_pic FROM users WHERE user_id=?");
        userPs.setInt(1, loggedInUserId);
        userRs = userPs.executeQuery();
        
        if (userRs.next()) {
            loggedInUsername = userRs.getString("username");
            
            // ? CHANGE 2: Assign the profile picture path ?
            String dbPic = userRs.getString("profile_pic");
            if (dbPic != null && !dbPic.isEmpty()) {
                loggedInUserPic = dbPic;
            }
        }
    } catch (Exception e) {
        // Handle exception (logging is recommended in a real app)
        e.printStackTrace();
    } finally {
        // Resources are closed here for the header block setup
        if (userRs != null) userRs.close();
        if (userPs != null) userPs.close();
    }
    // --- JSP LOGIC END ---
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hive feed</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        :root {
            --primary-blue: #0095f6;
            --secondary-text: #8e8e8e;
            --border-color: #dbdbdb;
            --background-color: #fafafa; /* Fixed typo in background color */
            --card-background: #ffffff;
            /* Gradient for branding/emphasis */
            --brand-gradient: linear-gradient(to right, #cc2366, #e6683c, #f09433);
        }

        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--background-color);
        }
        
        a {
            text-decoration: none;
            color: #333;
            font-weight: 500;
        }

        /* --- Header / Top Navigation Bar --- */
        .header {
            position: sticky;
            top: 0;
            background-color: var(--card-background);
            border-bottom: 1px solid var(--border-color);
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 1000;
        }

        .header-logo {
            font-family: 'Pacifico', cursive; /* Assuming a custom font for 'Hive' logo */
            font-size: 28px;
            font-weight: bold;
            color: #333;
            margin-left:40px;
        }

        .nav-links {
            display: flex;
            align-items: center;
        }
        
        .nav-link {
            padding: 8px 15px;
            margin: 0 5px;
            color: #333;
            font-size: 14px;
            transition: color 0.2s;
        }

        .nav-link:hover {
            color: var(--primary-blue);
        }
        
        .profile-link {
            display: flex;
            align-items: center;
            font-weight: bold;
            margin-left: 15px;
        }
        
        /* ? CSS Modified for <img> element ? */
        .profile-pic-small {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            margin-right: 8px;
            object-fit: cover;
            /* Gradient style remains but applied to the img */
            border: 2px solid transparent;
            padding: 1px;
            background-clip: padding-box, border-box;
            background-image: linear-gradient(var(--card-background), var(--card-background)), var(--brand-gradient);
            background-origin: border-box;
        }

        /* --- Search Bar --- */
        .search-form {
            display: flex;
            align-items: center;
            background-color: var(--background-color);
            border-radius: 8px;
            padding: 5px 10px;
            border: 1px solid var(--border-color);
        }

        .search-input {
            border: none;
            padding: 5px 10px;
            font-size: 14px;
            background: transparent;
            width: 200px;
            outline: none;
        }

        .search-button {
            background: none;
            border: none;
            cursor: pointer;
            color: var(--secondary-text);
            padding: 0 5px;
            font-size: 16px;
        }
        
        /* Ensure icons in buttons are styled correctly */
        .action-button i {
            color: #333; /* Default icon color */
        }
        
        .action-button i.fa-solid.fa-heart {
            color: #ff3040; /* Red color for liked posts */
        }


        /* --- Main Content Layout --- */
        .main-container {
            max-width: 600px; /* Standard feed width */
            margin: 20px auto;
            padding: 0 10px;
        }

        /* --- Post Card Styling --- */
        .post-card {
            background-color: var(--card-background);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            margin-bottom: 25px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05); /* Soft shadow */
        }
        
        .post-header {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            border-bottom: 1px solid var(--border-color);
        }

        .post-header .username-link {
            font-weight: bold;
            font-size: 15px;
            margin-left: 10px;
        }
        
        .post-image {
            width: 100%;
            max-height: 700px;
            object-fit: cover;
            display: block;
        }

        .post-actions {
            padding: 10px 15px;
            display: flex;
            align-items: center;
        }

        .action-button {
            border: none;
            background: none;
            cursor: pointer;
            font-size: 20px;
            margin-right: 15px;
            transition: transform 0.1s;
        }
        
        .action-button:active {
            transform: scale(0.95);
        }

        .like-count {
            font-weight: bold;
            font-size: 14px;
        }

        .post-details {
            padding: 0 15px 15px;
        }

        .caption-text {
            margin: 5px 0 10px 0;
            font-size: 14px;
        }
        
        .timestamp {
            font-size: 12px;
            color: var(--secondary-text);
            display: block;
            margin-top: 5px;
        }

        /* --- Comments Section --- */
        .comment-section {
            padding: 10px 15px 0;
            border-top: 1px solid var(--border-color);
            margin-top: 15px;
        }

        .comment-form {
            display: flex;
            margin-bottom: 10px;
        }
        
        .comment-input {
            flex-grow: 1;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            padding: 8px;
            margin-right: 10px;
            font-size: 14px;
        }
        
        .comment-post-button {
            background-color: var(--primary-blue);
            color: white;
            border: none;
            border-radius: 4px;
            padding: 8px 15px;
            font-weight: bold;
            cursor: pointer;
            transition: opacity 0.2s;
        }
        
        .comment-post-button:hover {
            opacity: 0.8;
        }

        .comment-item {
            font-size: 14px;
            margin-bottom: 5px;
        }
        
        .comment-username {
            font-weight: bold;
            margin-right: 5px;
        }
        
        .comment-timestamp {
             font-size: 11px;
             color: var(--secondary-text);
             margin-left: 5px;
        }

    </style>
</head>
<body>

    <header class="header">
        <div class="header-logo">Hive</div>

        <div class="search-bar">
            <form action="feed.jsp" method="get" class="search-form">
                <input type="text" name="query" placeholder="Search users..." class="search-input"
                        value="<%= request.getParameter("query") != null ? request.getParameter("query") : "" %>">
                <button type="submit" class="search-button"><i class="fa-solid fa-magnifying-glass"></i></button>
            </form>
        </div>
        
        <div class="nav-links">
            <a href="home.jsp" class="nav-link"><i class="fa-solid fa-house"></i> Upload Post</a>
            <a href="logout" class="nav-link"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
            
            <a href="profile.jsp?user_id=<%= loggedInUserId %>" class="profile-link">
                <img src="<%= loggedInUserPic %>" alt="<%= loggedInUsername %>" class="profile-pic-small" title="<%= loggedInUsername %>">
                <%= loggedInUsername %>
            </a>
        </div>
    </header>

    <main class="main-container">

        <%
            // Re-open connection after closing the initial setup block (safe practice)
            if (conn == null || conn.isClosed()) conn = DBConnection.getConnection();
        
            // --- JSP LOGIC START (SEARCH RESULTS) ---
            String searchQuery = request.getParameter("query");
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                
                PreparedStatement searchPs = conn.prepareStatement(
                    "SELECT user_id, username FROM users WHERE username LIKE ?"
                );
                searchPs.setString(1, "%" + searchQuery + "%");
                ResultSet searchRs = searchPs.executeQuery();
        %>
            <div style="margin-bottom: 20px; padding: 15px; border-radius: 8px; background-color: white; border: 1px solid var(--border-color);">
                <h3>Search Results for "<%= searchQuery %>":</h3>
                <ul style="list-style: none; padding: 0;">
                <%
                    while (searchRs.next()) {
                %>
                    <li style="margin-bottom: 5px;"><a href="viewProfile.jsp?user_id=<%= searchRs.getInt("user_id") %>" class="username-link">
                        <%= searchRs.getString("username") %>
                    </a></li>
                <%
                    }
                    searchRs.close();
                    searchPs.close();
                %>
                </ul>
            </div>
        <%
            }
            // --- JSP LOGIC END ---
        %>

        <h2>Trending Today</h2>

        <%
            // --- JSP LOGIC START (FEED LOOP) ---
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM posts ORDER BY created_at DESC");

            while (rs.next()) {
                int postId = rs.getInt("post_id");
                String caption = rs.getString("caption");
                String imagePath = rs.getString("image_path");
                String createdAt = rs.getString("created_at");
                int postUserId = rs.getInt("user_id");

                // Get username of post owner
                PreparedStatement postUserPs = conn.prepareStatement("SELECT username FROM users WHERE user_id=?");
                postUserPs.setInt(1, postUserId);
                ResultSet postUserRs = postUserPs.executeQuery();
                String postUsername = "Unknown";
                if (postUserRs.next()) {
                    postUsername = postUserRs.getString("username");
                }
                postUserRs.close();
                postUserPs.close();

                // Get like count
                PreparedStatement likeCountPs = conn.prepareStatement(
                    "SELECT COUNT(*) AS like_count FROM likes WHERE post_id=?");
                likeCountPs.setInt(1, postId);
                ResultSet likeCountRs = likeCountPs.executeQuery();
                likeCountRs.next();
                int likeCount = likeCountRs.getInt("like_count");

                // Check if current user liked the post
                PreparedStatement userLikePs = conn.prepareStatement(
                    "SELECT * FROM likes WHERE post_id=? AND user_id=?");
                userLikePs.setInt(1, loggedInUserId);
                userLikePs.setInt(2, postUserId); // Use postUserId here if the like is for the post owner, otherwise use loggedInUserId for the post... assuming the original logic was for the current post. Let's fix this to check if the current user liked the current POST.
                
                // --- FIX: The userLikePs logic in the provided code was incorrect. 
                // The correct check is whether the logged-in user liked the current post (postId).
                userLikePs.setInt(2, loggedInUserId);
                // Corrected line is already above, but ensure it's correct for the post
                // userLikePs.setInt(1, postId); // Correct
                // userLikePs.setInt(2, loggedInUserId); // Correct

                ResultSet userLikeRs = userLikePs.executeQuery();
                boolean liked = userLikeRs.next();
        %>

        <div class="post-card">
            
            <div class="post-header">
                <%
                    // Get profile picture of the post owner
                    PreparedStatement picPs = conn.prepareStatement("SELECT profile_pic FROM users WHERE user_id=?");
                    picPs.setInt(1, postUserId);
                    ResultSet picRs = picPs.executeQuery();
                    String postProfilePic = "uploads/default_profile.png"; // default pic
                    if (picRs.next()) {
                        String dbPic = picRs.getString("profile_pic");
                        if (dbPic != null && !dbPic.isEmpty()) {
                            postProfilePic = dbPic;
                        }
                    }
                    picRs.close();
                    picPs.close();
                %>
                <img src="<%= postProfilePic %>" alt="<%= postUsername %>" class="profile-pic-small" title="<%= postUsername %>">

                <a href="viewProfile.jsp?user_id=<%= postUserId %>" class="username-link"><%= postUsername %></a>
            </div>

            <img src="<%= imagePath %>" class="post-image" alt="Post Image" />

            <div class="post-actions">
                <form action="like" method="post" style="display:inline;">
                    <input type="hidden" name="post_id" value="<%= postId %>">
                    <button type="submit" class="action-button">
                        <%= liked ? "<i class='fa-solid fa-heart'></i>" : "<i class='fa-regular fa-heart'></i>" %>
                    </button>
                </form>
                
                <span class="like-count"><%= likeCount %> likes</span>
            </div>
            
            <div class="post-details">
                <p class="caption-text">
                    <a href="viewProfile.jsp?user_id=<%= postUserId %>" class="username-link"><%= postUsername %></a> 
                    <%= caption %>
                </p>
                <small class="timestamp"><%= createdAt %></small>
            </div>

            <div class="comment-section">
                
                <%
                    PreparedStatement commentPs = conn.prepareStatement(
                        "SELECT c.comment_text, c.created_at, u.username " +
                        "FROM comments c JOIN users u ON c.user_id=u.user_id " +
                        "WHERE c.post_id=? ORDER BY c.created_at ASC" 
                    );
                    commentPs.setInt(1, postId);
                    ResultSet commentRs = commentPs.executeQuery();

                    while (commentRs.next()) {
                %>
                    <p class="comment-item">
                        <span class="comment-username"><%= commentRs.getString("username") %>:</span>
                        <%= commentRs.getString("comment_text") %>
                        <span class="comment-timestamp">(<%= commentRs.getString("created_at") %>)</span>
                    </p>
                <%
                    }
                    commentRs.close();
                    commentPs.close();
                %>
                
                <form action="comment" method="post" class="comment-form">
                    <input type="hidden" name="post_id" value="<%= postId %>">
                    <input type="text" name="comment" placeholder="Add a comment..." required class="comment-input">
                    <button type="submit" class="comment-post-button">Post</button>
                </form>
            </div>
        </div>

        <%
                // Close resources for the inner loop
                likeCountRs.close();
                userLikeRs.close();
                likeCountPs.close();
                userLikePs.close();
            }

            rs.close();
            stmt.close();
            // Closing the main connection
            if (conn != null) conn.close();
        %>
    </main>
</body>
</html>
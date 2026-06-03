<%@page import="com.mycompany.minigram.dao.DBConnection"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.*" %>
<%@ page session="true" %>

<%
    Integer user_id = (Integer) session.getAttribute("user_id");
    // Session check and username retrieval remains the same
    String username = (String) session.getAttribute("username");
    // Using a placeholder name from the image if session is null for display purposes
    String displayUsername = (username != null) ? username : "Ritikakri"; 

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String profilePic = "uploads/default.png"; // default
    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement("SELECT profile_pic FROM users WHERE user_id=?");
        ps.setInt(1, user_id);
        ResultSet rs = ps.executeQuery();
        if (rs.next() && rs.getString("profile_pic") != null && !rs.getString("profile_pic").isEmpty()) {
            profilePic = rs.getString("profile_pic");
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hive - Create Post</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Pacifico&display=swap" rel="stylesheet">
    <style>
        :root {
            /* Standardized Colors for consistency */
            --primary-blue: #0095f6;
            --secondary-text: #8e8e8e;
            --border-color: #dbdbdb;
            --background-color: #fafafa;
            --card-background: #ffffff;

            /* Custom Gradient Colors (kept from original image prototype) */
            --gradient-start: #cc2366; 
            --gradient-mid: #e6683c; 
            --gradient-end: #f09433; 
            --black-btn: #363636;
        }

        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--background-color);
        }

        .main-wrapper {
            display: flex;
            max-width: 1200px;
            margin: 40px auto; /* Increased margin for better spacing */
            padding: 0 20px;
        }

        /* --- Left Panel (Sidebar) --- */
        .left-panel {
            flex: 0 0 250px; /* Fixed width */
            padding: 20px;
            text-align: center;
            /* Added sticky positioning for better UX */
            position: sticky; 
            top: 20px;
            height: fit-content;
        }

        .profile-info {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 10px 0;
            margin-bottom: 20px;
            text-decoration: none;
        }
        
        /* The Hive logo at the top of the sidebar */
        .hive-logo {
            font-family: 'Pacifico', cursive; 
            font-size: 28px;
            margin-bottom: 30px;
            color: #333;
        }

        .profile-pic {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
            padding: 3px; 
            border: 3px solid transparent; 
            background: linear-gradient(white, white) padding-box, 
                        linear-gradient(to right, var(--gradient-start), var(--gradient-end)) border-box;
        }

        .username-text {
            margin-top: 10px;
            font-size: 16px;
            font-weight: 600;
            color: #333;
        }
        
        /* Navigation Buttons */
        .nav-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            padding: 12px;
            margin-bottom: 15px;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            font-size: 16px;
            transition: opacity 0.3s;
        }

        .nav-btn i {
            margin-right: 10px;
        }
        
        .gradient-btn {
            color: #fff;
            text-decoration: none;
            background: linear-gradient(to right, #a262e3, var(--gradient-start), var(--gradient-mid)); 
        }

        .black-btn {
            color: #fff;
            background-color: var(--black-btn);
            text-decoration: none;
        }

        /* --- Right Content Area --- */
        .right-content {
            flex: 1;
            padding-left: 50px;
        }

        /* Search Bar & Ribbon */
        .search-bar-container {
            display: flex;
            align-items: center;
            margin-bottom: 30px;
            background-color: var(--card-background);
            border-radius: 10px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            padding: 10px;
        }
        
        .view-feed-ribbon {
            display: flex;
            align-items: center;
            font-size: 16px;
            font-weight: bold;
            color: #fff;
            padding: 10px 20px;
            clip-path: polygon(0 0, 100% 0, 100% 75%, 90% 100%, 0 100%);
            background: linear-gradient(to right, var(--gradient-end), var(--gradient-start));
            margin-right: 20px;
            text-decoration: none;
            min-width: 120px;
        }
        
        .view-feed-ribbon i {
            margin-right: 8px;
        }

        .search-input-container {
            display: flex;
            align-items: center;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            background-color: var(--background-color);
            flex-grow: 1;
            padding: 0 10px;
        }

        .search-input {
            border: none;
            flex-grow: 1;
            padding: 10px 5px;
            font-size: 14px;
            background: transparent;
            outline: none;
        }
        
        .search-btn {
            background-color: var(--black-btn);
            color: #fff;
            padding: 10px 20px;
            border-radius: 8px;
            margin-left: 10px;
            cursor: pointer;
            transition: opacity 0.3s;
            border: none;
        }

        /* Create Post Card */
        .post-card {
            background-color: var(--card-background);
            border-radius: 15px;
            /* Updated shadow for a cleaner, modern look */
            box-shadow: 0 4px 15px rgba(0,0,0,0.08); 
            padding: 30px;
        }

        .post-card h3 {
            font-size: 22px;
            font-weight: 700;
            margin-top: 0;
            color: #333;
        }

        .caption-textarea {
            width: 100%;
            padding: 15px;
            border: 1px solid var(--border-color); /* Cleaner border color */
            border-radius: 12px;
            resize: none;
            box-sizing: border-box;
            margin-top: 5px;
            font-size: 15px;
        }

        /* Custom File Upload Styling */
        .file-upload-wrapper {
            margin-top: 15px;
            border: 1px solid var(--border-color); /* Cleaner border color */
            border-radius: 12px;
            padding: 15px;
            display: flex;
            align-items: center;
            background-color: var(--background-color);
        }

        .file-upload-wrapper label {
            background-color: var(--card-background);
            border: 1px solid #333;
            padding: 8px 15px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: normal;
            margin-right: 15px;
        }

        .file-upload-wrapper input[type="file"] {
            display: none;
        }

        .file-name-display {
            color: var(--secondary-text);
            font-style: italic;
        }
        
        .share-now-btn {
            margin-top: 30px;
        }
    </style>
    <script>
        // Simple JS for file name display, as seen in the image prototype
        document.addEventListener('DOMContentLoaded', function() {
            const fileInput = document.getElementById('image-upload');
            const fileNameDisplay = document.getElementById('file-name');

            fileInput.addEventListener('change', function() {
                if (fileInput.files.length > 0) {
                    fileNameDisplay.textContent = fileInput.files[0].name;
                } else {
                    fileNameDisplay.textContent = 'No Chosen file';
                }
            });
        });
    </script>
</head>
<body>

<div class="main-wrapper">
    <div class="left-panel">
        <div class="hive-logo">Hive</div>
        
        <a href="profile.jsp" class="profile-info">
           <img class="profile-pic" src="<%= profilePic %>" alt="User Profile Picture">
<span class="username-text"><%= username %></span>

        </a>

        <a href="profile.jsp" class="nav-btn gradient-btn"><i class="fa-solid fa-user"></i> My Profile</a>
        <a href="logout" class="nav-btn black-btn"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>

    </div>

    <div class="right-content">

        <div class="search-bar-container">
    <a href="feed.jsp" class="view-feed-ribbon"><i class="fa-solid fa-list-ul"></i> View Feed</a>
    
    <form id="searchForm" action="searchResults.jsp" method="get" class="search-input-container">
        <input type="text" name="query" class="search-input" placeholder="Search for Users" required>
        <button type="submit" class="search-btn"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
    </form>
</div>

        <div class="post-card">
            <h3>Create a Post</h3>
            
            <form action="upload" method="post" enctype="multipart/form-data" class="post-form">
                
                <label for="caption" style="font-weight: 600; display: block;">Caption</label>
                <textarea id="caption" name="caption" class="caption-textarea" rows="4" placeholder="Share Your Thoughts........" required></textarea>

                <label style="font-weight: 600; display: block; margin-top: 20px;">Choose image</label>
                <div class="file-upload-wrapper">
                    <label for="image-upload">Choose a file</label>
                    <input type="file" name="image" id="image-upload" accept="image/*" required>
                    <span id="file-name" class="file-name-display">No Chosen file</span>
                </div>

                <button type="submit" class="nav-btn gradient-btn share-now-btn">Share Now</button>
            </form>
        </div>
    </div>
</div>

</body>
</html>
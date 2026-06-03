<%@ page session="true" %>
<%@ page import="java.sql.*, com.mycompany.minigram.dao.DBConnection" %>

<%
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String searchQuery = request.getParameter("query");
    if (searchQuery == null || searchQuery.trim().isEmpty()) {
        out.println("Please enter a search term.");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Search Results for "<%= searchQuery %>"</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        :root {
            --primary-color: #0095f6;
            --card-bg: #fff;
            --bg-color: #f9f9f9;
            --text-color: #333;
            --secondary-text: #8e8e8e;
            --border-color: #e0e0e0;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            margin: 0;
            padding: 20px;
        }

        h2 {
            text-align: center;
            color: var(--text-color);
            margin-bottom: 30px;
        }

        .results-container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 20px;
        }

        .user-card {
            background-color: var(--card-bg);
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            padding: 20px;
            width: 220px;
            text-align: center;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .user-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.15);
        }

        .user-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            margin-bottom: 15px;
            object-fit: cover;
            border: 2px solid var(--primary-color);
        }

        .username {
            font-weight: 600;
            color: var(--text-color);
            margin-bottom: 10px;
        }

        .view-profile-btn {
            display: inline-block;
            padding: 8px 15px;
            background-color: var(--primary-color);
            color: white;
            border-radius: 8px;
            text-decoration: none;
            font-size: 14px;
            transition: background-color 0.2s;
        }

        .view-profile-btn:hover {
            background-color: #0073c9;
        }

        .no-results {
            text-align: center;
            color: var(--secondary-text);
            font-size: 18px;
            margin-top: 40px;
        }
    </style>
</head>
<body>

<h2>Search Results for "<%= searchQuery %>"</h2>

<div class="results-container">
<%
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT user_id, username, profile_pic FROM users WHERE username LIKE ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, "%" + searchQuery + "%");
        rs = ps.executeQuery();

        boolean found = false;
        while (rs.next()) {
            found = true;
            int id = rs.getInt("user_id");
            String username = rs.getString("username");
            String profilePic = rs.getString("profile_pic");
            if (profilePic == null || profilePic.isEmpty()) {
                profilePic = "uploads/default.png"; // default avatar
            }
%>
    <div class="user-card">
        <img src="<%= profilePic %>" alt="Avatar" class="user-avatar">
        <div class="username"><%= username %></div>
        <a href="profile.jsp?user_id=<%= id %>" class="view-profile-btn">View Profile</a>
    </div>
<%
        }

        if (!found) {
%>
    <div class="no-results">No users found matching "<%= searchQuery %>"</div>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div class='no-results'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (ps != null) try { ps.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>
</div>

</body>
</html>

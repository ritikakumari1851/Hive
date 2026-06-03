<%@ page session="true" %>
<%
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Search Users</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        :root {
            --border-color: #dbdbdb;
            --secondary-text: #8e8e8e;
            --background-color: #fafafa;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--background-color);
            padding: 20px;
        }

        /* The container for the entire search bar */
        .search-container {
            max-width: 400px;
            margin: 20px auto;
            text-align: center;
        }

        h2 {
            color: #333;
            margin-bottom: 25px;
        }

        /* The visual element that holds the icon and input */
        .search-box {
            display: flex;
            align-items: center;
            background-color: white;
            border: 1px solid var(--border-color);
            border-radius: 20px; /* Highly rounded corners */
            padding: 8px 15px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05); /* Soft, subtle shadow */
            width: 100%;
            box-sizing: border-box;
        }

        /* The magnifying glass icon */
        .search-icon {
            color: var(--secondary-text);
            font-size: 16px;
            margin-right: 10px;
        }

        /* The actual input field */
        .search-input {
            border: none;
            flex-grow: 1; /* Allows input to take up all available space */
            padding: 0;
            font-size: 16px;
            outline: none; /* Removes the default focus border */
            background: transparent;
        }

        /* We hide the default search button for this design */
        .search-button-hidden {
            display: none;
        }
    </style>
</head>
<body>

<div class="search-container">
    <h2>Search Users</h2>
    <form action="searchResults.jsp" method="get">
        <div class="search-box">
            <i class="fa-solid fa-magnifying-glass search-icon"></i>
            
            <input 
                type="text" 
                name="query" 
                placeholder="Search for a username..." 
                required 
                class="search-input"
            >
            
            <button type="submit" class="search-button-hidden">Search</button>
        </div>
    </form>
</div>

</body>
</html>
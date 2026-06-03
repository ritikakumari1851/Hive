<%
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register - Hive</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background-color: #ffffff;
        }
        h2 {
            font-family: 'Pacifico', cursive;
            font-size: 36px;
        }
        .container {
            display: flex;
            max-height: 90vh;
           
           
        }
    .left {
    flex: 1;
    display: flex;
    justify-content: center;  /* center horizontally */
    align-items: center;      /* center vertically */
    margin: 0;                /* remove extra margins */
    height: 100vh;            /* make the div full height */
}

.round-image {
    width: 300px;        
    height: 300px;       
    border-radius: 50%;  
    object-fit: cover;   
    border: 2px solid #fff; 
}


        .right {
            flex: 1.2;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            padding-top: 60px;
        }
        .register-box {
            width: 380px;
            padding: 20px;
            text-align: center;
            margin-right: 90px;
            box-shadow: 0 0 15px rgba(0,0,0,0.05);
            border-radius: 10px;
            background-color: #fff;
        }
        .register-box h2 {
            margin-bottom: 20px;
            font-weight: normal;
            color: #333;
        }
        .register-box input[type="text"],
        .register-box input[type="email"],
        .register-box input[type="password"] {
            width: 80%;
            padding: 12px;
            margin: 10px 0;
            border: 1px solid #dbdbdb;
            border-radius: 6px;
            background-color: #fafafa;
            font-size: 14px;
        }
        .register-box button {
            width: 90%;
            padding: 12px;
            margin-top: 15px;
            border: none;
            border-radius: 6px;
            color: #fff;
            font-weight: bold;
            cursor: pointer;
            font-size: 16px;
            background: linear-gradient(to right, #f09433, #e6683c, #dc2743, #cc2366, #bc1888);
            transition: opacity 0.3s;
        }
        .register-box button:hover {
            opacity: 0.9;
        }
        .register-box p {
            margin-top: 15px;
            font-size: 14px;
        }
        .register-box p a {
            color: #0095f6;
            text-decoration: none;
        }
        .error-message {
            color: red;
            font-weight: bold;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>

<div class="container">
   <div class="left">
    <img src="<%= request.getContextPath() %>/uploads/imgs/80.jpg" alt="Hive Image" class="round-image">
</div>

    <div class="right">
        <div class="register-box">
            <h2><b><i>Register Now</i></b></h2>

            <% if ("1".equals(error)) { %>
                <p class="error-message">Error: Could not register. Please try again.</p>
            <% } else if ("2".equals(error)) { %>
                <p class="error-message">Error: Username or Email may already exist.</p>
            <% } %>

            <form action="register" method="post">
                <input type="text" name="username" placeholder="Username" required>
                <input type="email" name="email" placeholder="Email" required>
                <input type="password" name="password" placeholder="Password" required>
                
    <input type="password" name="confirm_password" placeholder="Confirm Password" required>
    <button type="submit">Sign Up</button>

            
            </form>

            <p>Already have an account? <a href="login.jsp"><b>Login here</b></a></p>
        </div>
    </div>
</div>

</body>
</html>

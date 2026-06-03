<%
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title class = "t1" >HIVE</title>
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
            min-height: 100vh;
        }
       .left {
    flex: 1;
    background-color: #ffffff; /* just to check if the left div is visible */
    background-image: url('<%= request.getContextPath() %>/uploads/imgs/2.png');
    background-size: contain;   /* makes the whole image visible without cropping */
    background-repeat: no-repeat; /* prevents repetition */
    
    background-position: center;  /* centers the image */
    margin-left : 100px;
}


        .right {
            flex: 1.2;
            display: flex;
            
            align-items: center;
            
        }
        .login-box {
            width: 300px;
            padding: 20px;
            text-align: center;
            
            margin-left: 80px;
        }
        .login-box h2 {
           
            font-weight: normal;
            color: #333;
        }
        .login-box input[type="email"],
        .login-box input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 8px 0px;
            border: 1px solid #dbdbdb;
            border-radius: 4px;
            background-color: #fafafa;
        }
        .login-box button {
            width: 108%;
            padding: 10px;
            
            margin-top: 12px;
            border: none;
            border-radius: 4px;
            color: #fff;
            font-weight: bold;
            cursor: pointer;
            background: linear-gradient(to right, #f09433, #e6683c, #dc2743, #cc2366, #bc1888);
            transition: opacity 0.3s;
        }
        .login-box button:hover {
            opacity: 0.9;
        }
        .login-box p {
            margin-top: 15px;
            font-size: 14px;
        }
        .login-box p a {
            color: #0095f6;
            text-decoration: none;
        }
        .message {
            color: green;
            font-weight: bold;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="left"></div>
    <div class="right">
        <div class="login-box">
            <h2><b><i>Hive</i></b></h2>

            <% if ("logout_success".equals(msg)) { %>
                <p class="message">You have been logged out successfully.</p>
            <% } %>

            <form action="login" method="post">
                <input type="email" name="email" placeholder="Email" required>
                <input type="password" name="password" placeholder="Password" required>
                <button type="submit">Login</button>
            </form>

            <p>Don?t have an account? <a href="register.jsp"><b>sign up</b></a></p>
        </div>
    </div>
</div>

</body>
</html>

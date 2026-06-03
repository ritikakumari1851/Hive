package com.mycompany.minigram.servlet;

import com.mycompany.minigram.dao.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Default profile picture path
        String defaultProfilePic = "uploads/default_profile.png";

        try (Connection conn = DBConnection.getConnection()) {

            // Insert user with default profile picture
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO users(username, email, password, profile_pic) VALUES (?, ?, ?, ?)"
            );
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, password); // TODO: hash password for security
            ps.setString(4, defaultProfilePic);

            ps.executeUpdate();

            // Redirect to login page after successful registration
            response.sendRedirect("login.jsp");

        } catch (SQLException e) {
            // Handle duplicate entry
            if (e.getErrorCode() == 1062) { // MySQL duplicate error
                response.sendRedirect("register.jsp?error=2");
            } else {
                e.printStackTrace();
                response.sendRedirect("register.jsp?error=1");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=1");
        }
    }
}

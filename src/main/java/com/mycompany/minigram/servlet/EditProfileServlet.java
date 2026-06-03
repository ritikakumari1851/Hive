package com.mycompany.minigram.servlet;

import com.mycompany.minigram.dao.DBConnection;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.*;

@WebServlet("/editProfile")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 15    // 15MB
)
public class EditProfileServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        String newUsername = request.getParameter("username");
        String newEmail = request.getParameter("email");

        try (Connection conn = DBConnection.getConnection()) {

            Part profilePicPart = request.getPart("profile_pic");
            String sql;
            PreparedStatement ps;

            if (profilePicPart != null && profilePicPart.getSize() > 0) {
                // Save file
                String fileName = System.currentTimeMillis() + "_" +
                        Paths.get(profilePicPart.getSubmittedFileName()).getFileName().toString();
                
                String uploadDir = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadFolder = new File(uploadDir);
                if (!uploadFolder.exists()) uploadFolder.mkdirs();

                String filePath = uploadDir + File.separator + fileName;
                profilePicPart.write(filePath);

                // Update DB including profile_pic
                sql = "UPDATE users SET username=?, email=?, profile_pic=? WHERE user_id=?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, newUsername);
                ps.setString(2, newEmail);
                ps.setString(3, "uploads/" + fileName); // Save relative path
                ps.setInt(4, userId);

            } else {
                // Update only username and email
                sql = "UPDATE users SET username=?, email=? WHERE user_id=?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, newUsername);
                ps.setString(2, newEmail);
                ps.setInt(3, userId);
            }

            ps.executeUpdate();
            ps.close();

            // Update session info
            session.setAttribute("username", newUsername);

            response.sendRedirect("profile.jsp?msg=updated");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?msg=error");
        }
    }
}

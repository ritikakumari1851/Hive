package com.mycompany.minigram.servlet;

import com.mycompany.minigram.dao.DBConnection;
import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

@WebServlet("/upload")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class UploadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        String caption = request.getParameter("caption");
        Part imagePart = request.getPart("image");

        // Directory to save uploaded images
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        // Save file
        String fileName = System.currentTimeMillis() + "_" + imagePart.getSubmittedFileName();
        String filePath = uploadPath + File.separator + fileName;
        imagePart.write(filePath);

        // Save image info in DB
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO posts (user_id, caption, image_path) VALUES (?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, caption);
            ps.setString(3, "uploads/" + fileName);
            ps.executeUpdate();
            response.sendRedirect("feed.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Upload failed: " + e.getMessage());
        }
    }
}

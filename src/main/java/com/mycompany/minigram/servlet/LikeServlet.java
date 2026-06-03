package com.mycompany.minigram.servlet;

import com.mycompany.minigram.dao.DBConnection;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/like")
public class LikeServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int postId = Integer.parseInt(request.getParameter("post_id"));
        int userId = (int) session.getAttribute("user_id");

        try (Connection conn = DBConnection.getConnection()) {
            // ✅ Check if already liked
            String checkSql = "SELECT * FROM likes WHERE post_id=? AND user_id=?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, postId);
            checkPs.setInt(2, userId);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                // ✅ Unlike (remove record)
                String deleteSql = "DELETE FROM likes WHERE post_id=? AND user_id=?";
                PreparedStatement deletePs = conn.prepareStatement(deleteSql);
                deletePs.setInt(1, postId);
                deletePs.setInt(2, userId);
                deletePs.executeUpdate();
            } else {
                // ✅ Add like
                String insertSql = "INSERT INTO likes (post_id, user_id) VALUES (?, ?)";
                PreparedStatement insertPs = conn.prepareStatement(insertSql);
                insertPs.setInt(1, postId);
                insertPs.setInt(2, userId);
                insertPs.executeUpdate();
            }

            // ✅ Redirect back to feed
            response.sendRedirect("feed.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

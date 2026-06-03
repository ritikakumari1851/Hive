package com.mycompany.minigram.servlet;

import com.mycompany.minigram.dao.DBConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/comment")
public class CommentServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = (int) request.getSession().getAttribute("user_id");
        int postId = Integer.parseInt(request.getParameter("post_id"));
        String commentText = request.getParameter("comment");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO comments (post_id, user_id, comment_text) VALUES (?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            ps.setString(3, commentText);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("feed.jsp");
    }
}

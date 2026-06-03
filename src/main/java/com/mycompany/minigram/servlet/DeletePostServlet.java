package com.mycompany.minigram.servlet;

import com.mycompany.minigram.dao.DBConnection;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/deletePost")
public class DeletePostServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int postId = Integer.parseInt(request.getParameter("post_id"));
        int userId = (int) session.getAttribute("user_id");

        try (Connection conn = DBConnection.getConnection()) {
            // Delete post only if it belongs to current user
            String sql = "DELETE FROM posts WHERE post_id=? AND user_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            int rows = ps.executeUpdate();

            if (rows > 0) {
                response.sendRedirect("profile.jsp?msg=deleted");
            } else {
                response.sendRedirect("profile.jsp?msg=notallowed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?msg=error");
        }
    }
}

package com.mycompany.minigram.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.mycompany.minigram.dao.DBConnection;

@WebServlet("/followUnfollow")
public class FollowUnfollowServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        Integer loggedInUserId = (Integer) request.getSession().getAttribute("user_id");
        if (loggedInUserId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int followingId = Integer.parseInt(request.getParameter("following_id"));

        try (Connection conn = DBConnection.getConnection()) {

            // Check if already following
            PreparedStatement checkPs = conn.prepareStatement(
                "SELECT * FROM follows WHERE follower_id=? AND following_id=?"
            );
            checkPs.setInt(1, loggedInUserId);
            checkPs.setInt(2, followingId);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                // Unfollow
                PreparedStatement deletePs = conn.prepareStatement(
                    "DELETE FROM follows WHERE follower_id=? AND following_id=?"
                );
                deletePs.setInt(1, loggedInUserId);
                deletePs.setInt(2, followingId);
                deletePs.executeUpdate();
                deletePs.close();
            } else {
                // Follow
                PreparedStatement insertPs = conn.prepareStatement(
                    "INSERT INTO follows (follower_id, following_id) VALUES (?, ?)"
                );
                insertPs.setInt(1, loggedInUserId);
                insertPs.setInt(2, followingId);
                insertPs.executeUpdate();
                insertPs.close();
            }

            rs.close();
            checkPs.close();
        } catch (Exception e) {
            throw new ServletException(e);
        }

        response.sendRedirect("viewProfile.jsp?user_id=" + followingId);
    }
}

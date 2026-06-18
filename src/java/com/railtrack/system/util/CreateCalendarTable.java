package com.railtrack.system.util;

import java.sql.Connection;
import java.sql.Statement;

public class CreateCalendarTable {
    public static void main(String[] args) {
        String sql = "CREATE TABLE IF NOT EXISTS `calendar_events` (\n" +
                     "  `id` int(11) NOT NULL AUTO_INCREMENT,\n" +
                     "  `title` varchar(200) NOT NULL,\n" +
                     "  `description` text DEFAULT NULL,\n" +
                     "  `start_date` date NOT NULL,\n" +
                     "  `end_date` date DEFAULT NULL,\n" +
                     "  `color` varchar(20) DEFAULT '#2563eb',\n" +
                     "  `created_by_id` int(11) NOT NULL,\n" +
                     "  `created_at` datetime NOT NULL DEFAULT current_timestamp(),\n" +
                     "  PRIMARY KEY (`id`),\n" +
                     "  FOREIGN KEY (`created_by_id`) REFERENCES `users` (`id`) ON DELETE CASCADE\n" +
                     ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;";
        try (Connection conn = DBConnection.get();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
            System.out.println("calendar_events table created successfully.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

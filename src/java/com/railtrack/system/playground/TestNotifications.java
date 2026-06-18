package com.railtrack.system.playground;

import com.railtrack.system.service.EmailService;
import com.railtrack.system.util.DBConnection;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class TestNotifications {

    public static void main(String[] args) {
        System.out.println("=========================================================================================================================");
        System.out.println("                                      RailTrack Email Notification Tester                                                ");
        System.out.println("=========================================================================================================================");

        // Run database migration to ensure all current supervisor assignments also become PITA 1 & PITA 2 Evaluation assignments
        runPitaMigration();

        // Display current user records from the DB to help the tester choose targets
        System.out.println("Registered Users and Email Preference Status:");
        try (Connection conn = DBConnection.get();
             PreparedStatement ps = conn.prepareStatement("SELECT id, username, email, phone, role, email_notif_enabled FROM users");
             ResultSet rs = ps.executeQuery()) {
            
            System.out.printf("%-4s | %-12s | %-25s | %-15s | %-12s | %-8s\n",
                    "ID", "Username", "Email", "Phone", "Role", "Email Ok");
            System.out.println("-------------------------------------------------------------------------------------------------------------------------");
            int count = 0;
            while (rs.next()) {
                System.out.printf("%-4d | %-12s | %-25s | %-15s | %-12s | %-8b\n",
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("role"),
                        rs.getBoolean("email_notif_enabled"));
                count++;
            }
            if (count == 0) {
                System.out.println("(No users found in database)");
            }
        } catch (Exception e) {
            System.out.println("⚠️ Database fetch skipped or failed: " + e.getMessage());
        }
        System.out.println("=========================================================================================================================\n");

        String emailInput = "";
        if (args.length >= 1) {
            emailInput = args[0].trim();
        }

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(System.in))) {
            if (args.length == 0) {
                System.out.print("Enter recipient email address (or press Enter/type 'skip' to skip email test): ");
                emailInput = reader.readLine().trim();
            }

            if (!emailInput.isEmpty() && !"skip".equalsIgnoreCase(emailInput)) {
                System.out.println("\n--- Triggering Email Send to " + emailInput + " ---");
                try {
                    EmailService.sendEmail(
                        emailInput,
                        "RailTrack System Test Notification",
                        "Hello! This is a test email sent from the RailTrack Playground system.\n" +
                        "If you receive this, the SMTP custom SSLSocket implementation is functioning correctly!"
                    );
                    System.out.println("🎉 Email sent successfully!");
                } catch (Exception e) {
                    System.err.println("❌ Email transmission failed:");
                    e.printStackTrace();
                }
            } else {
                System.out.println("Skipped Email Test.");
            }

        } catch (Exception e) {
            System.err.println("An unexpected error occurred during test execution:");
            e.printStackTrace();
        }

        System.out.println("\n==================================================");
        System.out.println("               Test Session Ended                 ");
        System.out.println("==================================================");
    }

    private static void runPitaMigration() {
        System.out.println("🔍 Running database migrations...");
        
        // Ensure milestones table has pita_stage column
        try (Connection conn = DBConnection.get()) {
            boolean hasPitaStage = false;
            try (ResultSet rs = conn.getMetaData().getColumns(null, null, "milestones", "pita_stage")) {
                if (rs.next()) {
                    hasPitaStage = true;
                }
            }
            if (!hasPitaStage) {
                try (ResultSet rs = conn.getMetaData().getColumns(null, null, "MILESTONES", "PITA_STAGE")) {
                    if (rs.next()) {
                        hasPitaStage = true;
                    }
                }
            }
            if (!hasPitaStage) {
                System.out.println("Adding column 'pita_stage' to 'milestones' table...");
                try (PreparedStatement ps = conn.prepareStatement("ALTER TABLE milestones ADD COLUMN pita_stage VARCHAR(10) DEFAULT NULL")) {
                    ps.executeUpdate();
                    System.out.println("Column 'pita_stage' added successfully.");
                }
            }
        } catch (Exception e) {
            System.err.println("⚠️ Column 'pita_stage' migration check failed or skipped: " + e.getMessage());
        }

        System.out.println("🔍 Scanning supervisor assignments to synchronize PITA 1 & PITA 2 assignments...");
        try (Connection conn = DBConnection.get()) {
            String sql = "SELECT id, supervisor_id FROM projects WHERE supervisor_id IS NOT NULL AND supervisor_id > 0";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                int migratedCount = 0;
                while (rs.next()) {
                    int projectId = rs.getInt("id");
                    int supervisorId = rs.getInt("supervisor_id");
                    
                    if (insertEvaluatorIfAbsent(conn, projectId, supervisorId, "PITA1")) {
                        migratedCount++;
                    }
                    if (insertEvaluatorIfAbsent(conn, projectId, supervisorId, "PITA2")) {
                        migratedCount++;
                    }
                }
                System.out.println("✅ PITA assignment synchronization completed. Created " + migratedCount + " PITA evaluator records.");
            }
        } catch (Exception e) {
            System.err.println("⚠️ PITA database migration failed or skipped: " + e.getMessage());
        }
        System.out.println("-------------------------------------------------------------------------------------------------------------------------");
    }

    private static boolean insertEvaluatorIfAbsent(Connection conn, int projectId, int evaluatorId, String stage) throws SQLException {
        String checkSql = "SELECT COUNT(*) FROM project_evaluators WHERE project_id = ? AND evaluator_id = ? AND stage = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, projectId);
            ps.setInt(2, evaluatorId);
            ps.setString(3, stage);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return false;
                }
            }
        }

        String insertSql = "INSERT INTO project_evaluators (project_id, evaluator_id, stage) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setInt(1, projectId);
            ps.setInt(2, evaluatorId);
            ps.setString(3, stage);
            ps.executeUpdate();
            return true;
        }
    }
}
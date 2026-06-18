/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.playground;
import com.railtrack.system.service.EmailService;
/**
 *
 * @author izzatahmad
 */
public class TestEmail {

    public static void main(String[] args) {

        String recipient = "timekeeper.semicolon@gmail.com";

        try {
            System.out.println("==================================================");
            System.out.println("        RailTrack Email Service Test");
            System.out.println("==================================================");

            EmailService.sendEmail(
                    recipient,
                    "🚆 RailTrack Test Email",
                    "Hello,\n\n"
                    + "This is a test email from the RailTrack notification system.\n\n"
                    + "If you received this message, the email service is functioning correctly.\n\n"
                    + "Regards,\n"
                    + "RailTrack System"
            );

            System.out.println("✅ Test completed successfully.");

        } catch (Exception e) {
            System.err.println("❌ Email test failed:");
            e.printStackTrace();
        }
    }
}


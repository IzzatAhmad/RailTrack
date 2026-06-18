package com.railtrack.system.service;

import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class EmailService {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 465;

    private static final String SENDER_EMAIL =
            System.getenv().getOrDefault(
                    "GMAIL_USER",
                    "railtrack.noreply@gmail.com"
            );

    private static final String SENDER_PASSWORD =
            System.getenv().getOrDefault(
                    "GMAIL_PASSWORD",
                    "mywe tjnr wfkz toly"
            );

    public static void sendEmailAsync(
            final String to,
            final String subject,
            final String body) {

        new Thread(() -> {
            try {
                sendEmail(to, subject, body);
            } catch (Exception e) {
                System.err.println("❌ Failed to send email:");
                e.printStackTrace();
            }
        }).start();
    }

    public static void sendEmail(
            String to,
            String subject,
            String body) throws Exception {

        if (SENDER_EMAIL == null || SENDER_EMAIL.isEmpty()) {
            throw new RuntimeException(
                    "GMAIL_USER environment variable is not configured."
            );
        }

        if (SENDER_PASSWORD == null || SENDER_PASSWORD.isEmpty()) {
            throw new RuntimeException(
                    "GMAIL_PASSWORD environment variable is not configured."
            );
        }

        System.out.println("Connecting to Gmail SMTP server...");

        SSLSocketFactory factory =
                (SSLSocketFactory) SSLSocketFactory.getDefault();

        try (SSLSocket socket =
                     (SSLSocket) factory.createSocket(
                             SMTP_HOST,
                             SMTP_PORT
                     );
             BufferedReader reader =
                     new BufferedReader(
                             new InputStreamReader(
                                     socket.getInputStream(),
                                     StandardCharsets.UTF_8
                             )
                     );
             OutputStream os = socket.getOutputStream()) {

            socket.setSoTimeout(10000);

            readResponse(reader, "220");

            sendCmd(os, reader, "EHLO localhost", "250");

            byte[] authBytes =
                    ("\0" + SENDER_EMAIL + "\0" + SENDER_PASSWORD)
                            .getBytes(StandardCharsets.UTF_8);

            String authBase64 =
                    Base64.getEncoder().encodeToString(authBytes);

            sendCmd(
                    os,
                    reader,
                    "AUTH PLAIN " + authBase64,
                    "235"
            );

            sendCmd(
                    os,
                    reader,
                    "MAIL FROM:<" + SENDER_EMAIL + ">",
                    "250"
            );

            try {
                sendCmd(
                        os,
                        reader,
                        "RCPT TO:<" + to + ">",
                        "250"
                );
            } catch (Exception ex) {
                throw new RuntimeException(
                        "Recipient email address rejected: " + to,
                        ex
                );
            }

            sendCmd(os, reader, "DATA", "354");

            String encodedSubject =
                    "=?UTF-8?B?"
                            + Base64.getEncoder().encodeToString(
                                    subject.getBytes(StandardCharsets.UTF_8)
                            )
                            + "?=";

            String message =
                    "From: RailTrack <" + SENDER_EMAIL + ">\r\n"
                    + "To: " + to + "\r\n"
                    + "Subject: " + encodedSubject + "\r\n"
                    + "MIME-Version: 1.0\r\n"
                    + "Content-Type: text/plain; charset=UTF-8\r\n"
                    + "Content-Transfer-Encoding: 8bit\r\n"
                    + "\r\n"
                    + body
                    + "\r\n.\r\n";

            os.write(message.getBytes(StandardCharsets.UTF_8));
            os.flush();

            readResponse(reader, "250");

            sendCmd(os, reader, "QUIT", "221");

            System.out.println(
                    "✅ Email sent successfully to: " + to
            );
        }
    }

    private static void sendCmd(
            OutputStream os,
            BufferedReader reader,
            String cmd,
            String expectedCode) throws Exception {

        System.out.println("CLIENT: " + cmd);

        os.write(
                (cmd + "\r\n")
                        .getBytes(StandardCharsets.UTF_8)
        );

        os.flush();

        readResponse(reader, expectedCode);
    }

    private static void readResponse(
            BufferedReader reader,
            String expectedCode) throws Exception {

        String line;

        while ((line = reader.readLine()) != null) {

            System.out.println("SMTP: " + line);

            if (line.length() < 4) {
                continue;
            }

            if (line.charAt(3) == ' ') {

                if (line.startsWith(expectedCode)) {
                    return;
                }

                throw new RuntimeException(
                        "Unexpected SMTP response. Expected "
                                + expectedCode
                                + " but received: "
                                + line
                );
            }
        }

        throw new RuntimeException(
                "SMTP connection closed unexpectedly."
        );
    }
}
package com.railtrack.system.playground;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class GenerateUsers {

    static class TestuserJson {

        String username;
        String password;
        String fullName;
        String email;
        String department;
        String role;

        public TestuserJson(String username, String password, String fullName,
                String email, String department, String role) {
            this.username = username;
            this.password = password;
            this.fullName = fullName;
            this.email = email;
            this.department = department;
            this.role = role;
        }
    }

    public static void main(String[] args) {

        List<TestuserJson> users = new ArrayList<>();

        String[] departments = {
            "Software Engineering",
            "Computer Science",
            "Information Technology",
            "Information Systems",
            "Cyber Security"
        };

        // Generate 180 Students
        for (int i = 1; i <= 180; i++) {
            users.add(new TestuserJson(
                    String.format("student%03d", i),
                    "Password123!",
                    String.format("Student %03d", i),
                    String.format("student%03d@railtrack.local", i),
                    departments[(i - 1) % departments.length],
                    "STUDENT"
            ));
        }

        // Generate 20 Supervisors
        for (int i = 1; i <= 20; i++) {
            users.add(new TestuserJson(
                    String.format("supervisor%03d", i),
                    "Password123!",
                    String.format("Supervisor %03d", i),
                    String.format("supervisor%03d@railtrack.local", i),
                    departments[(i - 1) % departments.length],
                    "SUPERVISOR"
            ));
        }

        StringBuilder json = new StringBuilder();
        json.append("[\n");

        for (int i = 0; i < users.size(); i++) {

            TestuserJson u = users.get(i);

            json.append("  {\n");
            json.append("    \"username\": \"").append(u.username).append("\",\n");
            json.append("    \"password\": \"").append(u.password).append("\",\n");
            json.append("    \"fullName\": \"").append(u.fullName).append("\",\n");
            json.append("    \"email\": \"").append(u.email).append("\",\n");
            json.append("    \"department\": \"").append(u.department).append("\",\n");
            json.append("    \"role\": \"").append(u.role).append("\"\n");
            json.append("  }");

            if (i < users.size() - 1) {
                json.append(",");
            }

            json.append("\n");
        }

        json.append("]");

        File file = new File(System.getProperty("user.home"), "users.json");

        try (FileWriter writer = new FileWriter(file)) {

            writer.write(json.toString());

            System.out.println("=================================");
            System.out.println("Generated " + users.size() + " users.");
            System.out.println("JSON file saved to:");
            System.out.println(file.getAbsolutePath());
            System.out.println("=================================");

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
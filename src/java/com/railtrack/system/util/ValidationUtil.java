/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.util;

import java.util.regex.Pattern;

/**
 *
 * @author izzat
 */
public class ValidationUtil {

    // ── Patterns ──────────────────────────────────────────────────────────────
    private static final Pattern EMAIL_PATTERN
            = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    private static final Pattern GITHUB_URL_PATTERN
            = Pattern.compile("^https://github\\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(\\.git)?/?$");

    private static final Pattern GIT_URL_PATTERN
            = Pattern.compile("^https?://[A-Za-z0-9._~:/?#\\[\\]@!$&'()*+,;=%-]+\\.git$|"
                    + "^https://github\\.com/.+|"
                    + "^https://gitlab\\.com/.+|"
                    + "^https://bitbucket\\.org/.+");

    private static final Pattern USERNAME_PATTERN
            = Pattern.compile("^[A-Za-z0-9_]{3,30}$");

    private static final Pattern SEMESTER_PATTERN
            = Pattern.compile("^\\d{4}/\\d{4}-[12]$");   // e.g. 2024/2025-1

    // HTML tag stripper
    private static final Pattern HTML_TAG_PATTERN
            = Pattern.compile("<[^>]*>");

    private ValidationUtil() {
    }

    // ── Email ─────────────────────────────────────────────────────────────────
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    // ── Username ──────────────────────────────────────────────────────────────
    /**
     * Username rules: 3–30 chars, alphanumeric + underscore only.
     */
    public static boolean isValidUsername(String username) {
        return username != null && USERNAME_PATTERN.matcher(username.trim()).matches();
    }

    // ── Password ──────────────────────────────────────────────────────────────
    /**
     * Password strength: min 8 chars, at least one digit, one uppercase, one
     * lowercase.
     */
    public static boolean isStrongPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        boolean hasUpper = password.chars().anyMatch(Character::isUpperCase);
        boolean hasLower = password.chars().anyMatch(Character::isLowerCase);
        boolean hasDigit = password.chars().anyMatch(Character::isDigit);
        return hasUpper && hasLower && hasDigit;
    }

    // ── Repository URL ────────────────────────────────────────────────────────
    public static boolean isValidGithubUrl(String url) {
        return url != null && GITHUB_URL_PATTERN.matcher(url.trim()).matches();
    }

    public static boolean isValidRepoUrl(String url) {
        return url != null && GIT_URL_PATTERN.matcher(url.trim()).matches();
    }

    // ── Semester ──────────────────────────────────────────────────────────────
    public static boolean isValidSemester(String semester) {
        return semester != null && SEMESTER_PATTERN.matcher(semester.trim()).matches();
    }

    // ── General ──────────────────────────────────────────────────────────────
    public static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static boolean notBlank(String s) {
        return !isBlank(s);
    }

    /**
     * Strips HTML tags and trims whitespace. Use before storing any
     * user-supplied text.
     */
    public static String sanitise(String input) {
        if (input == null) {
            return "";
        }
        return HTML_TAG_PATTERN.matcher(input).replaceAll("").trim();
    }

    /**
     * Truncates a string to maxLen chars, appending "…" if cut.
     */
    public static String truncate(String input, int maxLen) {
        if (input == null) {
            return "";
        }
        return input.length() <= maxLen ? input : input.substring(0, maxLen - 1) + "…";
    }

    /**
     * Returns value if not blank, otherwise returns the fallback.
     */
    public static String defaultIfBlank(String value, String fallback) {
        return isBlank(value) ? fallback : value.trim();
    }

    /**
     * Safely parses an int from a string; returns defaultValue on failure.
     */
    public static int parseIntSafe(String s, int defaultValue) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return defaultValue;
        }
    }

    /**
     * Safely parses a double from a string; returns defaultValue on failure.
     */
    public static double parseDoubleSafe(String s, double defaultValue) {
        try {
            return Double.parseDouble(s.trim());
        } catch (Exception e) {
            return defaultValue;
        }
    }

    /**
     * Grade must be between 0 and 100 inclusive.
     */
    public static boolean isValidGrade(double grade) {
        return grade >= 0.0 && grade <= 100.0;
    }

    /**
     * Milestone weight must be between 0 and 100.
     */
    public static boolean isValidWeight(double weight) {
        return weight > 0.0 && weight <= 100.0;
    }
}

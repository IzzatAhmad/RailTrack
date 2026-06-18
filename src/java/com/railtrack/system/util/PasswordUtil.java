/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.railtrack.system.util;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.util.Base64;

/**
 *
 * @author izzat
 */
public final class PasswordUtil {

    private static final int    ITERATIONS  = 120_000;
    private static final int    KEY_LENGTH  = 256;          // bits
    private static final int    SALT_BYTES  = 16;
    private static final String ALGORITHM   = "PBKDF2WithHmacSHA256";
    private static final String DELIMITER   = ":";

    private PasswordUtil() {}

    // ── Hash ─────────────────────────────────────────────────────────────────

    /**
     * Hash a plain-text password.
     * @return storable hash string  (iterations:salt:hash)
     */
    public static String hash(String rawPassword) {
        byte[] salt = generateSalt();
        byte[] hash = pbkdf2(rawPassword.toCharArray(), salt, ITERATIONS, KEY_LENGTH);

        return ITERATIONS
                + DELIMITER + Base64.getEncoder().encodeToString(salt)
                + DELIMITER + Base64.getEncoder().encodeToString(hash);
    }

    // ── Verify ────────────────────────────────────────────────────────────────

    /**
     * Verify a plain-text password against a stored hash.
     * Returns false (not an exception) if the stored value is malformed.
     */
    public static boolean verify(String rawPassword, String storedHash) {
        if (rawPassword == null || storedHash == null) return false;

        if (isBCryptHash(storedHash)) {
            return verifyBCrypt(rawPassword, storedHash);
        }

        String[] parts = storedHash.split(DELIMITER);
        if (parts.length != 3) return false;

        try {
            int    iterations = Integer.parseInt(parts[0]);
            byte[] salt       = Base64.getDecoder().decode(parts[1]);
            byte[] expected   = Base64.getDecoder().decode(parts[2]);

            byte[] actual = pbkdf2(rawPassword.toCharArray(), salt, iterations, expected.length * 8);
            return slowEquals(expected, actual);

        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    private static boolean isBCryptHash(String storedHash) {
        return storedHash.startsWith("$2a$")
                || storedHash.startsWith("$2b$")
                || storedHash.startsWith("$2y$");
    }

    private static boolean verifyBCrypt(String rawPassword, String storedHash) {
        try {
            return org.mindrot.jbcrypt.BCrypt.checkpw(rawPassword, storedHash);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    // ── Internals ─────────────────────────────────────────────────────────────

    private static byte[] generateSalt() {
        byte[] salt = new byte[SALT_BYTES];
        new SecureRandom().nextBytes(salt);
        return salt;
    }

    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLengthBits) {
        try {
            PBEKeySpec       spec    = new PBEKeySpec(password, salt, iterations, keyLengthBits);
            SecretKeyFactory factory = SecretKeyFactory.getInstance(ALGORITHM);
            byte[]           hash    = factory.generateSecret(spec).getEncoded();
            spec.clearPassword();
            return hash;
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("PBKDF2 hashing failed", e);
        }
    }

    /** Constant-time comparison to prevent timing attacks. */
    private static boolean slowEquals(byte[] a, byte[] b) {
        int diff = a.length ^ b.length;
        for (int i = 0; i < a.length && i < b.length; i++) {
            diff |= a[i] ^ b[i];
        }
        return diff == 0;
    }
}

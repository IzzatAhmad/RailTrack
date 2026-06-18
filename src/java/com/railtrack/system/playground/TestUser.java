/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.playground;

import com.railtrack.system.util.PasswordUtil;

/**
 *
 * @author izzat
 */
public class TestUser {
 
    // ── Seed credentials (matches railtrack_fixed.sql) ────────────────────────
 
    private static final String[][] USERS = {
        // { username, rawPassword, role }
        { "admin",       "Admin1234!", "COORDINATOR" },
        { "sup_ali",     "Admin1234!", "SUPERVISOR"  },
        { "sup_bob",     "Admin1234!", "SUPERVISOR"  },
        { "stu_charlie", "Admin1234!", "STUDENT"     },
        { "stu_dana",    "Admin1234!", "STUDENT"     },
    };
 
    public static void main(String[] args) {
 
        System.out.println("==============================================");
        System.out.println("  RailTrack — PasswordUtil Test");
        System.out.println("==============================================\n");
 
        int passed = 0, failed = 0;
 
        for (String[] u : USERS) {
            String username = u[0];
            String password = u[1];
            String role     = u[2];
 
            // 1. Hash the password (simulates registration / DB seed)
            String hash = PasswordUtil.hash(password);
 
            // 2. Verify correct password
            boolean correctOk = PasswordUtil.verify(password, hash);
 
            // 3. Verify wrong password must fail
            boolean wrongFail = !PasswordUtil.verify("WrongPass99!", hash);
 
            boolean ok = correctOk && wrongFail;
 
            System.out.printf("%-14s [%-11s]  hash=%-80s  correct=%-5s  wrongRejected=%-5s  -> %s%n",
                    username, role,
                    hash.substring(0, Math.min(hash.length(), 50)) + "...",
                    correctOk, wrongFail,
                    ok ? "PASS" : "FAIL");
 
            if (ok) passed++; else failed++;
        }
 
        // ── Extra: wrong password must always return false ────────────────────
        String h = PasswordUtil.hash("Admin1234!");
        boolean rejectEmpty  = !PasswordUtil.verify("",           h);
        boolean rejectNull   = !PasswordUtil.verify(null,         h);
        boolean rejectTamper = !PasswordUtil.verify("Admin1234!", "tampered:data:here");
 
        System.out.println();
        System.out.println("Edge cases:");
        System.out.printf("  empty password rejected   : %s%n", rejectEmpty  ? "PASS" : "FAIL");
        System.out.printf("  null  password rejected   : %s%n", rejectNull   ? "PASS" : "FAIL");
        System.out.printf("  tampered hash rejected    : %s%n", rejectTamper ? "PASS" : "FAIL");
 
        if (rejectEmpty && rejectNull && rejectTamper) passed += 3; else failed += 3;
 
        // ── Summary ───────────────────────────────────────────────────────────
        System.out.println();
        System.out.println("==============================================");
        System.out.printf("  PASSED: %d   FAILED: %d%n", passed, failed);
        System.out.println("==============================================");
 
        if (failed > 0) System.exit(1);
    }
}

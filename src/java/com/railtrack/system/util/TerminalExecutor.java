/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.util;

import java.io.*;
import java.util.concurrent.*;
import java.util.function.Consumer;

/**
 *
 * @author izzat
 */
public class TerminalExecutor {

    /**
     * Default command timeout in minutes.
     */
    private static final int DEFAULT_TIMEOUT_MINUTES = 10;

    private static final boolean IS_WINDOWS
            = System.getProperty("os.name", "").toLowerCase().contains("win");

    private TerminalExecutor() {
    }

    // ── Result container ──────────────────────────────────────────────────────
    public static class Result {

        public final int exitCode;
        public final String stdout;
        public final String stderr;

        Result(int exitCode, String stdout, String stderr) {
            this.exitCode = exitCode;
            this.stdout = stdout;
            this.stderr = stderr;
        }

        public boolean success() {
            return exitCode == 0;
        }

        /**
         * Combined output: stdout, then stderr if non-empty.
         */
        public String combined() {
            if (stderr == null || stderr.trim().isEmpty()) {
                return stdout;
            }
            return stdout + "\n--- STDERR ---\n" + stderr;
        }
    }

    // ── Blocking execution ────────────────────────────────────────────────────
    /**
     * Runs a command and waits up to {@code DEFAULT_TIMEOUT_MINUTES} minutes.
     *
     * @param command full shell command string
     * @return Result with exit code and captured output
     */
    public static Result execute(String command) throws IOException, InterruptedException {
        return execute(command, DEFAULT_TIMEOUT_MINUTES);
    }

    /**
     * Runs a command with a custom timeout.
     *
     * @param command full shell command string
     * @param timeoutMinutes max wait time in minutes
     */
    public static Result execute(String command, int timeoutMinutes)
            throws IOException, InterruptedException {

        ProcessBuilder pb = buildProcess(command);
        pb.redirectErrorStream(false);
        Process process = pb.start();

        // Capture stdout and stderr concurrently to avoid blocking
        Future<String> stdoutFuture = captureStream(process.getInputStream());
        Future<String> stderrFuture = captureStream(process.getErrorStream());

        boolean finished = process.waitFor(timeoutMinutes, TimeUnit.MINUTES);
        if (!finished) {
            process.destroyForcibly();
            return new Result(-1, "", "Command timed out after " + timeoutMinutes + " minutes.");
        }

        String stdout = "";
        String stderr = "";
        try {
            stdout = stdoutFuture.get(5, TimeUnit.SECONDS);
            stderr = stderrFuture.get(5, TimeUnit.SECONDS);
        } catch (ExecutionException | TimeoutException e) {
            stderr = "Failed to read process output: " + e.getMessage();
        }

        return new Result(process.exitValue(), stdout, stderr);
    }

    /**
     * Runs a piped shell command (e.g. "docker logs x | tail -50"). Passes the
     * command to /bin/sh -c on Linux or cmd /c on Windows.
     */
    public static Result executeShell(String shellCommand) throws IOException, InterruptedException {
        return executeShell(shellCommand, DEFAULT_TIMEOUT_MINUTES);
    }

    public static Result executeShell(String shellCommand, int timeoutMinutes)
            throws IOException, InterruptedException {

        String[] cmd;
        if (IS_WINDOWS) {
            // Use Git Bash instead of cmd — supports if/fi, grep, etc.
            String gitBash = "C:\\Program Files\\Git\\bin\\bash.exe";
            cmd = new String[]{gitBash, "-c", shellCommand};
        } else {
            cmd = new String[]{"/bin/sh", "-c", shellCommand};
        }

        ProcessBuilder pb = new ProcessBuilder(cmd);
        pb.redirectErrorStream(false);
        Process process = pb.start();

        Future<String> stdoutFuture = captureStream(process.getInputStream());
        Future<String> stderrFuture = captureStream(process.getErrorStream());

        boolean finished = process.waitFor(timeoutMinutes, TimeUnit.MINUTES);
        if (!finished) {
            process.destroyForcibly();
            return new Result(-1, "", "Shell command timed out.");
        }

        String stdout = "", stderr = "";
        try {
            stdout = stdoutFuture.get(5, TimeUnit.SECONDS);
            stderr = stderrFuture.get(5, TimeUnit.SECONDS);
        } catch (ExecutionException | TimeoutException e) {
            stderr = "Output read error: " + e.getMessage();
        }

        return new Result(process.exitValue(), stdout, stderr);
    }

    /**
     * Runs a command exactly as specified without passing it through a shell.
     * Prevents OS command injection.
     */
    public static Result executeCommand(String... command) throws IOException, InterruptedException {
        return executeCommand(DEFAULT_TIMEOUT_MINUTES, command);
    }

    public static Result executeCommand(int timeoutMinutes, String... command)
            throws IOException, InterruptedException {

        ProcessBuilder pb = new ProcessBuilder(command);
        pb.redirectErrorStream(false);
        Process process = pb.start();

        Future<String> stdoutFuture = captureStream(process.getInputStream());
        Future<String> stderrFuture = captureStream(process.getErrorStream());

        boolean finished = process.waitFor(timeoutMinutes, TimeUnit.MINUTES);
        if (!finished) {
            process.destroyForcibly();
            return new Result(-1, "", "Command timed out after " + timeoutMinutes + " minutes.");
        }

        String stdout = "", stderr = "";
        try {
            stdout = stdoutFuture.get(5, TimeUnit.SECONDS);
            stderr = stderrFuture.get(5, TimeUnit.SECONDS);
        } catch (ExecutionException | TimeoutException e) {
            stderr = "Output read error: " + e.getMessage();
        }

        return new Result(process.exitValue(), stdout, stderr);
    }

    // ── Non-blocking streaming ────────────────────────────────────────────────
    /**
     * Starts a command in the background and streams each line to the provided
     * consumer. Returns the Process so the caller can destroy it.
     *
     * Useful for live log tailing in SSE endpoints.
     *
     * @param command e.g. "docker logs -f --tail=50 <containerId>"
     * @param lineConsumer called for each line of output
     * @return the running Process (caller must destroy when done)
     */
    public static Process stream(String command, Consumer<String> lineConsumer)
            throws IOException {

        ProcessBuilder pb = buildProcess(command);
        pb.redirectErrorStream(true);
        Process process = pb.start();

        Thread reader = new Thread(() -> {
            try (BufferedReader br
                    = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = br.readLine()) != null) {
                    lineConsumer.accept(line);
                }
            } catch (IOException e) {
                lineConsumer.accept("[stream error] " + e.getMessage());
            }
        }, "docker-stream-" + System.currentTimeMillis());

        reader.setDaemon(true);
        reader.start();
        return process;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private static ProcessBuilder buildProcess(String command) {
    if (IS_WINDOWS) {
        String gitBash = "C:\\Program Files\\Git\\bin\\bash.exe";
        return new ProcessBuilder(gitBash, "-c", command);
    } else {
        return new ProcessBuilder(command.split("\\s+"));
    }
}

    private static Future<String> captureStream(InputStream is) {
        ExecutorService pool = Executors.newSingleThreadExecutor();
        Future<String> future = pool.submit(() -> {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(is))) {
                String line;
                while ((line = br.readLine()) != null) {
                    sb.append(line).append("\n");
                }
            }
            return sb.toString();
        });
        pool.shutdown();
        return future;
    }
}

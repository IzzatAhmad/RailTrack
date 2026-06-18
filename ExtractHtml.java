import java.nio.file.*;
import java.util.*;
import java.io.*;

public class ExtractHtml {
    public static void main(String[] args) throws Exception {
        String logPath = "C:\\Users\\izzatahmad\\.gemini\\antigravity-ide\\brain\\65e89b03-6b91-46ff-be44-27517023f812\\.system_generated\\logs\\transcript.jsonl";
        List<String> lines = Files.readAllLines(Paths.get(logPath));
        String lastUserInput = "";
        for (String line : lines) {
            if (line.contains("\"type\":\"USER_INPUT\"")) {
                lastUserInput = line;
            }
        }
        
        Files.write(Paths.get("rubrics_raw.txt"), lastUserInput.getBytes("UTF-8"));
        System.out.println("Extracted to rubrics_raw.txt");
    }
}

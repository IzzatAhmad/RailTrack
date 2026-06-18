import java.sql.*;
import java.nio.file.*;
public class InitRubric {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try(Connection c = DriverManager.getConnection("jdbc:mysql://localhost:3306/railtrack", "root", "")) {
            c.createStatement().executeUpdate("ALTER TABLE rubrics MODIFY content MEDIUMTEXT");
            c.createStatement().executeUpdate("DELETE FROM rubrics");
            
            String html = new String(Files.readAllBytes(Paths.get("e:/RailTrack/RailTrack/web/views/student/rubrics_content.jsp")), "UTF-8");
            
            PreparedStatement ps = c.prepareStatement("INSERT INTO rubrics (section, title, content, sort_order, is_enabled) VALUES (?, ?, ?, ?, ?)");
            ps.setString(1, "General");
            ps.setString(2, "Assessment Rubric");
            ps.setString(3, html);
            ps.setInt(4, 1);
            ps.setInt(5, 1);
            ps.executeUpdate();
            System.out.println("Initialized rubrics table with HTML content!");
        }
    }
}

import java.sql.*;
public class ShowMenu {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try(Connection c = DriverManager.getConnection("jdbc:mysql://localhost:3306/railtrack", "root", "")) {
            ResultSet rs = c.createStatement().executeQuery("SELECT * FROM student_menu_items ORDER BY sort_order ASC");
            while(rs.next()) {
                System.out.println(rs.getInt("id") + " | " + rs.getString("item_key") + " | " + rs.getString("label") + " | " + rs.getString("icon") + " | " + rs.getString("icon_color") + " | " + rs.getString("url") + " | " + rs.getInt("sort_order") + " | " + rs.getInt("is_enabled"));
            }
        }
    }
}

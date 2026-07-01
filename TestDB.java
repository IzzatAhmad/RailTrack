import com.railtrack.system.util.DBConnection;
import java.sql.Connection;
import java.sql.Statement;

public class TestDB {
    public static void main(String[] args) {
        try (Connection c = DBConnection.get();
             Statement s = c.createStatement()) {
            s.executeUpdate("ALTER TABLE projects ADD COLUMN today_running_seconds INT DEFAULT 0");
            s.executeUpdate("ALTER TABLE projects ADD COLUMN last_running_update DATE DEFAULT CURRENT_DATE");
            System.out.println("Columns added!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

package playground;
import com.railtrack.system.util.TerminalExecutor;

public class FixDB {
    public static void main(String[] args) throws Exception {
        TerminalExecutor.Result r = TerminalExecutor.executeShell("docker ps -a --format \"{{.ID}}|{{.Image}}|{{.Command}}|{{.CreatedAt}}|{{.Status}}|{{.Ports}}|{{.Names}}\"");
        System.out.println("ExitCode: " + r.exitCode);
        System.out.println("Output: " + r.stdout);
        System.out.println("Error: " + r.stderr);
    }
}

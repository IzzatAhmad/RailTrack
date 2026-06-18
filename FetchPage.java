import java.net.*;
import java.io.*;
import java.util.*;

public class FetchPage {
    public static void main(String[] args) throws Exception {
        CookieManager cookieManager = new CookieManager(null, CookiePolicy.ACCEPT_ALL);
        CookieHandler.setDefault(cookieManager);

        HttpURLConnection con = (HttpURLConnection) new URL("http://localhost:8080/RailTrack/login").openConnection();
        con.setRequestMethod("POST");
        con.setDoOutput(true);
        con.setInstanceFollowRedirects(false);
        String postData = "email=coordinator@railtrack.com&password=password123";
        try(OutputStream os = con.getOutputStream()) {
            os.write(postData.getBytes("UTF-8"));
        }
        con.getInputStream().read(); // read response
        
        System.out.println("Login Response Code: " + con.getResponseCode());

        HttpURLConnection con2 = (HttpURLConnection) new URL("http://localhost:8080/RailTrack/coordinator/menu").openConnection();
        con2.setRequestMethod("GET");
        
        System.out.println("Page Response Code: " + con2.getResponseCode());
        try(BufferedReader br = new BufferedReader(new InputStreamReader(con2.getInputStream(), "UTF-8"))) {
            String line;
            while((line = br.readLine()) != null) {
                System.out.println(line);
            }
        }
    }
}

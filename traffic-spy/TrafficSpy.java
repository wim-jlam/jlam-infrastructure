import java.io.*;
import java.net.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * HTTP Traffic Spy - Console Monitor
 * Watches HTTP traffic and reports SSL/Cookie issues
 */
public class TrafficSpy {
    private static final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("HH:mm:ss");
    
    public static void main(String[] args) {
        System.out.println("🕵️  HTTP Traffic Spy Started");
        System.out.println("👀 Monitoring auth.jlam.nl traffic...");
        System.out.println("=" .repeat(60));
        
        // Monitor in een loop
        while (true) {
            try {
                checkAuthentikTraffic();
                Thread.sleep(5000); // Check elke 5 seconden
            } catch (Exception e) {
                log("❌ Error: " + e.getMessage());
            }
        }
    }
    
    private static void checkAuthentikTraffic() {
        try {
            log("🔍 Testing Authentik internally...");
            
            // Test internal Docker network communication first
            URL url = new URL("http://authentik-server:9000/-/health/ready/");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            
            // Request headers
            conn.setRequestMethod("GET");
            conn.setRequestProperty("User-Agent", "TrafficSpy/1.0");
            conn.setInstanceFollowRedirects(false);
            
            log("📤 REQUEST:");
            log("   → " + conn.getRequestMethod() + " " + url);
            log("   → User-Agent: " + conn.getRequestProperty("User-Agent"));
            
            // Get response
            int responseCode = conn.getResponseCode();
            log("📥 RESPONSE:");
            log("   ← Status: " + responseCode + " " + conn.getResponseMessage());
            
            // Check response headers
            boolean foundSecureCookie = false;
            boolean foundHttpOnlyCookie = false;
            int cookieCount = 0;
            
            for (String headerName : conn.getHeaderFields().keySet()) {
                if (headerName != null) {
                    for (String headerValue : conn.getHeaderFields().get(headerName)) {
                        if ("Set-Cookie".equalsIgnoreCase(headerName)) {
                            cookieCount++;
                            log("   ← 🍪 Set-Cookie: " + headerValue);
                            
                            if (headerValue.toLowerCase().contains("secure")) {
                                foundSecureCookie = true;
                                log("      ✅ Has Secure flag");
                            } else {
                                log("      ❌ Missing Secure flag");
                            }
                            
                            if (headerValue.toLowerCase().contains("httponly")) {
                                foundHttpOnlyCookie = true;
                                log("      ✅ Has HttpOnly flag");
                            } else {
                                log("      ❌ Missing HttpOnly flag");
                            }
                        }
                    }
                }
            }
            
            // Summary
            log("📊 SUMMARY:");
            log("   → Cookies found: " + cookieCount);
            log("   → Secure cookies: " + (foundSecureCookie ? "✅ YES" : "❌ NO"));
            log("   → HttpOnly cookies: " + (foundHttpOnlyCookie ? "✅ YES" : "❌ NO"));
            
            if (!foundSecureCookie && cookieCount > 0) {
                log("🚨 PROBLEM: Cookies missing Secure flag!");
            }
            
            conn.disconnect();
            
        } catch (Exception e) {
            log("💥 Connection failed: " + e.getMessage());
        }
        
        log("-".repeat(60));
    }
    
    private static void log(String message) {
        String time = LocalDateTime.now().format(TIME_FORMAT);
        System.out.println("[" + time + "] " + message);
    }
}
import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;

/**
 * SSL Cookie Proxy for Authentik
 * Intercepts HTTP traffic and forces Secure flag on cookies
 */
public class SSLProxy {
    private static final int PROXY_PORT = 9001;
    private static final String BACKEND_HOST = "localhost";
    private static final int BACKEND_PORT = 9000;
    
    public static void main(String[] args) throws IOException {
        System.out.println("🔒 SSL Cookie Proxy starting on port " + PROXY_PORT);
        System.out.println("📡 Proxying to Authentik at " + BACKEND_HOST + ":" + BACKEND_PORT);
        
        ServerSocket serverSocket = new ServerSocket(PROXY_PORT);
        ExecutorService executor = Executors.newFixedThreadPool(10);
        
        while (true) {
            Socket clientSocket = serverSocket.accept();
            executor.submit(() -> handleClient(clientSocket));
        }
    }
    
    private static void handleClient(Socket clientSocket) {
        try (Socket backendSocket = new Socket(BACKEND_HOST, BACKEND_PORT);
             BufferedReader clientIn = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
             PrintWriter clientOut = new PrintWriter(clientSocket.getOutputStream(), true);
             BufferedReader backendIn = new BufferedReader(new InputStreamReader(backendSocket.getInputStream()));
             PrintWriter backendOut = new PrintWriter(backendSocket.getOutputStream(), true)) {
            
            System.out.println("🔗 New connection from " + clientSocket.getRemoteSocketAddress());
            
            // Read client request
            List<String> requestLines = new ArrayList<>();
            String line;
            while ((line = clientIn.readLine()) != null && !line.isEmpty()) {
                requestLines.add(line);
            }
            
            // Forward request to backend with HTTPS headers
            for (String requestLine : requestLines) {
                backendOut.println(requestLine);
            }
            
            // Force HTTPS headers
            backendOut.println("X-Forwarded-Proto: https");
            backendOut.println("X-Forwarded-Ssl: on");
            backendOut.println("X-Forwarded-Port: 443");
            backendOut.println(); // Empty line to end headers
            
            // Read backend response
            List<String> responseLines = new ArrayList<>();
            while ((line = backendIn.readLine()) != null) {
                
                // Modify Set-Cookie headers to add Secure flag
                if (line.toLowerCase().startsWith("set-cookie:")) {
                    if (!line.toLowerCase().contains("secure")) {
                        line = line + "; Secure";
                        System.out.println("🍪 Added Secure flag: " + line);
                    }
                }
                
                responseLines.add(line);
                
                // Break on empty line (end of headers) or if we have response body
                if (line.isEmpty()) break;
            }
            
            // Send response back to client
            for (String responseLine : responseLines) {
                clientOut.println(responseLine);
            }
            
            clientOut.flush();
            
        } catch (IOException e) {
            System.err.println("❌ Error handling client: " + e.getMessage());
        }
    }
}
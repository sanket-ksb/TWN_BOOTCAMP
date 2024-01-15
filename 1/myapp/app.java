import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class HelloWorldServer {
    public static void main(String[] args) throws IOException {
        try (ServerSocket listener = new ServerSocket(80)) {
            while (true) {
                new Handler(listener.accept()).start();
            }
        }
    }

    private static class Handler extends Thread {
        private Socket socket;

        public Handler(Socket socket) {
            this.socket = socket;
        }

        public void run() {
            try (PrintWriter out = new PrintWriter(socket.getOutputStream(), true)) {
                out.println("Hello World");
            } finally {
                try {
                    socket.close();
                } catch (IOException e) {
                }
            }
        }
    }
}
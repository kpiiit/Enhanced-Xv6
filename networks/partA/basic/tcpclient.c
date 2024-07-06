#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 12345
#define BUFFER_SIZE 1024

void handle_error(const char *msg) {
    perror(msg);
    exit(EXIT_FAILURE);
}

int main() {
    int client_socket;
    struct sockaddr_in server_addr;
    char buffer[BUFFER_SIZE];

    // Create socket
    if ((client_socket = socket(AF_INET, SOCK_STREAM, 0)) == -1)
        handle_error("Error creating socket");

    // Prepare server address structure
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    server_addr.sin_port = htons(PORT);

    // Connect to server
    if (connect(client_socket, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
        handle_error("Error connecting to server");

    // Send data to server
    const char *message = "Hello, server!";
    if (send(client_socket, message, strlen(message), 0) == -1)
        handle_error("Error sending data to server");

    // Receive response from server
    ssize_t received_bytes = recv(client_socket, buffer, sizeof(buffer), 0);
    if (received_bytes == -1)
        handle_error("Error receiving data from server");

    buffer[received_bytes] = '\0';
    printf("Received from server: %s\n", buffer);

    // Close socket
    close(client_socket);

    return 0;
}

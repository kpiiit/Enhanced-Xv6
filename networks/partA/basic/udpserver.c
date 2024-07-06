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
    int server_socket;
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_addr_len = sizeof(client_addr);
    char buffer[BUFFER_SIZE];

    // Create socket
    if ((server_socket = socket(AF_INET, SOCK_DGRAM, 0)) == -1)
        handle_error("Error creating socket");

    // Prepare server address structure
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);

    // Bind the socket
    if (bind(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
        handle_error("Error binding socket");

    printf("UDP Server listening on port %d\n", PORT);

    // Receive data from client
    ssize_t received_bytes = recvfrom(server_socket, buffer, sizeof(buffer), 0, (struct sockaddr *)&client_addr, &client_addr_len);
    if (received_bytes == -1)
        handle_error("Error receiving data from client");

    buffer[received_bytes] = '\0';
    printf("Received data: %s from %s:%d\n", buffer, inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));

    // Send response to client
    const char *response = "Hello, client! Your message was received.";
    if (sendto(server_socket, response, strlen(response), 0, (struct sockaddr *)&client_addr, client_addr_len) == -1)
        handle_error("Error sending response to client");

    // Close socket
    close(server_socket);

    return 0;
}

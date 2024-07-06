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
    if ((client_socket = socket(AF_INET, SOCK_DGRAM, 0)) == -1)
        handle_error("Error creating socket");

    // Prepare server address structure
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    server_addr.sin_port = htons(PORT);

    // Send data to server
    const char *message = "Hello, server!";
    if (sendto(client_socket, message, strlen(message), 0, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
        handle_error("Error sending data to server");

    // Receive response from server
    struct sockaddr_in server_response_addr;
    socklen_t server_response_addr_len = sizeof(server_response_addr);

    ssize_t received_bytes = recvfrom(client_socket, buffer, sizeof(buffer), 0, (struct sockaddr *)&server_response_addr, &server_response_addr_len);
    if (received_bytes == -1)
        handle_error("Error receiving data from server");

    buffer[received_bytes] = '\0';
    printf("Received from server: %s at %s:%d\n", buffer, inet_ntoa(server_response_addr.sin_addr), ntohs(server_response_addr.sin_port));

    // Close socket
    close(client_socket);

    return 0;
}

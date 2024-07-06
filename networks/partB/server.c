#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <time.h>

#define MAX_PACKET_SIZE 1024
#define SERVER_PORT 8888
#define TIMEOUT_SEC 0
#define TIMEOUT_USEC 1000000  // 0.1 seconds
#define FILENAME "received_data.txt"

// Structure representing a data packet
typedef struct {
    int seq_num;
    int total_chunks;
    char data[MAX_PACKET_SIZE];
} DataPacket;

// Structure representing an acknowledgment packet
typedef struct {
    int seq_num;
} AckPacket;

// Function to simulate a random ACK drop (for testing purposes)
int shouldDropAck() {
    return rand() % 3 == 0;  // Drop ACK every third time (for testing)
}

// Function to simulate a random data drop (for testing purposes)
int shouldDropData() {
    return rand() % 5 == 0;  // Drop data packet with a 20% probability (for testing)
}

// Function to simulate packet transmission
void sendPacket(int socket, const void *packet, size_t packet_size, struct sockaddr_in *client_addr, socklen_t addr_len) {
    if (shouldDropData()) {
        printf("Dropped packet (for testing)\n");
        return;
    }

    ssize_t send_len = sendto(socket, packet, packet_size, 0, (struct sockaddr *)client_addr, addr_len);

    if (send_len == -1) {
        perror("Error sending packet");
        exit(EXIT_FAILURE);
    }
}

// Function to simulate packet reception
ssize_t receivePacket(int socket, void *packet, size_t packet_size, struct sockaddr_in *client_addr, socklen_t *addr_len) {
    ssize_t recv_len;
    
    if (addr_len != NULL) {
        recv_len = recvfrom(socket, packet, packet_size, 0, (struct sockaddr *)client_addr, addr_len);
    } else {
        // If addr_len is not provided, assume a fixed size address structure
        struct sockaddr_in temp_addr;
        socklen_t temp_len = sizeof(temp_addr);
        recv_len = recvfrom(socket, packet, packet_size, 0, (struct sockaddr *)&temp_addr, &temp_len);

        // If client_addr is not NULL, copy the received address
        if (client_addr != NULL) {
            memcpy(client_addr, &temp_addr, sizeof(temp_addr));
        }
    }

    if (recv_len == -1) {
        perror("Error receiving packet");
        exit(EXIT_FAILURE);
    }

    return recv_len;
}

int main() {
    int server_socket;
    struct sockaddr_in server_addr, client_addr;

    srand(time(NULL));

    // Create UDP socket
    server_socket = socket(AF_INET, SOCK_DGRAM, 0);
    if (server_socket == -1) {
        perror("Error creating socket");
        exit(EXIT_FAILURE);
    }

    // Configure server address
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(SERVER_PORT);

    // Bind the socket to the specified address and port
    if (bind(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1) {
        perror("Error binding socket");
        close(server_socket);
        exit(EXIT_FAILURE);
    }

    printf("Server listening on port %d...\n", SERVER_PORT);

    // Open a file for appending received data
    FILE *file = fopen(FILENAME, "ab");
    if (file == NULL) {
        perror("Error opening file");
        close(server_socket);
        exit(EXIT_FAILURE);
    }

    // Server main loop
    int expected_seq_num = 1;
    int total_chunks = -1;  // Variable to store the total number of chunks
    while (expected_seq_num <= total_chunks || total_chunks == -1) {
        DataPacket recv_packet;
        AckPacket send_ack;

        // Receive data packet from the client
        ssize_t recv_len = receivePacket(server_socket, &recv_packet, sizeof(DataPacket), &client_addr, NULL);

        if (recv_packet.seq_num == expected_seq_num) {
            // Simulate random ACK drop for testing
            if (!shouldDropAck()) {
                // Prepare acknowledgment packet
                send_ack.seq_num = recv_packet.seq_num;

                // Send acknowledgment to the client
                sendPacket(server_socket, &send_ack, sizeof(AckPacket), &client_addr, sizeof(client_addr));

                // If it's the first packet, set the total_chunks variable
                if (total_chunks == -1) {
                    total_chunks = recv_packet.total_chunks;
                }

                // Write data to the file
                fwrite(recv_packet.data, sizeof(char), strlen(recv_packet.data), file);
                fflush(file);

                printf("Received data packet with sequence number: %d\n", recv_packet.seq_num);
                printf("Sent acknowledgment for sequence number: %d\n", send_ack.seq_num);

                // Move to the next expected sequence number
                expected_seq_num++;
                if(expected_seq_num==10){
              break;
            }
            } else {
                printf("Dropped acknowledgment (for testing)\n");
            }
        } else {
            // Out-of-order or duplicate packet, ignore and request retransmission
            printf("Received out-of-order or duplicate packet. Requesting retransmission.\n");

            // Resend acknowledgment for the last correctly received packet
            send_ack.seq_num = expected_seq_num - 1;
            sendPacket(server_socket, &send_ack, sizeof(AckPacket), &client_addr, sizeof(client_addr));
        }
    }

    // Close the file
    fclose(file);

    // Close the socket
    close(server_socket);

    return 0;
}
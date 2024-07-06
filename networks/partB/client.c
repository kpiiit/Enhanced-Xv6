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
#define TIMEOUT_USEC 1000000 // 0.1 seconds

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
void sendPacket(int socket, const void *packet, size_t packet_size, struct sockaddr_in *server_addr, socklen_t addr_len) {
    if (shouldDropData()) {
        printf("Dropped packet (for testing)\n");
        return;
    }

    ssize_t send_len = sendto(socket, packet, packet_size, 0, (struct sockaddr *)server_addr, addr_len);

    if (send_len == -1) {
        perror("Error sending packet");
        exit(EXIT_FAILURE);
    }
}

// Function to simulate packet reception
ssize_t receivePacket(int socket, void *packet, size_t packet_size, struct sockaddr_in *server_addr, socklen_t *addr_len) {
    // Use recvfrom function with proper address parameters
    ssize_t recv_len = recvfrom(socket, packet, packet_size, 0, (struct sockaddr *)server_addr, addr_len);

    if (recv_len == -1) {
        perror("Error receiving packet");
        exit(EXIT_FAILURE);
    }

    return recv_len;
}

int main() {
    int client_socket;
    struct sockaddr_in server_addr;

    srand(time(NULL));

    // Create UDP socket
    client_socket = socket(AF_INET, SOCK_DGRAM, 0);
    if (client_socket == -1) {
        perror("Error creating socket");
        exit(EXIT_FAILURE);
    }

    // Configure server address
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(SERVER_PORT);

    // Client main loop
    int expected_seq_num = 1;
    while (expected_seq_num <= 10) {
        DataPacket send_packet;
        AckPacket recv_ack;

        // Properly initialize the size of the server address structure
        socklen_t addr_len = sizeof(server_addr);

        // Prepare data packet
        send_packet.seq_num = expected_seq_num;
        send_packet.total_chunks = 10;  // For simplicity, assuming a fixed number of chunks
        sprintf(send_packet.data, "Data for sequence number %d", expected_seq_num);

        // Send data packet to the server
        sendPacket(client_socket, &send_packet, sizeof(DataPacket), &server_addr, addr_len);
        printf("Sent data packet with sequence number: %d\n", send_packet.seq_num);

        // Set timeout for select()
        struct timeval timeout;
        timeout.tv_sec = TIMEOUT_SEC;
        timeout.tv_usec = TIMEOUT_USEC;

        // Set up file descriptors for select()
        fd_set read_fds;
        FD_ZERO(&read_fds);
        FD_SET(client_socket, &read_fds);

        // Wait for acknowledgment or timeout
        int select_result = select(client_socket + 1, &read_fds, NULL, NULL, &timeout);

        if (select_result == -1) {
            perror("Error in select");
            exit(EXIT_FAILURE);
        } else if (select_result > 0) {
            // Receive acknowledgment from the server
            ssize_t recv_len = receivePacket(client_socket, &recv_ack, sizeof(AckPacket), &server_addr, &addr_len);

            if (recv_ack.seq_num == expected_seq_num) {
                printf("Received acknowledgment for sequence number: %d\n", recv_ack.seq_num);
                expected_seq_num++;  // Move to the next expected sequence number
            } else {
                printf("Received incorrect acknowledgment\n");
            }
            if(expected_seq_num==10){
              break;
            }
        } 
        
            else {
            // Timeout: Resend the data packet
            printf("Timeout! Resending data packet with sequence number: %d\n", send_packet.seq_num);
            sendPacket(client_socket, &send_packet, sizeof(DataPacket), &server_addr, addr_len);
        }
    }

    // Close the socket
    close(client_socket);

    return 0;
}
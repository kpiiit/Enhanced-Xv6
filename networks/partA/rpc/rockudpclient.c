#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<sys/socket.h>
#include<arpa/inet.h>
#include<unistd.h>

#define BUFLEN 1024
#define PORT 8885

void die(char *s)
{
    perror(s);
    exit(1);
}

int main()
{
    char *server_ip = "127.0.0.1";
    struct sockaddr_in server_addr;
    socklen_t addr_size;

    // Create a UDP socket
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
        die("socket()");

    // Configure settings in address struct
    memset(&server_addr, '\0', sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = inet_addr(server_ip);

    printf("Welcome to Rock Paper Scissors!\n");

    while (1)
    {
        int choice;
        printf("\n");
        printf("1. Rock\n");
        printf("2. Paper\n");
        printf("3. Scissors\n");
        printf("Enter your choice:\n");
        scanf("%d", &choice);
        char buf[BUFLEN];
        memset(buf, '\0', BUFLEN);
        if (choice == 1)
        {
            strcpy(buf, "rock");
        }
        else if (choice == 2)
        {
            strcpy(buf, "paper");
        }
        else if (choice == 3)
        {
            strcpy(buf, "scissors");
        }
        else
        {
            printf("Invalid choice!\n");
            continue;
        }

        // Send message to server
        if (sendto(sockfd, buf, strlen(buf), 0, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
            die("sendto()");
        printf("Waiting for opponent...\n");

        // Receive message from server
        addr_size = sizeof(server_addr);
        memset(buf, '\0', BUFLEN);
        int recv_len = recvfrom(sockfd, buf, BUFLEN, 0, (struct sockaddr *)&server_addr, &addr_size);
        if (recv_len < 0)
            die("recvfrom()");

        printf("\n");
        if (strcmp(buf, "win") == 0)
        {
            printf("You win!\n");
        }
        else if (strcmp(buf, "lose") == 0)
        {
            printf("You lose!\n");
        }
        else if (strcmp(buf, "draw") == 0)
        {
            printf("It's a draw!\n");
        }
        else
        {
            printf("Invalid response from server!\n");
        }

        printf("Do you want to play again? (y/n)\n");
        char play_again;
        scanf(" %c", &play_again);
        if (play_again == 'y')
        {
            continue;
        }
        else if (play_again == 'n')
        {
            break;
        }
        else
        {
            printf("Invalid choice!\n");
            break;
        }
    }
    close(sockfd);

    return 0;
}
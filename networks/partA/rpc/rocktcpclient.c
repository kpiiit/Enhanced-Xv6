#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>

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

    // Create a TCP socket
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0)
        die("socket()");

    // Configure settings in address struct
    memset(&server_addr, '\0', sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = inet_addr(server_ip);

    // Connect to the server
    if (connect(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
        die("connect()");

    printf("Client: Welcome to Rock Paper Scissors!\n");

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
            printf("Client: Invalid choice!\n");
            continue;
        }

        // Send message to server
        if (send(sockfd, buf, strlen(buf), 0) < 0)
            die("send()");

        printf("Client: Waiting for opponent...\n");

        // Receive message from server
        memset(buf, '\0', BUFLEN);
        int recv_len = recv(sockfd, buf, BUFLEN, 0);
        if (recv_len < 0)
            die("recv()");

        printf("\n");
        //printf("%s",buf);
        if (strcmp(buf, "win") == 0)
        {
            printf("Client: You win!\n");
        }
        else if (strcmp(buf, "lose") == 0)
        {
            printf("Client: You lose!\n");
        }
        else if (strcmp(buf, "draw") == 0)
        {
            printf("Client: It's a draw!\n");
        }
        else
        {
            printf("Client: Invalid response from server!\n");
        }

        printf("Client: Do you want to play again? (y/n)\n");
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
            printf("Client: Invalid choice!\n");
            break;
        }
    }

    close(sockfd);

    return 0;
}

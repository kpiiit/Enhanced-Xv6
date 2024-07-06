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

int rpc(char *player1, char *player2)
{
    if (strcmp(player1, player2) == 0)
    {
        return 0; // Draw
    }
    else if ((strcmp(player1, "rock") == 0 && strcmp(player2, "scissors") == 0) ||
             (strcmp(player1, "paper") == 0 && strcmp(player2, "rock") == 0) ||
             (strcmp(player1, "scissors") == 0 && strcmp(player2, "paper") == 0))
    {
        return 1; // Player 1 wins
    }
    else
    {
        return 2; // Player 2 wins
    }
}


int main()
{
    char *server_ip = "127.0.0.1";
    struct sockaddr_in server_addr, client_addr1,client_addr2;
    socklen_t addr_size;

    // Create a TCP socket
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0)
        die("socket()");

    // Configure settings in address struct
    memset(&server_addr, '\0', sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = inet_addr(server_ip);

    // Bind socket with address struct
    if (bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
        die("bind()");

    // Listen for incoming connections
    if (listen(sockfd, 2) < 0)
        die("listen()");

    int sum = 0;
    char *player1 = (char *)malloc(sizeof(char) * BUFLEN);
    char *player2 = (char *)malloc(sizeof(char) * BUFLEN);
    int new_socket[2];
    int i=0;
      // Accept a connection from a client
    int flag=1;
    printf("Waiting for player 1...\n");
    new_socket[0]= accept(sockfd, (struct sockaddr *)&client_addr1, &addr_size);
    printf("Waiting for player 2...\n");
    new_socket[1] = accept(sockfd, (struct sockaddr *)&client_addr2, &addr_size);
        while (1)
    {
        char buf[BUFLEN];
        memset(buf, '\0', BUFLEN);
        if (sum == 0&&flag==0)
        {
            printf("Waiting for player 1...\n");
            //flag=1;
            //new_socket[0]= accept(sockfd, (struct sockaddr *)&client_addr1, &addr_size);

        }
        else if (sum == 1&&flag==0)
        {
            printf("Waiting for player 2...\n");
            //flag=1;
             //new_socket[1] = accept(sockfd, (struct sockaddr *)&client_addr2, &addr_size);
        }
        else
        {
            if(flag==0){
            printf("Waiting for players...\n");
            }
        }

      

        if (sum == 0)
        {
            int recv_len = recv(new_socket[0], buf, BUFLEN, 0);
            if (recv_len < 0)
                die("recv()");
            strcpy(player1, buf);
            sum++;
        }
        else if (sum == 1)
        {
            int recv_len = recv(new_socket[1], buf, BUFLEN, 0);
            if (recv_len < 0)
                die("recv()");
            strcpy(player2, buf);
            sum++;
        }
        else
        {
            printf("Only two players allowed!\n");
            close(new_socket[1]);
            continue;
        }

        if (sum == 2)
        {
            //printf("1");
            int result = rpc(player1, player2);
            char reply_msg1[BUFLEN];
            char reply_msg2[BUFLEN];
            memset(reply_msg1, '\0', BUFLEN);
            memset(reply_msg2, '\0', BUFLEN);
            if (result == 0)
            {
                strcpy(reply_msg1, "draw");
                strcpy(reply_msg2, "draw");
            }
            else if (result == 1)
            {
                strcpy(reply_msg1, "win");
                strcpy(reply_msg2, "lose");
            }
            else if (result == 2)
            {
                strcpy(reply_msg1, "lose");
                strcpy(reply_msg2, "win");
            }
            else
            {
                printf("Invalid response from server!\n");
            }

            // Send results to clients
            if (send(new_socket[0], reply_msg1, strlen(reply_msg1), 0) < 0)
                die("send()");

            if (send(new_socket[1], reply_msg2, strlen(reply_msg2), 0) < 0)
                die("send()");

            sum = 0;
            printf("Result sent to clients!\n");
            i=0;
            flag=0;
            //printf("%d",i);
            // Close the connection with the clients
            //close(new_socket[0]);
            //close(new_socket[1]);

        }
    }

    close(sockfd);

    return 0;
}

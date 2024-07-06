#include "type.h"
#include "user.h"

int number_of_processes = 10;


int main(int argc, char *argv[])
{
  int j;
  for (j = 0; j < number_of_processes; j++)
  {
    int pid = fork();
    if (pid < 0)
    { 
      int l=1;
      printf("Fork failed: %d\n",l);
      continue;
    }
    if (pid == 0)
    {
      volatile int i;
      for (volatile int k = 0; k < number_of_processes; k++)
      {
        if (k <= j)
        {
          sleep(200); // io time
        }
        else
        {
          for (i = 0; i < 100000000; i++)
          {
              ;
          }
        }
      }
      if (!PLOT)
        printf("Process: 1 Finished\n");
      exit(0);
    }
   
  }
  for (j = 0; j < number_of_processes + 5; j++)
  {
    int status;
    wait(&status);
  }
  exit(0);
}

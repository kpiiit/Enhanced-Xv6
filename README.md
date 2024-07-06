# Specification 2 : Scheduling

The default scheduler of xv6 is round-robin based. In this task, four other scheduling policies were implemented and incorporated in xv6. The scheduling policy used by the kernel will be declared by the user during compilation, with the user specifying the scheduling type using predefined flags. The `SCHEDULER` macro was defined in the `Makefile` to handle the compilation of xv6 according to the specified scheduling algorithm done by the flags set by the user. Compilation instructions with the flags have been shown under each of the individual scheduling algorithms.
## Round Robin (RR)
### Implementation
- Nothing was to be changed. Except one in `Makefile` and other in definitions of `yield`.
### Time Analysis

On being run on a single CPU, the data obtained is as follows ➖

- Average run time = 16
- Average wait time = 164

## First Come First Serve ( FCFS )
### Implementation

- A variable `int time_creation` was declared in the `struct proc` data structure under the macro `FCFS` in the file `kernel/proc.h` and initialized in the `static struct proc * allocproc(void)` function in the file `kernel/proc.c` to the value of `ticks` at that moment. It is evident that `ctime` in the same structure can be used to implement this algorithm, but for the sake of separate and independent implementation of the algorithm and to provide a complete and thorough explanation, another separate variable with the same functionality has been declared.


- Under the `void scheduler(void)` function, in the file `kernel/proc.c`, the algorithm, has been implemented under the `FCFS` macro. Firstly, the array `struct proc proc[NPROC]` is being traversed to obtain the process `p_first` with the `min_time_creation` and once found, it is being scheduled as a `RUNNING` process, following which is the context switch, running the process till it no longer needs the CPU time.


- As a non-preemptive scheduler was being implemented, the process must not be preempted and hence, in the functions, `void usertrap(void)` and `void kerneltrap(void)` in the file `kernel/trap.c` the function `yield()` must not be called under the `FCFS` macro, if present.

### Time Analysis

On being run on a single CPU, the data obtained is as follows ➖

- Average run time = 15
- Average wait time = 131

## Multi Level Feedback Queue ( MLFQ )

- The following variables were declared in the `struct proc` data structure, inside the file `kernel/proc.h` and initialized as shown below in the `static proc * allocproc(void)` function in the file `kernel/proc.c`. The variables, in order of their declaration store the current priority queue the process is a part of, the previous priority queue the process was a part of before getting popped, the time the process has waited since it being last scheduled or witnessed a shift of queue and finally the time for which the process has been running since being last scheduled.

```c
#ifdef MLFQ
   p->current_trun = 0;
  p->current_tsun = 0;
  p->qprio=0;
  q_count[0]++;
  p->intime = ticks;
#endif
```
- Under the `void scheduler(void)` function, in the file `kernel/proc.c`, the scheduling algorithm was being written under the macro `MLFQ`. Firstly, we check he array of processes `struct proc proc[NPROC]` for any process that is `RUNNABLE` but not pushed in the queue till this point as scheduling begins here, including both, processes being scheduled for the first time and those who have been scheduled before as well. Further, it is ensured that the queues only have `RUNNABLE` processes and processes which are in the state `ZOMBIE` or `SLEEPING` have been popped out of their queues.
- Now, in the same function, it is checked whether the calling process, if `RUNNING` has exceeded it’s `time-slice` according to the `priority queue` it was popped from. If yes, we would `yield()` it, that is preempt it. The same would also be done if there is some other process in a higher queue than the calling one.
- For all the processes in the `struct proc proc[NPROC]` array, we check if the `time_wait` of any process has exceeded the `aging` time limit set as `30`, if so, we pop it from it’s current queue and push it in a queue with a higher priority if it exists.
- Finally, scheduling is being done by selecting the process lying first in the first non-empty queue with highest priority. On choosing a process, we pop it from it’s existing queue
- In some functions in the file `kernel/proc.c`, a line of code that pushes a process into a priority queue, depending on the nature of the process has been added as they generate new processes in the `RUNNABLE` state.
- Modify the `void update_time()` function in the file `kernel/proc.c` to change the value of the time variables after every CPU tick, as necessary.

### Time Analysis

On being run on a single CPU and aging ticks to be 30, the data obtained is as follows ➖

- Average run time = 16
- Average wait time = 136

### GRAPH
     ![Alt text](https://github.com/serc-courses/mini-project-2-kpiiit/assets/116482611/09db0a01-be55-4e4a-8928-d5cfa07140ec)

>>>>>>> origin

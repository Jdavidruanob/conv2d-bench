#define _GNU_SOURCE
#include <omp.h>
#include <sched.h>
#include <stdio.h>
int main(int c, char**v){ (void)c;(void)v;
 for(int n=4;n<=16;n+=12){
 #pragma omp parallel num_threads(n) proc_bind(spread)
 { cpu_set_t s; sched_getaffinity(0,sizeof s,&s);
   #pragma omp critical
   printf("n=%d hilo %d: cpus permitidas=%d, place=%d, cpu actual=%d\n",n,omp_get_thread_num(),CPU_COUNT(&s),omp_get_place_num(),sched_getcpu()); }}
}

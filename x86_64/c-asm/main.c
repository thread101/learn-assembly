#include <stdio.h>

extern long print_num(long a);

int main(void) {
  for (long i=1; i<1000000000000000000; i*=10) {
    printf("Your number is: ");
    fflush(stdout);
    long len = print_num(i);
    printf(" [len=%ld]\n", len);
  }
  return 0;
}


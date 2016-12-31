#include <stdio.h>
#include "sha512_all.h"
#include <inttypes.h>
#include <stdlib.h>
#include <sys/time.h>

#define INTELSHA 1

#if INTELSHA
#include "../sha512.h"
#endif

#define N (1<<23)

double timeval_diff(const struct timeval * const start, const struct timeval * const end)
{
    /* Calculate the second difference*/
    double r = end->tv_sec - start->tv_sec;

    /* Calculate the microsecond difference */
    if (end->tv_usec > start->tv_usec)
        r += (end->tv_usec - start->tv_usec)/1000000.0;
    else if (end->tv_usec < start->tv_usec)
        r -= (start->tv_usec - end->tv_usec)/1000000.0;

    return r;
}


int main() {
  struct timeval tv_start, tv_end;
  printf("Hello, ispc\n");
  uint64_t *buf = (uint64_t *)malloc(sizeof(uint64_t)*8*N);
  uint64_t data[5];
  for (int i =0; i < 5; i++) { data[i] = 1; }

  gettimeofday(&tv_start, NULL);
  for (int i = 0; i < (1<<23); i += 8) {
    ispc::sha512_ispc(data, (uint64_t *)buf, i);
  }
  gettimeofday(&tv_end, NULL);
  printf("dga:   %.3f\n", timeval_diff(&tv_start, &tv_end));

#if INTELSHA
  Init_SHA512_sse4();

  SHA512_Context c512;
  SHA512_Init(&c512);
  gettimeofday(&tv_start, NULL);

  for (int i = 0; i < (1<<23); i++) {
    SHA512_Final_Shift(&c512, i, (uint8_t *)buf);
  }
  gettimeofday(&tv_end, NULL);
  printf("intel: %.3f\n", timeval_diff(&tv_start, &tv_end));
#endif

}

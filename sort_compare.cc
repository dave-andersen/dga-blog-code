// Quick benchmark comparison of inlined 4-element sorting network
// vs std::sort.
// compile with: g++ --std=c++11 -O3 sort_compare.cc -o sort_compare
// Copyright (C) 2016 David G. Andersen.
// Apache licensed, see LICENSE file.

#include <sys/types.h>
#include <sys/time.h>
#include <inttypes.h>
#include <stdio.h>
#include <algorithm>
#include <iterator>

constexpr int WARMUP_ITERS = 1000;
constexpr int EVAL_ITERS = 200000000;
constexpr int NUM_TAGS = 4;


// Benchmark function 1 - the inlined version.  Note that both
// benchmark functions return the value of the last tag;  we use
// this to discourage the compiler from optimizing away all of this
// useless work.

inline void SortPair(uint32_t& a, uint32_t& b) {
  if ((a & 0x0f) > (b & 0x0f)) {
    std::swap(a, b);
  }
}

inline int32_t SortTags(uint32_t tags[4]) {
  SortPair(tags[0], tags[2]);
  SortPair(tags[1], tags[3]);
  SortPair(tags[0], tags[1]);
  SortPair(tags[2], tags[3]);
  SortPair(tags[1], tags[2]);
  return tags[3];
}

// STL version.
inline int32_t STLSortTags(uint32_t (&tags)[4]) {
  std::sort(std::begin(tags), std::end(tags), [](uint32_t a, uint32_t b) {
      return (a & 0xf) < (b & 0xf);
    });
  return tags[3];
}

// Quick hack LCRNG to seed tags.  We seed the tags randomly each
// time so that the benchmark isn't getting excess benefit from
// the branch predictor, which might change the results.  This
// isn't designed to be strong, it's designed to be fast and
// just good enough that the compiler doesn't invalidate our results.
uint64_t state = 1234567u;

inline void randomizeTags(uint32_t tags[NUM_TAGS]) {
  uint64_t old = state;
  tags[0] = state >> 4;
  tags[1] = state >> 16;
  tags[2] = state >> 24;
  tags[3] = state >> 32;
  state = state * 6364136223846793005ULL + 7;
}

void print_timing(const struct timeval *tv_start, const struct timeval *tv_end,
		  const char *name, int32_t sum) {
  int64_t usec = (tv_end->tv_sec - tv_start->tv_sec) * 1000000 +
    (tv_end->tv_usec - tv_start->tv_usec);
  float sec = (float)usec/1000000.0;
  printf("%s : %.2f seconds\n", name, sec);
  if (sum == 0) {
    printf("Hey, neat coincidence, sum is zero\n");
  }
}

#define BENCHMARK(f, name) do { \
  struct timeval tv_start, tv_end;	   \
  int32_t sum = 0;			   \
  for (int i = 0; i < WARMUP_ITERS; i++) { \
    randomizeTags(tags);		   \
    f;					   \
  }					   \
  gettimeofday(&tv_start, NULL);	   \
  for (int i = 0; i < EVAL_ITERS; i++) {   \
    randomizeTags(tags);		   \
    sum += f;				   \
  }					   \
  gettimeofday(&tv_end, NULL);		   \
  print_timing(&tv_start, &tv_end, name, sum); \
  } while(0)


int main() {
  uint32_t tags[4];
  
  BENCHMARK(SortTags(tags), "fully inlined");
  BENCHMARK(STLSortTags(tags), "STL sort");
}

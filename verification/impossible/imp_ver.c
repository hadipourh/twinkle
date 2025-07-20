#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <math.h>

/* /1* for 64 bit version *1/ */
/* #define ROUNDS 5 */

/* for 128 bit version */
// #define ROUNDS 9.5

/* /1* for 256 bit version *1/ */
/* #define ROUNDS 18.5 */

#include "my_lib.h"
#include "rc.h"
#include "oracle.h"

#include "input.c"

#define STATE_SIZE (16*128)

int main() {

	srand(time(NULL));
	
	clock_t clock_timer;
	clock_timer = clock();
	
	uint64_t N1 = 1ULL << DEG; // Number of queries:  N1 = 2^(DEG)
	unsigned int initial_seed;
	
	/// Prepare input diff and output mask
	uint64_t *id = mem_alloc(STATE_SIZE);
	str_to_random_state(inputDiff,id);

	uint64_t *od = mem_alloc(STATE_SIZE);
	str_to_random_state(outputDiff, od);
	
	for(int expNum = 0; expNum < totalExps; expNum++) {
		uint64_t sum = 0;
		uint64_t *state1 = mem_alloc(STATE_SIZE);
		uint64_t *state2 = mem_alloc(STATE_SIZE);
		uint64_t *key    = mem_alloc(STATE_SIZE);
		uint64_t *out_xr = mem_alloc(STATE_SIZE);
		
		initial_seed = init_prng(((unsigned int)rand() << 16) | rand());
		printf("Exp No. %d \t Initial seed: 0x%X\n", expNum+1, initial_seed);
		rand_state(key); 
		
		for(uint64_t loopCount = 0; loopCount < N1; loopCount++) {
			rand_state(state1);
			copy(state2, state1, STATE_SIZE);
			xr(state2, id, STATE_SIZE);
			oracle(state1, key,ROUNDS);
			oracle(state2, key,ROUNDS);

			copy(out_xr, state1, STATE_SIZE);
			xr(out_xr, state2, STATE_SIZE);

			if (check_eq(out_xr, od, STATE_SIZE) == 1) {
				sum += 1;
			}
		}

		printf("\nNumber of times the impossible difference got satisfied = %ld\n", sum);
		printf("%s: %0.4f\n", "time on clock", (double)(clock() - clock_timer) / CLOCKS_PER_SEC);
		printf("#############################################################\n\n\n");

		free(state1);
		free(state2);
		free(key);
		free(out_xr);
	}
//	printf("#############################################################\n");	
	
	return 0;

}

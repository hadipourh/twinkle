#include <stdio.h>
#include<stdlib.h>
#include<stdint.h>
#include<time.h>
#include<math.h>

/* /1* for 64 bit version *1/ */
/* #define ROUNDS 5 */

/* for 128 bit version */
// #define ROUNDS 9.5

/* /1* for 256 bit version *1/ */
/* #define ROUNDS 18.5 */

#include "../twinkle/my_lib.h"
#include "../twinkle/rc.h"
#include "../twinkle/oracle.h"

#include "input.c"




#define STATE_SIZE (16*128)




int main(){

    


    srand(time(NULL));

    clock_t clock_timer;
    clock_timer = clock();

    uint64_t N1 = 1ULL << DEG; // Number of queries:  N1 = 2^(DEG)
	uint64_t CORR;
	uint64_t sum = 0;
    unsigned int initial_seed;


    /// Prepare input diff and output mask
    uint64_t *id=mem_alloc(STATE_SIZE);
    str_to_state(inputDiff,id);
    uint64_t *outMask = mem_alloc(16*128);
    str_to_state(outMaskString, outMask);

    for(int expNum=0;expNum<totalExps;expNum++){
        double corr_log = 0;
		uint64_t counter0 = 0ULL;
		uint64_t counter1 = 0ULL; 
        uint64_t *state1 = mem_alloc(16*128);
        uint64_t *state2 = mem_alloc(16*128);
        uint64_t *key = mem_alloc(16*128);

        initial_seed = init_prng(((unsigned int)rand() << 16) | rand());
        printf("Exp No. %d \t Initial seed: 0x%X\n", expNum+1, initial_seed);
        rand_state(key); 

        for(uint64_t loopCount=0;loopCount<N1;loopCount++){
            rand_state(state1);
            copy(state2,state1,STATE_SIZE);
            xr(state2,id,STATE_SIZE);
            oracle( state1, key,ROUNDS);
            oracle( state2, key,ROUNDS);
            if(dotProd(state1,outMask,STATE_SIZE) == dotProd(state2,outMask,STATE_SIZE)){
                counter0+=1;
            }
            else{
                counter1+=1;
            } 
        }
        if (counter0 > counter1) {
            CORR = counter0 - counter1;
            printf("Sign: +\n");
        } else {
            CORR = counter1 - counter0;
            printf("Sign: -\n");
        }
        
        printf("counter0 - counter1: %lld\n", (unsigned long long)(counter0-counter1));
        printf("%s: %0.4f\n", "time on clock", (double)(clock() - clock_timer) / CLOCKS_PER_SEC);
        corr_log = (log(CORR) / log(2)) - DEG;
        printf("Correlation = %c2^(%0.2f)\n", (counter0 > counter1) ? '+' : '-', corr_log);
        printf("#############################################################\n\n\n");
        sum += CORR;
    }
    double corr = 0;
	corr = ((log(sum) - log(totalExps)) / log(2)) - DEG;
	printf("Average magnitude of correlation: 2^(%0.2f)\n", corr);
	printf("#############################################################\n");	

    return 0;

}

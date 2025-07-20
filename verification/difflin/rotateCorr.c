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


#define NUM_STRINGS 16
#define STR_LEN 80  

void printMultipleCrosses(int size, int count);
void rightRotateBinaryStrings(const char *inputDiff[NUM_STRINGS], char *resArray[NUM_STRINGS], int rotIndex);



int main(){

    srand(time(NULL));

    clock_t clock_timer;
    clock_timer = clock();

    uint64_t N1 = 1ULL << DEG; // Number of queries:  N1 = 2^(DEG)
    unsigned int initial_seed;

    double avgCorrArr[80];

    for (int rotIndex = 0; rotIndex < 80; rotIndex++){
        char *resInputDiff[16];
        char *resOutMask[16];

        rightRotateBinaryStrings(inputDiff, resInputDiff, rotIndex);
        rightRotateBinaryStrings(outMaskString, resOutMask, rotIndex);
        

        /// Prepare input diff and output mask
        uint64_t *id=mem_alloc(STATE_SIZE);
        str_to_state(resInputDiff,id);
        uint64_t *outMask = mem_alloc(16*128);
        str_to_state(resOutMask, outMask);

        //print varous rotated input differentials
        // print_lane("Rot\n",id);

        //print varous rotated outputMask
        // print_lane("Rot\n",outMask);

        uint64_t CORR;
        uint64_t sum = 0;

        printf("##########################################################################################################################\n");
        printf("Rotation Index: %d\n", rotIndex);	
        printf("#############################################################\n");

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
            if (counter0 > counter1)
                CORR = counter0 - counter1;
            else
                CORR = counter1 - counter0;
            
            printf("Counter0-counter1: %lld\n", (unsigned long long)(counter0-counter1));
            printf("%s: %0.4f\n", "time on clock", (double)(clock() - clock_timer) / CLOCKS_PER_SEC);
            corr_log = (log(CORR) / log(2)) - DEG;
            printf("Correlation = 2^(%0.2f)\n", corr_log);
            printf("#############################################################\n\n");
            sum += CORR;
        }
        double corr = 0;
        corr = ((log(sum) - log(totalExps)) / log(2)) - DEG;
        printf("Average correlation: 2^(%0.2f)\n", corr);
        avgCorrArr[rotIndex]=corr;
        printf("##########################################################################################################################\n");	
        printMultipleCrosses(3, 25);
    }
    
    //print avg correlation for various rotation indexes
    // ptintf("\n\nAverage Correlations\n\n");
    printf("\n\nRotation Index: \t Avg. Correlation\n\n");
    for(int i=0;i<80;i++){
        printf("\t%d\t\t\t2^(%0.2f)\n",i, avgCorrArr[i]);
    }


    return 0;
}


void printMultipleCrosses(int size, int count) {
    if (size < 3 || size % 2 == 0) {
        printf("Size must be an odd number >= 3.\n");
        return;
    }

    for (int i = 0; i < size; ++i) {
        for (int c = 0; c < count; ++c) {
            for (int j = 0; j < size; ++j) {
                if (j == i || j == size - 1 - i)
                    printf("*");
                else
                    printf(" ");
            }
            printf("  "); // space between crosses
        }
        printf("\n");
    }
}

void rightRotateBinaryStrings(const char *inputDiff[NUM_STRINGS], char *resArray[NUM_STRINGS], int rotIndex) {
    for (int i = 0; i < NUM_STRINGS; ++i) {
        resArray[i] = malloc((STR_LEN) * sizeof(char));
        int len = strlen(inputDiff[i]);
        rotIndex = rotIndex % len;  // Ensure rotation is within bounds


        // printf("len=%d\n",len);

        // Perform left rotation
        for (int j = 0; j < len; ++j) {
            resArray[i][j] = inputDiff[i][(j + rotIndex) % len];
        }
        // resArray[i][len] = '\0';  // Null-terminate the string
    }
}
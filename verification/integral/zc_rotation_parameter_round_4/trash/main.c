/* gist: Integral distinguisher for 4 rounds given in code/zc-sat/results/twinkle_zc_4r_v0.pdf */
/* ------------------------------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#define ROUNDS 4
#define TIMES 1000

#define STATE_SIZE (16*128)

#include "my_lib.h"
#include "rc.h"
#include "oracle.h"

int main(){
    srand(time(NULL));

    /* output mask */
    uint64_t *out_mask = mem_alloc(STATE_SIZE);
    const char *binary_out_mask[16] ={
        "00100010000001001000000000000000000100100000000001001000000010000100000000000001",
        "00000000000000000000000001000000000000000100000000000100001000010000001010000010",
        "00000000100000000000000010010000000000000001001000000000000010000000000100000010",
        "00010000000000010000000000000001100000001000000000000000000010000001000000000000",
        "00010010001000001000010000000010000001010000000000000100000000000000000000000000",
        "10000000000000000001001000100000010010000001000000000001001000000000010000000000",
        "00000000000000100000000000000000000000010100000010001000000000100000000000000000",
        "00000000000100100000000000001000000000010000000000000000000000000000000010010000",
        "00000000000000011100000000000001000000000000110001000000000001011000110000000000",
        "00000000010000000000001000000000000010000000000000000000000000000000000000000000",
        "00000000000000011001000010000001000000000000101000010000000000000001000000000001",
        "00000010000000000100000000000000000000000000000000000000000000000000000000001000",
        "01001000110000010010000000000000000001001010000000010010100000100000000000000000",
        "00000000000000001000000000100010000000000000000000000000010100000000000001000000",
        "00000000001100000000000000010000000000010001001000000001100000101100000000000001",
        "00000000000000000010000000000000000000010000000000000000000000001010000000000000"
    };
    str_to_state(binary_out_mask, out_mask);

    for (uint32_t y=0; y<4; y++){
        for (uint32_t z=0; z<80; z++){
            /* taking all bit positions in the specific bits */
            uint16_t all_bits[] = {(4*y)*80 +z, (4*y +1)*80 +z, (4*y +2)*80 +z, (4*y +3)*80 +z};

            uint32_t cnt =0;

            uint64_t *or_state = mem_alloc(STATE_SIZE);
            for (int i=0; i<TIMES; i++){
                /* initializing state, fstate and key */
                uint64_t *state = mem_alloc(STATE_SIZE);
                uint64_t *fstate = mem_alloc(STATE_SIZE);
                uint64_t *key = mem_alloc(STATE_SIZE);

                /* randomly allocating state and key */
                rand_state(state);
                rand_state(key);

                /* output difference */
                uint64_t *out_diff = mem_alloc(STATE_SIZE);

                for (uint64_t i=0; i<16; i++){
                    /* making diff by putting All possible values in all_bits[] positions */
                    uint64_t *diff =mem_alloc(STATE_SIZE);
                    for (uint16_t idx=0; idx<4; idx++){
                        uint64_t cell =all_bits[idx]/80;
                        uint64_t bit =all_bits[idx]%80;

                        if (bit<64){
                            diff[2*cell +1] ^= (uint64_t)((i>>idx)&1) <<bit;
                        }
                        else{
                            diff[2*cell] ^= (uint64_t)((i>>idx)&1) <<(bit-64);
                        }
                    }

                    /* making s' */
                    uint64_t *tmp_s =mem_alloc(STATE_SIZE);
                    copy(tmp_s, state, STATE_SIZE);
                    xr(tmp_s, diff, STATE_SIZE);

                    /* calling oracle */
                    oracle(tmp_s, key);

                    xr(out_diff, tmp_s, STATE_SIZE);
                }

                OR(or_state, out_diff, STATE_SIZE);
            }

            lane_rot_right(out_mask, 1);
            if (eq_state(or_state, out_mask) ==1){
                printf("\n")
            }

        }
    }

    /* printing value */
    print_lane_binary("or state:", or_state);
    printf("\n");
}

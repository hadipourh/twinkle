/* If the print details is true then only all the state values will print */
char *print_details = "false";
/* char *print_details = "true"; */



/* anf of twinkle sbox */
/* y0 = x0 + x1 + x1x0 + x2x1 + x3 */
/* y1 = x0 + x1x0 + x2 + x2x0 + x3 + x3x2x1 */
/* y2 = x1 + x2 + x3x0 + x3x2 */
/* y3 = x1x0 + x2x0 + x2x1 + x3 + x3x0 + x3x1x0 */

/* Authors are seeing down-right most bit as 0 in a slice like s3s2s1s0 (its the last row). */
/* at the time of applying sbox, they rearrange the bits of a row in s0s1s2s3. Then apply sbox. */
/* Here we permute x_i's and y_i's, and then apply twinkle sbox: */
#define sb(x3, x2, x1, x0, y3, y2, y1, y0)\
    (y3) = (x3) ^ (x2) ^ (x2)&(x3) ^ (x1)&(x2) ^ (x0);\
    (y2) = (x3) ^ (x2)&(x3) ^ (x1) ^ (x1)&(x3) ^ (x0) ^ (x0)&(x1)&(x2);\
    (y1) = (x2) ^ (x1) ^ (x0)&(x3) ^ (x0)&(x1);\
    (y0) = (x2)&(x3) ^ (x1)&(x3) ^ (x1)&(x2) ^ (x0) ^ (x0)&(x3) ^ (x0)&(x2)&(x3);

void sbox(uint64_t *s){
    uint64_t *tmp_s = mem_alloc(16*128);

    /* applying the sbox anf wise */
    for (uint16_t row=0; row<4; row++){
        /* applying sbox on most significant 16 bits */
        sb(s[8*row +2*3], s[8*row +2*2], s[8*row +2*1], s[8*row +2*0],
            tmp_s[8*row +2*3], tmp_s[8*row +2*2], tmp_s[8*row +2*1], tmp_s[8*row +2*0]);

        /* applying sbox on least significant 64 bits */
        sb(s[8*row +2*3 +1], s[8*row +2*2 +1], s[8*row +2*1 +1], s[8*row +2*0 +1],
            tmp_s[8*row +2*3 +1], tmp_s[8*row +2*2 +1], tmp_s[8*row +2*1 +1], tmp_s[8*row +2*0 +1]);
    }

    copy(s, tmp_s, 16*128);
    free(tmp_s);

    /* printing */
    if (print_details == "true"){
        print_lane("sbox: ", s);
    }
}


void lr(uint64_t *state, uint8_t lane_num){
    /* lane rotation offsets */
    uint16_t o0[16] = {20, 24, 38, 77, 49, 66, 30, 40, 76, 15, 46, 50, 17, 18, 61, 62};
    uint16_t o1[16] = {63, 45, 34, 39, 32, 43, 60, 66, 54, 26, 55, 36, 61, 12, 15, 35};

    for (uint16_t x=0; x<16; x++){
        /* lane rotation_0 */
        if (lane_num == 0){
            circ_shift_right(state + (2*x), o0[x]); 
        }

        /* lane rotation_1 */
        else{
            circ_shift_right(state + (2*x), o1[x]); 
        }
    }

    /* printing */
    if (print_details == "true"){
        print_lane("\nlr: ", state);
    }
}

void ms(uint64_t *s){
    uint64_t *tmp_s = mem_alloc(16*128);

    /* doing mixslice for each lane */
    for (uint16_t cell=0; cell<16; cell++){
        tmp_s[2*cell] = s[2*cell] ^ s[2*((cell+11)%16)] ^ s[2*((cell+4)%16)];
        tmp_s[2*cell +1] = s[2*cell +1] ^ s[2*((cell+11)%16) +1] ^ s[2*((cell+4)%16) +1];
    }

    copy(s, tmp_s, 16*128);
    free(tmp_s);

    if (print_details == "true"){
        print_lane("\nmixslice: ", s);
    }
}

void oracle( uint64_t *state, uint64_t *key,float ROUNDS){

    xr(state, key, 16*128);
    if (print_details == "true"){
        print_lane("\nkey pre-whitening: ", state);
    }

    /* loading rc from 1d array */
    uint64_t *rc = mem_alloc(18*16*128);
    load_rc_1d(rc);

    for (uint16_t rnd=0; rnd< (int)ROUNDS; rnd++){
        if (print_details == "true"){
            printf("\n\n-------------------------------------------------");
            printf("\nround %d:", rnd);
            printf("\n-------------------------------------------------");
        }

        sbox(state);
        lr(state, 0);
        ms(state);
        lr(state, 1);

        xr(state, rc+ 32*rnd, 16*128);
        if (print_details == "true"){
            print_lane("\nafter rc: ", state);
        }
    }

    /* for half round */
    if (ROUNDS != (int)ROUNDS){
        if (print_details == "true"){
            printf("\n\n-------------------------------------------------");
            printf("\nHalf round:");
            printf("\n-------------------------------------------------");
        }

        sbox(state);
        lr(state, 0);
    }

    free(rc);
}

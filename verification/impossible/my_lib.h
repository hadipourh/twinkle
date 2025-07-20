/* gist: The functions works on the chunks of 64-bit memory. */
/* ----------------------------------------------------------------------------------------- */
#include <string.h>
#include <sys/random.h>

/* allocate the memory of 64-bit chunks */
#define mem_alloc(size) ((uint64_t*)calloc((size)/64, sizeof(uint64_t)))

/* this creates the random msg of the given size */
void rand_alloc(uint64_t *msg, uint32_t size){
    for (uint16_t i=0; i<(size/64); i++){
        msg[i] = rand();
        msg[i] = (msg[i]<<32)|(rand()&0xffffffff);
    }
}   

void rand_state(uint64_t *msg){                                                                     
    for (uint16_t i=0; i<16; i++){                                                                  
        msg[2*i] = rand()&0xffff;                                                                   
        msg[2*i +1] = rand();    msg[2*i +1] = (msg[2*i +1]<<32)|(rand()&0xffffffff);               
    }
}

/* copy y to x */
void copy(uint64_t *x, uint64_t *y, uint32_t size){    
    for (uint8_t i=0; i<(size/64); i++){
        x[i] = y[i];
    }
}   

/* printing slice wise from 1280 bit state */
/* Note: This print whole 1280 bit of the state */
void print(char* str, uint64_t *state){
    printf("\n%s", str);

    for (int16_t z=0; z<80; z++){
        uint16_t slice =0;

        for (uint8_t i=0; i<16; i++){
            /* for most significant 16 bits */
            if (z< 16){
                slice ^= ((state[2*i] >> (15-z))&1) <<i;
            }

            /* for least significant 64 bits */
            else{
                slice ^= ((state[2*i +1] >> (79-z))&1) <<i;
            }
        }
        printf("%04x ", slice);
    }
    printf("\n");
}

/* printing least 1152 bits of the state */
void print_out(char* str, uint64_t *state){
    printf("\n%s", str);

    /* printing least significant 1152 bits */
    for (int16_t z=8; z<80; z++){
        uint16_t slice =0;

        for (uint8_t i=0; i<16; i++){
            /* for most significant 16 bits */
            if (z< 16){
                slice ^= ((state[2*i] >> (15-z))&1) <<i;
            }

            /* for least significant 64 bits */
            else{
                slice ^= ((state[2*i +1] >> (79-z))&1) <<i;
            }
        }
        printf("%04x ", slice);
    }
}


/* printing lanewise from 0 - 16 */
void print_lane(char* str, uint64_t *state){
    printf("\n%s", str);

    for (uint8_t i=0; i<16; i++){
        printf("\n%04lx %016lx", state[2*i], state[2*i +1]);
    }
}

/* circular shifting within 80 bits */
void circ_shift_right(uint64_t *msg, uint16_t pos){
    if (pos <16){
        uint64_t tmp = msg[1];
        msg[1] = (msg[1] >>pos) | (msg[0] <<(64-pos));
        msg[0] = ((msg[0] >>pos) | (tmp <<(16-pos)))&0xffff;
    }

    else if (pos == 16){
        uint64_t tmp = msg[1];
        msg[1] = (msg[1] >>pos) | (msg[0] <<(64-pos));
        msg[0] = (tmp >>(pos-16))&0xffff;
    }

    else if (pos <64){
        uint64_t tmp = msg[1];
        msg[1] = (msg[1] >>pos) | (msg[0] <<(64-pos)) | (msg[1] <<(16+64-pos));
        msg[0] = (tmp >>(pos-16))&0xffff;
    }

    else{
        /* left shift by (pos-16) */
        uint64_t tmp = msg[1];
        msg[1] = (msg[1] <<(80-pos)) | (msg[0] >>(16-(80-pos)));
        msg[0] = ((msg[0] << (80-pos)) | (tmp >>(64-(80-pos))))&0xffff;
    }
}

/* xor of a, b (depending upon the size) and keep that in a */
void xr(uint64_t *a, uint64_t *b, uint32_t size){
    for (uint8_t i=0; i<(size/64); i++){
        a[i] ^= b[i];
    }
}


/* AND of a, b (depending upon the size) and keep that in a */
void and(uint64_t *a, uint64_t *b, uint32_t size){
    for (uint8_t i=0; i<(size/64); i++){
        a[i] &= b[i];
    }
}

/* and of a, b (depending upon the size) and keep that in a */
uint8_t dot(uint64_t *a, uint32_t size){
    uint64_t cnt=0;

    for (uint32_t i=0; i<size; i++){
        cnt += (a[i/64]>>(i%64))&1;
    }
    return (cnt&1);
}

/* Dot product of a, b (depending upon the size) and keep that in a */
uint8_t dotProd(uint64_t *a, uint64_t *b, uint32_t size){
    and(a,b,size);
    return dot(a,size);
}


/* insert 128-bit in x */
void insert128(uint64_t *x, uint64_t msb, uint64_t lsb){    
    x[0] = msb; x[1] = lsb;
}   

void _1d_to_lane_wise(uint64_t *rc, uint16_t *rc_1d){
    for (int16_t z=0; z<80; z++){
        for (uint8_t i=0; i<16; i++){
            /* for least significant 64 bits */
            if (z <64){
                rc[2*i +1] ^= (((uint64_t)rc_1d[79-z] >>i)&1) <<z;
            }

            /* for most significant 16 bits */
            else{
                rc[2*i] ^= ((((uint64_t)rc_1d[79-z] >>i)&1) <<(z-64));
            }
        }
    }
}


void bitstring_to_state(const char *bitstring, uint64_t *state1) {
    for (int i = 0; i < 16; ++i) {
        uint64_t lane_high = 0; // Leftmost 16 bits
        uint64_t lane_low = 0;  // Remaining 64 bits

        // Start index of this lane in the bitstring
        int start = i * 80;

        // First 16 bits → lane_high
        for (int j = 0; j < 16; ++j) {
            lane_high <<= 1;
            if (bitstring[start + j] == '1') {
                lane_high |= 1;
            }
        }

        // Remaining 64 bits → lane_low
        for (int j = 16; j < 80; ++j) {
            lane_low <<= 1;
            if (bitstring[start + j] == '1') {
                lane_low |= 1;
            }
        }

        state1[2 * i] = lane_high;
        state1[2 * i + 1] = lane_low;
    }
}

//----------------------------------
// Init PRNG
//----------------------------------

unsigned int init_prng(unsigned int offset) {
    unsigned int initial_seed = 0;
    ssize_t temp;
    temp = getrandom(&initial_seed, sizeof(initial_seed), 0);
    //temp=5;
    if (temp == -1) perror("error!");
    initial_seed += offset;
    // srand(initial_seed);
    // srand(time(NULL));
	printf("[+] PRNG initialized to 0x%08X\n", initial_seed);
    return initial_seed;
}


void str_to_state(const char **binary, uint64_t *state) {
    for (int i = 0; i < 16; i++) {
        // First 64 bits
        for (int j = 63; j >=0; j--) {
            state[2*i +1] <<= 1;
            if (binary[i][j] == '1') {
                state[2*i +1] |= 1;
            }
        }

        // Remaining 16 bits
        for (int j = 79; j >= 64; j--) {
            state[2*i] <<= 1;
            if (binary[i][j] == '1') {
                state[2*i] |= 1;
            }
        }
    }
}



/* printing lanewise from 0 - 16 in binary */
/* printing according to the trail of pdf */
void print_lane_binary(char* str, uint64_t *state){
    printf("\n\n%s", str);

    for (uint8_t i=0; i<16; i++){
        printf("\n");
        for (int16_t bit=0; bit<80; bit++){
            uint64_t tmp;
            /* taking the bit */
            if (bit <64){
                tmp = (state[2*i +1]>>bit)&1;
            }
            else{
                tmp = (state[2*i]>>(bit-64))&1;
            }

            /* if bit == 0, print 0, else print ? */
            if (tmp == 0){
                printf("0");
            }
            else{
                printf("1");
            }
        }
    }

    free(state);
}

/* Check if x is equal to y */
uint8_t check_eq(uint64_t *x, uint64_t *y, uint32_t size) {
	uint8_t eq = 1;
	for (uint8_t i = 0; i < (size / 64); i++) {
		if (x[i] != y[i]) {
			eq = 0;
		}
	}
	return eq;
}

/* Randomly fixes a value to the non-fixed bits while keeping the same value for the fixed bits */
void str_to_random_state(const char **binary, uint64_t *state) {
	for (int i = 0; i < 16; i++) {
		// First 64 bits
		for (int j = 63; j >= 0; j--) {
			state[2 * i + 1] <<= 1;
			if (binary[i][j] == '1') {
				state[2 * i + 1] |= 1;
			} else if (binary[i][j] == '?') {
				state[2 * i + 1] |= (rand() % 2);
			}
		}
		// Remaining 16 bits
		for (int j = 79; j >= 64; j--) {
			state[2 * i] <<= 1;
			if (binary[i][j] == '1') {
				state[2 * i] |= 1;
			} else if (binary[i][j] == '?') {
				state[2 * i] |= (rand() % 2);
			}
		}
	}
}

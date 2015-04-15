#include <io.h>
#include <stdlib.h>
#include <sys/alt_stdio.h>
#include <system.h>

#define ARRAY_SIZE (100)
#if ARRAY_SIZE <= 10
#define SMALL_ARRAY
#endif

long array_for_c[ARRAY_SIZE];
long array_for_custom_instr[ARRAY_SIZE];
volatile long array_for_accelerator[ARRAY_SIZE];

void* cache_bypass(volatile void* addr)
{
	return (void*) ((1 << 31) | (long) (addr));
}

void fill_arrays_with_random_values(void)
{
    int i = 0;
    for (i = 0; i < ARRAY_SIZE; ++i) {
        long rand_value = 0x12345678;
        array_for_c[i] = rand_value;
        array_for_custom_instr[i] = rand_value;
        ((long*)cache_bypass(array_for_accelerator))[i] = rand_value;
    }
}

void verify_arrays(void)
{
    int i = 0;
    for (i = 0; i < ARRAY_SIZE; ++i) {
        if (array_for_c[i] != array_for_custom_instr[i]
                || array_for_custom_instr[i] != ((long*)cache_bypass(array_for_accelerator))[i]) {
            alt_printf("Verification failed for index 0x%x: 0x%x, 0x%x, 0x%x",
                    i, array_for_c[i], array_for_custom_instr[i],
                    array_for_accelerator[i]);
            while (1)
                ;
        }
    }

    alt_putstr("Verifying OK\n");
}

void shuffle_in_c(long* array, int size)
{

    int i = 0;
    for (i = 0; i < size; i++) {

        long result = 0;
        long MSB = ((array[i] & 0xFF000000) >> 24) & 0xFF;
        long LSB = (array[i] & 0x000000FF);

        int j = 0;
        for (j = 8; j < 16; ++j) {
            long tmp = (array[i] & (0x1 << (31 - j))) >> (31 - j);
            long bit = (array[i] & (0x1 << j)) >> (j);
            result |= (bit << (31 - j)) | (tmp << j);
        }

        result |= (LSB << 24) | MSB;
        array[i] = result;
    }

}

void shuffle_with_custom_instruction(long* array, int size)
{

    int i = 0;
    for (i = 0; i < size; i++) {
        array[i] = ALT_CI_SHUFFLE_0(array[i]);
    }

}

void shuffle_with_accelerator(volatile long* array, int size)
{
    // Set Start address and array size
    IOWR_32DIRECT(ACCELERATOR_0_BASE, 0x0, (long ) array);
    IOWR_32DIRECT(ACCELERATOR_0_BASE, 0x4, ARRAY_SIZE);

    // Start
    IOWR_32DIRECT(ACCELERATOR_0_BASE, 0x8, 1);

    // Wait for Done
    while (IORD_32DIRECT(ACCELERATOR_0_BASE, 0xC) != 1) {
        alt_putstr("Waiting for accelerator\n");
    }

}

void print_array(volatile long* array, int size)
{

    int i = 0;
    for (i = 0; i < size; ++i) {
        alt_printf("0x%x ", array[i]);
    }

    alt_putstr("\n");

}

int main(void)
{
    alt_putstr("Hello from Nios II!\n");

    fill_arrays_with_random_values();

    shuffle_in_c(array_for_c, ARRAY_SIZE);
    shuffle_with_custom_instruction(array_for_custom_instr, ARRAY_SIZE);
    shuffle_with_accelerator(array_for_accelerator, ARRAY_SIZE);

    verify_arrays();

#ifdef SMALL_ARRAY
    alt_putstr("Shuffle with C:\t\t\t");
    print_array(array_for_c, ARRAY_SIZE);
    alt_putstr("Shuffle with custom instruction:\t");
    print_array(array_for_custom_instr, ARRAY_SIZE);
    alt_putstr("Shuffle with accelerator:\t\t");
    print_array(cache_bypass(array_for_accelerator), ARRAY_SIZE);
#endif

    return 0;
}

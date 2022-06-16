#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"

#include "headers/hps_0.h"

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

#define WGT_ROWS 2
#define WGT_COLS 2
#define INPT_ROWS 9
#define INPT_COLS 9

int main() {
	
	// Debug, show code is executing
	printf("Executing Actual Project main.c\nBuild ID: %d", 1);
	
	// Map the address space for the entire CSR span of the HPS since we want to access various registers within that span
	int fd;
	void *virtual_base;
	
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}
	
	virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );

	if( virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	printf("\nvirtual_base: 0x%08x\n", (unsigned int)virtual_base);
		
	printf("HW_REGS_BASE: 0x%08x\n", (unsigned int)ALT_STM_OFST);
	printf("ALT_LWFPGASLVS_OFST: 0x%08x\n", (unsigned int)ALT_LWFPGASLVS_OFST);
	
	// Virtual address to get Qsys System ID
	void * hwp_lw_qsys_id;
	hwp_lw_qsys_id = virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + SYSID_QSYS_BASE ) & ( unsigned long)( HW_REGS_MASK ) );	
	printf("QSYS SYS ID: %d\n", *(unsigned int*)hwp_lw_qsys_id);

	// Virtual address to access LEDs
	void * h2p_lw_led_addr;
	h2p_lw_led_addr = virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + LED_PIO_BASE ) & ( unsigned long)( HW_REGS_MASK ) );
	printf("h2p_lw_led_addr: 0x%08x\n", (unsigned int)h2p_lw_led_addr);

	// Create virtual address to access KEYS on board
	void * h2p_lw_keys_addr;
	h2p_lw_keys_addr = virtual_base + ( (unsigned long)(ALT_LWFPGASLVS_OFST + BUTTON_PIO_BASE) & (unsigned long)(HW_REGS_MASK) );
	printf("h2p_lw_keys_addr: 0x%08x\n", (unsigned int)h2p_lw_keys_addr);

	// Create virtual address to access DIPSWITCHES on board
	void * h2p_lw_dipsw_addr;
	h2p_lw_dipsw_addr = virtual_base + ( (unsigned long)(ALT_LWFPGASLVS_OFST + DIPSW_PIO_BASE) & (unsigned long)(HW_REGS_MASK) );
	printf("h2p_lw_dipsw_addr: 0x%08x\n", (unsigned int)h2p_lw_dipsw_addr);

	// Create virtual address to access custom IP on board
	void * h2p_lw_simple_inc_addr;
	h2p_lw_simple_inc_addr = virtual_base + ( (unsigned long)(ALT_LWFPGASLVS_OFST + SIMPLE_INC_0_BASE) & (unsigned long)(HW_REGS_MASK) );
	printf("h2p_lw_simple_inc_addr: 0x%08x\n", (unsigned int)h2p_lw_simple_inc_addr);
	
	// CONV_ACCEL addresses
	void * ca_weight_addr;
	ca_weight_addr = virtual_base + ( (unsigned long)(ALT_LWFPGASLVS_OFST + CONV_ACCEL_0_WEIGHT_SLAVE_BASE) & (unsigned long)(HW_REGS_MASK) );
	printf("ca_weight_addr: 0x%08x\n", (unsigned int)ca_weight_addr);
	void * ca_output_addr;
	ca_output_addr = virtual_base + ( (unsigned long)(ALT_LWFPGASLVS_OFST + CONV_ACCEL_0_OUTPUT_SLAVE_BASE) & (unsigned long)(HW_REGS_MASK) );
	printf("ca_output_addr: 0x%08x\n", (unsigned int)ca_output_addr);
	void * ca_feat_map_addr;
	ca_feat_map_addr = virtual_base + ( (unsigned long)(ALT_LWFPGASLVS_OFST + CONV_ACCEL_0_FEAT_MAP_IN_SLAVE_BASE) & (unsigned long)(HW_REGS_MASK) );
	printf("ca_feat_map_addr: 0x%08x\n", (unsigned int)ca_feat_map_addr);
	void * ca_control_addr;
	ca_control_addr = virtual_base + ( (unsigned long)(ALT_LWFPGASLVS_OFST + CONV_ACCEL_0_CONTROL_SLAVE_BASE) & (unsigned long)(HW_REGS_MASK) );
	printf("ca_control_addr: 0x%08x\n", (unsigned int)ca_control_addr);
	void * ca_output_flag_addr;
	ca_output_flag_addr = virtual_base + ( (unsigned long)(ALT_LWFPGASLVS_OFST + CONV_ACCEL_0_OUTPUT_FLAG_BASE) & (unsigned long)(HW_REGS_MASK) );
	printf("ca_output_flag_addr: 0x%08x\n", (unsigned int)ca_output_flag_addr);
	
	
	// Convolution in action
	int loop_count = 0;
	int exit_loop = 0;
	
	int key_data = 0x0;
	int key_mask = 0xf;
	
	//unsigned int output_data = 0x0;
	//uint8_t output_data_mask = 0xff;
	
	/*
	uint8_t feat_map[] =
					{7, 12, 14, 6,
					6, 6, 7, 8,
					13, 11, 10, 12,
					4, 3, 7, 12};
					*/
	
	uint8_t feat_map[INPT_ROWS * INPT_COLS] = {0};
	
	for (uint8_t i = 0; i < INPT_ROWS*INPT_COLS; i++)
	{
		feat_map[i] = i;
	}
	
	uint8_t weights[WGT_ROWS * WGT_COLS] = {1, 2, 3, 4};
	
	//uint8_t output[(WGT_COLS - 1) * (INPT_ROWS - WGT_ROWS)] = {0};
	
	uint8_t big_output[10000] = {69};
	
	while (exit_loop != 1)
	{
		// Read buttons
		key_data = (~ (* (uint32_t *) h2p_lw_keys_addr ) ) & key_mask;
		printf("\nLoop count: %d\n", loop_count);
		printf("button_data: 0x%x\n", (unsigned int)key_data);
		
		
		// KEY 0 pressed
		if (key_data == 0x01)
		{
			// Turn on LED
			* (uint8_t *) ca_control_addr = 0x08; // 0b0000 1000
		}
		// KEY 1 pressed
		else if (key_data == 0x02)
		{
			// Turn off LED
			* (uint8_t *) ca_control_addr = 0x00; // 0b0000 0000
		}
		// KEY 2 pressed
		else if (key_data == 0x04)
		{
			// Enable and Reset the unit
			* (uint8_t *) ca_control_addr = 0x05; // 0b0000 0101
			
			// Disable Reset
			* (uint8_t *) ca_control_addr = 0x01; // 0b0000 0001
			
			// Feed Weights
			for (int i = 0; i < WGT_ROWS*WGT_COLS; i++)
			{
				*(uint8_t *)ca_weight_addr = weights[i];
			}
			
			// Feed Feature Map
			for (int i = 0; i < INPT_ROWS*INPT_COLS; i++)
			{
				*(uint8_t *)ca_feat_map_addr = feat_map[i];
			}
			
			// Begin convolution
			* (uint8_t *) ca_control_addr = 0x03; // 0b0000 0011
			
			// Lower begin_conv bit, leave enable set
			* (uint8_t *) ca_control_addr = 0x01; // 0b0000 0001
			
			// Read and save outputs
			/*
			for (int i = 0; i < (WGT_COLS - 1) * (INPT_ROWS - WGT_ROWS); i++)
			{
				output[i] = *(uint8_t *)ca_output_addr & output_data_mask;
			}
			*/
			
			for (int i = 0; i < 10000; i++)
			{
				//big_output[i] = *(uint8_t *)ca_output_addr & output_data_mask;
				big_output[i] = *(uint8_t *)ca_output_flag_addr;
			}
			
			big_output[9999] = 12;
			
			// Set control to disable enable
			* (uint8_t *) ca_control_addr = 0x00; // 0b00000000
			
			// Set control to reset
			* (uint8_t *) ca_control_addr = 0x04; // 0b0000 0100
			
			// Set control to null
			* (uint8_t *) ca_control_addr = 0x00; // 0b0000 0000
			
			printf("Finished.\n");
			
		}
		// KEY 3 pressed
		else if (key_data == 0x8)
		{
			
		}
		else if (key_data == 0xf)
		{
			exit_loop++;
		}
		
		
		// wait 1 sec
		usleep( 1*1000*1000 );
		loop_count++;
	}
	
	printf("Exiting program.\n");
	
	printf("output data:\n");
	
	/*
	for (int i = 0; i < (WGT_COLS - 1) * (INPT_ROWS - WGT_ROWS); i++)
	{
		printf("%d, ", output[i]);
	}
	*/
	for (int i = 0; i < 10000; i++)
	{
		if (big_output[i] != 0)
		{
			printf("%4d -     %d\n", i, big_output[i]);
		};
	}
	
	// Clean up our memory mapping and exit
	if( munmap( virtual_base, HW_REGS_SPAN ) != 0 ) {
		printf( "ERROR: munmap() failed...\n" );
		close( fd );
		return( 1 );
	}

	close( fd );

	return( 0 );
}
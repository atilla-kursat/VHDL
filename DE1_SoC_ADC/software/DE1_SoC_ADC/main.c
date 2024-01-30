// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------

#include "altera_avalon_spi_regs.h"
#include <stdio.h>
#include <stdlib.h> // malloc, free
#include <string.h>
#include <stddef.h>
#include <unistd.h>  // usleep (unix standard?)

#include "alt_types.h"  // alt_u32
#include "altera_avalon_pio_regs.h" //IOWR_ALTERA_AVALON_PIO_DATA
#include "system.h"


 
int main()
{

        alt_u16 adc_result;
        alt_u16 status=0x00;
	    int i;
       printf("channel 0-7 voltage value:\n");
		//initial the spi controller
		IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x1); //select device 0
		IOWR_ALTERA_AVALON_SPI_CONTROL(SPI_0_BASE, 0x00);  //reset the control reg
		//initial the adc after power supply
	    if( IORD_ALTERA_AVALON_SPI_STATUS(SPI_0_BASE) & ALTERA_AVALON_SPI_STATUS_TRDY_MSK )//tx two cycle dummy bits
		   IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, 0xffff); //the first cycle dummy bits
	    while(!(IORD_ALTERA_AVALON_SPI_STATUS(SPI_0_BASE) & ALTERA_AVALON_SPI_STATUS_TRDY_MSK));
	       IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, 0xffff); //the second cycle dummy bits

	    // SEQ Bit = 1, SHADOW Bit = 1
	    while(!(IORD_ALTERA_AVALON_SPI_STATUS(SPI_0_BASE) & ALTERA_AVALON_SPI_STATUS_TRDY_MSK)); //write control and sequence register
	       IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, 0xdf90); //datasheet figure 13,config the control reg, channel 0-7
//	    while(!(IORD_ALTERA_AVALON_SPI_STATUS(SPI_0_BASE) & ALTERA_AVALON_SPI_STATUS_TRDY_MSK)); //write control and sequence register
//	       IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, 0x5f90); //read the convert result channel 0

	    //read converting result from channel 0 - channel 7

	 for(i=0;i<8;i++){
		// if(i==0)
		// usleep(1); //matthew add
	    while(!(IORD_ALTERA_AVALON_SPI_STATUS(SPI_0_BASE) & ALTERA_AVALON_SPI_STATUS_TRDY_MSK)); //write control and sequence register
	       IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, 0x5f90); //read the convert result channel 0

	       // wait tx done
	       while (!(status & ALTERA_AVALON_SPI_STATUS_TMT_MSK)){
	        status = IORD_ALTERA_AVALON_SPI_STATUS(SPI_0_BASE);
	       }

	    while(!(IORD_ALTERA_AVALON_SPI_STATUS(SPI_0_BASE) & ALTERA_AVALON_SPI_STATUS_RRDY_MSK));
	       adc_result = IORD_ALTERA_AVALON_SPI_RXDATA(SPI_0_BASE);

	       printf("CH%d = %fv\n",(adc_result>>12)&0x7,2*2.5*(adc_result&0x0fff)/4096);

   }//end for

}//end main

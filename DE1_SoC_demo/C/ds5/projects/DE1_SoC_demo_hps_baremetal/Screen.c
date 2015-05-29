#include "Screen.h"
#include "alt_globaltmr.h"
#include "alt_clock_manager.h"
#include <assert.h>
#include <stdio.h>

#include "alt_dma.h"
#include "alt_dma_common.h"
#include "alt_dma_program.h"

static volatile uint32_t volatile screen[SCREEN_SIZE/4];
static volatile uint32_t* volatile vga_screen = (uint32_t*) (VGA_BASE);


ALT_DMA_CHANNEL_t dma_channel;
ALT_STATUS_CODE status = ALT_E_SUCCESS;
ALT_DMA_PROGRAM_t program;

void DMA_init(){

	status = alt_dma_channel_alloc(ALT_DMA_CHANNEL_0);
	if (status != ALT_E_SUCCESS)
	{
		printf("Allocation not possible\n");
	}
	status = alt_dma_program_init(&program);
	if (status != ALT_E_SUCCESS)
	{
		printf("Program init failed\n");
	}
}



static ALT_STATUS_CODE alt_dma_channel_wait_for_state(ALT_DMA_CHANNEL_t channel,
                                                      ALT_DMA_CHANNEL_STATE_t state,
                                                      uint32_t count)
{
    ALT_STATUS_CODE status = ALT_E_SUCCESS;

    ALT_DMA_CHANNEL_STATE_t current;

    uint32_t i = count;
    while (--i)
    {
        status = alt_dma_channel_state_get(channel, &current);
        if (status != ALT_E_SUCCESS)
        {
            break;
        }
        if (current == state)
        {
            break;
        }
    }

    if (i == 0)
    {
        printf("FPGA[AXI]: Timeout [count=%u] waiting for DMA state [%d]. Last state was [%d]",
                (unsigned)count,
                (int)state, (int)current);
        status = ALT_E_TMO;
    }

    return status;
}



void DMA_start(void){

	status = alt_dma_memory_to_memory(dma_channel,
											&program,
											vga_screen,
											screen,
											SCREEN_SIZE,
											false,
											ALT_DMA_EVENT_0);



	if (status != ALT_E_SUCCESS)
	{
		printf("DMA start failed\n");
	}

	 status = alt_dma_channel_wait_for_state(dma_channel, ALT_DMA_CHANNEL_STATE_STOPPED, SCREEN_SIZE);

}


void Screen_Clear(const Color bg_color) {

	volatile uint32_t* volatile ptr = screen;
	memset(screen, bg_color, SCREEN_SIZE);

}

void Screen_DrawSquare(int x, int y, int w, Color color) {
	volatile uint32_t* volatile ptr = screen + (x + y * (640))/4;
	int i = 0;
	int j = 0;
	for (j = 0; j < w; ++j) {
		for (i = 0; i < w/4; ++i) {
			*ptr = (color << 24) | (color << 16) | (color << 8)
						| color;
			ptr++;
		}
		ptr += (640 - w)/4;
	}
}

void Screen_FlipBuffer(void) {
	if (vga_screen == (uint32_t*) (VGA_BASE)) {
		vga_screen = (uint32_t*) (VGA_BASE + SCREEN_SIZE);
	} else {
		vga_screen = (uint32_t*) (VGA_BASE);
	}

	vga_module[0] = 0;
}

void Screen_DrawBorders(Color color) {
	volatile uint32_t* volatile ptr = screen;
	int i = 0;

//	for (i = 0; i < 640 / 4; ++i) {
//		*ptr++ = (color << 24) | (color << 16) | (color << 8) | color;
//	}

	memset(screen, color, 640);
	ptr+= 640/4;


	for (i = 0; i < 478; i++) {
		*ptr = (*ptr & 0xFFFFFF00) | color;
		ptr += 636 / 4;
		*ptr = (*ptr & 0xFFFFFF) | (color << 24);
		ptr++;
	}

	memset(screen, color, 640);

}

void Screen_drawSpritePrecise(uint32_t x, uint32_t y, Sprite s){

	volatile uint8_t* volatile ptr = (uint8_t*)screen + (x + y * (640));
		int i = 0;
		int j = 0;
		for (j = 0; j < s.h; ++j) {
			for (i = 0; i < s.w; ++i) {
				*ptr = ((uint8_t*)s.pixels)[i + j * s.w];
				ptr++;
			}
			ptr += 640 - s.w;
		}

}

void Screen_drawSprite(uint32_t x, uint32_t y, Sprite s){

	volatile uint32_t* volatile ptr = screen + (x + y * (640))/4;
		int i = 0;
		int j = 0;
		for (j = 0; j < s.h; ++j) {
			for (i = 0; i < s.w/4; ++i) {
				*ptr = s.pixels[i + j*(s.w/4)];
				ptr++;
			}
			ptr += (640 - s.w)/4;
		}

}

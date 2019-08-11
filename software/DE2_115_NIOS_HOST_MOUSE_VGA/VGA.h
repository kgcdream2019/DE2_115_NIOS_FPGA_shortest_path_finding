#ifndef   __INC_VGA_H__
#define   __INC_VGA_H__
#include "alt_types.h"

//  VGA Parameter
#define VGA_WIDTH     640
#define VGA_HEIGHT    480
#define OSD_MEM_ADDR  VGA_WIDTH*VGA_HEIGHT

//  VGA Set Function 
#define Vga_Write_Ctrl(base,value)          IOWR(base, OSD_MEM_ADDR   , value)
#define Vga_Cursor_X(base,value)            IOWR(base, OSD_MEM_ADDR+1 , value)        
#define Vga_Cursor_Y(base,value)            IOWR(base, OSD_MEM_ADDR+2 , value)        
#define Vga_Cursor_Color_R(base,value)      IOWR(base, OSD_MEM_ADDR+3 , value)        
#define Vga_Cursor_Color_G(base,value)      IOWR(base, OSD_MEM_ADDR+4 , value)        
#define Vga_Cursor_Color_B(base,value)      IOWR(base, OSD_MEM_ADDR+5 , value)        
#define Vga_Pixel_On_Color_R(base,value)    IOWR(base, OSD_MEM_ADDR+6 , value)        
#define Vga_Pixel_On_Color_G(base,value)    IOWR(base, OSD_MEM_ADDR+7 , value)        
#define Vga_Pixel_On_Color_B(base,value)    IOWR(base, OSD_MEM_ADDR+8 , value)        
#define Vga_Pixel_Off_Color_R(base,value)   IOWR(base, OSD_MEM_ADDR+9 , value)        
#define Vga_Pixel_Off_Color_G(base,value)   IOWR(base, OSD_MEM_ADDR+10 , value)        
#define Vga_Pixel_Off_Color_B(base,value)   IOWR(base, OSD_MEM_ADDR+11 , value)        
#define Vga_Set_Pixel(base,x,y)             IOWR(base, y*VGA_WIDTH+x, 1)        
#define Vga_Clr_Pixel(base,x,y)             IOWR(base, y*VGA_WIDTH+x, 0)   
//newly added code for shortest path finding
//set input parameter
#define Dijstra_set_clk_NIOS(base,value)   		IOWR(base, OSD_MEM_ADDR+12 , value)
#define Dijstra_set_reset(base,value)   		IOWR(base, OSD_MEM_ADDR+13 , value)
#define Dijstra_set_start(base,value)   		IOWR(base, OSD_MEM_ADDR+14 , value)
#define Dijstra_set_trans_count(base,value)   	IOWR(base, OSD_MEM_ADDR+17 , value)
//get output parameter
#define Dijstra_clk_NIOS(base)   			IORD(base, OSD_MEM_ADDR+12)
#define Dijstra_reset(base)   				IORD(base, OSD_MEM_ADDR+13)
#define Dijstra_start(base)   				IORD(base, OSD_MEM_ADDR+14)
#define Dijstra_state(base)   				IORD(base, OSD_MEM_ADDR+15)
#define Dijstra_neighbor(base)   			IORD(base, OSD_MEM_ADDR+16)
#define Dijstra_trans_count(base)   		IORD(base, OSD_MEM_ADDR+17)
#define Dijstra_distance(base)   			IORD(base, OSD_MEM_ADDR+18)
//end
//-------------------------------------------------------------------------

//-------------------------------------------------------------------------
typedef union VGA_Ctrl_Reg {
	struct _VGA_Ctrl_Flags {
		unsigned char RED_ON :1;
		unsigned char GREEN_ON :1;
		unsigned char BLUE_ON :1;
		unsigned char CURSOR_ON :1;
		unsigned char RESERVED :4;
	} VGA_Ctrl_Flags;
	unsigned char Value;
} VGA_Ctrl_Reg;
//-------------------------------------------------------------------------
void Set_Cursor_XY(unsigned int X, unsigned int Y);
void Set_Cursor_Color(unsigned int R, unsigned int G, unsigned int B);
void Set_Pixel_On_Color(unsigned int R, unsigned int G, unsigned int B);
void Set_Pixel_Off_Color(unsigned int R, unsigned int G, unsigned int B);
//-------------------------------------------------------------------------

#endif //

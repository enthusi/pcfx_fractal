.include "macros.s"
.include "defines.s"

/*============================================================= */
/* registers */
.equiv r_register, r6      /* goes to 0x300 */
.equiv r_value,    r7      /* goes to 0x304 */
.equiv r_tmp_loop, r20
.equiv r_tmp_adr,  r21

.equiv r_tmp_data, r22

.equiv r_tmp, r23
.equiv r_keypad, r29

/*============================================================= */
#constants related to the Mandelbrot drawing routine
.equiv _fractal_height, 240
.equiv _fractal_width, 256
/* ============================================================= */
.org = 0x8000

.global _start
_start:	

    movw 0x200000, sp
    movw 0x8000, gp #technically this should be higher so it can make use of signed offsets
    
	#hint from Elmer: CD-DMA during boot may have invalidated it!
    ldsr    r0,chcw
    movea   0x8001,r0,r1
    ldsr    r1,chcw
    mov     2,r1
    ldsr    r1,chcw
	
    mov HuC6261_SCREENMODE, r_register	
	movw ( HuC6261_line262 | HuC6261_intsync | HuC6261_256px | HuC6261_KingBG0_on | HuC6261_KingBG1_on | HuC6261_7upBG_on), r_value
	out.h r_register, HuC6261_reg[r0]
	out.h r_value   , HuC6261_dat[r0]

/* Tetsu palette */
	mov HuC6261_PAL_NR, r_register	
	mov 0, r_value
	out.h r_register, HuC6261_reg[r0]
	out.h r_value   , HuC6261_dat[r0]
		
/* 	; 7up palette offsets */
	mov HuC6261_PAL_7UP_OFF, r_register	/*; 7up palette offsets*/
	mov 0, r_value	/*; BG & spr. offset = 0*/
	out.h r_register, HuC6261_reg[r0]
	out.h r_value   , HuC6261_dat[r0]

/* 	; KING BG0/1 palette offsets */
	mov HuC6261_PAL_KING_01, r_register/*; KING BG0/1 palette offsets*/
	mov (0 | 0<<8), r_value	/*; Both offsets = 0*/
	out.h r_register, HuC6261_reg[r0]
	out.h r_value   , HuC6261_dat[r0]

/* 	; Priority: 7up spr = 3, KING BG0 = 2, KING BG1 = 1 */
/* 	; Lower priorities go in the back. */
	mov HuC6261_PRIO_0, r_register	/*; 7up/Rainbow priority*/
	movw 0x010, r_value	/*; 7up spr = 3*/
	out.h r_register, HuC6261_reg[r0]
	out.h r_value   , HuC6261_dat[r0]
	
	mov HuC6261_PRIO_1, r_register	/*; KING priority*/
	movw 0x0032, r_value	/*; BG0 = 2, BG1 = 1*/
	out.h r_register, HuC6261_reg[r0]
	out.h r_value   , HuC6261_dat[r0]

/* 	; Cellophane control: disable */
	movw HuC6261_CTRL_CELL, r_register	
	mov 0,r_value	/*; Disable*/
	out.h r_register, HuC6261_reg[r0]
	out.h r_value   , HuC6261_dat[r0]

/* 	; Initialize BG0 KRAM */
/* 	; (0 to 0x10000 - see BG0 CG address) */
	movw 0x10000, r_tmp_loop
	
	mov KING_KRAM_ADR_write, r_register/*
	mov r0, r_value/*	; Address = 0x000 here*/
	mov 1, r_tmp  /*increase by 1*/ 
	shl KING_b_inc, r_tmp
	or r_tmp, r_value
	out.h r_register, KING_reg[r0]
	out.w r_value, KING_dat[r0]
	
	mov KING_KRAM_rw, r_register
	out.h r_register, KING_reg[r0]
.nextKRAMWrite1:	
	out.w r0, KING_dat[r0]
	add -2, r_tmp_loop
	bnz .nextKRAMWrite1

/* 	; KRAM page setup: use page 0 for everything */
	mov KING_KRAM_page, r_register
	mov (0<<8), r_value
	/*; Everything = page 0*/
/*      0	KRAM page for SCSI */
/*      8	KRAM page for BG */
/*     16	KRAM page for RAINBOW */
/*     24	KRAM page for ADPCM */
	out.h r_register, KING_reg[r0]
	out.w r_value, KING_dat[r0]

/* 	; BG mode: BG0*/
	movw KING_BG_MODE, r_register
	movw (KING_mode_256<<0 | KING_mode_256<<4 | 0<<8 | 0<<12), r_value 
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]

/* 	; BG priority*/
	movw KING_BG_PRIO, r_register
	movw (KING_prio_underfirst | KING_prio_first<<3 | KING_prio_hidden<<6 | KING_prio_hidden<<9), r_value  /*; (binary 001 010)*/
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]

/* 	; KING microprogram */
	movw KING_MICRO_CTRL, r_register
	mov 0, r_value	/*; Running = off*/
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]
	
	movw KING_MICRO_ADR, r_register	
	mov 0, r_value	/*; Address*/
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]
	
	movw .kingMicroprogram, r_tmp_adr
	movw 16, r_tmp_loop

	movw KING_MICRO_DATA, r_register	/*; Microprogram data*/
	out.h r_register, KING_reg[r0]
.microprogramLoop:
	ld.h 0[r_tmp_adr], r_value
	out.h r_value, KING_dat[r0]
	add 2, r_tmp_adr
	add -1, r_tmp_loop
	bnz .microprogramLoop
	
	movw KING_MICRO_CTRL, r_register
	mov 1, r_value/*	; Running = on*/
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]

/* 	; BG scroll mode */
	movw KING_BG_SCROLL, r_register
	mov 0b0000, r_value	/*; BG0/1 = single background area*/
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]

/* 	; BG0 CG address: it starts at 0 */
	movw KING_BG0_CG, r_register
	mov 0, r_value
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]

	movw KING_BG0_CGsub, r_register
	mov 0, r_value
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]
	
 	/*; BG1 CG address*/
 	movw KING_BG1_CG, r_register	
 	movw 64, r_value /*64*1024*/
 	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0] 

	movw KING_BG0_size, r_register
	movw ((KING_size_256 << KING_b_height) | (KING_size_256 << KING_b_width)) , r_value
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]

	movw KING_BG1_size, r_register
	movw ((KING_size_256 << KING_b_height) | (KING_size_256 << KING_b_width)) , r_value
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]
	
/* 	; BG0 X/Y scroll */
	movw KING_BG0_X, r_register	
	mov 0, r_value
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]
	movw KING_BG0_Y, r_register	
	mov 0, r_value
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]

	movw KING_BG1_X, r_register
	mov 0, r_value
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]
	movw KING_BG1_Y, r_register
	mov 0, r_value
	out.h r_register, KING_reg[r0]
	out.h r_value, KING_dat[r0]
	
	#depack border gfx into RAM buffer
    movw border_img, r10
    movw buffer, r11
    call depack/*;r10=source, r11=destination; 124 Bytes*/
    call upload_bitmap
    

	mov SUP_HSYNC, r_register
	movw 0x0202, r_value/*	; Eris and MagicKit say 0x202*/
	out.h r_register, SUPA_reg[r0]
	out.h r_value, SUPA_dat[r0]
	
	mov SUP_HDISP, r_register
	movw 0x041f, r_value	/*; Eris says 0x41F, MagicKit says 0x31F*/
	out.h r_register, SUPA_reg[r0]
	out.h r_value, SUPA_dat[r0]
	
	mov SUP_VSYNC, r_register
	movw 0x1102, r_value	/*; Eris says 0x1102, MagicKit says 0xF02*/
	out.h r_register, SUPA_reg[r0]
	out.h r_value, SUPA_dat[r0]
	
	mov SUP_VDISP, r_register
	movw 0xEF, r_value	/*; Eris and MagicKit say 0xEF*/
	out.h r_register, SUPA_reg[r0]
	out.h r_value, SUPA_dat[r0]
	
	mov SUP_VDISPEND, r_register
	mov 2, r_value/*	; Eris says 2, MagicKit says 3*/
	out.h r_register, SUPA_reg[r0]
	out.h r_value, SUPA_dat[r0]

/* set IRQ for 7UP vblank */
 
	mov SUP_CTRL, r_register	/*; DMA control*/
	movw (1<<3), r_value	/*; vblank*/
	out.h r_register, SUPA_reg[r0]
	out.h r_value, SUPA_dat[r0]
	
	
	call put_palette 
	

 #METHOD 1 to set the VECTOR JUMP
    movw	VEC_IRQ_VBLA, r10
    movw irq_handler ,r11
	sub	r10, r11
	st.h	r11, 2[r10]
	shr	16, r11
	andi	0x03FF, r11, r11
	ori	0xA800, r11, r11
	st.h	r11, 0[r10]
	
	#mask 
    movw (~(1<<3)&0x7f), r_tmp_data
	out.h r_tmp_data, 0xe40[zero]
	jr skip_handler

#----------------------------------
irq_handler:
    addi	-0x20, sp, sp
	st.w	r_tmp_adr, 0x00[sp]
	st.w	r_tmp_loop, 0x04[sp]
	st.w	r_tmp_data, 0x08[sp]
    call update_palette 
    call cycle 
    call mypcfxReadPad0
	ld.w	0x08[sp], r_tmp_data
	ld.w	0x04[sp], r_tmp_loop
	ld.w	0x00[sp], r_tmp_adr
	addi	0x20, sp, sp
	in.h SUPA_reg[zero],r0 #clear IRQ flag
	in.h 0[r0],r0 #clear pad irq?
    reti
#----------------------------------    
skip_handler:
/* 	cli, oh CLI is nintendo only. Bleh.... */
/* http://perfectkiosk.net/stsvb.html#cpu_psw */
    stsr	PSW, r_tmp /*current sys reg */
    movw	~(1<<12),  r_tmp_data /*1<<12 = 0x1000*/
	and	r_tmp, r_tmp_data /*keep formerly set bits*/
	ldsr	r_tmp_data, PSW
	
	#set level too
	mov 12, r6 #level
	stsr	PSW, r10
	shl	16, r6
	movw 0b00000000000000001111111111111111, r7 #mask out level 16-19, 20-31 = undef
	and r7,r10
	or  r6,r10
	ldsr	r10, PSW
/* 	=================================== */

    #prepare dirty for redraw
    mov 1, r_tmp
    st.b r_tmp,zdaoff(dirty)[gp]
    
    call set_full_size
    movw 16,r_tmp
    st.h r_tmp, zdaoff(iterations)[gp]
/* 	=================================== */	
.loop:	

    ld.b zdaoff(dirty)[gp],r_tmp 
     cmp r0, r_tmp 
     bz _skip_compute 
    
     st.b r0,zdaoff(dirty)[gp] 
     call plot_mandelbrot 
    
_skip_compute:
    call transfer_result
	

	
/* 	first check buttons */
	andi (1<<0), r_keypad, r0	/*; Button I */
	bz .checkButton2
.Button1:
/*     iter++ */
    ld.h zdaoff(iterations)[gp], r10
    add 2,r10
    st.h r10,zdaoff(iterations)[gp]
     call set_full_size 
    br .loop

.checkButton2:
	andi (1<<1), r_keypad, r0	/*; Button II */
	bz .checkButton3
.Button2: /*     iter++ */
    ld.h zdaoff(iterations)[gp], r10
    add -2,r10
    st.h r10,zdaoff(iterations)[gp]
     call set_full_size 
    br .loop

.checkButton3:
	andi (1<<2), r_keypad, r0	/*; Button III */
	bz .checkButton4
.Button3: /*zoom in*/
    ld.h zdaoff(xpixsize)[gp], r9
    shl 4,r9 
    ld.h zdaoff(add_left)[gp], r10
    add r9,r10
    st.h r10, zdaoff(add_left)[gp]
    ld.h zdaoff(add_right)[gp], r10
    sub r9,r10
    st.h r10, zdaoff(add_right)[gp]
    
    ld.h zdaoff(ypixsize)[gp], r9
    shl 4,r9 
    ld.h zdaoff(add_top)[gp], r10
    add r9,r10
    st.h r10, zdaoff(add_top)[gp]
    ld.h zdaoff(add_bottom)[gp], r10
    sub r9,r10
    st.h r10, zdaoff(add_bottom)[gp]
    
    ld.h zdaoff(iterations)[gp], r10 
    add 2,r10
    st.h r10,zdaoff(iterations)[gp]
    call set_full_size
    br .loop
    
.checkButton4:
    andi (1<<3), r_keypad, r0	/*; Button IV */
	bz .checkup
.Button4: /*zoom in*/
    ld.h zdaoff(xpixsize)[gp], r9
    shl 4,r9 
    ld.h zdaoff(add_left)[gp], r10
    sub r9,r10
    st.h r10, zdaoff(add_left)[gp]
    ld.h zdaoff(add_right)[gp], r10
    add r9,r10
    st.h r10, zdaoff(add_right)[gp]
    
    ld.h zdaoff(ypixsize)[gp], r9
    shl 4,r9 
    ld.h zdaoff(add_top)[gp], r10
    sub r9,r10
    st.h r10, zdaoff(add_top)[gp]
    ld.h zdaoff(add_bottom)[gp], r10
    add r9,r10
    st.h r10, zdaoff(add_bottom)[gp]
    
    ld.h zdaoff(iterations)[gp], r10 
    add -2,r10
    st.h r10,zdaoff(iterations)[gp]
    call set_full_size
    br .loop
    
.checkup:    
	andi (1<<8), r_keypad, r0	/*; Up?*/
	bz .checkPadDown
	
.joy_up:
	
/* 	;scroll BUFFER up */
    movw (buffer), r10 
    movw (_fractal_height-16),r8 /*;lines*/
_loop2c:
    movw (_fractal_width/4),r9 /*;full width */
_loop1c:
    ld.w (256*16)[r10], r11 /*we move by 16 lines*/
    st.w r11,0[r10]
    add 4,r10
    add -1, r9
    bne _loop1c
/*     addi (256-192),r10,r10  */
    add -1, r8
    bne _loop2c
    
    ld.h zdaoff(ypixsize)[gp], r9
    shl 4,r9 /*;faster in case we have power of 2 steps*/
     
    ld.h zdaoff(add_top)[gp], r10
    add r9,r10
    st.h r10, zdaoff(add_top)[gp]
    
    ld.h zdaoff(add_bottom)[gp], r10
    add r9,r10
    st.h r10, zdaoff(add_bottom)[gp]
    
/*   plot full width next time */
    st.h r0,zdaoff(startx)[gp]
    movw _fractal_width,r_tmp
    st.h r_tmp,zdaoff(endx)[gp]
    
/*     but only start near the bottom to fill the new 16 pix gap */
    movw (_fractal_height-16),r_tmp 
    st.h r_tmp,zdaoff(starty)[gp]
    movw _fractal_height,r_tmp 
    st.h r_tmp,zdaoff(endy)[gp]
    
    mov 1,r_tmp/*;also prepare redraw*/
    st.b r_tmp, zdaoff(dirty)[gp]
    br .loop /*ret*/
    
.checkPadDown:
	andi (1<<10), r_keypad, r0/*	; Down?*/
	bz .checkPadLeft
	
.joydown:
	
/*     ;scroll BUFFER down */
    movw (buffer+256*(_fractal_height-16)), r10 
    movw (_fractal_height-15),r8 
_loop2d:
    movw ((_fractal_width)/4),r9 
_loop1d:
    ld.w 0[r10], r11
    st.w r11,256*16[r10]
    add 4,r10
    add -1, r9
    bne _loop1d
    addi (-(256+_fractal_width)),r10,r10 
    add -1, r8
    bne _loop2d
    
    ld.h zdaoff(ypixsize)[gp], r9
    shl 4,r9
     
    ld.h zdaoff(add_top)[gp], r10
    sub r9,r10
    st.h r10, zdaoff(add_top)[gp]
    ld.h zdaoff(add_bottom)[gp]], r10
    sub r9,r10
    st.h r10, zdaoff(add_bottom)[gp]
    
    st.h r0,zdaoff(startx)[gp]
    movw _fractal_width,r_tmp
    st.h r_tmp,zdaoff(endx)[gp]
    
    st.h r0,zdaoff(starty)[gp]
    movw 16,r_tmp 
    st.h r_tmp,zdaoff(endy)[gp]
    
    mov 1,r_tmp
    st.b r_tmp, zdaoff(dirty)[gp]
    br .loop

.checkPadLeft:
	andi (1<<11), r_keypad, r0/*	; Left?*/
	bz .checkPadRight
.joy_left:	
	add -1, r21
	movw (buffer), r10
    movw _fractal_height,r8 
_loop2:
    movw ((_fractal_width-16+4)/4),r9 /*;full width minus shifts*/
_loop1:
    ld.w 16[r10], r11
    st.w r11,0[r10]
    add 4,r10
    add -1, r9
    bne _loop1
    addi (256-(_fractal_width-16+4)),r10,r10 
    add -1, r8
    bne _loop2
    
    ld.h zdaoff(xpixsize)[gp], r9
    shl 4,r9 
     
    ld.h zdaoff(add_left)[gp], r10
    add r9,r10
    st.h r10, zdaoff(add_left)[gp]
    ld.h zdaoff(add_right)[gp], r10
    add r9,r10
    st.h r10, zdaoff(add_right)[gp]
    
    movw (_fractal_width-16-4),r_tmp
    st.h r_tmp,zdaoff(startx)[gp]
    movw (_fractal_width),r_tmp
    st.h r_tmp,zdaoff(endx)[gp]
    
    st.h r0,zdaoff(starty)[gp]
    movw _fractal_height,r_tmp
    st.h r_tmp,zdaoff(endy)[gp]
    
    mov 1,r_tmp
    st.b r_tmp, zdaoff(dirty)[gp]
	br .loop
	
.checkPadRight:
	andi (1<<9), r_keypad, r0	/*; Right?*/
	bz .check_next
.joy_right:
	add 1, r21
	movw (buffer+_fractal_width-4), r10
    movw _fractal_height,r8 
_loop2b:
    movw ((_fractal_width-16)/4),r9
_loop1b:
/*     ;write to the right end the value of right_end - 16 */
    ld.w -16[r10], r11
    st.w r11,0[r10]
    add -4,r10
    add -1, r9
    bne _loop1b
    addi (256+_fractal_width-16),r10,r10 
    add -1, r8
    bne _loop2b
  
    ld.h zdaoff(xpixsize)[gp], r9
    shl 4,r9 
    
    ld.h zdaoff(add_left)[gp], r10
    sub r9,r10
    st.h r10, zdaoff(add_left)[gp]
    ld.h zdaoff(add_right)[gp], r10
    sub r9,r10
    st.h r10, zdaoff(add_right)[gp]
    
    st.h r0,zdaoff(startx)[gp]
    movw 16,r_tmp
    st.h r_tmp,zdaoff(endx)[gp]
    
    st.h r0,zdaoff(starty)[gp]
    movw _fractal_height,r_tmp
    st.h r_tmp,zdaoff(endy)[gp]
    
    mov 1,r_tmp
    st.b r_tmp, zdaoff(dirty)[gp]
	br .loop
	
.check_next:	
	br .loop
mypcfxReadPad0:	
    mov 5, r_keypad	/*; 5 = Transmit enable + receive enable*/
	out.h r_keypad, 0x00[r0]
wait_for_input_ready:	
	in.h 0x00[r0], r_keypad
	andi 9, r_keypad, r_keypad
	cmp 1, r_keypad	/*; 9 = Received data + unknown*/
	bz wait_for_input_ready
	in.w 0x40[r0], r_keypad
	ret
/* ============================================================= */
.align 2

 /* alignment required ? */
/*  01000001 =0x41=bit6 =1 = BG1 */
/*  76543210 */
 
.kingMicroprogram:
.hword 0x0000
.hword 0x0001
.hword 0x0002
.hword 0x0003
.hword 0x0040 
.hword 0x0041 
.hword 0x0042 
.hword 0x0043 

.hword 0x0100
.hword 0x0100
.hword 0x0100
.hword 0x0100
.hword 0x0100
.hword 0x0100
.hword 0x0100
.hword 0x0100

.align 4
add_left:  .hword 0x0000
add_right: .hword 0x0000
add_top:   .hword 0x0000
add_bottom: .hword 0x0000
xpixsize: .hword 0x0000
ypixsize: .hword 0x0000
startx: .hword 0x0000
starty: .hword 0x0000
endx: .hword 0x0000
endy: .hword 0x0000
dirty: .hword 0x0000
iterations: .hword 0x0000

spritex: .hword 0x0000
spritey: .hword 0x0000

.align 2
set_full_size:

    st.h r0,zdaoff(startx)[gp]
    
    movw _fractal_width,r27
    st.h r27,zdaoff(endx)[gp]
    
    st.h r0,zdaoff(starty)[gp]
    
    movw _fractal_height,r27
    st.h r27,zdaoff(endy)[gp]
    
    mov 1,r_tmp/*;also prepare redraw*/
    st.b r_tmp, zdaoff(dirty)[gp]
    ret
    
plot_mandelbrot:
     movw (-18337-4000+1000),r11/* ;#xmin -1.26136183 * 2**13 =-10333*/
	 movw (6869-12000),r12 /*;#xmax -1.24763480*/
     movw (-12602),r13 /*;#ymin 0.37648215*/
     movw (12602-10000),r14 /*;#ymax 0.38676353*/
     
     ld.h zdaoff(add_left)[gp], r15
     add r15,r11

     ld.h zdaoff(add_right)[gp], r15
     add r15,r12

     ld.h zdaoff(add_top)[gp], r15
     add r15,r13
  
     ld.h zdaoff(add_bottom)[gp], r15
     add r15,r14
     
     movw (16384), r23
	 movw (268435456),r24
	 
bigloop:

    movw buffer, r18 
    movw 8*16,r27 
    mov r12,r2
    sub r11,r2
    div r27,r2   
    st.h r2, zdaoff(xpixsize)[gp]
    movw 8*16,r27
    mov r14,r19
    sub r13,r19
    div r27,r19
    st.h r19,zdaoff(ypixsize)[gp]
    
    ld.h zdaoff(starty)[gp], r5

loopy:
    mov r5,r7
    mul r19,r7
    add r13,r7
    ld.h zdaoff(startx)[gp], r6
loopx:
    mov r6,r8 
    mul r2,r8
    add r11,r8
    mov 0,r9
    mov 0,r10
    mov 0,r26
    ld.h zdaoff(iterations)[gp], r22 
innerloop: 
    mov r10,r20
    add r26,r20
    mov r10,r21
    sub r26,r21
    
    mov r20,r9
    mul r21,r9
    sar 13,r9
  
    add r8,r9

    mov r10,r20
    mul r26,r20
    sar 13,r20

    mov r23,r26
    mul r20, r26 
    sar 13,r26   
    add r7,r26    
    
    mov r9,r10
    mov r9,r20
    mul r9,r20

    mov r26,r21
    mul r26,r21
    add r21,r20
          
    cmp r20, r24 
    blt exitloop
     
    add -1,r22
    bne innerloop
     
    movw 1, r22
/*inner part of mandelbrot*/
/*     0 = transparent */
/*     1 - also black now */
    br special 
    
exitloop:
    shl 1,r22
 
/*   here we could avoid to have the reserved backdrop color being used */
/*     mul r22,r22 */
/*     andi 0xff,r22,r22 */

    andi 0x3f,r22,r22
    #avoid this wrapping to 0 or 1
    #in case we have >63 iterations!
    cmp 1, r22
    bgt valid_value
    
    mov 2,r22
valid_value:    
special:
/*     plot pixel   */
    mov r5, r27
/*     shl 8, r27 */
    shl 8, r27 /* y*256 */
    add r6,r27 /* +x */
/*     NOW INVERSE X%1 steps to have big endian data! */

    add r18,r27
    andi 0x1, r6,r20 
    bz plot_right
    st.b r22, -1[r27]
    br plot_left
plot_right:     
    st.b r22, 0x1[r27]
plot_left:    
    add 1, r6
    ld.h zdaoff(endx)[gp], r20
    cmp r6,r20
    bne loopx
     
    add 1,r5
    ld.h zdaoff(endy)[gp], r20
    cmp r5,r20
    bne loopy
    ret 
/*    =================================== */

transfer_result:
/* http://daifukkat.su/pcfx/data/memmap.html */
/* you can use bitstring here as well */
    movw 0x10000, r_tmp_loop
	movw buffer, r_tmp_adr

	mov KING_KRAM_ADR_write, r_register
	movw (0x00000 | (1 << KING_b_inc)) , r_value
	out.h r_register, KING_reg[r0]
	out.w r_value, KING_dat[r0]
	
	mov KING_KRAM_rw, r_register
    out.h r_register, KING_reg[r0]
.tloop:
	ld.w 0x0[r_tmp_adr], r_value
	out.w r_value, (KING_dat)[r0]
	add 4, r_tmp_adr 
	add -4, r_tmp_loop
	bnz .tloop
	ret

cycle:
/*     ;move first color to back and then all one up */
/* but col 00 = transparent */
/* col 01 = kept black */
        movw test_palette+4, r_tmp_adr
        ld.h 0[r_tmp_adr],r_tmp_data
        st.h r_tmp_data,(63*2)[r_tmp_adr]
        movw 63*2, r_tmp_loop
_loopcy:
        ld.h 2[r_tmp_adr],r_tmp_data
        st.h r_tmp_data,0[r_tmp_adr]
        add  2, r_tmp_adr
        add -2, r_tmp_loop
        bne _loopcy
    ret
 
put_palette:
    movw 256, r_tmp_loop #once store the full palette
    br full_range
update_palette:    
    movw 64, r_tmp_loop #for the color cycle only push the required ones
full_range:
    #writes increase pal-entry-index and we need to reset it!
    mov HuC6261_PAL_NR, r_tmp_data
    out.h r_tmp_data, HuC6261_reg[r0]
	out.h r0, HuC6261_dat[r0]
	
	movw test_palette, r_tmp_adr
	mov HuC6261_PAL_DATA, r_tmp_data	
	out.h r_tmp_data, HuC6261_reg[r0]
.nextTetsuPaletteEntry:
	ld.h 0[r_tmp_adr], r_tmp_data
	out.h r_tmp_data, HuC6261_dat[r0]
	
	add 2, r_tmp_adr
	add -1, r_tmp_loop
	bnz .nextTetsuPaletteEntry    
	mov HuC6261_PAL_NR, r_tmp_data
    out.h r_tmp_data, HuC6261_reg[r0]
	out.h r0, HuC6261_dat[r0]
	ret

	
upload_bitmap:
/* http://daifukkat.su/pcfx/data/memmap.html */
/* you can use bitstring here as well */
    movw 0x10000, r_tmp_loop
	movw buffer, r_tmp_adr

	mov KING_KRAM_ADR_write, r_register
	movw (0x10000 | (1 << KING_b_inc)) , r_value
	out.h r_register, KING_reg[r0]
	out.w r_value, KING_dat[r0]
	
	mov KING_KRAM_rw, r_register
    out.h r_register, KING_reg[r0]
.bloop:
	ld.w 0x0[r_tmp_adr], r_value
	out.w r_value, (KING_dat)[r0]
	add 4, r_tmp_adr 
	add -4, r_tmp_loop
	bnz .bloop
	ret
	
begin_depack:
depack:
    add     -4, sp
    st.w    lp, 0[sp]
        
    movea 0xff,r0,r20 /*;for later compare*/
    ld.h 0[r10],r12 /*;size*/
    andi 0xffff,r12,r12
    add 2,r10
    
    mov r10,r15
    add r12,r15 /*;r15 = end of packed data*/
fetch_token:
   ld.b 0[r10],r16/* ;token*/
   andi 0xff,r16,r16
   add 1, r10 

   mov r16,r14 
   shr 4,r14 /*;r14 = literal*/ 
   be fetch_offset

   jal fetch_length

   mov r10,r12
   jal copy_data /*;literal copy r12 to r11*/
   mov r12,r10

fetch_offset:
   ld.b 0[r10],r13
   andi 0xff,r13,r13
   mov r11,r12
   sub r13,r12
   ld.b 1[r10],r13
   andi 0xff,r13,r13
   shl 8,r13
   sub r13,r12
   add 2,r10
   
   andi 15,r16,r14 /*;match length*/
   jal fetch_length 
   add 4,r14 /*;add min size offset*/
   jal copy_data  /*;copy match r12 to r11*/
   cmp r15,r10 /*;end of data stream?*/
   ble fetch_token
   
   ld.w 0[sp], lp
   add 4, sp
   jmp [lp]
   
fetch_length:
   cmp 0xf,r14 /*;max=$f indicates more to come*/
   bne _done

_loop:   
   ld.b 0[r10],r13
   andi 0xff,r13,r13
   add 1,r10
   add r13,r14
   cmp r13,r20 /*;r20=ff*/
   be _loop
_done:
   jmp [lp]

copy_data:
   ld.b 0[r12],r21
   st.b r21,0[r11]
   add 1,r12
   add 1,r11
   add -1,r14
   bne copy_data
   jmp [lp]
end_depack:


.align 2
test_palette:
.incbin "pal64.dat"
.hword 0x0088 /*placeholder for cycle*/
.incbin "border_pal.dat"

.align 2
border_img:
.incbin "border_bitmap.datprep.dat" #lz4 packed border bitmap in 256col mode (but only using 256-64=192 colors)


#end marker which helps debugging
.hword 0x55aa
.hword 0x77bb

.align 2
buffer:      

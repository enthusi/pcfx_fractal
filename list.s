GAS LISTING mandelbrot.s 			page 1


   1              	/* ============================================ */
   2              	/* MACROS */
   3              	
   4              	.macro  push reg1
   5              	        add     -4, sp
   6              	        st.w    \reg1, 0x0[sp]
   7              	.endm
   8              	
   9              	.macro  pop reg1
  10              	        ld.w    0x0[sp], \reg1
  11              	        add     4, sp
  12              	.endm
  13              	#https://astro.uni-bonn.de/~sysstw/CompMan/gnu/as.html#SEC60
  14              	
  15              	#20912
  16              	.macro  movw data, reg1
  17              	        movhi   hi(\data),r0,\reg1
  18              	        movea   lo(\data),\reg1,\reg1
  19              	.endm
  20              	
  21              	.macro  movwl data, reg1
  22              	        movea   lo(\data),r0,\reg1
  23              	        movhi   hi(\data),\reg1,\reg1
  24              	.endm
  25              	
  26              	.macro  call target
  27              	        push lp
  28              	        jal \target
  29              	        pop lp
  30              	.endm
  31              	
  32              	.macro  ret
  33              	        jmp [lp]
  34              	.endm
  35              	
  36              	.macro  jump target
  37              	        movw    \target, r30
  38              	        jmp     [r30]
  39              	.endm
  40              	/*============================================================= */
  41              	/* IO ADRESSES */
  42              	
  43              	.equiv HuC6261_reg, 0x300
  44              	.equiv HuC6261_dat, 0x304
  45              	
  46              	.equiv SUPA_reg, 0x400
  47              	.equiv SUPA_dat, 0x404
  48              	
  49              	.equiv SUPB_reg, 0x500
  50              	.equiv SUPB_dat, 0x504
  51              	
  52              	.equiv KING_reg, 0x600
  53              	.equiv KING_dat, 0x604
  54              	.equiv KING_dat2, 0x606
  55              	
  56              	/* register OFFSETS */
  57              	
GAS LISTING mandelbrot.s 			page 2


  58              	.equiv HuC6261_SCREENMODE, 0x00
  59              	.equiv HuC6261_PAL_NR, 0x01
  60              	.equiv HuC6261_PAL_DATA, 0x02
  61              	.equiv HuC6261_PAL_READ, 0x03 
  62              	.equiv HuC6261_PAL_7UP_OFF, 0x4
  63              	.equiv HuC6261_PAL_KING_01, 0x5 
  64              	.equiv HuC6261_PAL_KING_23, 0x6 
  65              	.equiv HuC6261_PAL_RAINBOW, 0x7 
  66              	.equiv HuC6261_PRIO_0, 0x8
  67              	.equiv HuC6261_PRIO_1, 0x9 
  68              	.equiv HuC6261_COLKEY_Y, 0xa
  69              	.equiv HuC6261_COLKEY_U, 0xb
  70              	.equiv HuC6261_COLKEY_V, 0xc
  71              	.equiv HuC6261_COLCELL, 0xd
  72              	.equiv HuC6261_CTRL_CELL, 0xe
  73              	.equiv HuC6261_CELL_SPRBANK, 0x0f 
  74              	.equiv HuC6261_CELL_1A, 0x10 
  75              	.equiv HuC6261_CELL_1B, 0x11
  76              	.equiv HuC6261_CELL_2A, 0x12
  77              	.equiv HuC6261_CELL_2B, 0x13
  78              	.equiv HuC6261_CELL_3A, 0x14
  79              	.equiv HuC6261_CELL_3B, 0x15
  80              	
  81              	.equiv KING_KRAM_ADR_read, 0x0c
  82              	.equiv KING_KRAM_ADR_write, 0x0d
  83              	.equiv KING_KRAM_rw, 0x0e
  84              	.equiv KING_KRAM_page, 0x0f
  85              	
  86              	.equiv KING_BG_MODE, 0x10
  87              	.equiv KING_BG_PRIO, 0x12
  88              	.equiv KING_MICRO_ADR, 0x13
  89              	.equiv KING_MICRO_DATA, 0x14
  90              	.equiv KING_MICRO_CTRL, 0x15
  91              	
  92              	.equiv KING_BG_SCROLL, 0x16
  93              	
  94              	.equiv KING_BG0_BAT,    0x20
  95              	.equiv KING_BG0_CG,     0x21
  96              	.equiv KING_BG0_BATsub, 0x22
  97              	.equiv KING_BG0_CGsub,  0x23
  98              	
  99              	.equiv KING_BG1_BAT,    0x24
 100              	.equiv KING_BG1_CG,     0x25
 101              	
 102              	.equiv KING_BG2_BAT,    0x26
 103              	.equiv KING_BG2_CG,     0x27
 104              	
 105              	.equiv KING_BG3_BAT,    0x28
 106              	.equiv KING_BG3_CG,     0x29
 107              	
 108              	.equiv KING_BG0_size,   0x2c
 109              	.equiv KING_BG1_size,   0x2d
 110              	.equiv KING_BG2_size,   0x2e
 111              	.equiv KING_BG3_size,   0x2f
 112              	
 113              	.equiv KING_BG0_X,   0x30
 114              	.equiv KING_BG0_Y,   0x31
GAS LISTING mandelbrot.s 			page 3


 115              	
 116              	.equiv KING_BG1_X,   0x32
 117              	.equiv KING_BG1_Y,   0x33
 118              	
 119              	.equiv KING_BG2_X,   0x34
 120              	.equiv KING_BG2_Y,   0x35
 121              	
 122              	.equiv KING_BG3_X,   0x36
 123              	.equiv KING_BG3_Y,   0x37
 124              	
 125              	.equiv KING_BG_aff_A, 0x38
 126              	.equiv KING_BG_aff_B, 0x39
 127              	.equiv KING_BG_aff_C, 0x3a
 128              	.equiv KING_BG_aff_D, 0x3b
 129              	.equiv KING_BG_aff_centerX, 0x3c
 130              	.equiv KING_BG_aff_centerY, 0x3d
 131              	
 132              	.equiv SUP_VRAM_ADR_W, 0x00
 133              	.equiv SUP_VRAM_ADR_R, 0x01
 134              	.equiv SUP_VRAM_RW, 0x02
 135              	.equiv SUP_CTRL, 0x05
 136              	.equiv SUP_RASTER, 0x06
 137              	.equiv SUP_BG_X, 0x7
 138              	.equiv SUP_BG_Y, 0x8
 139              	.equiv SUP_MEMWIDTH, 0x09
 140              	.equiv SUP_HSYNC, 0x0a
 141              	.equiv SUP_HDISP, 0x0b
 142              	.equiv SUP_VSYNC, 0x0c
 143              	.equiv SUP_VDISP, 0x0d
 144              	.equiv SUP_VDISPEND, 0x0e
 145              	.equiv SUP_DMA_CTRL, 0x0f
 146              	.equiv SUP_DMA_SRC, 0x10
 147              	.equiv SUP_DMA_DST, 0x11
 148              	.equiv SUP_DMA_LEN, 0x12
 149              	.equiv SUP_SAT_ADR, 0x13
 150              	
 151              	/* BIT FLAGS */
 152              	
 153              	.equiv HuC6261_line262, (0x01 << 0)
 154              	.equiv HuC6261_intsync, ( 0x0 << 2) /* int or ext? */
 155              	.equiv HuC6261_320px,   ( 0x1 << 3)
 156              	.equiv HuC6261_256px,   ( 0x0 << 3)
 157              	.equiv HuC6261_bg16,    ( 0x0 << 6)
 158              	.equiv HuC6261_bg256,   ( 0x1 << 6)
 159              	.equiv HuC6261_spr16,   ( 0x0 << 7)
 160              	.equiv HuC6261_spr256,  ( 0x1 << 7)
 161              	
 162              	.equiv HuC6261_7upBG_on,  ( 0x1 << 8)
 163              	.equiv HuC6261_7upSPR_on, ( 0x1 << 9)
 164              	.equiv HuC6261_KingBG0_on,( 0x1 << 10)
 165              	.equiv HuC6261_KingBG1_on,( 0x1 << 11)
 166              	.equiv HuC6261_KingBG2_on,( 0x1 << 12)
 167              	.equiv HuC6261_KingBG3_on,( 0x1 << 13)
 168              	.equiv HuC6261_Rainbow_on,( 0x1 << 14)
 169              	
 170              	.equiv KING_mode_4,     0b0001
 171              	.equiv KING_mode_16,    0b0010
GAS LISTING mandelbrot.s 			page 4


 172              	.equiv KING_mode_256,   0b0011
 173              	.equiv KING_mode_64k,   0b0100
 174              	.equiv KING_mode_16m,   0b0101
 175              	.equiv KING_mode_4block,  0b1001
 176              	.equiv KING_mode_16block, 0b1010
 177              	.equiv KING_mode_256block,0b1011
 178              	
 179              	.equiv KING_prio_hidden,     0b000
 180              	.equiv KING_prio_last,       0b001
 181              	.equiv KING_prio_abovelast,  0b010
 182              	.equiv KING_prio_underfirst, 0b011
 183              	.equiv KING_prio_first,      0b100
 184              	
 185              	.equiv KING_size_8,     0b0011
 186              	.equiv KING_size_16,    0b0100
 187              	.equiv KING_size_32,    0b0101
 188              	.equiv KING_size_64,    0b0110
 189              	.equiv KING_size_128,   0b0111
 190              	.equiv KING_size_256,   0b1000
 191              	.equiv KING_size_512,   0b1001
 192              	.equiv KING_size_1024,  0b1010 /*only bg0*/
 193              	
 194              	.equiv KING_b_height,    0
 195              	.equiv KING_b_width,     4
 196              	.equiv KING_b_subheight, 8
 197              	.equiv KING_b_subwidth, 12
 198              	.equiv KING_b_inc, 18 /*for read/write*/
 199              	
 200              	.equiv KING_bg0_rotation,    (1<<12)
 201              	
 202              	.equiv SUP_SPR_on, (1<<6)
 203              	.equiv SUP_BG_on, (1<<7)
 204              	
 205              	/*============================================================= */
 206              	/* registers */
 207              	.equiv r_register, r6      /* goes to 0x300 */
 208              	.equiv r_value,    r7      /* goes to 0x304 */
 209              	.equiv r_tmp_loop, r20
 210              	.equiv r_tmp_adr,  r21
 211              	
 212              	.equiv r_tmp_data, r22
 213              	
 214              	.equiv r_tmp, r23
 215              	.equiv r_keypad, r29
 216              	
 217              	/*============================================================= */
 218              	#constants related to the Mandelbrot drawing routine
 219              	.equiv _fractal_height, 240
 220              	.equiv _fractal_width, 256
 221              	
 222              	/*============================================================= */
 223              	.equiv VEC_IRQ_VBLA,  0x7fcc
 224              	/* ============================================================= */
 225              	.org = 0x8000
 226              	
 227              	.global _start
 228              	_start:	
GAS LISTING mandelbrot.s 			page 5


 229              	
 230 0000 60BC2000 	    movw 0x200000, sp
 230      63A00000 
 231 0008 80BC0100 	    movw 0x8000, gp #technically this should be higher so it can make use of signed offsets
 231      84A00080 
 232              	    
 233 0010 C242     		mov     2, r22 /*;enable cache as default*/
 234 0012 D872     	    ldsr    r22, 24/*;CHCW*/
 235              		
 236 0014 C040     	    mov HuC6261_SCREENMODE, r_register	
 237 0016 E0BC0000 		movw ( HuC6261_line262 | HuC6261_intsync | HuC6261_256px | HuC6261_KingBG0_on | HuC6261_KingBG1_on
 237      E7A0010D 
 238 001e C0F40003 		out.h r_register, HuC6261_reg[r0]
 239 0022 E0F40403 		out.h r_value   , HuC6261_dat[r0]
 240              	
 241              	/* Tetsu palette */
 242 0026 C140     		mov HuC6261_PAL_NR, r_register	
 243 0028 E040     		mov 0, r_value
 244 002a C0F40003 		out.h r_register, HuC6261_reg[r0]
 245 002e E0F40403 		out.h r_value   , HuC6261_dat[r0]
 246              			
 247              	/* 	; 7up palette offsets */
 248 0032 C440     		mov HuC6261_PAL_7UP_OFF, r_register	/*; 7up palette offsets*/
 249 0034 E040     		mov 0, r_value	/*; BG & spr. offset = 0*/
 250 0036 C0F40003 		out.h r_register, HuC6261_reg[r0]
 251 003a E0F40403 		out.h r_value   , HuC6261_dat[r0]
 252              	
 253              	/* 	; KING BG0/1 palette offsets */
 254 003e C540     		mov HuC6261_PAL_KING_01, r_register/*; KING BG0/1 palette offsets*/
 255 0040 E040     		mov (0 | 0<<8), r_value	/*; Both offsets = 0*/
 256 0042 C0F40003 		out.h r_register, HuC6261_reg[r0]
 257 0046 E0F40403 		out.h r_value   , HuC6261_dat[r0]
 258              	
 259              	/* 	; Priority: 7up spr = 3, KING BG0 = 2, KING BG1 = 1 */
 260              	/* 	; Lower priorities go in the back. */
 261 004a C840     		mov HuC6261_PRIO_0, r_register	/*; 7up/Rainbow priority*/
 262 004c E0BC0000 		movw 0x010, r_value	/*; 7up spr = 3*/
 262      E7A01000 
 263 0054 C0F40003 		out.h r_register, HuC6261_reg[r0]
 264 0058 E0F40403 		out.h r_value   , HuC6261_dat[r0]
 265              		
 266 005c C940     		mov HuC6261_PRIO_1, r_register	/*; KING priority*/
 267 005e E0BC0000 		movw 0x0032, r_value	/*; BG0 = 2, BG1 = 1*/
 267      E7A03200 
 268 0066 C0F40003 		out.h r_register, HuC6261_reg[r0]
 269 006a E0F40403 		out.h r_value   , HuC6261_dat[r0]
 270              	
 271              	/* 	; Cellophane control: disable */
 272 006e C0BC0000 		movw HuC6261_CTRL_CELL, r_register	
 272      C6A00E00 
 273 0076 E040     		mov 0,r_value	/*; Disable*/
 274 0078 C0F40003 		out.h r_register, HuC6261_reg[r0]
 275 007c E0F40403 		out.h r_value   , HuC6261_dat[r0]
 276              	
 277              	/* 	; Initialize BG0 KRAM */
 278              	/* 	; (0 to 0x10000 - see BG0 CG address) */
 279 0080 80BE0100 		movw 0x10000, r_tmp_loop
GAS LISTING mandelbrot.s 			page 6


 279      94A20000 
 280              		
 281 0088 CD40     		mov KING_KRAM_ADR_write, r_register/*
 282              		mov r0, r_value/*	; Address = 0x000 here*/
 283 008a E142     		mov 1, r_tmp  /*increase by 1*/ 
 284 008c F252     		shl KING_b_inc, r_tmp
 285 008e F730     		or r_tmp, r_value
 286 0090 C0F40006 		out.h r_register, KING_reg[r0]
 287 0094 E0FC0406 		out.w r_value, KING_dat[r0]
 288              		
 289 0098 CE40     		mov KING_KRAM_rw, r_register
 290 009a C0F40006 		out.h r_register, KING_reg[r0]
 291              	.nextKRAMWrite1:	
 292 009e 00FC0406 		out.w r0, KING_dat[r0]
 293 00a2 9E46     		add -2, r_tmp_loop
 294 00a4 FA95     		bnz .nextKRAMWrite1
 295              	
 296              	/* 	; KRAM page setup: use page 0 for everything */
 297 00a6 CF40     		mov KING_KRAM_page, r_register
 298 00a8 E040     		mov (0<<8), r_value
 299              		/*; Everything = page 0*/
 300              	/*      0	KRAM page for SCSI */
 301              	/*      8	KRAM page for BG */
 302              	/*     16	KRAM page for RAINBOW */
 303              	/*     24	KRAM page for ADPCM */
 304 00aa C0F40006 		out.h r_register, KING_reg[r0]
 305 00ae E0FC0406 		out.w r_value, KING_dat[r0]
 306              	
 307              	/* 	; BG mode: BG0*/
 308 00b2 C0BC0000 		movw KING_BG_MODE, r_register
 308      C6A01000 
 309 00ba E0BC0000 		movw (KING_mode_256<<0 | KING_mode_256<<4 | 0<<8 | 0<<12), r_value 
 309      E7A03300 
 310 00c2 C0F40006 		out.h r_register, KING_reg[r0]
 311 00c6 E0F40406 		out.h r_value, KING_dat[r0]
 312              	
 313              	/* 	; BG priority*/
 314 00ca C0BC0000 		movw KING_BG_PRIO, r_register
 314      C6A01200 
 315 00d2 E0BC0000 		movw (KING_prio_underfirst | KING_prio_first<<3 | KING_prio_hidden<<6 | KING_prio_hidden<<8), r_va
 315      E7A02300 
 316 00da C0F40006 		out.h r_register, KING_reg[r0]
 317 00de E0F40406 		out.h r_value, KING_dat[r0]
 318              	
 319              	/* 	; KING microprogram */
 320 00e2 C0BC0000 		movw KING_MICRO_CTRL, r_register
 320      C6A01500 
 321 00ea E040     		mov 0, r_value	/*; Running = off*/
 322 00ec C0F40006 		out.h r_register, KING_reg[r0]
 323 00f0 E0F40406 		out.h r_value, KING_dat[r0]
 324              		
 325 00f4 C0BC0000 		movw KING_MICRO_ADR, r_register	
 325      C6A01300 
 326 00fc E040     		mov 0, r_value	/*; Address*/
 327 00fe C0F40006 		out.h r_register, KING_reg[r0]
 328 0102 E0F40406 		out.h r_value, KING_dat[r0]
 329              		
GAS LISTING mandelbrot.s 			page 7


 330 0106 A0A20000 		movwl .kingMicroprogram, r_tmp_adr
 330      B5BE0000 
 331 010e 80BE0000 		movw 16, r_tmp_loop
 331      94A21000 
 332              	
 333 0116 C0BC0000 		movw KING_MICRO_DATA, r_register	/*; Microprogram data*/
 333      C6A01400 
 334 011e C0F40006 		out.h r_register, KING_reg[r0]
 335              	.microprogramLoop:
 336 0122 F5C40000 		ld.h 0[r_tmp_adr], r_value
 337 0126 E0F40406 		out.h r_value, KING_dat[r0]
 338 012a A246     		add 2, r_tmp_adr
 339 012c 9F46     		add -1, r_tmp_loop
 340 012e F495     		bnz .microprogramLoop
 341              		
 342 0130 C0BC0000 		movw KING_MICRO_CTRL, r_register
 342      C6A01500 
 343 0138 E140     		mov 1, r_value/*	; Running = on*/
 344 013a C0F40006 		out.h r_register, KING_reg[r0]
 345 013e E0F40406 		out.h r_value, KING_dat[r0]
 346              	
 347              	/* 	; BG scroll mode */
 348 0142 C0BC0000 		movw KING_BG_SCROLL, r_register
 348      C6A01600 
 349 014a E040     		mov 0b0000, r_value	/*; BG0/1 = single background area*/
 350 014c C0F40006 		out.h r_register, KING_reg[r0]
 351 0150 E0F40406 		out.h r_value, KING_dat[r0]
 352              	
 353              	/* 	; BG0 CG address: it starts at 0 */
 354 0154 C0BC0000 		movw KING_BG0_CG, r_register
 354      C6A02100 
 355 015c E040     		mov 0, r_value
 356 015e C0F40006 		out.h r_register, KING_reg[r0]
 357 0162 E0F40406 		out.h r_value, KING_dat[r0]
 358              	
 359 0166 C0BC0000 		movw KING_BG0_CGsub, r_register
 359      C6A02300 
 360 016e E040     		mov 0, r_value
 361 0170 C0F40006 		out.h r_register, KING_reg[r0]
 362 0174 E0F40406 		out.h r_value, KING_dat[r0]
 363              		
 364              	 	/*; BG1 CG address*/
 365 0178 C0BC0000 	 	movw KING_BG1_CG, r_register	
 365      C6A02500 
 366 0180 E0BC0000 	 	movw 64, r_value /*64*1024*/
 366      E7A04000 
 367 0188 C0F40006 	 	out.h r_register, KING_reg[r0]
 368 018c E0F40406 		out.h r_value, KING_dat[r0] 
 369              	
 370 0190 C0BC0000 		movw KING_BG0_size, r_register
 370      C6A02C00 
 371 0198 E0BC0000 		movw ((KING_size_256 << KING_b_height) | (KING_size_256 << KING_b_width)) , r_value
 371      E7A08800 
 372 01a0 C0F40006 		out.h r_register, KING_reg[r0]
 373 01a4 E0F40406 		out.h r_value, KING_dat[r0]
 374              	
 375 01a8 C0BC0000 		movw KING_BG1_size, r_register
GAS LISTING mandelbrot.s 			page 8


 375      C6A02D00 
 376 01b0 E0BC0000 		movw ((KING_size_256 << KING_b_height) | (KING_size_256 << KING_b_width)) , r_value
 376      E7A08800 
 377 01b8 C0F40006 		out.h r_register, KING_reg[r0]
 378 01bc E0F40406 		out.h r_value, KING_dat[r0]
 379              		
 380              	/* 	; BG0 X/Y scroll */
 381 01c0 C0BC0000 		movw KING_BG0_X, r_register	
 381      C6A03000 
 382 01c8 E040     		mov 0, r_value
 383 01ca C0F40006 		out.h r_register, KING_reg[r0]
 384 01ce E0F40406 		out.h r_value, KING_dat[r0]
 385 01d2 C0BC0000 		movw KING_BG0_Y, r_register	
 385      C6A03100 
 386 01da E040     		mov 0, r_value
 387 01dc C0F40006 		out.h r_register, KING_reg[r0]
 388 01e0 E0F40406 		out.h r_value, KING_dat[r0]
 389              	
 390 01e4 C0BC0000 		movw KING_BG1_X, r_register
 390      C6A03200 
 391 01ec E040     		mov 0, r_value
 392 01ee C0F40006 		out.h r_register, KING_reg[r0]
 393 01f2 E0F40406 		out.h r_value, KING_dat[r0]
 394 01f6 C0BC0000 		movw KING_BG1_Y, r_register
 394      C6A03300 
 395 01fe E040     		mov 0, r_value
 396 0200 C0F40006 		out.h r_register, KING_reg[r0]
 397 0204 E0F40406 		out.h r_value, KING_dat[r0]
 398              		
 399              		#depack border gfx into RAM buffer
 400 0208 40A10000 	    movwl border_img, r10
 400      4ABD0000 
 401 0210 60A10000 	    movwl buffer, r11
 401      6BBD0000 
 402 0218 7C44E3DF 	    call depack/*;r10=source, r11=destination; 124 Bytes*/
 402      000000AC 
 402      DA06E3CF 
 402      00006444 
 403 0228 7C44E3DF 	    call upload_bitmap
 403      000000AC 
 403      9206E3CF 
 403      00006444 
 404              	    
 405              	
 406 0238 CA40     		mov SUP_HSYNC, r_register
 407 023a E0BC0000 		movw 0x0202, r_value/*	; Eris and MagicKit say 0x202*/
 407      E7A00202 
 408 0242 C0F40004 		out.h r_register, SUPA_reg[r0]
 409 0246 E0F40404 		out.h r_value, SUPA_dat[r0]
 410              		
 411 024a CB40     		mov SUP_HDISP, r_register
 412 024c E0BC0000 		movw 0x041f, r_value	/*; Eris says 0x41F, MagicKit says 0x31F*/
 412      E7A01F04 
 413 0254 C0F40004 		out.h r_register, SUPA_reg[r0]
 414 0258 E0F40404 		out.h r_value, SUPA_dat[r0]
 415              		
 416 025c CC40     		mov SUP_VSYNC, r_register
GAS LISTING mandelbrot.s 			page 9


 417 025e E0BC0000 		movw 0x1102, r_value	/*; Eris says 0x1102, MagicKit says 0xF02*/
 417      E7A00211 
 418 0266 C0F40004 		out.h r_register, SUPA_reg[r0]
 419 026a E0F40404 		out.h r_value, SUPA_dat[r0]
 420              		
 421 026e CD40     		mov SUP_VDISP, r_register
 422 0270 E0BC0000 		movw 0xEF, r_value	/*; Eris and MagicKit say 0xEF*/
 422      E7A0EF00 
 423 0278 C0F40004 		out.h r_register, SUPA_reg[r0]
 424 027c E0F40404 		out.h r_value, SUPA_dat[r0]
 425              		
 426 0280 CE40     		mov SUP_VDISPEND, r_register
 427 0282 E240     		mov 2, r_value/*	; Eris says 2, MagicKit says 3*/
 428 0284 C0F40004 		out.h r_register, SUPA_reg[r0]
 429 0288 E0F40404 		out.h r_value, SUPA_dat[r0]
 430              	
 431              	/* set IRQ for 7UP vblank */
 432              	 
 433 028c C540     		mov SUP_CTRL, r_register	/*; DMA control*/
 434 028e E0BC0000 		movw (1<<3), r_value	/*; vblank*/
 434      E7A00800 
 435 0296 C0F40004 		out.h r_register, SUPA_reg[r0]
 436 029a E0F40404 		out.h r_value, SUPA_dat[r0]
 437              		
 438              		
 439 029e 7C44E3DF 		call put_palette 
 439      000000AC 
 439      D805E3CF 
 439      00006444 
 440              	
 441              	 #METHOD 1 to set the VECTOR JUMP
 442 02ae 40BD0000 	    movw	VEC_IRQ_VBLA, r10
 442      4AA1CC7F 
 443 02b6 60A10000 	    movwl irq_handler ,r11
 443      6BBD0000 
 444 02be 6A09     		sub	r10, r11
 445 02c0 6AD50200 		st.h	r11, 2[r10]
 446 02c4 7055     		shr	16, r11
 447 02c6 6BB5FF03 		andi	0x03FF, r11, r11
 448 02ca 6BB100A8 		ori	0xA800, r11, r11
 449 02ce 6AD50000 		st.h	r11, 0[r10]
 450              		
 451              		#mask 
 452 02d2 C0BE0000 	    movw (~(1<<3)&0x7f), r_tmp_data
 452      D6A27700 
 453 02da C0F6400E 		out.h r_tmp_data, 0xe40[zero]
 454 02de 00A85E00 		jr skip_handler
 455              	
 456              	#----------------------------------
 457              	irq_handler:
 458 02e2 63A4E0FF 	    addi	-0x20, sp, sp
 459 02e6 A3DE0000 		st.w	r_tmp_adr, 0x00[sp]
 460 02ea 83DE0400 		st.w	r_tmp_loop, 0x04[sp]
 461 02ee C3DE0800 		st.w	r_tmp_data, 0x08[sp]
 462 02f2 7C44E3DF 	    call update_palette 
 462      000000AC 
 462      8E05E3CF 
GAS LISTING mandelbrot.s 			page 10


 462      00006444 
 463 0302 7C44E3DF 	    call cycle 
 463      000000AC 
 463      4C05E3CF 
 463      00006444 
 464 0312 7C44E3DF 	    call mypcfxReadPad0
 464      000000AC 
 464      7A03E3CF 
 464      00006444 
 465 0322 C3CE0800 		ld.w	0x08[sp], r_tmp_data
 466 0326 83CE0400 		ld.w	0x04[sp], r_tmp_loop
 467 032a A3CE0000 		ld.w	0x00[sp], r_tmp_adr
 468 032e 63A42000 		addi	0x20, sp, sp
 469 0332 00E40004 		in.h SUPA_reg[zero],r0 #clear IRQ flag
 470 0336 00E40000 		in.h 0[r0],r0 #clear pad irq?
 471 033a 0064     	    reti
 472              	#----------------------------------    
 473              	skip_handler:
 474              	/* 	cli, oh CLI is nintendo only. Bleh.... */
 475              	/* http://perfectkiosk.net/stsvb.html#cpu_psw */
 476 033c E576     	    stsr	PSW, r_tmp /*current sys reg */
 477 033e C0BE0000 	    movw	~(1<<12),  r_tmp_data /*1<<12 = 0x1000*/
 477      D6A2FFEF 
 478 0346 D736     		and	r_tmp, r_tmp_data /*keep formerly set bits*/
 479 0348 C572     		ldsr	r_tmp_data, PSW
 480              		
 481              		#set level too
 482 034a CC40     		mov 12, r6 #level
 483 034c 4575     		stsr	PSW, r10
 484 034e D050     		shl	16, r6
 485 0350 E0BC0100 		movw 0b00000000000000001111111111111111, r7 #mask out level 16-19, 20-31 = undef
 485      E7A0FFFF 
 486 0358 4735     		and r7,r10
 487 035a 4631     		or  r6,r10
 488 035c 4571     		ldsr	r10, PSW
 489              	/* 	=================================== */
 490              	
 491              	    #prepare dirty for redraw
 492 035e E142     	    mov 1, r_tmp
 493 0360 E4D20000 	    st.b r_tmp,zdaoff(dirty)[gp]
 494              	    
 495 0364 7C44E3DF 	    call set_full_size
 495      000000AC 
 495      8203E3CF 
 495      00006444 
 496 0374 E0BE0000 	    movw 16,r_tmp
 496      F7A21000 
 497 037c E4D60000 	    st.h r_tmp, zdaoff(iterations)[gp]
 498              	/* 	=================================== */	
 499              	.loop:	
 500              	
 501 0380 E4C20000 	    ld.b zdaoff(dirty)[gp],r_tmp 
 502 0384 E00E     	     cmp r0, r_tmp 
 503 0386 1684     	     bz _skip_compute 
 504              	    
 505 0388 04D00000 	     st.b r0,zdaoff(dirty)[gp] 
 506 038c 7C44E3DF 	     call plot_mandelbrot 
GAS LISTING mandelbrot.s 			page 11


 506      000000AC 
 506      8203E3CF 
 506      00006444 
 507              	    
 508              	_skip_compute:
 509 039c 7C44E3DF 	    call transfer_result
 509      000000AC 
 509      7A04E3CF 
 509      00006444 
 510              		
 511              	
 512              		
 513              	/* 	first check buttons */
 514 03ac 1DB40100 		andi (1<<0), r_keypad, r0	/*; Button I */
 515 03b0 1E84     		bz .checkButton2
 516              	.Button1:
 517              	/*     iter++ */
 518 03b2 44C50000 	    ld.h zdaoff(iterations)[gp], r10
 519 03b6 4245     	    add 2,r10
 520 03b8 44D50000 	    st.h r10,zdaoff(iterations)[gp]
 521 03bc 7C44E3DF 	     call set_full_size 
 521      000000AC 
 521      2A03E3CF 
 521      00006444 
 522 03cc B48B     	    br .loop
 523              	
 524              	.checkButton2:
 525 03ce 1DB40200 		andi (1<<1), r_keypad, r0	/*; Button II */
 526 03d2 1E84     		bz .checkButton3
 527              	.Button2: /*     iter++ */
 528 03d4 44C50000 	    ld.h zdaoff(iterations)[gp], r10
 529 03d8 5E45     	    add -2,r10
 530 03da 44D50000 	    st.h r10,zdaoff(iterations)[gp]
 531 03de 7C44E3DF 	     call set_full_size 
 531      000000AC 
 531      0803E3CF 
 531      00006444 
 532 03ee 928B     	    br .loop
 533              	
 534              	.checkButton3:
 535 03f0 1DB40400 		andi (1<<2), r_keypad, r0	/*; Button III */
 536 03f4 5284     		bz .checkButton4
 537              	.Button3: /*zoom in*/
 538 03f6 24C50000 	    ld.h zdaoff(xpixsize)[gp], r9
 539 03fa 2451     	    shl 4,r9 
 540 03fc 44C50000 	    ld.h zdaoff(add_left)[gp], r10
 541 0400 4905     	    add r9,r10
 542 0402 44D50000 	    st.h r10, zdaoff(add_left)[gp]
 543 0406 44C50000 	    ld.h zdaoff(add_right)[gp], r10
 544 040a 4909     	    sub r9,r10
 545 040c 44D50000 	    st.h r10, zdaoff(add_right)[gp]
 546              	    
 547 0410 24C50000 	    ld.h zdaoff(ypixsize)[gp], r9
 548 0414 2451     	    shl 4,r9 
 549 0416 44C50000 	    ld.h zdaoff(add_top)[gp], r10
 550 041a 4905     	    add r9,r10
 551 041c 44D50000 	    st.h r10, zdaoff(add_top)[gp]
GAS LISTING mandelbrot.s 			page 12


 552 0420 44C50000 	    ld.h zdaoff(add_bottom)[gp], r10
 553 0424 4909     	    sub r9,r10
 554 0426 44D50000 	    st.h r10, zdaoff(add_bottom)[gp]
 555              	    
 556 042a 44C50000 	    ld.h zdaoff(iterations)[gp], r10 
 557 042e 4245     	    add 2,r10
 558 0430 44D50000 	    st.h r10,zdaoff(iterations)[gp]
 559 0434 7C44E3DF 	    call set_full_size
 559      000000AC 
 559      B202E3CF 
 559      00006444 
 560 0444 3C8B     	    br .loop
 561              	    
 562              	.checkButton4:
 563 0446 1DB40800 	    andi (1<<3), r_keypad, r0	/*; Button IV */
 564 044a 5484     		bz .checkup
 565              	.Button4: /*zoom in*/
 566 044c 24C50000 	    ld.h zdaoff(xpixsize)[gp], r9
 567 0450 2451     	    shl 4,r9 
 568 0452 44C50000 	    ld.h zdaoff(add_left)[gp], r10
 569 0456 4909     	    sub r9,r10
 570 0458 44D50000 	    st.h r10, zdaoff(add_left)[gp]
 571 045c 44C50000 	    ld.h zdaoff(add_right)[gp], r10
 572 0460 4905     	    add r9,r10
 573 0462 44D50000 	    st.h r10, zdaoff(add_right)[gp]
 574              	    
 575 0466 24C50000 	    ld.h zdaoff(ypixsize)[gp], r9
 576 046a 2451     	    shl 4,r9 
 577 046c 44C50000 	    ld.h zdaoff(add_top)[gp], r10
 578 0470 4909     	    sub r9,r10
 579 0472 44D50000 	    st.h r10, zdaoff(add_top)[gp]
 580 0476 44C50000 	    ld.h zdaoff(add_bottom)[gp], r10
 581 047a 4905     	    add r9,r10
 582 047c 44D50000 	    st.h r10, zdaoff(add_bottom)[gp]
 583              	    
 584 0480 44C50000 	    ld.h zdaoff(iterations)[gp], r10 
 585 0484 5E45     	    add -2,r10
 586 0486 44D50000 	    st.h r10,zdaoff(iterations)[gp]
 587 048a 7C44E3DF 	    call set_full_size
 587      000000AC 
 587      5C02E3CF 
 587      00006444 
 588 049a FFABE6FE 	    br .loop
 589              	    
 590              	.checkup:    
 591 049e 1DB40001 		andi (1<<8), r_keypad, r0	/*; Up?*/
 592 04a2 7884     		bz .checkPadDown
 593              		
 594              	.joy_up:
 595              		
 596              	/* 	;scroll BUFFER up */
 597 04a4 40A10000 	    movwl (buffer), r10 
 597      4ABD0000 
 598 04ac 00BD0000 	    movw (_fractal_height-16),r8 /*;lines*/
 598      08A1E000 
 599              	_loop2c:
 600 04b4 20BD0000 	    movw (_fractal_width/4),r9 /*;full width */
GAS LISTING mandelbrot.s 			page 13


 600      29A14000 
 601              	_loop1c:
 602 04bc 6ACD0010 	    ld.w (256*16)[r10], r11 /*we move by 16 lines*/
 603 04c0 6ADD0000 	    st.w r11,0[r10]
 604 04c4 4445     	    add 4,r10
 605 04c6 3F45     	    add -1, r9
 606 04c8 F495     	    bne _loop1c
 607              	/*     addi (256-192),r10,r10  */
 608 04ca 1F45     	    add -1, r8
 609 04cc E895     	    bne _loop2c
 610              	    
 611 04ce 24C50000 	    ld.h zdaoff(ypixsize)[gp], r9
 612 04d2 2451     	    shl 4,r9 /*;faster in case we have power of 2 steps*/
 613              	     
 614 04d4 44C50000 	    ld.h zdaoff(add_top)[gp], r10
 615 04d8 4905     	    add r9,r10
 616 04da 44D50000 	    st.h r10, zdaoff(add_top)[gp]
 617              	    
 618 04de 44C50000 	    ld.h zdaoff(add_bottom)[gp], r10
 619 04e2 4905     	    add r9,r10
 620 04e4 44D50000 	    st.h r10, zdaoff(add_bottom)[gp]
 621              	    
 622              	/*   plot full width next time */
 623 04e8 04D40000 	    st.h r0,zdaoff(startx)[gp]
 624 04ec E0BE0000 	    movw _fractal_width,r_tmp
 624      F7A20001 
 625 04f4 E4D60000 	    st.h r_tmp,zdaoff(endx)[gp]
 626              	    
 627              	/*     but only start near the bottom to fill the new 16 pix gap */
 628 04f8 E0BE0000 	    movw (_fractal_height-16),r_tmp 
 628      F7A2E000 
 629 0500 E4D60000 	    st.h r_tmp,zdaoff(starty)[gp]
 630 0504 E0BE0000 	    movw _fractal_height,r_tmp 
 630      F7A2F000 
 631 050c E4D60000 	    st.h r_tmp,zdaoff(endy)[gp]
 632              	    
 633 0510 E142     	    mov 1,r_tmp/*;also prepare redraw*/
 634 0512 E4D20000 	    st.b r_tmp, zdaoff(dirty)[gp]
 635 0516 FFAB6AFE 	    br .loop /*ret*/
 636              	    
 637              	.checkPadDown:
 638 051a 1DB40004 		andi (1<<10), r_keypad, r0/*	; Down?*/
 639 051e 7484     		bz .checkPadLeft
 640              		
 641              	.joydown:
 642              		
 643              	/*     ;scroll BUFFER down */
 644 0520 40A10000 	    movwl (buffer+256*(_fractal_height-16)), r10 
 644      4ABD0000 
 645 0528 00BD0000 	    movw (_fractal_height-15),r8 
 645      08A1E100 
 646              	_loop2d:
 647 0530 20BD0000 	    movw ((_fractal_width)/4),r9 
 647      29A14000 
 648              	_loop1d:
 649 0538 6ACD0000 	    ld.w 0[r10], r11
 650 053c 6ADD0010 	    st.w r11,256*16[r10]
GAS LISTING mandelbrot.s 			page 14


 651 0540 4445     	    add 4,r10
 652 0542 3F45     	    add -1, r9
 653 0544 F495     	    bne _loop1d
 654 0546 4AA500FE 	    addi (-(256+_fractal_width)),r10,r10 
 655 054a 1F45     	    add -1, r8
 656 054c E495     	    bne _loop2d
 657              	    
 658 054e 24C50000 	    ld.h zdaoff(ypixsize)[gp], r9
 659 0552 2451     	    shl 4,r9
 660              	     
 661 0554 44C50000 	    ld.h zdaoff(add_top)[gp], r10
 662 0558 4909     	    sub r9,r10
 663 055a 44D50000 	    st.h r10, zdaoff(add_top)[gp]
 664 055e 44C50000 	    ld.h zdaoff(add_bottom)[gp]], r10
 665 0562 4909     	    sub r9,r10
 666 0564 44D50000 	    st.h r10, zdaoff(add_bottom)[gp]
 667              	    
 668 0568 04D40000 	    st.h r0,zdaoff(startx)[gp]
 669 056c E0BE0000 	    movw _fractal_width,r_tmp
 669      F7A20001 
 670 0574 E4D60000 	    st.h r_tmp,zdaoff(endx)[gp]
 671              	    
 672 0578 04D40000 	    st.h r0,zdaoff(starty)[gp]
 673 057c E0BE0000 	    movw 16,r_tmp 
 673      F7A21000 
 674 0584 E4D60000 	    st.h r_tmp,zdaoff(endy)[gp]
 675              	    
 676 0588 E142     	    mov 1,r_tmp
 677 058a E4D20000 	    st.b r_tmp, zdaoff(dirty)[gp]
 678 058e FFABF2FD 	    br .loop
 679              	
 680              	.checkPadLeft:
 681 0592 1DB40008 		andi (1<<11), r_keypad, r0/*	; Left?*/
 682 0596 7E84     		bz .checkPadRight
 683              	.joy_left:	
 684 0598 BF46     		add -1, r21
 685 059a 40A10000 		movwl (buffer), r10
 685      4ABD0000 
 686 05a2 00BD0000 	    movw _fractal_height,r8 
 686      08A1F000 
 687              	_loop2:
 688 05aa 20BD0000 	    movw ((_fractal_width-16+4)/4),r9 /*;full width minus shifts*/
 688      29A13D00 
 689              	_loop1:
 690 05b2 6ACD1000 	    ld.w 16[r10], r11
 691 05b6 6ADD0000 	    st.w r11,0[r10]
 692 05ba 4445     	    add 4,r10
 693 05bc 3F45     	    add -1, r9
 694 05be F495     	    bne _loop1
 695 05c0 4AA50C00 	    addi (256-(_fractal_width-16+4)),r10,r10 
 696 05c4 1F45     	    add -1, r8
 697 05c6 E495     	    bne _loop2
 698              	    
 699 05c8 24C50000 	    ld.h zdaoff(xpixsize)[gp], r9
 700 05cc 2451     	    shl 4,r9 
 701              	     
 702 05ce 44C50000 	    ld.h zdaoff(add_left)[gp], r10
GAS LISTING mandelbrot.s 			page 15


 703 05d2 4905     	    add r9,r10
 704 05d4 44D50000 	    st.h r10, zdaoff(add_left)[gp]
 705 05d8 44C50000 	    ld.h zdaoff(add_right)[gp], r10
 706 05dc 4905     	    add r9,r10
 707 05de 44D50000 	    st.h r10, zdaoff(add_right)[gp]
 708              	    
 709 05e2 E0BE0000 	    movw (_fractal_width-16-4),r_tmp
 709      F7A2EC00 
 710 05ea E4D60000 	    st.h r_tmp,zdaoff(startx)[gp]
 711 05ee E0BE0000 	    movw (_fractal_width),r_tmp
 711      F7A20001 
 712 05f6 E4D60000 	    st.h r_tmp,zdaoff(endx)[gp]
 713              	    
 714 05fa 04D40000 	    st.h r0,zdaoff(starty)[gp]
 715 05fe E0BE0000 	    movw _fractal_height,r_tmp
 715      F7A2F000 
 716 0606 E4D60000 	    st.h r_tmp,zdaoff(endy)[gp]
 717              	    
 718 060a E142     	    mov 1,r_tmp
 719 060c E4D20000 	    st.b r_tmp, zdaoff(dirty)[gp]
 720 0610 FFAB70FD 		br .loop
 721              		
 722              	.checkPadRight:
 723 0614 1DB40002 		andi (1<<9), r_keypad, r0	/*; Right?*/
 724 0618 7684     		bz .check_next
 725              	.joy_right:
 726 061a A146     		add 1, r21
 727 061c 40A10000 		movwl (buffer+_fractal_width-4), r10
 727      4ABD0000 
 728 0624 00BD0000 	    movw _fractal_height,r8 
 728      08A1F000 
 729              	_loop2b:
 730 062c 20BD0000 	    movw ((_fractal_width-16)/4),r9
 730      29A13C00 
 731              	_loop1b:
 732              	/*     ;write to the right end the value of right_end - 16 */
 733 0634 6ACDF0FF 	    ld.w -16[r10], r11
 734 0638 6ADD0000 	    st.w r11,0[r10]
 735 063c 5C45     	    add -4,r10
 736 063e 3F45     	    add -1, r9
 737 0640 F495     	    bne _loop1b
 738 0642 4AA5F001 	    addi (256+_fractal_width-16),r10,r10 
 739 0646 1F45     	    add -1, r8
 740 0648 E495     	    bne _loop2b
 741              	  
 742 064a 24C50000 	    ld.h zdaoff(xpixsize)[gp], r9
 743 064e 2451     	    shl 4,r9 
 744              	    
 745 0650 44C50000 	    ld.h zdaoff(add_left)[gp], r10
 746 0654 4909     	    sub r9,r10
 747 0656 44D50000 	    st.h r10, zdaoff(add_left)[gp]
 748 065a 44C50000 	    ld.h zdaoff(add_right)[gp], r10
 749 065e 4909     	    sub r9,r10
 750 0660 44D50000 	    st.h r10, zdaoff(add_right)[gp]
 751              	    
 752 0664 04D40000 	    st.h r0,zdaoff(startx)[gp]
 753 0668 E0BE0000 	    movw 16,r_tmp
GAS LISTING mandelbrot.s 			page 16


 753      F7A21000 
 754 0670 E4D60000 	    st.h r_tmp,zdaoff(endx)[gp]
 755              	    
 756 0674 04D40000 	    st.h r0,zdaoff(starty)[gp]
 757 0678 E0BE0000 	    movw _fractal_height,r_tmp
 757      F7A2F000 
 758 0680 E4D60000 	    st.h r_tmp,zdaoff(endy)[gp]
 759              	    
 760 0684 E142     	    mov 1,r_tmp
 761 0686 E4D20000 	    st.b r_tmp, zdaoff(dirty)[gp]
 762 068a FFABF6FC 		br .loop
 763              		
 764              	.check_next:	
 765 068e FFABF2FC 		br .loop
 766              	mypcfxReadPad0:	
 767 0692 A543     	    mov 5, r_keypad	/*; 5 = Transmit enable + receive enable*/
 768 0694 A0F70000 		out.h r_keypad, 0x00[r0]
 769              	wait_for_input_ready:	
 770 0698 A0E70000 		in.h 0x00[r0], r_keypad
 771 069c BDB70900 		andi 9, r_keypad, r_keypad
 772 06a0 A14F     		cmp 1, r_keypad	/*; 9 = Received data + unknown*/
 773 06a2 F685     		bz wait_for_input_ready
 774 06a4 A0EF4000 		in.w 0x40[r0], r_keypad
 775 06a8 1F18     		ret
 776              	/* ============================================================= */
 777 06aa 0000     	.align 2
 778              	
 779              	 /* alignment required ? */
 780              	/*  01000001 =0x41=bit6 =1 = BG1 */
 781              	/*  76543210 */
 782              	 
 783              	.kingMicroprogram:
 784 06ac 0000     	.hword 0x0000
 785 06ae 0100     	.hword 0x0001
 786 06b0 0200     	.hword 0x0002
 787 06b2 0300     	.hword 0x0003
 788 06b4 4000     	.hword 0x0040 
 789 06b6 4100     	.hword 0x0041 
 790 06b8 4200     	.hword 0x0042 
 791 06ba 4300     	.hword 0x0043 
 792              	
 793 06bc 0001     	.hword 0x0100
 794 06be 0001     	.hword 0x0100
 795 06c0 0001     	.hword 0x0100
 796 06c2 0001     	.hword 0x0100
 797 06c4 0001     	.hword 0x0100
 798 06c6 0001     	.hword 0x0100
 799 06c8 0001     	.hword 0x0100
 800 06ca 0001     	.hword 0x0100
 801              	
 802 06cc 00000000 	.align 4
 803 06d0 0000     	add_left:  .hword 0x0000
 804 06d2 0000     	add_right: .hword 0x0000
 805 06d4 0000     	add_top:   .hword 0x0000
 806 06d6 0000     	add_bottom: .hword 0x0000
 807 06d8 0000     	xpixsize: .hword 0x0000
 808 06da 0000     	ypixsize: .hword 0x0000
GAS LISTING mandelbrot.s 			page 17


 809 06dc 0000     	startx: .hword 0x0000
 810 06de 0000     	starty: .hword 0x0000
 811 06e0 0000     	endx: .hword 0x0000
 812 06e2 0000     	endy: .hword 0x0000
 813 06e4 0000     	dirty: .hword 0x0000
 814 06e6 0000     	iterations: .hword 0x0000
 815              	
 816 06e8 0000     	spritex: .hword 0x0000
 817 06ea 0000     	spritey: .hword 0x0000
 818              	
 819              	.align 2
 820              	set_full_size:
 821              	
 822 06ec 04D40000 	    st.h r0,zdaoff(startx)[gp]
 823              	    
 824 06f0 60BF0000 	    movw _fractal_width,r27
 824      7BA30001 
 825 06f8 64D70000 	    st.h r27,zdaoff(endx)[gp]
 826              	    
 827 06fc 04D40000 	    st.h r0,zdaoff(starty)[gp]
 828              	    
 829 0700 60BF0000 	    movw _fractal_height,r27
 829      7BA3F000 
 830 0708 64D70000 	    st.h r27,zdaoff(endy)[gp]
 831              	    
 832 070c E142     	    mov 1,r_tmp/*;also prepare redraw*/
 833 070e E4D20000 	    st.b r_tmp, zdaoff(dirty)[gp]
 834 0712 1F18     	    ret
 835              	    
 836              	plot_mandelbrot:
 837 0714 60BD0000 	     movw (-18337-4000+1000),r11/* ;#xmin -1.26136183 * 2**13 =-10333*/
 837      6BA1A7AC 
 838 071c 80BD0000 		 movw (6869-12000),r12 /*;#xmax -1.24763480*/
 838      8CA1F5EB 
 839 0724 A0BD0000 	     movw (-12602),r13 /*;#ymin 0.37648215*/
 839      ADA1C6CE 
 840 072c C0BD0000 	     movw (12602-10000),r14 /*;#ymax 0.38676353*/
 840      CEA12A0A 
 841              	     
 842 0734 E4C50000 	     ld.h zdaoff(add_left)[gp], r15
 843 0738 6F05     	     add r15,r11
 844              	
 845 073a E4C50000 	     ld.h zdaoff(add_right)[gp], r15
 846 073e 8F05     	     add r15,r12
 847              	
 848 0740 E4C50000 	     ld.h zdaoff(add_top)[gp], r15
 849 0744 AF05     	     add r15,r13
 850              	  
 851 0746 E4C50000 	     ld.h zdaoff(add_bottom)[gp], r15
 852 074a CF05     	     add r15,r14
 853              	     
 854 074c E0BE0000 	     movw (16384), r23
 854      F7A20040 
 855 0754 00BF0010 		 movw (268435456),r24
 855      18A30000 
 856              		 
 857              	bigloop:
GAS LISTING mandelbrot.s 			page 18


 858              	
 859 075c 40A20000 	    movwl buffer, r18 
 859      52BE0000 
 860 0764 60BF0000 	    movw 8*16,r27 
 860      7BA38000 
 861 076c 4C00     	    mov r12,r2
 862 076e 4B08     	    sub r11,r2
 863 0770 5B24     	    div r27,r2   
 864 0772 44D40000 	    st.h r2, zdaoff(xpixsize)[gp]
 865 0776 60BF0000 	    movw 8*16,r27
 865      7BA38000 
 866 077e 6E02     	    mov r14,r19
 867 0780 6D0A     	    sub r13,r19
 868 0782 7B26     	    div r27,r19
 869 0784 64D60000 	    st.h r19,zdaoff(ypixsize)[gp]
 870              	    
 871 0788 A4C40000 	    ld.h zdaoff(starty)[gp], r5
 872              	
 873              	loopy:
 874 078c E500     	    mov r5,r7
 875 078e F320     	    mul r19,r7
 876 0790 ED04     	    add r13,r7
 877 0792 C4C40000 	    ld.h zdaoff(startx)[gp], r6
 878              	loopx:
 879 0796 0601     	    mov r6,r8 
 880 0798 0221     	    mul r2,r8
 881 079a 0B05     	    add r11,r8
 882 079c 2041     	    mov 0,r9
 883 079e 4041     	    mov 0,r10
 884 07a0 4043     	    mov 0,r26
 885 07a2 C4C60000 	    ld.h zdaoff(iterations)[gp], r22 
 886              	innerloop: 
 887 07a6 8A02     	    mov r10,r20
 888 07a8 9A06     	    add r26,r20
 889 07aa AA02     	    mov r10,r21
 890 07ac BA0A     	    sub r26,r21
 891              	    
 892 07ae 3401     	    mov r20,r9
 893 07b0 3521     	    mul r21,r9
 894 07b2 2D5D     	    sar 13,r9
 895              	  
 896 07b4 2805     	    add r8,r9
 897              	
 898 07b6 8A02     	    mov r10,r20
 899 07b8 9A22     	    mul r26,r20
 900 07ba 8D5E     	    sar 13,r20
 901              	
 902 07bc 5703     	    mov r23,r26
 903 07be 5423     	    mul r20, r26 
 904 07c0 4D5F     	    sar 13,r26   
 905 07c2 4707     	    add r7,r26    
 906              	    
 907 07c4 4901     	    mov r9,r10
 908 07c6 8902     	    mov r9,r20
 909 07c8 8922     	    mul r9,r20
 910              	
 911 07ca BA02     	    mov r26,r21
GAS LISTING mandelbrot.s 			page 19


 912 07cc BA22     	    mul r26,r21
 913 07ce 9506     	    add r21,r20
 914              	          
 915 07d0 140F     	    cmp r20, r24 
 916 07d2 108C     	    blt exitloop
 917              	     
 918 07d4 DF46     	    add -1,r22
 919 07d6 D095     	    bne innerloop
 920              	     
 921 07d8 C0BE0000 	    movw 1, r22
 921      D6A20100 
 922              	/*inner part of mandelbrot*/
 923              	/*     0 = transparent */
 924              	/*     1 - also black now */
 925 07e0 0E8A     	    br special 
 926              	    
 927              	exitloop:
 928 07e2 C152     	    shl 1,r22
 929              	 
 930              	/*   here we could avoid to have the reserved backdrop color being used */
 931              	/*     mul r22,r22 */
 932              	/*     andi 0xff,r22,r22 */
 933              	
 934 07e4 D6B63F00 	    andi 0x3f,r22,r22
 935              	    #avoid this wrapping to 0 or 1
 936              	    #in case we have >63 iterations!
 937 07e8 C14E     	    cmp 1, r22
 938 07ea 049E     	    bgt valid_value
 939              	    
 940 07ec C242     	    mov 2,r22
 941              	valid_value:    
 942              	special:
 943              	/*     plot pixel   */
 944 07ee 6503     	    mov r5, r27
 945              	/*     shl 8, r27 */
 946 07f0 6853     	    shl 8, r27 /* y*256 */
 947 07f2 6607     	    add r6,r27 /* +x */
 948              	/*     NOW INVERSE X%1 steps to have big endian data! */
 949              	
 950 07f4 7207     	    add r18,r27
 951 07f6 86B60100 	    andi 0x1, r6,r20 
 952 07fa 0884     	    bz plot_right
 953 07fc DBD2FFFF 	    st.b r22, -1[r27]
 954 0800 068A     	    br plot_left
 955              	plot_right:     
 956 0802 DBD20100 	    st.b r22, 0x1[r27]
 957              	plot_left:    
 958 0806 C144     	    add 1, r6
 959 0808 84C60000 	    ld.h zdaoff(endx)[gp], r20
 960 080c 860E     	    cmp r6,r20
 961 080e 8895     	    bne loopx
 962              	     
 963 0810 A144     	    add 1,r5
 964 0812 84C60000 	    ld.h zdaoff(endy)[gp], r20
 965 0816 850E     	    cmp r5,r20
 966 0818 7495     	    bne loopy
 967 081a 1F18     	    ret 
GAS LISTING mandelbrot.s 			page 20


 968              	/*    =================================== */
 969              	
 970              	transfer_result:
 971              	/* http://daifukkat.su/pcfx/data/memmap.html */
 972              	/* you can use bitstring here as well */
 973 081c 80BE0100 	    movw 0x10000, r_tmp_loop
 973      94A20000 
 974 0824 A0A20000 		movwl buffer, r_tmp_adr
 974      B5BE0000 
 975              	
 976 082c CD40     		mov KING_KRAM_ADR_write, r_register
 977 082e E0BC0400 		movw (0x00000 | (1 << KING_b_inc)) , r_value
 977      E7A00000 
 978 0836 C0F40006 		out.h r_register, KING_reg[r0]
 979 083a E0FC0406 		out.w r_value, KING_dat[r0]
 980              		
 981 083e CE40     		mov KING_KRAM_rw, r_register
 982 0840 C0F40006 	    out.h r_register, KING_reg[r0]
 983              	.tloop:
 984 0844 F5CC0000 		ld.w 0x0[r_tmp_adr], r_value
 985 0848 E0FC0406 		out.w r_value, (KING_dat)[r0]
 986 084c A446     		add 4, r_tmp_adr 
 987 084e 9C46     		add -4, r_tmp_loop
 988 0850 F495     		bnz .tloop
 989 0852 1F18     		ret
 990              	
 991              	cycle:
 992              	/*     ;move first color to back and then all one up */
 993              	/* but col 00 = transparent */
 994              	/* col 01 = kept black */
 995 0854 A0A20000 	        movwl test_palette+4, r_tmp_adr
 995      B5BE0000 
 996 085c D5C60000 	        ld.h 0[r_tmp_adr],r_tmp_data
 997 0860 D5D67E00 	        st.h r_tmp_data,(63*2)[r_tmp_adr]
 998 0864 80BE0000 	        movw 63*2, r_tmp_loop
 998      94A27E00 
 999              	_loopcy:
 1000 086c D5C60200 	        ld.h 2[r_tmp_adr],r_tmp_data
 1001 0870 D5D60000 	        st.h r_tmp_data,0[r_tmp_adr]
 1002 0874 A246     	        add  2, r_tmp_adr
 1003 0876 9E46     	        add -2, r_tmp_loop
 1004 0878 F495     	        bne _loopcy
 1005 087a 1F18     	    ret
 1006              	 
 1007              	put_palette:
 1008 087c 80BE0000 	    movw 256, r_tmp_loop #once store the full palette
 1008      94A20001 
 1009 0884 0A8A     	    br full_range
 1010              	update_palette:    
 1011 0886 80BE0000 	    movw 64, r_tmp_loop #for the color cycle only push the required ones
 1011      94A24000 
 1012              	full_range:
 1013              	    #writes increase pal-entry-index and we need to reset it!
 1014 088e C142     	    mov HuC6261_PAL_NR, r_tmp_data
 1015 0890 C0F60003 	    out.h r_tmp_data, HuC6261_reg[r0]
 1016 0894 00F40403 		out.h r0, HuC6261_dat[r0]
 1017              		
GAS LISTING mandelbrot.s 			page 21


 1018 0898 A0A20000 		movwl test_palette, r_tmp_adr
 1018      B5BE0000 
 1019 08a0 C242     		mov HuC6261_PAL_DATA, r_tmp_data	
 1020 08a2 C0F60003 		out.h r_tmp_data, HuC6261_reg[r0]
 1021              	.nextTetsuPaletteEntry:
 1022 08a6 D5C60000 		ld.h 0[r_tmp_adr], r_tmp_data
 1023 08aa C0F60403 		out.h r_tmp_data, HuC6261_dat[r0]
 1024              		
 1025 08ae A246     		add 2, r_tmp_adr
 1026 08b0 9F46     		add -1, r_tmp_loop
 1027 08b2 F495     		bnz .nextTetsuPaletteEntry    
 1028 08b4 C142     		mov HuC6261_PAL_NR, r_tmp_data
 1029 08b6 C0F60003 	    out.h r_tmp_data, HuC6261_reg[r0]
 1030 08ba 00F40403 		out.h r0, HuC6261_dat[r0]
 1031 08be 1F18     		ret
 1032              	
 1033              		
 1034              	upload_bitmap:
 1035              	/* http://daifukkat.su/pcfx/data/memmap.html */
 1036              	/* you can use bitstring here as well */
 1037 08c0 80BE0100 	    movw 0x10000, r_tmp_loop
 1037      94A20000 
 1038 08c8 A0A20000 		movwl buffer, r_tmp_adr
 1038      B5BE0000 
 1039              	
 1040 08d0 CD40     		mov KING_KRAM_ADR_write, r_register
 1041 08d2 E0BC0500 		movw (0x10000 | (1 << KING_b_inc)) , r_value
 1041      E7A00000 
 1042 08da C0F40006 		out.h r_register, KING_reg[r0]
 1043 08de E0FC0406 		out.w r_value, KING_dat[r0]
 1044              		
 1045 08e2 CE40     		mov KING_KRAM_rw, r_register
 1046 08e4 C0F40006 	    out.h r_register, KING_reg[r0]
 1047              	.bloop:
 1048 08e8 F5CC0000 		ld.w 0x0[r_tmp_adr], r_value
 1049 08ec E0FC0406 		out.w r_value, (KING_dat)[r0]
 1050 08f0 A446     		add 4, r_tmp_adr 
 1051 08f2 9C46     		add -4, r_tmp_loop
 1052 08f4 F495     		bnz .bloop
 1053 08f6 1F18     		ret
 1054              		
 1055              	begin_depack:
 1056              	depack:
 1057 08f8 7C44     	    add     -4, sp
 1058 08fa E3DF0000 	    st.w    lp, 0[sp]
 1059              	        
 1060 08fe 80A2FF00 	    movea 0xff,r0,r20 /*;for later compare*/
 1061 0902 8AC50000 	    ld.h 0[r10],r12 /*;size*/
 1062 0906 8CB5FFFF 	    andi 0xffff,r12,r12
 1063 090a 4245     	    add 2,r10
 1064              	    
 1065 090c EA01     	    mov r10,r15
 1066 090e EC05     	    add r12,r15 /*;r15 = end of packed data*/
 1067              	fetch_token:
 1068 0910 0AC20000 	   ld.b 0[r10],r16/* ;token*/
 1069 0914 10B6FF00 	   andi 0xff,r16,r16
 1070 0918 4145     	   add 1, r10 
GAS LISTING mandelbrot.s 			page 22


 1071              	
 1072 091a D001     	   mov r16,r14 
 1073 091c C455     	   shr 4,r14 /*;r14 = literal*/ 
 1074 091e 0E84     	   be fetch_offset
 1075              	
 1076 0920 00AC4000 	   jal fetch_length
 1077              	
 1078 0924 8A01     	   mov r10,r12
 1079 0926 00AC5000 	   jal copy_data /*;literal copy r12 to r11*/
 1080 092a 4C01     	   mov r12,r10
 1081              	
 1082              	fetch_offset:
 1083 092c AAC10000 	   ld.b 0[r10],r13
 1084 0930 ADB5FF00 	   andi 0xff,r13,r13
 1085 0934 8B01     	   mov r11,r12
 1086 0936 8D09     	   sub r13,r12
 1087 0938 AAC10100 	   ld.b 1[r10],r13
 1088 093c ADB5FF00 	   andi 0xff,r13,r13
 1089 0940 A851     	   shl 8,r13
 1090 0942 8D09     	   sub r13,r12
 1091 0944 4245     	   add 2,r10
 1092              	   
 1093 0946 D0B50F00 	   andi 15,r16,r14 /*;match length*/
 1094 094a 00AC1600 	   jal fetch_length 
 1095 094e C445     	   add 4,r14 /*;add min size offset*/
 1096 0950 00AC2600 	   jal copy_data  /*;copy match r12 to r11*/
 1097 0954 4F0D     	   cmp r15,r10 /*;end of data stream?*/
 1098 0956 BA8F     	   ble fetch_token
 1099              	   
 1100 0958 E3CF0000 	   ld.w 0[sp], lp
 1101 095c 6444     	   add 4, sp
 1102 095e 1F18     	   jmp [lp]
 1103              	   
 1104              	fetch_length:
 1105 0960 CF4D     	   cmp 0xf,r14 /*;max=$f indicates more to come*/
 1106 0962 1294     	   bne _done
 1107              	
 1108              	_loop:   
 1109 0964 AAC10000 	   ld.b 0[r10],r13
 1110 0968 ADB5FF00 	   andi 0xff,r13,r13
 1111 096c 4145     	   add 1,r10
 1112 096e CD05     	   add r13,r14
 1113 0970 8D0E     	   cmp r13,r20 /*;r20=ff*/
 1114 0972 F285     	   be _loop
 1115              	_done:
 1116 0974 1F18     	   jmp [lp]
 1117              	
 1118              	copy_data:
 1119 0976 ACC20000 	   ld.b 0[r12],r21
 1120 097a ABD20000 	   st.b r21,0[r11]
 1121 097e 8145     	   add 1,r12
 1122 0980 6145     	   add 1,r11
 1123 0982 DF45     	   add -1,r14
 1124 0984 F295     	   bne copy_data
 1125 0986 1F18     	   jmp [lp]
 1126              	end_depack:
 1127              	
GAS LISTING mandelbrot.s 			page 23


 1128              	
 1129              	.align 2
 1130              	test_palette:
 1131 0988 88008800 	.incbin "pal64.dat"
 1131      B712B717 
 1131      C71DC725 
 1131      C62EC638 
 1131      C642C64B 
 1132 0a0a 8800     	.hword 0x0088 /*placeholder for cycle*/
 1133 0a0c 31955AAE 	.incbin "border_pal.dat"
 1133      5AB35AB0 
 1133      5AB43B8F 
 1133      4B993B8E 
 1133      4AA45AB5 
 1134              	
 1135              	.align 2
 1136              	border_img:
 1137 0b60 4C46F0A7 	.incbin "border_bitmap.datprep.dat" #lz4 packed border bitmap in 256col mode (but only using 256-64
 1137      44434544 
 1137      47464948 
 1137      4B4A444C 
 1137      444C4D44 
 1138              	
 1139 51ae 0000     	.align 2
 1140              	buffer:      

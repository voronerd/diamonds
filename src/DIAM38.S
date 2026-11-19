* $Id: diam38.s 1.5 1998/10/13 18:46:38 Detlef Rel $
*
* Diamonds 38 for the HP38G
*
* By: Douglas R. Cannon
* On: August 7, 1993
* Modified for the HP38G on October 19, 1996.
* Modified slowly up until June 20, 1997.
*
* email: dougc@erudite.com or doug_cannon@juno.com
* Dougc's HP48 page: http://www.erudite.com/~dougc/hp48.htm
*
* Home address:
* 350 N. 850 E.
* American Fork, UT 84003
* (801) 763-8798
*
* $Log: diam38.s $
* Revision 1.5  1998/10/13 18:46:38  Detlef
* Gone to v1.1
*
* Revision 1.4  1998/10/13 18:30:54  Detlef
* Changed DEPTH NDROP to DropJunk upon game exit.
*
* Revision 1.3  1998/07/31 21:58:05  Detlef
* Ported to Yved _deletable_ Aplet-frame, added debouncing of the keyboard
* upon game exit and enabled all 50 level.
*
* Revision 1.2  1997/06/24 17:46:11  Detlef
* Wrapped into an Applet shell, fixed a few calls (missing $j..).
* Limited to 15 levels. 1st working version.
*
*
* Each field is separated by one Tab, so just port this file into your
* favorite word processor, stretch out the tab stops, and it should
* look really nice.  If you print it with a small font, it looks nice too.
*
* Special thanks to Paul Hart for converting the source code into
* SASM format.  The source was originally written for my own assembler,
* SATASM.EXE, and has now been converted to be SASM compatible.  Paul spent
* many hours working on it, and he did a great job!  Thanks Paul!
*
* Special thanks to Jim Donnelly for the final tweaking to get Diamonds
* working on the HP38G.  I owe him thanks as well for his latest book
* (_An Introduction to HP 48 System RPL and Assembly Lanugage Programming_),
* his earlier books, miscellaneous help and encouragement over the last couple
* years, and most of all... for the HP38G itself!  Thanks Jim!
*
* Thanks to Detlef Mueller too.  I had all but dropped this Diamonds 38
* project (no time to work on it!) when Detlef emailed me out of the blue
* asking me what I knew about 48 to 38 conversions.  We got together with
* Jim Donnelly, I dusted of the Diamonds 38 source, and the ball was rolling
* again.  Thanks Detlef!
*
* Then, Jean-Yves Avenard helped me with the final 38G conversions.
* I still use his String-Writer program, as well, Thanks Jean-Yves!
*

* ----------------------------------------------
* | Global Label prefix assignments:
* |
* | be: BONUS_ERASE
* | bo: BOUNCE
* | cb: CHECK_BOUNCE
* | cf: Clear Field (cfCLEAR)
* | db: DRAW_BALL
* | de: DRAW_LEVEL
* | dl: DRAW_LIVES
* | dm: dmDRAW_MENU
* | dm: dmDRAW_HLP
* | ds: DRAW_SCREEN
* | em: ERASE MODE
* | er: ERASE
* | gr: GRAPHICS displays
* | hb: HIT_BRICK
* | is: Init Screen (isINIT_SCN)
* | ma: MAIN
* | me: MAIN_EVENT
* | mn: Menu (mnMENU)
* | mv: MOVE
* | pk: PAUSE_KEY
* | sc: Score (scADD_SCORE, scDISP_SCORE)
* | sd: DISOLVE (screen disolver)
* | so: SOUND
* | sr: Variable Storage/Retrieval system
* | ud: Universal Delay (udDELAY)
* | wa: Wait  (waWAIT)
* |
* ----------------------------------------------

* ----------------------------------------------
* | Global Variable assignments:
* |
* | R0: Permanent storage for address of sr data.
* | R1: |
* | R2: | Temp in hb
* | R3: |
* | R4:
* |-----------------
* | (by Var#)
* |
* | 0:  (PERM) current X coord
* | 1:  (PERM) current Y coord
* | 2:  (PERM) current direction of travel
* | 3:  temp storage for screen pos (mv, fd)
* | 4:  temp in (ds, db, ud, fd, nd)
* | 5:  (PERM) @ of brick graphics
* | 6:  (PERM) @ of current screen data (brick matrix)
* | 7:  temp holder, ball addr (mv, fd)
* | 8:  Permanent address of STACK bitmap area
* | 9:  Permanent address of PICT bitmap area
* | 10: |
* | 11: | 10-14 are used by cbCHK_BOUNCE
* | 12: | (no need for srRCL10_C or srSTO10_C etc.
* | 13: | cbCHK_BOUNCE calls srRCL_C etc.
* | 14: | directly.
* | 15: (PERM) current erase mode (which bricks get erased)
* | 16: (PERM) number of bricks left (not counting diamonds)
* | 17: (PERM) number of diamonds left. (done when == 0)
* | 18: (PERM) DELAY (speed)
* | 19: (PERM) Total number of levels
* | 20: (PERM) Current level number
* | 21: (PERM) @ of level 1 (X,Y,DIR)
* | 22: (PERM) # of lives left
* | 23: (PERM) Score
* | 24: Temp in (gr, ud, fd, nd)
* | 25: (PERM) time left to erase another bonus
* | 26: (PERM) next bonus life at this score
* | 27: temp in (ds, ud, fd, nd)
* | 28: temp in ud
* | 29: Temp in (fd, nd)
* | 30: Temp in (fd, nd)
* | 31: Temp in (nd, in)
* | 32:
* | 33:
* | 34: Temp in (in, il, dh)
* | 35: Temp in (in, il)
* | 36: Temp in (cc, mn)
* | 37: Temp in (dh, mn)
* | 38: Temp in (dh, mn)
* | 39: (Perm) in cu
* | 40:
* | 41: (PERM) Speed toggle var
* | 42: Temp in (mn)
* | 43: Myth
* | 44: (Perm) DMID bitmap address
* | 45: (Perm) DCLEAR bitmap address
* | 46: mn
* | 47: (perm) ticks (me, ud)
* ----------------------------------------------
* | Status flags:
* |--------------------
* |
* | 0:  (temp) used for bouncing, key check (cb, mn, ud)
* | 1:  (perm) used for bouncing (me, cb)
* | 2:  (perm) used for bouncing (me, cb)
* | 3:  (perm) key move direction (me, hb)
* | 4:  (perm) 0==alive 1==DEAD (hb, me, cb)
* | 5:  (perm) 0==play 1==You WON! (hb, me)
* | 6:  (perm) 0==reg bricks 1==diamond bricks (hb)
* | 7:  (perm) 0==no key, 1==you have a key
* | 8:
* | 9:
* | 10: (temp) used for erasing the ball (mv, er, mn)
* | 11: (perm) 0 == Sound on, 1 == Sound off.
* ----------------------------------------------

ASSEMBLE

* ----------------------------------------------
* Addresses
*
CRC	EQU	#00104

* ----------------------------------------------
* Global constants
*
SLOW_SPD	EQU	#000F0	SLOW speed
NORMAL_SPD	EQU	#000A0	NORMAL speed (delay in main loop)
FAST_SPD	EQU	#00050	FAST speed
SUPER_SPD	EQU	#00000	SUPER speed
SPEED_UP	EQU	#00050	amount to subtract to speed up.
BONUS_TIME	EQU	#00070
BONUS_LIFE	EQU	#05000	in decimal
LIVES		EQU	#00005
NIBBLES		EQU	#0020D	#FFh + #10Eh (#FFh==51*5) (#10Eh==15*18)
VARS		EQU	#000FF	5 * (50+1) == #FFh

LOCK_SCORE	EQU	#00050
BRICK_SCORE	EQU	#00003
KEY_SCORE	EQU	#00025
DIAM_SCORE	EQU	#00100

* -----------------------------------------------

* -------------
* | When this main object is executed, the stack
* | should look like this:
* |
* | L3: DIAMONDS LEVELS
* | L2: Address of ABUFF (#12655h SYSEVAL)
* | L1: A STRING (with a length of at least NIBBLES + #77F)
* |
* -------------

	TITLE Diamonds Applet

ASSEMBLE

=TIMER2		EQU #00138	=	32-bit timer

RPL

INCLUDE common38.h


ASSEMBLE
	Dir_Head 8,Diamonds,601
RPL

	StndtType

INCLUDE share38.h

ASSEMBLE
	Vfield  L34,IntTable
	CON(5)	=DOHSTR
	REL(5)  endLink
	Link	_Main
	Link	_Entry
	Link	_Action

endLink
RPL


DEFINE Main		INT_00
DEFINE Entry		INT_01
DEFINE Action		INT_02


ASSEMBLE
	Vfield  IntTable,DirCode
RPL
ASSEMBLE
	CON(5)	=DOHSTR
	REL(5)  endCode
RPL


DEFINE Q     Tcol@
DEFINE P     Trow@

DEFINE X     TopicVar3@
DEFINE GRID  TopicVar4@

DEFINE Q!    Tcol!
DEFINE P!    Trow!

DEFINE X!    TopicVar3!
DEFINE GRID! TopicVar4!

DEFINE x00  FOUR

DEFINE x0-1 THIRTYTHREE
DEFINE x0   THIRTYFOUR
DEFINE x0+1 THIRTYFIVE

DEFINE x01  SIXTYFOUR

DEFINE y00  TWO
DEFINE y0-1 THIRTYONE
DEFINE y0   THIRTYTWO
DEFINE y0+1 THIRTYTHREE
DEFINE y01  SIXTYTWO


NAMELESS _Action
::
ASSEMBLE
	CON(5)	=DOEXT0
	REL(5)	LEVELS_END
	NIBHEX	23000	Number of levels (50)
*	NIBHEX	F0000	Number of levels (15)
	NIBHEX	70202	Level 1
	NIBHEX	0000000000
	NIBHEX	0091001B00
	NIBHEX	6A800008A6
	NIBHEX	8A802208A8
	NIBHEX	8A802208A8
	NIBHEX	6A800008A6
	NIBHEX	00B1001900
	NIBHEX	0000000000
	NIBHEX	73831	Level 2
	NIBHEX	0F22662290
	NIBHEX	00EEEEEE00
	NIBHEX	0008888000
	NIBHEX	0000110000
	NIBHEX	0000110000
	NIBHEX	0008888000
	NIBHEX	00EEEEEE00
	NIBHEX	09226622F0
	NIBHEX	73C21	Level 3
	NIBHEX	91000000E4
	NIBHEX	B1000000EE
	NIBHEX	23333000C4
	NIBHEX	22255000CC
	NIBHEX	22255000A4
	NIBHEX	23333000AA
	NIBHEX	D100000084
	NIBHEX	F100000088
	NIBHEX	73021	Level 4
	NIBHEX	7000000007
	NIBHEX	B10000001C
	NIBHEX	AD100001AC
	NIBHEX	AC220022AC
	NIBHEX	AC220022AC
	NIBHEX	AC100001BC
	NIBHEX	A10000001D
	NIBHEX	7000000007
	NIBHEX	B5831	Level 5
	NIBHEX	2250E364F4
	NIBHEX	2230E30000
	NIBHEX	2230E30000
	NIBHEX	3330E30888
	NIBHEX	0000E30CCC
	NIBHEX	1100E30111
	NIBHEX	9100E30100
	NIBHEX	D100050100
	NIBHEX	31831	Level 6
	NIBHEX	0010000100
	NIBHEX	00A0000E00
	NIBHEX	1AA6BF6EE1
	NIBHEX	0002222000
	NIBHEX	0002222000
	NIBHEX	5EE6FB6AA4
	NIBHEX	00E0000A00
	NIBHEX	0010000100
	NIBHEX	73802	Level 7
	NIBHEX	EE002200EE
	NIBHEX	06A0000A60
	NIBHEX	00B1001F00
	NIBHEX	2000000002
	NIBHEX	2000000002
	NIBHEX	00F1001B00
	NIBHEX	06E0000E60
	NIBHEX	AA002200AA
	NIBHEX	B5622	Level 8
	NIBHEX	BA00EE0001
	NIBHEX	5700E90001
	NIBHEX	0000EE0001
	NIBHEX	2323200006
	NIBHEX	3232300006
	NIBHEX	0000880001
	NIBHEX	47008F0001
	NIBHEX	AA00880001
	NIBHEX	34831	Level 9
	NIBHEX	6200000026
	NIBHEX	270A11E072
	NIBHEX	000A9D5000
	NIBHEX	01AA00EE10
	NIBHEX	018800CC10
	NIBHEX	0004BFC000
	NIBHEX	270811C072
	NIBHEX	6200000026
	NIBHEX	B5831	Level 10
	NIBHEX	0000026CC0
	NIBHEX	00002A8C89
	NIBHEX	0002A8C8C1
	NIBHEX	002A8C8C10
	NIBHEX	02A6C8C100
	NIBHEX	2A8C8C1000
	NIBHEX	BCC8C10000
	NIBHEX	0CD7100000
	NIBHEX	B5E02	Level 11
	NIBHEX	6100000016
	NIBHEX	1000220001
	NIBHEX	0009EEE000
	NIBHEX	002E008200
	NIBHEX	002E008200
	NIBHEX	000888F000
	NIBHEX	1000220001
	NIBHEX	6100000016
	NIBHEX	B5622	Level 12
	NIBHEX	1000150001
	NIBHEX	0000F50000
	NIBHEX	00005A0000
	NIBHEX	1EE4221898
	NIBHEX	5EEE224148
	NIBHEX	00001A0000
	NIBHEX	0000B40000
	NIBHEX	1000AA0001
	NIBHEX	70831	Level 13
	NIBHEX	0000000000
	NIBHEX	0000220000
	NIBHEX	0001FE1000
	NIBHEX	001DCCC100
	NIBHEX	01BAAAAA10
	NIBHEX	69EEE88887
	NIBHEX	6ECA00ACE6
	NIBHEX	0220000220
	NIBHEX	B5831	Level 14
	NIBHEX	00002080C0
	NIBHEX	000001080C
	NIBHEX	6000001080
	NIBHEX	0900000108
	NIBHEX	C0100000D0
	NIBHEX	0C01000006
	NIBHEX	80C0100000
	NIBHEX	080C020000
	NIBHEX	B2021	Level 15
	NIBHEX	6EE0000AA6
	NIBHEX	EE002200AA
	NIBHEX	E00911D00A
	NIBHEX	0022001100
	NIBHEX	0011002200
	NIBHEX	C00B11F008
	NIBHEX	CC00220088
	NIBHEX	6CC0000886
* not_this IFDEF NOT_THIS
	NIBHEX	B5831	Level 16
	NIBHEX	222C00088F
	NIBHEX	2223000666
	NIBHEX	3333000AAA
	NIBHEX	EEEE0CCCC9
	NIBHEX	B88E0C0000
	NIBHEX	888E0C0111
	NIBHEX	EEEE0C0100
	NIBHEX	666E0D0100
	NIBHEX	73621	Level 17
	NIBHEX	600E000E06
	NIBHEX	000E000E07
	NIBHEX	333F111D0A
	NIBHEX	222200020A
	NIBHEX	222200020A
	NIBHEX	222D111F0A
	NIBHEX	005C000C0A
	NIBHEX	B05C000C46
	NIBHEX	F1021	Level 18
	NIBHEX	EE009D00AA
	NIBHEX	E00222200A
	NIBHEX	E00100100A
	NIBHEX	0070000600
	NIBHEX	0060000700
	NIBHEX	C001001008
	NIBHEX	C002222008
	NIBHEX	CC00BF0088
	NIBHEX	B2E02	Level 19
	NIBHEX	0882112EE0
	NIBHEX	EEE0000888
	NIBHEX	29000000F2
	NIBHEX	1100000016
	NIBHEX	6100000011
	NIBHEX	2F00000092
	NIBHEX	8880000EEE
	NIBHEX	0EE2112880
	NIBHEX	80721	Level 20
	NIBHEX	00A0000C00
	NIBHEX	0AA6007CC0
	NIBHEX	2004004002
	NIBHEX	20AB11DC02
	NIBHEX	20AB11DC02
	NIBHEX	2005005002
	NIBHEX	0AA7006CC0
	NIBHEX	00A0000C00
	NIBHEX	F1202	Level 21
	NIBHEX	88088CC0CC
	NIBHEX	820F22B02C
	NIBHEX	0000000000
	NIBHEX	810067001C
	NIBHEX	A10076001E
	NIBHEX	0000000000
	NIBHEX	A20D22902E
	NIBHEX	AA0AAEE0EE
	NIBHEX	B5831	Level 22
	NIBHEX	6000000006
	NIBHEX	7000190007
	NIBHEX	6000820006
	NIBHEX	7000180007
	NIBHEX	6000820006
	NIBHEX	7000180007
	NIBHEX	6000820006
	NIBHEX	7000000000
	NIBHEX	73A12	Level 23
	NIBHEX	0078008700
	NIBHEX	68009C00C6
	NIBHEX	00EE00CE00
	NIBHEX	6C00D100C6
	NIBHEX	00E1001C00
	NIBHEX	6E001F0026
	NIBHEX	007E007800
	NIBHEX	6200220026
	NIBHEX	B5831	Level 24
	NIBHEX	2628F86262
	NIBHEX	0000000000
	NIBHEX	176ADA3333
	NIBHEX	0000000000
	NIBHEX	3333CBC671
	NIBHEX	0000000000
	NIBHEX	176E9E3333
	NIBHEX	0000000000
	NIBHEX	73E01	Level 25
	NIBHEX	1EE00008FC
	NIBHEX	0185008DC0
	NIBHEX	0016226C00
	NIBHEX	0002222000
	NIBHEX	0002222000
	NIBHEX	0016226800
	NIBHEX	01AA004880
	NIBHEX	1BA0000988
	NIBHEX	70412	Level 26
	NIBHEX	0EB00001A2
	NIBHEX	0E10000FA2
	NIBHEX	0E600001A2
	NIBHEX	0E100006A2
	NIBHEX	0EB00001A2
	NIBHEX	0E10000FA2
	NIBHEX	0E600001A2
	NIBHEX	0E100006A2
	NIBHEX	F4C21	Level 27
	NIBHEX	BD610700A2
	NIBHEX	11E00C00A2
	NIBHEX	00E00C00A2
	NIBHEX	00E00C00A2
	NIBHEX	00E00C00A2
	NIBHEX	00E00C00A2
	NIBHEX	00E00C00A2
	NIBHEX	1070016FA2
	NIBHEX	70411	Level 28
	NIBHEX	100072F008
	NIBHEX	700062900E
	NIBHEX	600072F008
	NIBHEX	700062900E
	NIBHEX	600072F008
	NIBHEX	700062900E
	NIBHEX	600072F008
	NIBHEX	7000000006
	NIBHEX	34202	Level 29
	NIBHEX	000A630003
	NIBHEX	030030030A
	NIBHEX	0030703A3A
	NIBHEX	322363AAAA
	NIBHEX	B223631111
	NIBHEX	0330703131
	NIBHEX	0300300301
	NIBHEX	0001630003
	NIBHEX	70202	Level 30
	NIBHEX	000800129B
	NIBHEX	0008000244
	NIBHEX	0015000211
	NIBHEX	4888000200
	NIBHEX	0018000200
	NIBHEX	000BA5AA5A
	NIBHEX	000A000001
	NIBHEX	0005000014
	NIBHEX	B5831	Level 31
	NIBHEX	0000000000
	NIBHEX	0011111100
	NIBHEX	0086AA6A00
	NIBHEX	008A228A00
	NIBHEX	008A228A00
	NIBHEX	0086886A00
	NIBHEX	0091111B00
	NIBHEX	0000000000
	NIBHEX	B5231	Level 32
	NIBHEX	2005001004
	NIBHEX	2003001006
	NIBHEX	2006001003
	NIBHEX	2003001006
	NIBHEX	2006001003
	NIBHEX	2003001006
	NIBHEX	2006000003
	NIBHEX	2003000006
	NIBHEX	31202	Level 33
	NIBHEX	00B1111100
	NIBHEX	00EE1AAA00
	NIBHEX	00111D1F00
	NIBHEX	00E1221100
	NIBHEX	00E1221A00
	NIBHEX	00E1111198
	NIBHEX	001AECAE88
	NIBHEX	001AECAE88
	NIBHEX	F1412	Level 34
	NIBHEX	002EEAA200
	NIBHEX	0E91001DA0
	NIBHEX	EE100001AA
	NIBHEX	2100670012
	NIBHEX	2100760012
	NIBHEX	CC10000188
	NIBHEX	0CB1001F80
	NIBHEX	002CC88200
	NIBHEX	F1231	Level 35
	NIBHEX	00F1006B00
	NIBHEX	A02600120E
	NIBHEX	C000000008
	NIBHEX	A008EAC00E
	NIBHEX	A00AC8E00E
	NIBHEX	C000000008
	NIBHEX	A02100620E
	NIBHEX	00D6001900
	NIBHEX	05D21	Level 36
	NIBHEX	0000F80022
	NIBHEX	E100180022
	NIBHEX	E900001800
	NIBHEX	00E6007800
	NIBHEX	00E7006800
	NIBHEX	00E10000F8
	NIBHEX	2200E10018
	NIBHEX	2200E90000
	NIBHEX	31622	Level 37
	NIBHEX	6010000102
	NIBHEX	20C0110C02
	NIBHEX	20A0AA0A02
	NIBHEX	6000AD0007
	NIBHEX	7000BC0006
	NIBHEX	20A0CC0A02
	NIBHEX	20C0110C02
	NIBHEX	2010000106
	NIBHEX	F1831	Level 38
	NIBHEX	2C00B800EF
	NIBHEX	C400850041
	NIBHEX	00E1002E00
	NIBHEX	00E200C100
	NIBHEX	6E00A20046
	NIBHEX	58002A0088
	NIBHEX	00C5004A00
	NIBHEX	00D1009500
	NIBHEX	70021	Level 39
	NIBHEX	0EE800CAA0
	NIBHEX	01E800CA10
	NIBHEX	0000000000
	NIBHEX	29060010D2
	NIBHEX	2B010060F2
	NIBHEX	0000000000
	NIBHEX	01CA00E810
	NIBHEX	0CCA00E880
	NIBHEX	83802	Level 40
	NIBHEX	E000A00020
	NIBHEX	0501090C0A
	NIBHEX	00E000A000
	NIBHEX	0106010F0C
	NIBHEX	2000200080
	NIBHEX	06010D0106
	NIBHEX	0080008000
	NIBHEX	020B040601
	NIBHEX	B5202	Level 41
	NIBHEX	151122E000
	NIBHEX	188F22E000
	NIBHEX	188422E000
	NIBHEX	188122E000
	NIBHEX	5511119000
	NIBHEX	48EEEEE000
	NIBHEX	0000000001
	NIBHEX	0000000014
	NIBHEX	44622	Level 42
	NIBHEX	0200A00200
	NIBHEX	2005004060
	NIBHEX	00100A0002
	NIBHEX	0500F00B00
	NIBHEX	A00A00E010
	NIBHEX	00600E000E
	NIBHEX	10040010E0
	NIBHEX	0200700E00
	NIBHEX	15331	Level 43
	NIBHEX	100E00E002
	NIBHEX	06001800B0
	NIBHEX	200C001002
	NIBHEX	0D00A10060
	NIBHEX	200100A002
	NIBHEX	06001C0090
	NIBHEX	2008008001
	NIBHEX	0F00E10060
	NIBHEX	70831	Level 44
	NIBHEX	2201005000
	NIBHEX	20100A0006
	NIBHEX	01006000A0
	NIBHEX	100A000B00
	NIBHEX	00B000A001
	NIBHEX	0A00060010
	NIBHEX	6000A00102
	NIBHEX	0004001022
	NIBHEX	F4411	Level 45
	NIBHEX	0CC0CE0000
	NIBHEX	0E20CE0000
	NIBHEX	02D0110670
	NIBHEX	0120110C00
	NIBHEX	00E0CE0210
	NIBHEX	0760CE0C20
	NIBHEX	0000CE02F0
	NIBHEX	0000110EE0
	NIBHEX	93202	Level 46
	NIBHEX	2000AA0002
	NIBHEX	FE00C100AA
	NIBHEX	0450C60140
	NIBHEX	00E2AA2C00
	NIBHEX	00EE4EEC00
	NIBHEX	0CC0110D70
	NIBHEX	1500BE0015
	NIBHEX	20006C0002
	NIBHEX	70831	Level 47
	NIBHEX	00BE00EE00
	NIBHEX	00DA00AC00
	NIBHEX	00FA00CA00
	NIBHEX	0016006100
	NIBHEX	6100A70016
	NIBHEX	EC00AA00CE
	NIBHEX	EC002200CE
	NIBHEX	2200110022
	NIBHEX	70831	Level 48
	NIBHEX	2100600100
	NIBHEX	2600100600
	NIBHEX	2100ECAECA
	NIBHEX	2100D00100
	NIBHEX	2B00100F00
	NIBHEX	2ECAECA100
	NIBHEX	2600100600
	NIBHEX	2100600100
	NIBHEX	73232	Level 49
	NIBHEX	81001800CA
	NIBHEX	8F004500DA
	NIBHEX	5500660041
	NIBHEX	0022002200
	NIBHEX	0022002200
	NIBHEX	5400660041
	NIBHEX	CB0045009E
	NIBHEX	C1001C00EE
	NIBHEX	31231	Level 50
	NIBHEX	C8C8C8C8C8
	NIBHEX	800D00100C
	NIBHEX	C001009008
	NIBHEX	111222600C
	NIBHEX	1006222EAE
	NIBHEX	600100B001
	NIBHEX	100F001001
	NIBHEX	EAEAEAEAEA
* not_this ENDIF
LEVELS_END
RPL

	HARDBUFF ZEROZERO BINT_131d SIXTYFOUR
	GROB!ZERODRP

	HARDBUFF
	# 264 ONE MAKEGROB DO>STR
CODE
*	P=	0
	GOSBVL	=SAVPTR

	INTOFF
	ST=0	15	STOP those interrupts

*	ST=1	11	set sound off (default for 38G)
	ST=0	11	set sound on (default for 38G)
	A=DAT1	A	addr of object in level 1 (data string)
	A=A+CON	A,10	point to string data portion
	R0=A.F	A	save it here forever

	LC(5)	NIBBLES	offset past data portion
	C=C+A	A	add addr
	GOSUBL	srSTO8_C	permanent storage

maLEVEL2	D1=D1+	5	move to stack level 2
	A=DAT1	A	get address of ABUFF
	LCHEX	#00014	skip prolog, length, etc (20 DEC)
	C=C+A	A
	GOSUBL	srSTO9_C	permanent storage

maLEVEL3	D1=D1+	5	move to stack level 3
	A=DAT1	A	addr of object in level 3 (levels)
	A=A+CON	A,10	point to # of levels
	D0=A
	C=DAT0	A	get number of levels
	GOSUBL	srSTO19_C	store it for good
	A=A+CON	A,5	now pointing to level 1 (to X,Y,DIR)
	C=A	A	must put it here
	GOSUBL	srSTO21_C	permanent storage

	GOSUBL	isINIT_SCN	draw screen (except for play field)

	LC(5)	NORMAL_SPD	"NORMAL SPEED"
	GOSUBL	srSTO41_C	init speed var


* This is the menu routine.  It displays the menu, and
* handles the key presses.

mnMENU	GOSUBL	cfCLEAR	clear playing field
mnREDRAW	GOSUBL	dmDRAW_MENU	draw menu

mnOK_KEY	C=0	A
	GOSUBL	srSTO43_C	stop spreading rumors

mnSTOP_KEY	LCHEX	#1FF	| check here to see
	OUT=C		  | if they are still pressing
	GOSBVL	=$jCINRTN | a key
	LAHEX	#0003F	  |
	A=A&C	A	  |
	?A#0	A	  |
	GOYES	mnSTOP_KEY	|

* This used to be the code below.  I changed it to
* wait for 5 minutes, then goto maEND.
*mnCHECK_KEY	C=0	A	clear out C
*	GOSUBL	udDELAY	check for [ON] (and [+/-])


mnCHECK_KEY	LCHEX	#18E70	about 5 minutes
	GOSUBL	waWAIT

	LCHEX	#1FF
	OUT=C
	GOSBVL	=$jCINRTN
	LAHEX	#0003F	all keys ( except [ON] )
	A=A&C	A
	?A#0	A	have you pressed a key?
	GOYES	mnA	yes? go check which one
	GOTO	maEND	no key?  Exit to RPL

mnA	LCHEX	#008
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	4	[A] key
	GOYES	mnNO_A
	GOTO	maSTART_GAME

mnNO_A	LCHEX	#020
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	4	[B] key
	GOYES	mnNO_B

mnB	GOSUBL	srRCL41_C	SPEED toggle var
	LA(5)	SPEED_UP	get speed-up var
	C=C-A	A	subtract it
	GONC	mnB_OK	no carry? we're OK
	LC(5)	SLOW_SPD	go to SLOW speed
	GOSUBL	srSTO41_C	store new speed
	GOSUBL	soMENU_DOWN	make DOWN sound
	GOTO	mnREDRAW

mnB_OK	GOSUBL	srSTO41_C	store new speed
	GOSUBL	soMENU_UP	make UP sound
	GOTO	mnREDRAW	display new menu

mnNO_B	?CBIT=1	3	[C] key
	GOYES	mnYES_C
	GOTO	mnCHECK_KEY	Go check keys again

mnYES_C	GOSUBL	cfCLEAR	Clear the playing field
	GOLONG	dmDRAW_HLP	Draw the Help screen graphic (auto RTN)

* This is executed only when you first start a game.

maSTART_GAME	GOSUBL	srRCL41_C	delay toggle var
	GOSUBL	srSTO18_C	save as starting speed

	LC(5)	LIVES	number of lives
	GOSUBL	srSTO22_C	store it
	LC(5)	BONUS_LIFE	points until first extra life
	GOSUBL	srSTO26_C	store it here
	C=0	A
	GOSUBL	srSTO20_C	level 1 (0+1)
	GOSUBL	srSTO23_C	score is zero
	GOSUBL	scDISP_SCORE	display the 00000 score

* This is executed at the start of each new level

maPLAY_AGAIN	GOSUBL	srRCL20_C	get level #
	LAHEX	#00055	#85d nibbles per level
	GOSBVL	=$jMUL#	put result in B, field A
	C=B	A
	GOSUBL	srRCL21_A	pointing to level 1
	A=A+C	A	pointing to current level
	A=A+CON	A,5	pointing to brick data
	GOSUBL	srSTO6_A	save it

	GOSUBL	deDRAW_LEVEL	display level number
	GOSUBL	beBONUS_DRAW	fill the bonus area
	GOSUBL	sdDISOLVE	disolve the bricks onto the screen
	GOTO	maSET_FLAGS

* This is executed each time you die (with some lives left)

maSTART_OVER	GOSUBL	dsQUICK_DRAW	draw the bricks quickly, not disolve
maSET_FLAGS	ST=0	6	you can't knock out diamonds yet.
	ST=0	7	you have no key
	GOSUBL	hbDRAW_KEY	make sure no key is showing
	LCHEX	#00001	white brick
	GOSUBL	srSTO15_C	erase mode
	GOSUBL	emDRAW_BRICK	show erase brick
	LC(5)	BONUS_TIME	a good time...
	GOSUBL	srSTO25_C	bonus time

	GOSUBL	dlDRAW_LIVES	draw lives left
	GOSUBL	srRCL6_C	get level addr
	C=C-CON	A,5	now pointing to X,Y and DIR
	D0=C		in D0 (pointing to X)
	C=0	A
	C=DAT0	2	read X
	GOSUBL	srSTO0_C	X
	D0=D0+	2	pointing to Y
	C=DAT0	2	read Y
	GOSUBL	srSTO1_C	Y
	D0=D0+	2	pointing to DIR
	C=0	A
	C=DAT0	1	read Direction
	GOSUBL	srSTO2_C	store it

	GOSUB	grGET_READY	display the GET READY window

	GOSUBL	srRCL43_C	check for myths
	?C=0	A	none?
	GOYES	maMOVE
	LCHEX	#002
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	1	no [U] key?
	GOYES	ma_M1
	GOTO	maNEXT_LEVEL	Go up one level

ma_M1	LCHEX	#020
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	2	no [D] key?
	GOYES	maMOVE
	GOSUBL	srRCL20_C	current level #
ma_M3	C=C-1	A	go down one level
	GONC	ma_M2
	GOSUBL	srRCL19_C
	C=C-1	A
ma_M2	GOSUBL	srSTO20_C	store the new level #
	GOTO	maPLAY_AGAIN


maMOVE	GOLONG	meMAIN_EVENT	instead of GOSUB (free up RSTK)
maMAIN_RTN	?ST=0	5	did you lose, or quit?
	GOYES	maCHECK_LOSE	go check

	C=0	A
	GOSUBL	srSTO2_C	set direction to none
	ST=1	10	set to erase
	GOSUBL	mvMOVE	erase the ball
	ST=0	10	set to draw
	GOSUBL	cnCONGRATS	BONUS, or NO BONUS banners

maNEXT_LEVEL	GOSUBL	srRCL20_C	get current level#
	C=C+1	A
	GOSUBL	srRCL19_A	get total number of levels
	?C<A	A	are we still OK?
	GOYES	maSET1

	GOSUBL	srRCL18_C	get current ball speed
	LA(5)	SPEED_UP	get speed-up var
	C=C-A	A	subtract it
	GONC	maOK	no carry? we're OK.
	LCHEX	#00001	make it 1 (FASTest)
maOK	GOSUBL	srSTO18_C
	C=0	A	level 0 (again...)

maSET1	GOSUBL	srSTO20_C	set new level#
	GOTO	maPLAY_AGAIN	play again!

maCHECK_LOSE	?ST=0	4	did you quit?
	GOYES	maGAME_OVER	done with game.

	GOSUBL	srRCL22_C	number of lives left
	?C=0	A	none?
	GOYES	maGAME_OVER	outta here! (game over)
	GOTO	maSTART_OVER	start that level again

maGAME_OVER	LCHEX	#000CC	about 1 second
	GOSUBL	waWAIT	wait a sec.
	GOLONG	mnMENU	Go back to menu

maEND
	LCHEX	#5FF	all keys (even [ON])
	OUT=C
	GOSBVL	=$jCINRTN
	LAHEX	#0803F	all keys (even [ON])
	A=A&C	A
	?A#0	A	still pressed ?
	GOYES	maEND

**	GOSBVL	=$jGETPTR
	INTON
	ST=1	15		allow interrupts again
	GOVLNG	=$jGETPTRLOOP	restore regs, back to RPL

* -----------------------------------------------------
* The following routines display various graphics
* in a "window", then a delay, then they re-draw
* what used to be there.
* -----------------------------------------------------

grGET_READY	GOSUB	grTEMP
	R3=C.F	A	@ of temp area
	GOSUB	grGR_NEXT

	NIBHEX	000000000000000000	line 0
	NIBHEX	CFFFFFFFFFFFFFFFF3
	NIBHEX	200000000000000004
	NIBHEX	200000100000000004
	NIBHEX	283F9F0C3E3E974444
	NIBHEX	24A2420A250959A244
	NIBHEX	228E020A1D1459A224
	NIBHEX	2A320208240C190124
	NIBHEX	221111042222980104
	NIBHEX	2C9F830E4F91D78014
	NIBHEX	201000004000008004
	NIBHEX	2C0000008100006004
	NIBHEX	200000000000000004
	NIBHEX	CFFFFFFFFFFFFFFFF3
	NIBHEX	000000000000000000	line 14

grGR_NEXT	C=RSTK		Get the address of the bitmap into C[A]
	R4=C.F	A	@ of graphic

	GOSUBL	srRCL9_A	screen @
	LCHEX	#00334	{#10h #18h}
	A=A+C	A
	D0=A

	LCHEX	#0000E	14+1 lines
	B=C	A
grGR_LINE	LCHEX	#00001	1+1 parts per line
	D=C	A

grGR_PART	C=R3.F	A	@ of temp area
	D1=C
	C=C+CON	A,9	increment C by 9
	R3=C.F	A	save it
	A=DAT0	9	get 9 screen nibbles
	DAT1=A	9	save them
	C=R4.F	A	@ of graphic
	D1=C
	C=C+CON	A,9	increment C by 9
	R4=C.F	A	save it
	A=DAT1	9	read 9 graphic nibbles
	DAT0=A	9	write 9 nibbles to screen
	D0=D0+	9	increment D0

	D=D-1	A
	GONC	grGR_PART	do next part

	AD0EX
	LCHEX	#00010	#22h - #12h
	A=A+C	A
	D0=A

	B=B-1	A	one less line
	GONC	grGR_LINE	do next line

	LCHEX	#03000	a couple of seconds
	B=C	A
grCHECK_KEY	LCHEX	#1FF	| wait here until
	OUT=C		  | they stop pressing
	GOSBVL	=$jCINRTN | a key
	LAHEX	#0003F	  |
	A=A&C	A	  |
	?A=0	A	  |
	GOYES	grNO_KEY	|
	B=B-1	A	don't wait forever, though
	GONC	grCHECK_KEY

grNO_KEY	LCHEX	#00198	about 2 seconds
	GOSUBL	waWAIT	delay, pressing a key gets out

	LCHEX	#03000
	B=C	A
grCHECK_KEY2	LCHEX	#1FF	| wait here until
	OUT=C		  | they stop pressing
	GOSBVL	=$jCINRTN | a key
	LAHEX	#0003F	  |
	A=A&C	A	  |
	?A=0	A	  |
	GOYES	grNO_KEY2	|
	B=B-1	A	don't wait forever, though
	GONC	grCHECK_KEY2

grNO_KEY2	GOSUB	grTEMP
	D1=C		temp area

	GOSUBL	srRCL9_A	screen @
	LCHEX	#00334	{#10h #18h}
	A=A+C	A
	D0=A

	LCHEX	#0000E	14+1 lines
	B=C	A
grGR_LINE2	LCHEX	#00001	1+1 parts per line
	D=C	A

grGR_PART2	A=DAT1	9	get 9 saved nibbles
	DAT0=A	9	put them back on the screen
	D1=D1+	9
	D0=D0+	9

	D=D-1	A
	GONC	grGR_PART2	do next part

	AD0EX
	LCHEX	#00010	#22h - #12h
	A=A+C	A
	D0=A

	B=B-1	A	one less line
	GONC	grGR_LINE2	do next line
	RTN


grTEMP	A=R0.F	A	@ of memory area
	LC(5)	VARS	offset past vars
	C=C+A	A	add the @ in C
	RTN		return value in C, field A


grBONUS	GOSUB	grB_NEXT

	NIBHEX	000000000000	line 0
	NIBHEX	CFFFFFFFFFF3
	NIBHEX	200000000004
	NIBHEX	200000100004
	NIBHEX	2C36C8C4C024
	NIBHEX	2A29A9A42024
	NIBHEX	2AB8AA844014
	NIBHEX	28A88A428014
	NIBHEX	24A48C429004
	NIBHEX	2E1368856804
	NIBHEX	200008000004
	NIBHEX	200000300004
	NIBHEX	200000000004
	NIBHEX	CFFFFFFFFFF3
	NIBHEX	000000000000	line 14

grB_NEXT	C=RSTK		Get the address of the bitmap into C[A]
	D1=C	A	@ of graphic

	GOSUBL	srRCL9_A	screen @
	LCHEX	#00337	{#13h #18h}
	A=A+C	A
	D0=A

	LCHEX	#0000E	14+1 lines
	B=C	A
	LCHEX	#00022

grB_LINE	A=DAT1	12	read 12 graphic nibbles
	DAT0=A	12	write 12 nibbles to screen
	D1=D1+	12	increment D1

	AD0EX
	A=A+C	A
	D0=A		set new D0

	B=B-1	A	one less line
	GONC	grB_LINE	do next line
	RTN


grNO_BONUS	GOSUB	grNB_NEXT

	NIBHEX	0000000000000000	line 0
	NIBHEX	CFFFFFFFFFFFFFF3
	NIBHEX	2000000000000004
	NIBHEX	2080000000400004
	NIBHEX	264C00F813231384
	NIBHEX	2D4218A4A6A29084
	NIBHEX	255118E2AA221144
	NIBHEX	245110A22A290244
	NIBHEX	2469009212394204
	NIBHEX	2346087C81269124
	NIBHEX	2040000000200004
	NIBHEX	2081000000C00004
	NIBHEX	2000000000000004
	NIBHEX	CFFFFFFFFFFFFFF3
	NIBHEX	0000000000000000	line 14

grNB_NEXT	C=RSTK		Get the address of the bitmap into C[A]
	D1=C

	GOSUBL	srRCL9_A	screen @
	LCHEX	#00335	{#11h #18h}
	A=A+C	A
	D0=A

	LCHEX	#0000E	14+1 lines
	B=C	A
	LCHEX	#00022

grNB_LINE	A=DAT1	16	read 16 graphic nibbles
	DAT0=A	16	write 16 nibbles to screen
	D1=D1+	16	increment D1

	AD0EX
	A=A+C	A
	D0=A

	B=B-1	A	one less line
	GONC	grNB_LINE	do next line
	RTN

grGAME_OVER	GOSUB	grGO_NEXT

	NIBHEX	000000000000000000	line 0
	NIBHEX	CFFFFFFFFFFFFFFFF3
	NIBHEX	200000000000000004
	NIBHEX	200000000000800004
	NIBHEX	283FC16F106C8C7E14
	NIBHEX	24AC2992009A4A0514
	NIBHEX	220AA69E088A4A3D04
	NIBHEX	2A3E8A020888280414
	NIBHEX	221988011848144214
	NIBHEX	2CD8689F00380E3724
	NIBHEX	201000000000000024
	NIBHEX	2C00000000000000C4
	NIBHEX	200000000000000004
	NIBHEX	CFFFFFFFFFFFFFFFF3
	NIBHEX	000000000000000000	line 14

grGO_NEXT	C=RSTK		Get the address of the bitmap into C[A]
	D1=C		address of graphic

	GOSUBL	srRCL9_A	screen @
	LCHEX	#00334	{#10h #18h}
	A=A+C	A
	D0=A

	LCHEX	#0000E	14+1 lines
	B=C	A
grGO_LINE	LCHEX	#00001	1+1 parts per line
	D=C	A

grGO_PART	A=DAT1	9	read 9 graphic nibbles
	DAT0=A	9	write 9 nibbles to screen
	D0=D0+	9	increment D0
	D1=D1+	9

	D=D-1	A
	GONC	grGO_PART	do next part

	AD0EX
	LCHEX	#00010	#22h - #12h
	A=A+C	A
	D0=A

	B=B-1	A	one less line
	GONC	grGO_LINE	do next line

	RTN



* This will erase one line from the bonus area.
* If there are no lines, then nothing will happen.
* Note that, upon return, field A of A != 0 if there
* is bonus left.

beBONUS_ERS	GOSUBL	srRCL9_A	screen @
	LCHEX	#003F4	{#68h #1Dh}
	A=A+C	A
	D0=A
	A=0	W
	C=0	W
	A=DAT0	7	get 7 nibbles of the screen
	LCHEX	#3FFFFFF	a mask of what we want
	A=A&C	W	mask it off
	ASRB		lose a bit
	LCHEX	#4000000	get that border back
	A=A!C	W	put it on
	DAT0=A	7	write it on the screen
	LCHEX	#00022
	B=C	A
	CD0EX
	C=C+B	A	down one line
	D0=C		into D0
	DAT0=A	7	draw the next line too
	RTN		that's all it takes!

* This will fill the bonus area

beBONUS_DRAW	GOSUBL	srRCL9_A	screen @
	LCHEX	#003F4	{#68h #1Dh}
	A=A+C	A
	D0=A
	LAHEX	#7FFFFFF	a full bonus, and a border
	DAT0=A	7	draw it
	LCHEX	#00022
	B=C	A
	CD0EX
	C=C+B	A	down one line
	D0=C
	DAT0=A	7	draw this one too
	RTN		all done


dlDRAW_LIVES	GOSUBL	srRCL9_A	screen @
	LCHEX	#007CE	{#68h #3Ah}
	C=C+A	A
	D0=C		set D0

	GOSUB	dlLIVES_LEFT

	NIBHEX	E0783C1	|This is the data for the graphic
	NIBHEX	F9FC7E3	|that shows how many lives left.
	NIBHEX	F9FC7E3	|This algorithm will also draw
	NIBHEX	F9FC7E3	|white if there is only 1 life
	NIBHEX	E0783C1	|left, so you don't have to erase.

dlLIVES_LEFT	C=RSTK		Get the address of the bitmap into C[A]
	D1=C		put that into D1

	LCHEX	#00004	(4+1) times
dlDO_LINE	R4=C.F	A
	GOSUB	srRCL22_C	# of lives left
	B=C	A
	B=B-1	A	display 1 less than you have (one is playing)
	LCHEX	#00004	never display more than 4 lives
	?B<=C	A	do you have 4 or less?
	GOYES	dlA_START	display what you have
	B=C	A	make it only 4
	B=B-1	A	now make it 3 to give room for a +
dlA_START	A=0	W
dlANOTHER	?B=0	A
	GOYES	dlNO_ADD
	LCHEX	#00006	(6+1) times
	D=C	A
dlSHIFT	A=A+A	W	shift bits left
	A=A+1	A	make bit 0 a 1
	D=D-1	A
	GONC	dlSHIFT
	B=B-1	A
	GOTO	dlANOTHER

dlNO_ADD	C=DAT1	7	read one line of data
	C=C&A	W	mask out what we want
	DAT0=C	7	write to the screen
	D1=D1+	7	increment to next line
	LCHEX	#00022
	AD0EX
	A=A+C	A
	D0=A
	C=R4.F	A
	C=C-1	A
	GONC	dlDO_LINE	do some more

	GOSUB	srRCL22_C	number of lives again
	B=C	A
	B=B-1	A	always display 1 less
	LCHEX	#00005	too many...
	?B<C	A	do you have 4 or less?
	RTNYES		then go home

dlPLUS	GOSUB	srRCL9_A	PICT @
	LCHEX	#007D3	{#7Ch #3Ah}
	C=C+A	A
	D0=C

	LCHEX	#00022
	B=C	A
	LAHEX	#08	first 2 nibbles
	DAT0=A	2	write to screen
	CD0EX		|
	C=C+B	A	| down 1 line
	D0=C		|
	DAT0=A	2	write to screen
	CD0EX		|
	C=C+B	A	| down 1 line
	D0=C		|
	LAHEX	#3E
	DAT0=A	2	write to screen
	CD0EX		|
	C=C+B	A	| down 1 line
	D0=C		|
	LAHEX	#08
	DAT0=A	2	write to screen
	CD0EX		|
	C=C+B	A	| down 1 line
	D0=C		|
	DAT0=A	2	write to screen

	RTN		end of dlDRAW_LIVES


meMAIN_EVENT	ST=0	1	key delay
	ST=0	2	key delay check
	ST=0	3	key move direction (0==NORMAL)
	ST=0	4	you're not dead (yet!)
	ST=0	5	you haven't won (yet!)
	ST=0	10	set to draw mode (for db)

* Check and see if they're holding down [J] [O] and [E]
* When the [GET READY] banner goes away
	LCHEX	#010
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	0	If they're not holding [J]
	GOYES	meMAIN_LSTRT	Go start

	LCHEX	#004
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	3	If they're not holding [O]
	GOYES	meMAIN_LSTRT	Go start

	LCHEX	#020
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	1	If they're not holding [E]
	GOYES	meMAIN_LSTRT	Go start

	GOSUBL	srSTO43_C	start spreading myths
	GOSUBL	soMYTH	make a mythical sound

* So what is the big myth anyway?  As is written in plain assembly above,
* whenever the GET READY banner is displayed, if you are holding down
* the keys [J] [O] [E] simultaneously when the banner disappears, then
* rumor has it that you will have unlimited lives.  Once you are in the
* "mythical" mode, you can press [U] or [D] whenever the GET READY banner
* is displayed.  When the banner goes away, you will automatically go
* up or down one level respectively.  Great debugging tool, and even greater
* cheat tool.  Joe is the name of my son.  At the time I wrote this, I had
* only two children, and Kathryn was just too many keys to make you hold
* down at one time! :)  Since this time, Jessica and Emilyn have been born,
* but I still think that Joe was the wise choice.
*
* This cheat code still works on the HP38G, but the J, O, and E keys
* have moved, of course.

meMAIN_LSTRT	D1=(5)	=TIMER2
	C=0	A
	C=DAT1	4	get the value of TIMER2
	GOSUBL	srSTO47_C	save (me) starting time

meMAIN_LOOP	LCHEX	#004
	OUT=C
	GOSBVL	=$jCINRTN

	?CBIT=0	5	[shift] key
	GOYES	meNO_BACK
	C=0	A
	GOSUBL	srSTO43_C	stop spreading myths
	LCHEX	#1	since C is already #00000
	GOSUB	srSTO22_C	set lives to 1
	GOSUBL	hbDEAD	make sound
	GOLONG	maMAIN_RTN	instead of RTN

* This is the key you press to restart the level (losing one life).
meNO_BACK	LCHEX	#002
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	5	[DEL] key
	GOYES	meNO_DEL
	ST=1	4	set YOU'RE DEAD flag
	GOSUBL	hbDEAD
	GOLONG	maMAIN_RTN	instead of RTN

meNO_DEL	LCHEX	#010
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	4	[ENTER] key (pause)
	GOYES	meNO_ENT

meSTILL_ENT	LCHEX	#010	| wait here until
	OUT=C		  | they stop pressing
	GOSBVL	=$jCINRTN | the [ENTER] key
	?CBIT=1	4	  |
	GOYES	meSTILL_ENT	|

	GOSUB	pkPAUSE_KEY

meNO_ENT	?ST=0	1	no bounce recently?
	GOYES	meKEY_LEFT	check keys
	?ST=1	2	Check keys anyway?
	GOYES	meSET1
	ST=1	2
	GOTO	meCONT

meSET1	ST=0	1
meKEY_LEFT	ST=0	2	make sure 2 is zero
	LCHEX	#040
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	2	[<-] key
	GOYES	meKEY_RIGHT

	GOSUB	srRCL2_A	Check if keys are reversed?
	LCHEX	#00003
	A=A&C	A
	?ST=0	3
	GOYES	meKL_NORMAL
	LCHEX	#00008	opposite dir (right)
	GOTO	meKL_CONT
meKL_NORMAL	LCHEX	#00004	left dir
meKL_CONT	A=A!C	A
	GOSUBL	srSTO2_A
	GOTO	meCONT

meKEY_RIGHT	LCHEX	#040
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	0	[->] key
	GOYES	meNONE

	GOSUB	srRCL2_A	Check if keys are reversed?
	LCHEX	#00003
	A=A&C	A
	?ST=0	3
	GOYES	meKR_NORMAL
	LCHEX	#00004
	GOTO	meKR_CONT
meKR_NORMAL	LCHEX	#00008
meKR_CONT	A=A!C	A
	GOSUBL	srSTO2_A
	GOTO	meCONT

meNONE	GOSUB	srRCL2_A
	LCHEX	#00003
	A=A&C	A
	GOSUBL	srSTO2_A

meCONT	GOSUBL	mvMOVE
	?ST=0	4	did you not die?
	GOYES	meC_NEXT1
	GOLONG	maMAIN_RTN	instead of RTN
meC_NEXT1	?ST=0	5	did you not win?
	GOYES	meC_NEXT2
	GOLONG	maMAIN_RTN	instead of RTN

meC_NEXT2	GOSUB	srRCL25_C	bonus time
	C=C-1	A
	GOSUB	srSTO25_C
	?C#0	A	still more?
	GOYES	meDELAY	yes? skip
	LC(5)	BONUS_TIME	reset bonus time
	GOSUB	srSTO25_C
	GOSUB	beBONUS_ERS	erase a bonus tick

meDELAY	GOSUB	srRCL18_C	minumum time for main event loop (ticks)
	R2=C.F	A	store n here
	GOSUBL	srRCL47_C	get starting time
	GOSUBL	udDELAYcont	delay the remaining time.
	GOTO	meMAIN_LOOP


pkPAUSE_KEY	LCHEX	#5FF	all keys (even [ON])
	OUT=C
	GOSBVL	=$jCINRTN
	LAHEX	#0803F	all keys (even [ON])
	A=A&C	A
	?A=0	A	no press?
	GOYES	pkPAUSE_KEY

	LAHEX	#08000	[ON]
	A=A&C	A
	?A=0	A	not this one?
	GOYES	pkWAIT
	GOLONG	maEND	return immediately to RPL.

pkWAIT	LCHEX	#1FF
	OUT=C
	GOSBVL	=$jCINRTN
	LAHEX	#0003F	all keys (not [ON])
	A=A&C	A
	?A#0	A	you're still pressing a key?
	GOYES	pkWAIT	wait here until you stop.
	RTN		done with PAUSE_KEY


* This will display either the BONUS or NO BONUS
* banners, and then add the bonus to the score,
* if necessary.

cnCONGRATS	GOSUB	cnMUSIC	play a little tune
	LCHEX	#00066	about 1/2 second
	GOSUBL	waWAIT

	GOSUB	srRCL9_A	screen @
	LCHEX	#003F4	{#1Ah #1Dh}
	A=A+C	A
	D0=A
	A=DAT0	1	get a nibble
	?ABIT=0	0	if bit 0 == 0, no bonus
	GOYES	cnNO_BONUS

	GOSUBL	grBONUS	display the BONUS banner

cnBONUS	GOSUB	beBONUS_ERS	erase one line
	?A=0	A	no more bonus?
	GOYES	cnALMOST_END
	LCHEX	#00025
	GOSUBL	scADD_SCORE
	GOSUBL	soBONUS
	LCHEX	#000C0	ticks
	GOSUBL	udDELAY
	GOTO	cnBONUS

cnALMOST_END	LCHEX	#00025
	GOSUBL	scADD_SCORE	get that last one!
	GOSUBL	soBONUS
	GOTO	cn_END

cnNO_BONUS	GOSUBL	grNO_BONUS	display the NO BONUS banner

cn_END	LCHEX	#00132	about 1.5 seconds
	GOSUBL	waWAIT	delay, pressing a key gets out
	RTN

cnMUSIC	?ST=1	11	sound off?
	RTNYES		outta here!

	LCHEX	#00066	about 1/2 second
	GOSUBL	waWAIT

	LCHEX	#00080	starting pitch
	D=C	A

cn_START	LCHEX	#00018	length
	B=C	A

cn_AGAIN	LCHEX	#800
	OUT=C
	C=D	A	current pitch
cn_DEC1	C=C-1	A
	GONC	cn_DEC1
	C=0	A
	OUT=C
	C=D	A	current pitch
cn_DEC2	C=C-1	A
	GONC	cn_DEC2
	B=B-1	A
	GONC	cn_AGAIN

	LCHEX	#00010
	D=D-C	A
	?D#0	A
	GOYES	cn_START
	RTN

* --------------------------------------
*
* This is a variable storage/retrieval system.
*
* Before any of these routines can be used, you
* must have RAM space pointed to by R0.
* If you call srRCL_C, or srSTO_C, then D0 and A field A
* remain unchanged.  Likewise, if you call srRCL_A or
* srSTO_A, then D0 and C field A remain unchanged even
* though they are used.  Also the data stored with
* srSTO_C and sr_STO_A is still in field A of the reg
* on exit.
*
* --------------------------------------


srRCL3_C	LCHEX	#00003	|  These simple routines
	GOTO	srRCL_C	|  make it possible to recall
srRCL4_C	LCHEX	#00004	|  a specific variable number
	GOTO	srRCL_C	|  with one single GOSUB.  More
srRCL5_C	LCHEX	#00005	|  can be added, if necessary.
	GOTO	srRCL_C	|
srRCL6_C	LCHEX	#00006	|
	GOTO	srRCL_C	|
srRCL7_C	LCHEX	#00007	|
	GOTO	srRCL_C	|
srRCL8_C	LCHEX	#00008	|
	GOTO	srRCL_C	|
srRCL9_C	LCHEX	#00009	|
	GOTO	srRCL_C	|
srRCL15_C	LCHEX	#0000F	|
	GOTO	srRCL_C	|
srRCL18_C	LCHEX	#00012	|
	GOTO	srRCL_C	|
srRCL19_C	LCHEX	#00013	|
	GOTO	srRCL_C	|
srRCL20_C	LCHEX	#00014	|
	GOTO	srRCL_C	|
srRCL22_C	LCHEX	#00016	|
	GOTO	srRCL_C	|
srRCL23_C	LCHEX	#00017	|
	GOTO	srRCL_C	|
srRCL24_C	LCHEX	#00018	|
	GOTO	srRCL_C	|
srRCL25_C	LCHEX	#00019	|
	GOTO	srRCL_C	|
srRCL26_C	LCHEX	#0001A	|
	GOTO	srRCL_C	|
srRCL27_C	LCHEX	#0001B	|
	GOTO	srRCL_C	|
srRCL28_C	LCHEX	#0001C	|
	GOTO	srRCL_C	|
srRCL29_C	LCHEX	#0001D	|
	GOTO	srRCL_C	|
srRCL30_C	LCHEX	#0001E	|
	GOTO	srRCL_C	|
srRCL31_C	LCHEX	#0001F	|
	GOTO	srRCL_C	|
srRCL32_C	LCHEX	#00020	|
	GOTO	srRCL_C	|
srRCL33_C	LCHEX	#00021	|
	GOTO	srRCL_C	|
srRCL34_C	LCHEX	#00022	|
	GOTO	srRCL_C	|
srRCL35_C	LCHEX	#00023	|
	GOTO	srRCL_C	|
srRCL36_C	LCHEX	#00024	|
	GOTO	srRCL_C	|
srRCL37_C	LCHEX	#00025	|
	GOTO	srRCL_C	|
srRCL38_C	LCHEX	#00026	|
	GOTO	srRCL_C	|
srRCL39_C	LCHEX	#00027	|
	GOTO	srRCL_C	|
srRCL40_C	LCHEX	#00028	|
	GOTO	srRCL_C	|
srRCL41_C	LCHEX	#00029	|
	GOTO	srRCL_C	|
srRCL42_C	LCHEX	#0002A	|
	GOTO	srRCL_C	|
srRCL43_C	LCHEX	#0002B	|
	GOTO	srRCL_C	|
srRCL44_C	LCHEX	#0002C	|
	GOTO	srRCL_C	|
srRCL45_C	LCHEX	#0002D	|
	GOTO	srRCL_C	|
srRCL46_C	LCHEX	#0002E	|
	GOTO	srRCL_C	|
srRCL47_C	LCHEX	#0002F	|


srRCL_C	ACEX	A
	CD0EX
	RSTK=C
	C=A	A
	C=C+C	A
	C=C+C	A
	C=C+A	A
	A=R0.F	A
	A=A+C	A
	AD0EX
	C=DAT0	A
	CD0EX
	C=RSTK
	CD0EX
	RTN


srRCL0_A	A=0	A	|  These simple routines
	GOTO	srRCL_A	|  make it possible to recall
srRCL1_A	LAHEX	#00001	|  a specific variable number
	GOTO	srRCL_A	|  with one single GOSUB.  More
srRCL2_A	LAHEX	#00002	|  can be added, if necessary.
	GOTO	srRCL_A	|
srRCL3_A	LAHEX	#00003	|
	GOTO	srRCL_A	|
srRCL4_A	LAHEX	#00004	|
	GOTO	srRCL_A	|
srRCL6_A	LAHEX	#00006	|
	GOTO	srRCL_A	|
srRCL7_A	LAHEX	#00007	|
	GOTO	srRCL_A	|
srRCL8_A	LAHEX	#00008	|
	GOTO	srRCL_A	|
srRCL9_A	LAHEX	#00009	|
	GOTO	srRCL_A	|
srRCL15_A	LAHEX	#0000F	|
	GOTO	srRCL_A	|
srRCL16_A	LAHEX	#00010	|
	GOTO	srRCL_A	|
srRCL17_A	LAHEX	#00011	|
	GOTO	srRCL_A	|
srRCL19_A	LAHEX	#00013	|
	GOTO	srRCL_A	|
srRCL21_A	LAHEX	#00015	|
	GOTO	srRCL_A	|
srRCL23_A	LAHEX	#00017	|
	GOTO	srRCL_A	|
srRCL24_A	LAHEX	#00018	|
	GOTO	srRCL_A	|
srRCL27_A	LAHEX	#0001B	|
	GOTO	srRCL_A	|
srRCL28_A	LAHEX	#0001C	|

srRCL_A	CD0EX
	RSTK=C
	C=A	A
	A=A+A	A
	A=A+A	A
	A=A+C	A
	C=R0.F	A
	C=C+A	A
	CD0EX
	A=DAT0	A
	CD0EX
	C=RSTK
	CD0EX
	RTN


srSTO0_C	GOSUBL	CSLW5	|  These simple routines
	C=0	A	|  make it possible to store
	GOTO	srSTO_C	|  a specific variable number
srSTO1_C	GOSUBL	CSLW5	|  with one single GOSUB.  More
	LCHEX	#00001	|  can be added, if necessary.
	GOTO	srSTO_C	|
srSTO2_C	GOSUBL	CSLW5	|  Also, the data being stored
	LCHEX	#00002	|  (in C, field A) is preserved,
	GOTO	srSTO_C	|  and on exit, it is still in
srSTO3_C	GOSUBL	CSLW5	|  C, field A.	You may call
	LCHEX	#00003	|  srSTO_C directly, if you first
	GOTO	srSTO_C	|  call =CSLW5 to shift the data over,
srSTO4_C	GOSUBL	CSLW5	|  then place the Var# in C, field A
	LCHEX	#00004	|  On exit, the var data is in C, field A.
	GOTO	srSTO_C	|
srSTO5_C	GOSUBL	CSLW5	|
	LCHEX	#00005	|
	GOTO	srSTO_C	|
srSTO7_C	GOSUBL	CSLW5	|
	LCHEX	#00007	|
	GOTO	srSTO_C	|
srSTO8_C	GOSUBL	CSLW5	|
	LCHEX	#00008	|
	GOTO	srSTO_C	|
srSTO9_C	GOSUBL	CSLW5	|
	LCHEX	#00009	|
	GOTO	srSTO_C	|
srSTO15_C	GOSUBL	CSLW5	|
	LCHEX	#0000F	|
	GOTO	srSTO_C	|
srSTO16_C	GOSUBL	CSLW5	|
	LCHEX	#00010	|
	GOTO	srSTO_C	|
srSTO17_C	GOSUBL	CSLW5	|
	LCHEX	#00011	|
	GOTO	srSTO_C	|
srSTO18_C	GOSUBL	CSLW5	|
	LCHEX	#00012	|
	GOTO	srSTO_C	|
srSTO19_C	GOSUBL	CSLW5	|
	LCHEX	#00013	|
	GOTO	srSTO_C	|
srSTO20_C	GOSUBL	CSLW5	|
	LCHEX	#00014	|
	GOTO	srSTO_C	|
srSTO21_C	GOSUBL	CSLW5	|
	LCHEX	#00015	|
	GOTO	srSTO_C	|
srSTO22_C	GOSUBL	CSLW5	|
	LCHEX	#00016	|
	GOTO	srSTO_C	|
srSTO23_C	GOSUBL	CSLW5	|
	LCHEX	#00017	|
	GOTO	srSTO_C	|
srSTO24_C	GOSUBL	CSLW5	|
	LCHEX	#00018	|
	GOTO	srSTO_C	|
srSTO25_C	GOSUBL	CSLW5	|
	LCHEX	#00019	|
	GOTO	srSTO_C	|
srSTO26_C	GOSUBL	CSLW5	|
	LCHEX	#0001A	|
	GOTO	srSTO_C	|
srSTO27_C	GOSUBL	CSLW5	|
	LCHEX	#0001B	|
	GOTO	srSTO_C	|
srSTO28_C	GOSUBL	CSLW5	|
	LCHEX	#0001C	|
	GOTO	srSTO_C	|
srSTO29_C	GOSUBL	CSLW5	|
	LCHEX	#0001D	|
	GOTO	srSTO_C	|
srSTO30_C	GOSUBL	CSLW5	|
	LCHEX	#0001E	|
	GOTO	srSTO_C	|
srSTO31_C	GOSUBL	CSLW5	|
	LCHEX	#0001F	|
	GOTO	srSTO_C	|
srSTO32_C	GOSUBL	CSLW5	|
	LCHEX	#00020	|
	GOTO	srSTO_C	|
srSTO33_C	GOSUBL	CSLW5	|
	LCHEX	#00021	|
	GOTO	srSTO_C	|
srSTO34_C	GOSUBL	CSLW5	|
	LCHEX	#00022	|
	GOTO	srSTO_C	|
srSTO35_C	GOSUBL	CSLW5	|
	LCHEX	#00023	|
	GOTO	srSTO_C	|
srSTO36_C	GOSUBL	CSLW5	|
	LCHEX	#00024	|
	GOTO	srSTO_C	|
srSTO37_C	GOSUBL	CSLW5	|
	LCHEX	#00025	|
	GOTO	srSTO_C	|
srSTO38_C	GOSUBL	CSLW5	|
	LCHEX	#00026	|
	GOTO	srSTO_C	|
srSTO39_C	GOSUBL	CSLW5	|
	LCHEX	#00027	|
	GOTO	srSTO_C	|
srSTO40_C	GOSUBL	CSLW5	|
	LCHEX	#00028	|
	GOTO	srSTO_C	|
srSTO41_C	GOSUBL	CSLW5	|
	LCHEX	#00029	|
	GOTO	srSTO_C	|
srSTO42_C	GOSUBL	CSLW5	|
	LCHEX	#0002A	|
	GOTO	srSTO_C	|
srSTO43_C	GOSUBL	CSLW5	|
	LCHEX	#0002B	|
	GOTO	srSTO_C	|
srSTO44_C	GOSUBL	CSLW5	|
	LCHEX	#0002C	|
	GOTO	srSTO_C	|
srSTO45_C	GOSUBL	CSLW5	|
	LCHEX	#0002D	|
	GOTO	srSTO_C	|
srSTO46_C	GOSUBL	CSLW5	|
	LCHEX	#0002E	|
	GOTO	srSTO_C	|
srSTO47_C	GOSUBL	CSLW5	|
	LCHEX	#0002F	|

srSTO_C	GOSUBL	ASLW5	preserve A, field A
	AD0EX		put D0 into A, field A
	GOSUBL	ASLW5	preserve it (D0)
	A=C	A	|
	C=C+C	A	| Multiply Var# by 5
	C=C+C	A	|
	C=C+A	A	|
	A=R0.F	A	get RAM address of Vars
	A=A+C	A	add the offset (Var# * 5)
	D0=A		put it in D0
	GOSUBL	CSRW5	shift C to get var data
	DAT0=C	A	write var to RAM
	GOSUBL	ASRW5	restore D0
	D0=A		put it in D0
	GOSUBL	ASRW5	restore A, field A
	RTN

srSTO2_A	GOSUBL	ASLW5	|  These simple routines
	LAHEX	#00002	|  make it possible to store
	GOTO	srSTO_A	|  a specific variable number
srSTO4_A	GOSUBL	ASLW5	|  with one single GOSUB.  More
	LAHEX	#00004	|  can be added, if necessary.
	GOTO	srSTO_A	|
srSTO6_A	GOSUBL	ASLW5	|
	LAHEX	#00006	|
	GOTO	srSTO_A	|
srSTO16_A	GOSUBL	ASLW5	|
	LAHEX	#00010	|
	GOTO	srSTO_A	|
srSTO17_A	GOSUBL	ASLW5	|
	LAHEX	#00011	|
	GOTO	srSTO_A	|
srSTO28_A	GOSUBL	ASLW5	|
	LAHEX	#0001C	|


srSTO_A	GOSUBL	CSLW5	preserve C, field A
	CD0EX		put D0 into C, field A
	GOSUBL	CSLW5	preserve it (D0)
	C=A	A	|
	A=A+A	A	| Multiply Var# by 5
	A=A+A	A	|
	A=A+C	A	|
	C=R0.F	A	get RAM address of Vars
	C=C+A	A	add the offset (Var # 5)
	D0=C		put it in D0
	GOSUBL	ASRW5	shift A to get var data
	DAT0=A	A	write var to RAM
	GOSUBL	CSRW5	restore D0
	D0=C		put it in D0
	GOSUBL	CSRW5	restore C, field A
	RTN


* -------------------------------------
* MOVE needs 3 arguments
*
* Var #0 == Current x coord
* Var #1 == Current y coord
* Var #2 == direction to move (0 for no move, just draw)
*
* MOVE will change x & y in the direction of R2.


mvMOVE	GOSUB	srRCL0_A	get X coord
	R1=A.F	A	put it in temp X
	GOSUB	srRCL1_A	get Y coord
	R2=A.F	A	put it in temp y

	GOSUB	srRCL2_A	Direction
	R3=A.F	A	Temp Dir used in cb
	?ABIT=0	0	Going up?
	GOYES	mvCHDN	no? check down

mvUP	C=R2.F	A	temp Y
	C=C-1	A	up one
	GOC	mvCHDN	less than 0? no good!
	R2=C.F	A	store it (in temp Y)

mvCHDN	?ABIT=0	1	going down?
	GOYES	mvCHLEFT	no? check left

mvDOWN	LCHEX	#0003C	stopping point (#40h - #5h + #1h)
	B=C	A	put it in B
	C=R2.F	A	temp Y
	C=C+1	A	down 1
	?B<=C	A	down too far?
	GOYES	mvCHLEFT	yes? check left
	R2=C.F	A	store it (in temp Y)

mvCHLEFT	?ABIT=0	2	going left?
	GOYES	mvCHRGT	no? check right

mvLEFT	C=R1.F	A	temp X
	C=C-1	A	left one
	GOC	mvCHRGT	too far left
	R1=C.F	A	store it (in tempX)

mvCHRGT	?ABIT=0	3	going right?
	GOYES	dbDRAW_BALL	no? draw it.
mvRIGHT	LCHEX	#0007F	limit (#83h - #5h + #1h) (#83h == 131)
	B=C	A
	C=R1.F	A	temp X
	C=C+1	A
	?B<=C	A	too far?
	GOYES	dbDRAW_BALL	draw it
	R1=C.F	A	store it (in tempX)

dbDRAW_BALL	GOSUB	dbSTART

	NIBHEX	E0F1F1F1E0	dbSHAPE

	NIBHEX	000000000110E00	dbUPMASK
	NIBHEX	000020020030C10	dbUPLEFTMASK
	NIBHEX	000800800810070	dbUPRIGHTMASK
	NIBHEX	E00110000000000	dbDOWNMASK
	NIBHEX	C10030020020000	dbDOWNLEFTMASK
	NIBHEX	070810800800000	dbDOWNRIGHTMASK
	NIBHEX	010020020020010	dbLEFTMASK
	NIBHEX	010800800800010	dbRIGHTMASK

dbSTART	C=RSTK		C is now set to @shape
	GOSUB	srSTO7_C	store it in Var#7

	LCHEX	#00022
	D=C	A	set D to Y incr.
	GOSUBL	srRCL9_C	PICT bitmap address (not GROB)
	B=0	A
	A=R1.F	A	tempX coord.
	SB=0
	ASRB.F	A	divide by 2
	?SB=0		was there a bit lost?
	GOYES	dbAGAIN1	no? continue
	B=B+1	A	have to shift it at least once
dbAGAIN1	SB=0
	ASRB.F	A	divide by 2
	?SB=0		was there a bit lost?
	GOYES	dbAGAIN2	no... continue
	B=B+1	A	need to shift once more...
	B=B+1	A	...and once more
dbAGAIN2	C=C+A	A	add X coord
	A=R2.F	A	temp Y coord.

dbADDY	?A=0	A	add some?
	GOYES	dbNONE	no? done
	C=C+D	A	down 1 line
	A=A-1	A
	GOTO	dbADDY
dbNONE	GOSUB	srSTO3_C	store it.
	C=B	A	get shifts
	GOSUB	srSTO4_C	save it for later
	?ST=1	10	check if we should erase the ball
	GOYES	dbSKIP

	GOSUB	cbCHK_BOUNCE	see if we bounce
	?ST=1	4	did you die?
	RTNYES
	?ST=1	5	did you win?
	RTNYES
dbSKIP	GOSUBL	srRCL3_C	good thing we saved it.
	D0=C		put screen @ in D0
	GOSUBL	srRCL7_C	@ of ball
	D1=C		put it in D1
	GOSUBL	srRCL4_C	# of shifts
	B=C	A	put it here
	C=R1.F	A	get temp X
	GOSUB	srSTO0_C	put in X
	C=R2.F	A	get temp Y
	GOSUB	srSTO1_C	put in Y

	LCHEX	#00004	set loop to 5 times
	D=C	A
dbDO_NEXT	A=0	A
	A=DAT1	2	get one line of ball
	C=B	A	number of shifts
dbCHECK	?C=0	A	do some?
	GOYES	dbCONT	no? continue
	A=A+A	A	shift graphic
	C=C-1	A
	GOTO	dbCHECK

dbCONT	C=DAT0	2	get current screen
	?ST=0	10	draw or erase?
	GOYES	dbORIT	go draw
	A=-A-1	A	NOT(A)
	A=A&C	A	mask out what we want
	GOTO	dbWRITEIT	go write it
dbORIT	A=A!C	A	OR with screen
dbWRITEIT	DAT0=A	2	draw graphic

	LCHEX	#00022
	AD0EX
	A=A+C	A	down 1 line
	D0=A		set D0
	D1=D1+	2	set D1 next ball line

	D=D-1	A	decrement counter

	GONC	dbDO_NEXT


dbCHECKDIR	GOSUB	srRCL2_A	direction
	?ABIT=0	0	shape not going up?
	GOYES	dbCHDOWN	yes it isn't? -> go next
	?ABIT=1	2	shape going left?
	GOYES	dbUPLEFT	yes? do up-left
	?ABIT=1	3	shape going right?
	GOYES	dbUPRIGHT	yes? do up-right

dbUP	GOSUB	srRCL3_A	get screen pos
	A=A+C	A	down 1 line
	D0=A		set D0
	GOTO	erERASE

dbUPLEFT	GOSUB	srRCL3_A	get screen pos
	A=A+C	A	down 1 line
	D0=A		set D0
	D1=D1+	15	go to next erase mask
	GOTO	erERASE

dbUPRIGHT	GOSUB	srRCL3_A	get screen pos
	A=A+C	A	up one line
	A=A-1	A	back one nibble
	D0=A		set D0
	D1=D1+	15	|
	D1=D1+	15	|set to up-right mask
	GOTO	erERASE

dbCHDOWN	D1=D1+	15	|
	D1=D1+	15	| Point to down erase mask
	D1=D1+	15	|

	?ABIT=0	1	shape not going down?
	RTNYES		yes it isn't? -> not moving.
	?ABIT=1	2	going left?
	GOYES	dbDNLEFT	yes? do down-left
	?ABIT=1	3	going right?
	GOYES	dbDNRIGHT	yes? do down-right

dbDOWN	GOSUB	srRCL3_A	screen pos
	A=A-C	A	up one line
	D0=A		set D0
	GOTO	erERASE

dbDNLEFT	GOSUB	srRCL3_A	screen pos
	A=A-C	A	up one line
	D0=A		set D0
	D1=D1+	15	set to down-left erase mask
	GOTO	erERASE

dbDNRIGHT	GOSUB	srRCL3_A	screen pos
	A=A-C	A	up one line
	A=A-1	A	back one nibble
	D0=A		set D0
	D1=D1+	15	|
	D1=D1+	15	|set to down-right erase mask

* No need to do a GOTO ERASE...it comes next.


erERASE	GOSUBL	srRCL4_C	DEBUG
	B=C	A	DEBUG
	LCHEX	#00004	loop 5 times
	D=C	A
erDO_NEXT	A=0	A
	A=DAT1	3	get 1 line of mask
	C=B	A	number of shifts
erCHECK	?C=0	A	do some?
	GOYES	erCONT	no? continue
	A=A+A	A	shift graphic
	C=C-1	A
	GOTO	erCHECK

erCONT	C=DAT0	3	get current screen
	A=-A-1	A	A=NOT(A) (inverse)
	A=A&C	A	mask out what we want
	DAT0=A	3	put on screen

	LCHEX	#00022
	AD0EX		get D0
	A=A+C	A	down 1 line
	D0=A		set D0
	D1=D1+	3	set D1 to next mask line
	D=D-1	A	decrement counter

	GONC	erDO_NEXT

	RTN


cbCHK_BOUNCE	GOSUBL	srRCL3_A	screen pos
	D0=A		set D0
	A=R3.F	A	temp direction

	GOSUB	cbSTART

	NIBHEX	000000000110E00	cbDNMASK
	NIBHEX	000010010810E00	cbDNRIGHTMASK
	NIBHEX	000100100300E00	cbDNLEFTMASK
	NIBHEX	E00110000000000	cbUPMASK
	NIBHEX	E00810010010000	cbUPRIGHTMASK
	NIBHEX	E00300100100000	cbUPLEFTMASK

cbSTART	C=RSTK		C is now @ cbDOWN mask
	D1=C		put it in D1
	?ABIT=1	0	ball going up?
	GOYES	cbCHUP	yes -> do up
	?ABIT=1	3	going right?
	GOYES	cbDNRIGHT	yes? do down-right
	?ABIT=0	2	shape not going left?
	GOYES	cbMASK	yes it isn't? go to down

cbDNLEFT	D1=D1+	15	|point to proper erase mask
cbDNRIGHT	D1=D1+	15	|depending on where you jumped to
	GOTO	cbMASK	|

cbCHUP	D1=D1+	15	|
	D1=D1+	15	|point to down erase mask
	D1=D1+	15	|
	?ABIT=0	0	ball not going up?
	RTNYES		no? -> not moving.
	?ABIT=1	3	going right?
	GOYES	cbUPRIGHT	yes? do up-right
	?ABIT=0	2	ball not going left?
	GOYES	cbMASK	yes it isn't? -> do up

cbUPLEFT	D1=D1+	15	|point to proper erase mask
cbUPRIGHT	D1=D1+	15	|depending on where you jumped to

* no GOTO, cbMASK must come next...

* ------------------------------
* | At this point, D1 should point to the proper
* | erase mask. (opposite of direction... DIR = UP
* |  -> MASK = DOWN, DIR = UP-LEFT -> MASK = DN-RIGHT.
* | D0 should point to the screen address that the
* | ball will be drawn to if no bounce.
* ------------------------------


cbMASK	LCHEX	#00004	set loop to 5 times
	D=C	A	use D
cbNEXT_LINE	A=0	A	clear
	A=DAT1	3	get 1 line of mask
	C=B	A	# of shifts
cbSHIFT	?C=0	A	do some?
	GOYES	cbCONT	no? continue
	A=A+A	A	shift graphic
	C=C-1	A	decrement # of shifts
	GOTO	cbSHIFT	do more

cbCONT	C=DAT0	3	get screen
	C=C&A	A	use mask
	GOSUB	cbFASTSTO_C	store data

	LCHEX	#00022	1 line distance
	AD0EX		get D0
	A=A+C	A	down 1 line
	D0=A		set D0
	D1=D1+	3	set D1 to next mask line
	D=D-1	A	dec counter
	GONC	cbNEXT_LINE	CARRY clear? do more

cbCHECK	ST=0	0	clear bounce flag
	LCHEX	#00004	loop 5 times
	D=C	A	Put it in D
cbGET_DATA	GOSUB	cbFASTRCL_C	recall data
	?C=0	A	no hit?
	GOYES	cbDEC	check next
	GOSUB	boBOUNCE	bounce it!
cbDEC	D=D-1	A	dec counter
	GONC	cbGET_DATA	do another line

	?ST=0	0	no bounce?
	RTNYES		RETURN
	ST=1	1	this tells (me) there was a recent bounce
	C=R3.F	A	get new direction
	GOSUBL	srSTO2_C	make it the current direction
	GOSUB	hbHIT_BRICK	check if a brick was hit
	?ST=1	4	did you die?
	RTNYES
	?ST=1	5	did you win?
	RTNYES
	GOTO	mvMOVE	go move it.


boBOUNCE	R4=C.F	A	save bounce data
	ST=1	0	set bounce flag
	C=0	A	clear C
	GOSUBL	srRCL2_A	direction
	?ABIT=1	0	ball going up?
	GOYES	boCHULFT	yes? check up-left
	GOTO	boCHDOWN	no? -> check down
boCHULFT	?ABIT=1	2	going left?
	GOYES	boUPLEFT	yes? do up-left
	?ABIT=1	3	going right?
	GOYES	boUPRIGHT	yes? do up-right

boUP	LCHEX	#4
	?C#D	A
	GOYES	boU_N1
	GOTO	boDOWN_DIR

boU_N1	GOSUB	boFIX_DATA
	?CBIT=0	0
	GOYES	boUN
	GOSUB	boDOWN_DIR
	GOTO	boRIGHT_DIR

boUN	?CBIT=0	4
	RTNYES
	GOSUB	boDOWN_DIR
	GOTO	boLEFT_DIR

boUPLEFT	LCHEX	#4
	?C#D	A	is D not equal to 4?
	GOYES	boUL_N1
	GOTO	boDOWN_DIR	set temp dir to down

boUL_N1	LCHEX	#3
	?C#D	A	is D not equal to 3?
	GOYES	boUL_N2
	GOSUB	boFIX_DATA	shift data back
	?CBIT=0	1	no down-right?
	GOYES	boULN	check next
	GOSUB	boDOWN_DIR	toggle temp-dir to down
	GOTO	boRIGHT_DIR	then to right

boULN	?CBIT=0	0	no bounce right?
	RTNYES		return
	GOTO	boRIGHT_DIR	toggle temp-dir to right

boUL_N2	?D=0	A	D=0?
	RTNYES		yes? return
	GOTO	boRIGHT_DIR	toggle temp-dir to right

boUPRIGHT	LCHEX	#4
	?C#D	A
	GOYES	boUR_N1
	GOTO	boDOWN_DIR

boUR_N1	LCHEX	#3
	?C#D	A
	GOYES	boUR_N2
	GOSUB	boFIX_DATA
	?CBIT=0	3	no dn-left?
	GOYES	boURN
	GOSUB	boDOWN_DIR
	GOSUB	boLEFT_DIR

boURN	?CBIT=0	4
	RTNYES
	GOTO	boLEFT_DIR

boUR_N2	?D=0	A
	RTNYES
	GOTO	boLEFT_DIR

boCHDOWN	?ABIT=0	1	ball not going down?
	RTNYES		must not be moving
	?ABIT=1	2	going left?
	GOYES	boDNLEFT	do down-left
	?ABIT=1	3	going right?
	GOYES	boDNRIGHT	do down-right

boDOWN	?D#0	A
	GOYES	boD_N1
	GOTO	boUP_DIR
boD_N1	GOSUB	boFIX_DATA
	?CBIT=0	0
	GOYES	boDN
	GOSUB	boUP_DIR
	GOTO	boRIGHT_DIR
boDN	?CBIT=0	4
	RTNYES
	GOSUB	boUP_DIR
	GOTO	boLEFT_DIR

boDNLEFT	?D#0	A
	GOYES	boDL_N1
	GOTO	boUP_DIR

boDL_N1	LCHEX	#1
	?D=C	A
	GOYES	boDL_N2
	GOTO	boRIGHT_DIR

boDL_N2	GOSUB	boFIX_DATA
	?CBIT=0	1	no up-right?
	GOYES	boDLN
	GOSUB	boUP_DIR
	GOTO	boRIGHT_DIR

boDLN	?CBIT=0	0	no right?
	RTNYES
	GOTO	boRIGHT_DIR

boDNRIGHT	?D#0	A
	GOYES	boDR_N1
	GOTO	boUP_DIR

boDR_N1	LCHEX	#1
	?D=C	A
	GOYES	boDR_N2
	GOTO	boLEFT_DIR

boDR_N2	GOSUB	boFIX_DATA
	?CBIT=0	3	no up-left?
	GOYES	boDRN
	GOSUB	boUP_DIR
	GOTO	boLEFT_DIR

boDRN	?CBIT=0	4	no left?
	RTNYES
	GOTO	boLEFT_DIR

boUP_DIR	A=R3.F	A	temp dir
	LCHEX	#C	binary -> 1100
	A=A&C	A	mask off other dir
	LCHEX	#00001	up
	A=A!C	A	or in onto dir
	R3=A.F	A	store it
	RTN

boDOWN_DIR	A=R3.F	A
	LCHEX	#C	binary -> 1100
	A=A&C	A
	LCHEX	#00002	down
	A=A!C	A
	R3=A.F	A
	RTN

boLEFT_DIR	A=R3.F	A
	LCHEX	#3	binary -> 0011
	A=A&C	A
	LCHEX	#00004	left
	A=A!C	A
	R3=A.F	A
	RTN

boRIGHT_DIR	A=R3.F	A
	LCHEX	#3	binary -> 0011
	A=A&C	A
	LCHEX	#00008	right
	A=A!C	A
	R3=A.F	A
	RTN

cbFASTSTO_C	CD0EX
	RSTK=C
	C=D	A
	C=C+CON	A,10
	A=C	A
	C=C+C	A
	C=C+C	A
	C=C+A	A
	A=R0.F	A
	A=A+C	A
	CD0EX
	D0=A
	DAT0=C	A
	C=RSTK
	D0=C
	RTN

cbFASTRCL_C	C=D	A
	C=C+CON	A,10
	A=C	A
	C=C+C	A
	C=C+C	A
	C=C+A	A
	A=R0.F	A
	A=A+C	A
	D0=A
	C=DAT0	A
	RTN

boFIX_DATA	C=R4.F	A
	A=B	A	# of shifts
boSHIFT	?A=0	A	do some?
	RTNYES		no? RTN
	CSRB.F	A	shift RIGHT
	A=A-1	A
	GOTO	boSHIFT

* ----------------------------------------------
* | hbHIT_BRICK
* | Find what kind of brick was hit, and
* | determine what to do about it. (and do it!)
* |
* | R1, R2, R3 are temporarily used.
* |
* ----------------------------------------------


hbHIT_BRICK	GOSUBL	srRCL3_A
	D1=A
	LCHEX	#00004	(4+1) times, you know.
	D=C	A
	GOSUB	cbFASTRCL_C
	?C=0	A	was there NO hit on this line?
	GOYES	hbCHECK0
	GOSUB	hbOUT
	?ST=1	4	did you die?
	RTNYES
	GOTO	hbCHECK1	only need to check 1 (since we hit)

hbCHECK0	GOSUBL	srRCL3_A
	LCHEX	#00088
	A=A+C	A
	D1=A
	D=0	A
	GOSUB	cbFASTRCL_C
	?C=0	A	no hit here?
	GOYES	hbCHECK3	then check sides
	GOSUB	hbOUT
	?ST=1	4	did you die?
	RTNYES

	GOSUBL	srRCL3_A
	LCHEX	#00022
	A=A+C	A
	D1=A
	LCHEX	#00003
	D=C	A
	GOSUB	cbFASTRCL_C
	?C=0	A
	RTNYES
	GOTO	hbOUT

hbCHECK3	GOSUBL	srRCL3_A
	LCHEX	#00022
	A=A+C	A
	D1=A
	LCHEX	#00003
	D=C	A
	GOSUB	cbFASTRCL_C
	?C=0	A
	GOYES	hbCHECK2
	GOTO	hbOUT

hbCHECK2	GOSUBL	srRCL3_A
	LCHEX	#00044
	A=A+C	A
	D1=A
	LCHEX	#00002
	D=C	A
	GOSUB	cbFASTRCL_C
	?C=0	A
	GOYES	hbCHECK1
	GOTO	hbOUT

hbCHECK1	GOSUBL	srRCL3_A
	LCHEX	#00066
	A=A+C	A
	D1=A
	LCHEX	#00001
	D=C	A
	GOSUB	cbFASTRCL_C
	?C=0	A
	RTNYES

hbOUT	LAHEX	#0000F	in binary 000000001111
	A=A&C	A	mask off nibble 0 (left-most on screen)
	?A#0	A	was there a hit here?
	GOYES	hbHIT
	D1=D1+	1	next nibble over
	LAHEX	#F0	in binary 000011110000
	A=A&C	A	mask off nibble 1 (middle nibble)
	?A#0	A	was there a hit here?
	GOYES	hbHIT
	D1=D1+	1

* I am assuming if you get this far with no hit,
* then the hit was in nibble 2.  (Unless you jumped to hbHIT)

hbHIT	C=0	W	zero reg
	A=0	W	zero reg
	GOSUBL	srRCL9_A	get screen address
	LCHEX	#45	offset to playing board
	C=C+A	A	add the amount
	AD1EX		get collision nibble
	A=A-C	A	get nibble offset
	GONC	hbNEXT1	carry is clear, OK for now
	GOTO	hbWALL	carry was set, we hit a wall.

hbNEXT1	LCHEX	#00022
	GOSUBL	DIV	A=A/C & C=A/C & B=remainder. (fields W)
	R1=C.F	A	save result
	A=B	A	get remainder
	LCHEX	#00003	each brick has 3 nibbles
	GOSUBL	DIV	C now contains column #
	LAHEX	#00007	7+1 columns
	?C<=A	A	column ok?
	GOYES	hbNEXT2
	GOTO	hbWALL	column too big? we hit a wall.

hbNEXT2	R3=C.F	A	put column # here for use in hbERS_BRICK
	LAHEX	#0000A	10 rows of bricks (use rows for offset)
	GOSBVL	=$jMUL#	B contains column offset
	C=B	A	column offset
	R2=C.F	A	save it

	A=R1.F	A	get earlier result back
	LCHEX	#00006	each brick has 6 rows
	GOSUBL	DIV	A & C contain row offset
	LCHEX	#00009	9+1 rows
	?C>=A	A	row ok?
	GOYES	hbNEXT3
	GOTO	hbWALL	row too big? we hit a wall

hbNEXT3	R1=A.F	A	R1 now contains row # for hbERS_BRICK

	C=R2.F	A	get column offset
	C=C+A	A	C is offset into brick matrix

* Now we can use C to see what kind of brick is at the collision site
* R1 == row#, R3 == column#

	GOSUBL	srRCL6_A	@ of current level brick matrix
	A=A+C	A
	D0=A
	C=0	A
	C=DAT0	1	get the brick
	?C#0	A	is it a brick?
	GOYES	hbNEXT4	then deal with it.
	GOTO	hbWALL	if there's no brick, it must be a wall

hbNEXT4	GOSUBL	srRCL15_A	erase mode
	?A=C	A	same as current brick?
	GOYES	hbNEXT5	deal with it.
	?ST=1	6	can we knock out diamonds?
	GOYES	hbCHECK_DM
	GOTO	hbCHK_OTHERS	otherwise, check others
hbCHECK_DM	LAHEX	#00002	a diamond brick
	?A=C	A	did you hit a diamond?
	GOYES	hbERASE_DIA	then deal with it
	GOTO	hbCHK_OTHERS	otherwise, deal with it differently

hbNEXT5	GOSUBL	srRCL16_A	number of bricks
	A=A-1	A	one less now
	GOSUBL	srSTO16_A
	?A=0	A	still more?
	GOYES	hbSET_ED	nope? set to erase diamonds
	GOSUB	hbERS_BRICK	erase the brick
	LC(5)	BRICK_SCORE	points for a NORMAL brick
	GOSUB	scADD_SCORE	add and display score.
	GOLONG	soERS_BRICK	make the sound
hbSET_ED	ST=1	6	we can erase diamonds now.
	GOSUB	hbERS_BRICK	we still need to erase that brick
	LC(5)	BRICK_SCORE	points for a NORMAL brick
	GOSUB	scADD_SCORE	add and display score.
	GOLONG	soERS_BRICK	make the sound

hbERASE_DIA	GOSUBL	srRCL17_A	number of diamonds left
	A=A-1	A	one less
	GOSUBL	srSTO17_A	store it

	?A#0	A	still more?
	GOYES	hbER_CONT
	ST=1	5	set YOU WON flag to 1

hbER_CONT	GOSUB	hbERS_BRICK	erase the diamond
	?ST=0	11	sound on?
	GOYES	hbED_START	yes? make the sound.

	LCHEX	#000E2	length of sound (ticks)
	GOSUBL	udDELAY	delay
	GOTO	hbED_END

hbED_START	LCHEX	#00066	starting pitch
	D=C	A

hbED_AGAIN	LCHEX	#800
	OUT=C
	C=D	A	current pitch
hbED_DEC1	C=C-1	A
	GONC	hbED_DEC1
	C=0	A
	OUT=C
	LCHEX	#00066
	C=C-D	A	inverse of current pitch
hbED_DEC2	C=C-1	A
	GONC	hbED_DEC2
	D=D-1	A
	LCHEX	#00050	ending value
	?D>C	A
	GOYES	hbED_AGAIN

hbED_END	LC(5)	DIAM_SCORE	points for a diamond
	GOTO	scADD_SCORE	add and display score.


hbCHK_OTHERS	?CBIT=0	3	check bit 3
	GOYES	hbCO_2
	?CBIT=1	0	if this bit is 0, then act as wall
	GOYES	hbCO_1	must be an erase mode changer
	GOTO	hbWALL	must be a brick you can't erase
hbCO_1	GOSUBL	srRCL15_A	get current erase mode
	C=C-1	A	one less than brick# is erase mode
	?C#A	A	is it a new mode?
	GOYES	hbCO_1CONT1	yes? change it
	GOTO	hbWALL	otherwise, act as wall
hbCO_1CONT1	GOSUBL	srSTO15_C	set new mode
	GOSUB	emDRAW_BRICK	draw new brick
	GOLONG	soEM_CHANGE	do erase mode change sound (then RTN)

hbCO_2	?CBIT=1	2	check bit 2
	GOYES	hbCO_3
	GOTO	hbWALL
* the above goto will only happen if the brick is
* 1(first brick) 2(diamond) or 3(wall) and the erase
* mode is not 1 or 2.  So, they all act as walls here.

hbCO_3	?CBIT=1	1	check bit 1
	GOYES	hbCO_4

	?CBIT=0	0	check bit 0
	GOYES	hbCO_KEY

* following is if you just hit a lock brick

	?ST=1	7	do you have a key?
	GOYES	hbCOL_OK	ok!
	GOTO	hbWALL	if not, be a wall.
hbCOL_OK	ST=0	7	no more key
	GOSUB	hbERS_BRICK	erase the lock brick
	GOSUB	hbDRAW_KEY	erase the key
	GOSUBL	soERASE_LOCK	make the sound
	LC(5)	LOCK_SCORE	points for a lock brick
	GOTO	scADD_SCORE	add and display score.

* following is if you just hit a key brick

hbCO_KEY	?ST=0	7	do you not have a key?
	GOYES	hbCOK_OK	ok!
	GOTO	hbWALL	can't have more than one
hbCOK_OK	ST=1	7	now you have a key
	GOSUB	hbERS_BRICK	erase the brick
	GOSUB	hbDRAW_KEY	draw the key
	GOSUBL	soERASE_KEY	make the sound
	LC(5)	KEY_SCORE	points for a key brick
	GOTO	scADD_SCORE	add and display score.

hbCO_4	?CBIT=1	0	check bit 0
	GOYES	hbCO_5
	GOTO	hbDEAD	you hit a cross!!

* To get here (below) you hit a double arrow brick.
hbCO_5	?ST=0	3	is direction NORMAL?
	GOYES	hbDIRCH1
	ST=0	3	dir is now NORMAL
	GOSUB	hbERS_BRICK	erase the arrows brick
	GOLONG	soDOUBLE_ARR	make a sound
hbDIRCH1	ST=1	3	dir is now opposite
	GOSUB	hbERS_BRICK
	GOLONG	soDOUBLE_ARR	make a sound

hbERS_BRICK	A=R1.F	A	row number
	LCHEX	#000CC	(6 * #22h) (6 lines per brick)
	GOSBVL	=$jMUL#	result in B
	A=B	A
	R1=A.F	A
	A=R3.F	A	column number
	LCHEX	#03	(3 nibbles per brick)
	GOSBVL	=$jMUL#	result in B
	C=B	A
	A=R1.F	A
	A=A+C	A	now I have the (almost) correct nibble offset
	LCHEX	#00045	two lines down, one nibble over
	A=A+C	A	now I have the correct nibble offset
	GOSUBL	srRCL9_C	screen bitmap address
	A=A+C	A	now I have the address of the brick nibble
	D0=A		into D0 (of course)

	LCHEX	#00005	(5 + 1) lines per brick
	B=C	A
	LCHEX	#22	same ole thing
	D=C	A
	LAHEX	#000	3 zero nibbles per line
hbERASE	DAT0=A	3	zap one line
	CD0EX
	C=C+D	A
	D0=C
	B=B-1	A
	GONC	hbERASE
	RTN

hbWALL	?ST=0	11	is sound on?
	GOYES	hbW_START	yes? make the sound.

	LCHEX	#0005E	length of sound (ticks)
	GOLONG	udDELAY	delay (RTN)

hbW_START	LCHEX	#00008	note length
	D=C	A

hbW_AGAIN	LCHEX	#800
	OUT=C
	LCHEX	#00050	pitch #1
hbW_DEC1	C=C-1	A
	GONC	hbW_DEC1
	C=0	A
	OUT=C
	LCHEX	#00028	pitch #2
hbW_DEC2	C=C-1	A
	GONC	hbW_DEC2
	D=D-1	A
	GONC	hbW_AGAIN
	RTN


hbDEAD	C=0	A
	GOSUBL	srSTO2_C	set dir to none
	ST=1	10	set to erase (for db)
	GOSUBL	mvMOVE	erase the ball
	ST=0	10	set to NORMAL (for db)

	GOSUBL	srRCL43_C	look in crystal ball...
	?C#0	A	is something in crytal ball?
	GOYES	hbD_SCHECK	start rumors about myths
	GOSUBL	srRCL22_C	number of lives left
	C=C-1	A	one less now
	GOSUBL	srSTO22_C	store it
	?C#0	A	still some lives left?
	GOYES	hbD_SCHECK	go check sound
	GOSUBL	grGAME_OVER	display GAME OVER banner

hbD_SCHECK	?ST=0	11	is sound on?
	GOYES	hbD_SOUND	make the sound

	LCHEX	#03000
	B=C	A
hbD_CKEY	LCHEX	#1FF	| wait here until
	OUT=C		  | they stop pressing
	GOSBVL	=$jCINRTN | a key
	LAHEX	#0003F	  |
	A=A&C	A	  |
	?A=0	A	  |
	GOYES	hbD_NO_KEY	|
	B=B-1	A	don't wait forever, though
	GONC	hbD_CKEY
	GOTO	hbDEND

hbD_NO_KEY	LCHEX	#000CC	about 1 second
	GOSUBL	waWAIT	delay, pressing a key gets out
	GOTO	hbDEND

hbD_SOUND	LCHEX	#00090	starting pitch
	D=C	A

hbD_START	LCHEX	#00002	length
	B=C	A

hbD_AGAIN	LCHEX	#800
	OUT=C
	C=D	A	current pitch
hbD_DEC1	C=C-1	A
	GONC	hbD_DEC1
	C=0	A
	OUT=C
	LCHEX	#00020	a pitch
hbD_DEC2	C=C-1	A
	GONC	hbD_DEC2
	B=B-1	A
	GONC	hbD_AGAIN

	D=D+CON	A,2
	LCHEX	#00100
	?C#D	A
	GOYES	hbD_START

hbDEND	ST=1	4
	RTN

hbDRAW_KEY	GOSUB	hbDK_NEXT

	NIBHEX	C10	|Key graphic
	NIBHEX	2E7	|
	NIBHEX	225	|Data
	NIBHEX	C15	|

hbDK_NEXT	C=RSTK		C is now @ of key graphic
	D1=C		put it into D1

	GOSUBL	srRCL9_A	get screen @
	LCHEX	#00508	{#78h #25h}
	A=A+C	A	add offset...
	D0=A		...and into D0

	LCHEX	#00003	(3+1) lines
	D=C	A
	LCHEX	#22	typical
	B=C	A

hbDK_LINE	C=DAT1	3	get one line of graphic
	?ST=1	7	do you have a key?
	GOYES	hbDK_OK	ok, draw it
	C=0	A	otherwise, blank
hbDK_OK	DAT0=C	3	draw it
	CD0EX
	C=C+B	A	down one line
	D0=C
	D1=D1+	3	next graphic line
	D=D-1	A	done?
	GONC	hbDK_LINE	do some more
	RTN

* ----------------------------------------
* | For emDRAW_BRICK, I assume that the
* | brick # to be drawn is contained in C,
* | field A.  And the address of the
* | brick graphics is in sr5.
* ----------------------------------------
emDRAW_BRICK	B=C	A	put brick# in B
	B=B-1	A	this is so GONC will work.
	GOSUBL	srRCL5_C	get block data addr
emADD	C=C+CON	A,15	|each brick is 18
	C=C+CON	A,3	|nibbles of data (6*3)
	B=B-1	A
	GONC	emADD
	D1=C

	GOSUBL	srRCL9_A	screen bitmap @
	LCHEX	#004E2	this puts us at {#68h #24h}
	C=C+A	A
	D0=C

	LCHEX	#00005	(5+1) times
	B=C	A
	LCHEX	#22
emLINE	A=DAT1	3
	DAT0=A	3
	D1=D1+	3
	AD0EX
	A=A+C	A
	D0=A
	B=B-1	A
	GONC	emLINE
	RTN

* ----------------------------------------
* |
* | These are the score adding and
* | displaying routines
* |
* ----------------------------------------

* for scADD_SCORE the amount to add to the score
* (in Var #23) must be contained in C, field A. (IN DECIMAL)

scADD_SCORE	GOSUBL	srRCL23_A	get current score
	SETDEC
	C=C+A	A
	SETHEX
	GOSUBL	srSTO23_C	save it

* for scDISP_SCORE the score to be displayed must
* be contained in C, field A.

scDISP_SCORE	R2=C.F	A	put the score here
	GOSUB	scNEXT

* The following data is stored in a strange and complicated
* way.  The reason for storing the data this way is to
* facilitate as well as accellerate the use of it.
*
* scD1L1 stands for (SCORE, Digit 1, Line 1)
* Digit 1 is the digit that fits right on a nibble boundary,
* Digit 2 is shifted left one bit (as pixels on the screen)
* Digit 3 is shifted left two bits
* Digit 4 is shifted left three bits
*
* Each line of each digit contains 2 nibbles of data for
* each digit (0-9) (With the exception of digit 1, which
* only contains 1 nibble per digit, since the entire
* digit can fit in one nibble, on the boundary).
*
* The score drawing routine must draw the digits one line
* at a time, so each digit type is grouped by line numbers.
* The drawing routine first gets a digit of type 1, line 1
* (right most digit in score), then a digit of type 2, line 1
* then type 3, line 1, and type 4, line 1.  Now it has created a
* one-line graphic of the score that it displays.  Then it
* does line 2 in a similar fashion, then line 3, etc.
* The left most digit of the score is on a nibble boundary, and
* is treated special.  Since the right most 4 digits can fit
* into a 5 nibble area (field A) they are treated separately.
* The left most digit will not change very often, so each time
* this drawing routine is called, if the digit hasn't changed,
* then it is left as-is.  This will speed up the scoring process.

	NIBHEX	646F9FEF66	scD1L1
	NIBHEX	03020387848707870303	scD2L1
	NIBHEX	810181C342C383C38181	scD3L1
	NIBHEX	C080C0E121E1C1E1C0C0	scD4L1

	NIBHEX	9698911899	scD1L2
	NIBHEX	84038404848080048484	scD2L2
	NIBHEX	42814202424040024242	scD3L2
	NIBHEX	21C02101212020012121	scD4L2

	NIBHEX	9484977469	scD1L3
	NIBHEX	84020402848383020384	scD2L3
	NIBHEX	4201020142C1C1018142	scD3L3
	NIBHEX	2180018021E0E080C021	scD4L3

	NIBHEX	9468F8929E	scD1L4
	NIBHEX	84020304870484018407	scD2L4
	NIBHEX	42018102C30242804283	scD3L4
	NIBHEX	2180C001E101214021C1	scD4L4

	NIBHEX	9419899298	scD1L5
	NIBHEX	84028084048484018404	scD2L5
	NIBHEX	42014042024242804202	scD3L5
	NIBHEX	21802021012121402101	scD4L5

	NIBHEX	6EF6866267	scD1L6
	NIBHEX	03078703040303010383	scD2L6
	NIBHEX	8183C3810281818081C1	scD3L6
	NIBHEX	C0C1E1C001C0C040C0E0	scD4L6

scNEXT	C=RSTK		C is now addr of data
	R4=C.F	A	temp storage
	R1=C.F	A	for use in scLEFT_DIGIT

	GOSUBL	srRCL9_A	screen @
	LCHEX	#0005F	{#6Ch #2h}
	A=A+C	A	add it
	D0=A		into D0

	LCHEX	#00005	5 + 1 lines per digit
	D=C	A	put in D.

scLINE	C=R2.F	A	the score
	B=C	A	put it in B
	A=R4.F	A	get digit data @

	LCHEX	#0000F	mask
	C=C&B	A	mask off nibble 0 of score
	A=A+C	A	add offset in @ of data
	D1=A		put @ here
	A=0	A
	A=DAT1	1	get 1 nibble
	ASL	A	| shift 2 nibbles
	ASL	A	| to the left
	R3=A.F	A	temp storage for graphic
	A=R4.F	A	get digit data @
	A=A+CON	A,10	move to next digit type
	R4=A.F	A	store it
	BSR	A	shift B right 1 nibble

	LCHEX	#0000F	mask
	C=C&B	A	mask off nibble 1 of score
	A=A+C	A	|add offset
	A=A+C	A	|(2 nibbles, we add twice)
	D1=A		put @ here
	A=0	A
	A=DAT1	2	get 2 nibbles
	C=R3.F	A	get graphic
	C=C!A	A	or on the new stuff
	CSL	A	shift only once this time
	R3=C.F	A	temp storage for graphic
	A=R4.F	A	get digit data @
	A=A+CON	A,10	| move to next digit type
	A=A+CON	A,10	| (2 nibbles, we add twice)
	R4=A.F	A	store it
	BSR	A	shift B right 1 nibble

	LCHEX	#0000F	mask
	C=C&B	A	mask off nibble 2 of score
	A=A+C	A
	A=A+C	A
	D1=A
	A=0	A
	A=DAT1	2
	C=R3.F	A
	C=C!A	A
	CSL	A
	R3=C.F	A
	A=R4.F	A	get digit data @
	A=A+CON	A,10	| move to next digit type
	A=A+CON	A,10	| (2 nibbles, we add twice)
	R4=A.F	A	store it
	BSR	A

	LCHEX	#0000F	mask
	C=C&B	A	mask off nibble 3 of score
	A=A+C	A
	A=A+C	A
	D1=A
	A=0	A
	A=DAT1	2
	C=R3.F	A
	C=C!A	A
	A=R4.F	A	get digit data @
	A=A+CON	A,10	| move to next digit type
	A=A+CON	A,10	| (2 nibbles, we add twice)
	R4=A.F	A	store it
	BSR	A

	DAT0=C	A	put it on the screen
	LCHEX	#00022	one line
	AD0EX		get D0
	A=A+C	A
	D0=A	A

	D=D-1	A	one line less to do...
	GOC	scLEFT_DIGIT	do the left digit
	GOTO	scLINE	go do more

scLEFT_DIGIT	GOSUBL	srRCL9_A	screen address
	LCHEX	#0005E	{#68h #2h}
	A=A+C	A
	D0=A		set D0

	A=R1.F	A	@ of digit data
	LCHEX	#0000F	mask
	C=C&B	A	get the left-most digit
	A=A+C	A	offset to proper digit
	D1=A		put it into D1

	LCHEX	#00005	5+1 lines
	D=C	A
	LCHEX	#00022	one line on screen
	B=C	A
	LCHEX	#00046	offset to next digit line

scLD_LINE	A=DAT1	1	get 1 line of the digit
	DAT0=A	1	put it on the screen
	AD0EX		get D0
	A=A+B	A	down 1 line
	D0=A
	AD1EX		get D1
	A=A+C	A	add offset
	D1=A
	D=D-1	A
	GONC	scLD_LINE	do another

	A=R2.F	A	current score
	GOSUBL	srRCL26_C	next bonus life at this score
	?C>A	A	no extra life yet?
	RTNYES		end of sc

	LA(5)	BONUS_LIFE	number of points until next life
	SETDEC
	C=C+A	A	add the increment (in decimal)
	SETHEX
	?C<A	A	have we gone too far?
	GOYES	scBONUS_FIX
	GOTO	scBONUS_STO
scBONUS_FIX	LCHEX	#99999	max bonus score
scBONUS_STO	GOSUBL	srSTO26_C	store it for next extra life.

	GOSUBL	srRCL22_C	number of lives left
	C=C+1	A	add one
	GOSUBL	srSTO22_C	store it
	GOSUBL	dlDRAW_LIVES	display the change
	GOTO	soBONUS_LIFE	make a nifty sound, auto RTN

deDRAW_LEVEL	GOSUB	deNEXT

* This data here is the same as in (sc) except that there are
* only digit types 3 and 4.

	NIBHEX	810181C342C383C38181	deD3L1
	NIBHEX	C080C0E121E1C1E1C0C0	deD4L1

	NIBHEX	42814202424040024242	deD3L2
	NIBHEX	21C02101212020012121	deD4L2

	NIBHEX	4201020142C1C1018142	deD3L3
	NIBHEX	2180018021E0E080C021	deD4L3

	NIBHEX	42018102C30242804283	deD3L4
	NIBHEX	2180C001E101214021C1	deD4L4

	NIBHEX	42014042024242804202	deD3L5
	NIBHEX	21802021012121402101	deD4L5

	NIBHEX	8183C3810281818081C1	deD3L6
	NIBHEX	C0C1E1C001C0C040C0E0	deD4L6

deNEXT	C=RSTK		Get the address of the bitmap into C[A]
	R4=C		save @ of numbers

	GOSUBL	srRCL20_C	(lev #) in hex
	A=0	A
deCONV	SETDEC
	A=A+1	A	add one in decimal
	SETHEX
	C=C-1	A	subtract one in hex
	GONC	deCONV	do more (for small nums, this works great)
	R2=A.F	A	(lev #)+1 in decimal

	GOSUBL	srRCL9_A	screen @
	LCHEX	#001B6	{#78h #Ch}
	A=A+C	A
	D0=A

	LCHEX	#00005	(5+1) lines in a digit
	D=C	A

deLINE	C=R2.F	A	lev #
	B=C	A
	A=R4.F	A	get digit data @
	LCHEX	#0000F	mask
	C=C&B	A	mask off nibble 0 of level num.
	A=A+C	A	|add offset into digit data
	A=A+C	A	| (twice, each digit is 2 nibbles)
	D1=A
	A=0	A
	A=DAT1	2	get 2 nibbles of data
	ASL	A	shift it left 1 nibble
	R3=A.F	A	store the graphic
	A=R4.F	A	data addr
	A=A+CON	A,10	| increment @ pointer
	A=A+CON	A,10	| twice, for the two nibbles
	R4=A.F	A	save it
	BSR	A	shift B right to get next digit

	LCHEX	#0000F	mask
	C=C&B	A	mask off nibble 1 of lev num
	A=A+C	A	| add offset into digit data
	A=A+C	A	| (twice, again)
	D1=A		put addr here
	A=0	A
	A=DAT1	2	get two nibbles data
	C=R3.F	A	get back graphic
	C=C!A	A	or new data on
	A=R4.F	A	digit data @
	A=A+CON	A,10	| increment @ pointer
	A=A+CON	A,10	| twice, for the two nibbles
	R4=A.F	A

	DAT0=C	3	put the 3 nibbles onto the screen
	LCHEX	#00022
	AD0EX
	A=A+C	A	down one line
	D0=A

	D=D-1	A
	RTNC		if carry==1, return (we're done)
	GOTO	deLINE	otherwise, carry on...


soEM_CHANGE	?ST=0	11	is sound on?
	GOYES	so3_START	yes? make the sound.

	LCHEX	#000E2	length of sound (ticks)
	GOTO	udDELAY	delay (RTN)

so3_START	LCHEX	#00010	note length
	D=C	A

so3_AGAIN	LCHEX	#800
	OUT=C
	LCHEX	#00070	pitch #1
so3_DEC1	C=C-1	A
	GONC	so3_DEC1
	C=0	A
	OUT=C
	LCHEX	#00020	pitch #2
so3_DEC2	C=C-1	A
	GONC	so3_DEC2
	D=D-1	A
	GONC	so3_AGAIN
	RTN

soERS_BRICK	?ST=0	11	is sound on?
	GOYES	so2_START	yes? make the sound.

	LCHEX	#00042	length of sound (ticks)
	GOTO	udDELAY	delay (RTN)

so2_START	LCHEX	#00007	note length
	D=C	A

so2_AGAIN	LCHEX	#800
	OUT=C
	LCHEX	#00020	pitch #1
so2_DEC1	C=C-1	A
	GONC	so2_DEC1
	C=0	A
	OUT=C
	LCHEX	#00040	pitch #2
so2_DEC2	C=C-1	A
	GONC	so2_DEC2
	D=D-1	A
	GONC	so2_AGAIN
	RTN

soDOUBLE_ARR	?ST=0	11	is sound on?
	GOYES	soDA_FIRST	yes? make the sound.

	LCHEX	#00042	length of sound (ticks)
	GOTO	udDELAY	delay (RTN)

soDA_FIRST	LCHEX	#00080	starting pitch
	D=C	A

soDA_START	LCHEX	#00002	length
	B=C	A

soDA_AGAIN	LCHEX	#800
	OUT=C
	C=D	A	current pitch
soDA_DEC1	C=C-1	A
	GONC	soDA_DEC1
	C=0	A
	OUT=C
	LCHEX	#00010	a pitch
soDA_DEC2	C=C-1	A
	GONC	soDA_DEC2
	B=B-1	A
	GONC	soDA_AGAIN

	D=D-CON	A,4
	LCHEX	#00050	ending pitch
	?D>C	A
	GOYES	soDA_START

	RTN		done with soDOUBLE_ARR


soERASE_KEY	?ST=0	11	is sound on?
	GOYES	soEK_FIRST	yes? make the sound.

	LCHEX	#00042	length of sound (ticks)
	GOTO	udDELAY	delay (RTN)

soEK_FIRST	LCHEX	#00021	starting pitch
	D=C	A

soEK_START	LCHEX	#00003	length
	B=C	A

soEK_AGAIN	LCHEX	#800
	OUT=C
	C=D	A	current pitch
soEK_DEC1	C=C-1	A
	GONC	soEK_DEC1
	C=0	A
	OUT=C
	C=D	A	current pitch
soEK_DEC2	C=C-1	A
	GONC	soEK_DEC2
	B=B-1	A
	GONC	soEK_AGAIN

	LCHEX	#00030
	?D<C	A
	GOYES	soEK_ADD

	D=D-CON	A,15
	GOTO	soEK_START

soEK_ADD	D=D+CON	A,16
	LCHEX	#00034
	?D#C	A
	GOYES	soEK_START

	RTN		end of soERASE_KEY


soERASE_LOCK	?ST=0	11	is sound on?
	GOYES	soEL_FIRST	yes? make the sound.

	LCHEX	#00042	length of sound (ticks)
	GOTO	udDELAY	delay (RTN)

soEL_FIRST	LCHEX	#00090	starting pitch
	D=C	A

soEL_START	LCHEX	#00008	length
	B=C	A

soEL_AGAIN	LCHEX	#800
	OUT=C
	C=D	A	current pitch
soEL_DEC1	C=C-1	A
	GONC	soEL_DEC1
	C=0	A
	OUT=C
	C=D	A	current pitch
soEL_DEC2	C=C-1	A
	GONC	soEL_DEC2
	B=B-1	A
	GONC	soEL_AGAIN

	LCHEX	#00090
	?D<C	A
	GOYES	soEL_ADD

	LCHEX	#00050
	D=D-C	A
	LCHEX	#00041
	?D=C	A
	RTNYES		end of soERASE_LOCK
	GOTO	soEL_START

soEL_ADD	LCHEX	#00051
	D=D+C	A
	GOTO	soEL_START


soBONUS	?ST=0	11	is sound on?
	GOYES	soB_START	yes? make the sound.

	LCHEX	#000D7	length of sound (ticks)
	GOTO	udDELAY	delay (RTN)

soB_START	LCHEX	#00010	note length
	D=C	A
	LCHEX	#00060
	B=C	A

soB_AGAIN	LCHEX	#800
	OUT=C
	C=B	A	pitch #1
soB_DEC1	C=C-1	A
	GONC	soB_DEC1
	C=0	A
	OUT=C
	C=B	A	#1
	LAHEX	#00020
	C=C-A	A	pitch #2
soB_DEC2	C=C-1	A
	GONC	soB_DEC2
	B=B-CON	A,2
	D=D-1	A
	GONC	soB_AGAIN
	RTN

soBONUS_LIFE	?ST=1	11	sound off?
	RTNYES		then all is quiet (no delay)

	LCHEX	#00015	starting pitch
	D=C	A
	A=0	A

soBL_START	LCHEX	#00003	length
	B=C	A

soBL_AGAIN	LCHEX	#800
	OUT=C
	C=D	A	current pitch
soBL_DEC1	C=C-1	A
	GONC	soBL_DEC1
	C=0	A
	OUT=C
	C=D	A	current pitch
soBL_DEC2	C=C-1	A
	GONC	soBL_DEC2
	B=B-1	A
	GONC	soBL_AGAIN

	?A#0	A
	GOYES	soBL_DOWN

	D=D-1	A
	?D#0	A
	GOYES	soBL_START

soBL_DOWN	LAHEX	#1
	D=D+1	A
	LCHEX	#00015
	?C#D	A
	GOYES	soBL_START
soBL_END	RTN


soHIGH_SCORE	?ST=1	11	is sound off?
	RTNYES		then we're done (no delay)

	LCHEX	#0004F	pitch
	B=C	A
	A=0	A	a flag
soHS_LENGTH	LCHEX	#00004	note length
	D=C	A

soHS_AGAIN	LCHEX	#800
	OUT=C
	C=B	A	pitch #1
soHS_DEC1	C=C-1	A
	GONC	soHS_DEC1
	C=0	A
	OUT=C
	C=B	A	pitch #2
soHS_DEC2	C=C-1	A
	GONC	soHS_DEC2
	D=D-1	A
	GONC	soHS_AGAIN

	?A#0	A
	GOYES	soHS_UP

	B=B-CON	A,10
	GONC	soHS_LENGTH
	LAHEX	#0004F
	B=B+CON	A,10
	B=B+CON	A,10
	GOTO	soHS_LENGTH

soHS_UP	B=B+CON	A,10
	?A>B	A
	GOYES	soHS_LENGTH
	RTN

soMENU_UP	?ST=1	11	is sound off?
	RTNYES		then we're done (no delay)

	LCHEX	#00060	starting pitch
	D=C	A

soMU_START	LCHEX	#00004	length
	B=C	A

soMU_AGAIN	LCHEX	#800
	OUT=C
	C=D	A	current pitch
soMU_DEC1	C=C-1	A
	GONC	soMU_DEC1
	C=0	A
	OUT=C
	C=D	A	current pitch
soMU_DEC2	C=C-1	A
	GONC	soMU_DEC2
	B=B-1	A
	GONC	soMU_AGAIN

	D=D-CON	A,4
	LCHEX	#00020	ending pitch
	?D>C	A
	GOYES	soMU_START
	RTN


soMENU_DOWN	?ST=1	11	is sound off?
	RTNYES		then we're done (no delay)

	LCHEX	#00020	starting pitch
	D=C	A

soMD_START	LCHEX	#00004	length
	B=C	A

soMD_AGAIN	LCHEX	#800
	OUT=C
	C=D	A	current pitch
soMD_DEC1	C=C-1	A
	GONC	soMD_DEC1
	C=0	A
	OUT=C
	C=D	A	current pitch
soMD_DEC2	C=C-1	A
	GONC	soMD_DEC2
	B=B-1	A
	GONC	soMD_AGAIN

	D=D+CON	A,4
	LCHEX	#00060	ending pitch
	?D<C	A
	GOYES	soMD_START
	RTN


soMYTH	?ST=1	11	is sound off?
	RTNYES		then we're done (no delay)

	LCHEX	#00021	starting pitch
	D=C	A
	A=0	A

soMY_START	LCHEX	#00003	length
	B=C	A

soMY_AGAIN	LCHEX	#800
	OUT=C
	C=D	A	current pitch
soMY_DEC1	C=C-1	A
	GONC	soMY_DEC1
	C=0	A
	OUT=C
	C=D	A	current pitch
soMY_DEC2	C=C-1	A
	GONC	soMY_DEC2
	B=B-1	A
	GONC	soMY_AGAIN

	LCHEX	#00030
	?D<C	A
	GOYES	soMY_ADD

	D=D-CON	A,14
	GOTO	soMY_START

soMY_ADD	D=D+CON	A,16
	A=A+1	A
	LCHEX	#00030
	?C>A	A
	GOYES	soMY_START

	RTN


* This udDELAY routine bases its delays on the internal TIMER2.
* Send C, field A with the number of ticks (n) you would like to delay.
* One tick is 1/8192 of a second.

* Registers used:  C, R1, R2, R3, CARRY, ST(0)
* A and D1 are saved.

* If you have a pre-starting time, then you must first place n in R2
* then put the starting time in C(A) and call udDELAYcont.
* In this case, D1, and A are not preserved.

udDELAY	R2=C.F	A	n
	C=A	A	save A
	GOSUBL	CSLW5
	CD1EX		save D1
	R3=C

	D1=(5)	=TIMER2
	C=0	A
	C=DAT1	4	read 4 nibbles
udDELAYcont	R1=C.F	A	starting time
	D1=(5)	=TIMER2	for the cases where udDELAYcont is used

udDELAYLP	LCHEX	#010
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	1	[-X] key
	GOYES	udNO_S
	ST=1	0	[-X] is being pressed
	GOSUBL	srRCL28_C	get [-X] still-being-pressed flag
	?C#0	A	Are you still holding it?
	GOYES	udNO_FLAG	yes? check [ON]
	?ST=0	11	is sound on?
	GOYES	udSET	yes? go turn it off
	ST=0	11	Turn sound on.

	LAHEX	#00020	length of blip
udSO_BLIP	LCHEX	#800
	OUT=C
	LCHEX	#00012	pitch 1
udSO_DEC1	C=C-1	A
	GONC	udSO_DEC1
	C=0	A
	OUT=C
	LCHEX	#0000E	pitch 2
udSO_DEC2	C=C-1	A
	GONC	udSO_DEC2
	A=A-1	A
	GONC	udSO_BLIP
	GOTO	udNEXT	go set ST0 to say you've pressed S already

udSET	ST=1	11	turn sound off.
udNEXT	LCHEX	1	make C non-NULL
	GOSUBL	srSTO28_C	set [+/-] flag to being pressed.
	GOTO	udNO_FLAG	skip next line

udNO_S	ST=0	0
udNO_FLAG	LCHEX	#400	[ON] key
	OUT=C
	GOSBVL	=$jCINRTN
	?CBIT=0	15	no press?
	GOYES	udNO_ON
	GOLONG	maEND	[ON] was pressed, you're done!

udNO_ON	C=0	A
	C=DAT1	4	read TIMER2
	A=R1.F	A	get start time
	C=A-C	A	elapsed time
	GOC	udFIX	did we have a carry? (wrap around)
udOK	A=R2.F	A	n
	?A<C	A	done with delay?
	GOYES	udDONE
	GOTO	udDELAYLP

udDONE	C=0	A
	C=DAT1	4	get TIMER2
	GOSUBL	srSTO47_C	save (me) new starting time

	?ST=1	0
	GOYES	udLEAVE_FLAG
	C=0	A
	GOSUBL	srSTO28_C	set [-X] flag to not pressing.
udLEAVE_FLAG	C=R3
	D1=C		restore D1
	GOSUBL	CSRW5
	A=C	A	restore A
	RTN		done with udDELAY

udFIX	LAHEX	#FE000	(#100000h - #2000h)
	C=C-A	A	fix wrap-around
	GOTO	udOK


dsDRAW_SCN	GOSUBL	srRCL6_C	get data addr.
	GOSUBL	srSTO4_C	put it here

	GOSUB	dsNEXT2

* Brick 0: blank (no brick)
* Brick 1: White
* Brick 2: Diamond
* Brick 3: Wall
* Brick 4: Key
* Brick 5: Lock
* Brick 6: Cross
* Brick 7: Double Arrow
* Brick 8: Brick 1
* Brick 9: Paintbrush 1
* Brick A: Brick 2
* Brick B: Paintbrush 2
* Brick C: Brick 3
* Brick D: Paintbrush 3
* Brick E: Brick 4
* Brick F: Paintbrush 4

	NIBHEX	000000000000000000	dsB0
	NIBHEX	EF7108108108108EF7	dsB1
	NIBHEX	E97F0F70E70EF0FE97	dsB2
	NIBHEX	EF7FFFB7FFEDFFFEF7	dsB3
	NIBHEX	EF73EFD18DDA3EAEF7	dsB4
	NIBHEX	EF7F9FF6F70E70EEF7	dsB5
	NIBHEX	EF7F9F30C30CF9FEF7	dsB6
	NIBHEX	6F73FE1CC3387FCEF6	dsB7
	NIBHEX	EF799976E99976EEF7	dsB8
	NIBHEX	EF799F76F99F76FEF7	dsB9
	NIBHEX	EF7BAABAA55D55DEF7	dsBA
	NIBHEX	EF7BAFBAF55F55FEF7	dsBB
	NIBHEX	EF739CD6BD6B39CEF7	dsBC
	NIBHEX	EF739FD6FD6F39FEF7	dsBD
	NIBHEX	EF73885599AA11CEF7	dsBE
	NIBHEX	EF738F55F9AF11FEF7	dsBF

dsNEXT2	C=RSTK		C is now @dsB1
	GOSUBL	srSTO5_C

	C=0	A
	GOSUBL	srSTO27_C	column counter
	GOSUBL	srSTO16_C	number of bricks
	GOSUBL	srSTO17_C	number of diamonds

dsDOCOLUMN	LCHEX	#00018	one line
	B=C	A
	GOSUBL	srRCL8_A	get STACK GROB @.

	LCHEX	#00008	max columns
	D=C	A
	GOSUBL	srRCL27_C	get column #
	?C#D	A	not done?
	GOYES	dsADDCOL	continue

	RTN		return from ds

dsADDCOL	?C=0	A
	GOYES	dsOK
	A=A+CON	A,3	move over one column.
	C=C-1	A
	GOTO	dsADDCOL

dsOK	D0=A

	GOSUBL	srRCL27_C	get col#
	C=C+1	A	add one for next time
	GOSUBL	srSTO27_C	store it.

	LCHEX	#00009	(9 + 1) times
	D=C	A	counter

dsDOBLOCK	GOSUBL	srRCL4_C	get board data addr
	D1=C		put it in D1
	C=C+1	A	next nibble
	GOSUBL	srSTO4_C	store it.

	C=0	A	zero reg
	C=DAT1	1	get a brick

	A=0	A
	LAHEX	#1	brick #1
	?C#A	A	not one of these?
	GOYES	dsNB_1
	GOSUBL	srRCL16_A
	A=A+1	A
	GOSUBL	srSTO16_A
dsNB_1	LAHEX	#2	a diamond
	?C#A	A	not one of these?
	GOYES	dsNB_2
	GOSUBL	srRCL17_A
	A=A+1	A
	GOSUBL	srSTO17_A
dsNB_2	?CBIT=0	3	|if bit 3=0 then
	GOYES	dsNB_3	|it's not a reg brick
	?CBIT=1	0	]if bit 0=0 then
	GOYES	dsNB_3	]it's a change-mode brick
	GOSUBL	srRCL16_A	}we know it's a reg brick
	A=A+1	A	}so we increment
	GOSUBL	srSTO16_A	}the number.

dsNB_3	B=C	A	put it here.
	GOSUBL	srRCL5_C	get block data addr
dsADD	?B=0	A	no block?
	GOYES	dsNOADD	C is correct @
	C=C+CON	A,15
	C=C+CON	A,3
	B=B-1	A
	GOTO	dsADD
dsNOADD	D1=C

	LCHEX	#00018	one buffer "line"
	B=C	A
	LAHEX	#00005	loop (5+1) times
dsDOLINE	C=DAT1	3
	DAT0=C	3
	CD0EX
	C=C+B	A
	D0=C
	D1=D1+	3
	A=A-1	A
	GONC	dsDOLINE

dsNOBLOCK	D=D-1	A
	GOC	dsDOCOG
	GOTO	dsDOBLOCK
dsDOCOG	GOTO	dsDOCOLUMN


dsQUICK_DRAW	GOSUB	dsDRAW_SCN	draw bricks into RAM area
	GOSUBL	srRCL8_C	RAM address where bricks were drawn
	D1=C
	GOSUBL	srRCL9_A	ABUFF @
	LCHEX	#00045	offset to field
	C=C+A	A
	D0=C		screen pointer

	LAHEX	#0003B	(59+1) lines
dsQD_NEXT	C=DAT1	12	get first 12 nibbles
	DAT0=C	12	write them to screen
	D1=D1+	12	increment buffer pointer
	D0=D0+	12	increment screen pointer
	C=DAT1	12	get next 12 nibbles
	DAT0=C	12	write them to screen
	D1=D1+	12
	D0=D0+	12	|
	D0=D0+	10	| next line
	A=A-1	A
	GONC	dsQD_NEXT

	RTN		go home


sdDISOLVE	GOSUB	dsDRAW_SCN	draw bricks into RAM area
	GOSUBL	cfCLEAR	clear the playing field
	GOSUBL	srRCL8_C	stack GROB @
	R1=C.F	A	top-left
	GOSUBL	srRCL9_C	PICT GROB @
	LAHEX	#00045	offset to field
	C=C+A	A
	R2=C.F	A	store it here

	LCHEX	#00500	a little less than #5A0
	R3=C.F	A
sdNUTHER_ONE	A=0	W
	C=0	W
	D1=(5)	=TIMER2	TIMER2 addr
	A=DAT1	4	randomize the CRC
	D1=(5)	CRC	pseudo random number
	A=DAT1	4	get the 4 nibbles
	ASL	A	multiply by 16
	LCHEX	#005B2	#100000h / #2CFh
	GOSUBL	DIV	get a num in range [#0h,#2CFh]
	A=A+A	A	multiply by 2, even # in range [#0h, #59E]

	C=R1.F	A	get buffer @
	C=C+A	A	add random offset
	D1=C		put it here
	C=0	A	blank C
	C=DAT1	2	get 2 nibbles from buffer
	?C=0	A	is this zero?
	GOYES	sdNEXT	yes? get a different one
	LCHEX	#00018	nibbles per line in buffer
	GOSUBL	DIV	get line number
	LCHEX	#00022	nibbles per line in PICT
	GOSUB	MPY	get line offset
	C=C+B	A	add remainder (for column)
	A=R2.F	A	get PICT @
	C=C+A	A	add offset
	D0=C		put it here

	C=DAT1	2	read 2 nibbles (non-zero)
	DAT0=C	2	write to screen
	C=0	A	zero
	DAT1=C	2	now it's zero, we won't pick it again.
sdNEXT	C=R3.F	A
	C=C-1	A
	R3=C.F	A
	?C=0	A
	GOYES	sdNEXT2
	GOTO	sdNUTHER_ONE	do another nibble

sdNEXT2	LCHEX	#0003B	59+1 times
	D=C	A
	A=R1.F	A	buffer @
	D1=A		put it here to start
	A=R2.F	A	PICT @
	D0=A		put it here to start

sdPARSE	LCHEX	#00017	23+1 nibbles per line in buffer
	B=C	A
	C=0	A	make sure C is zero
sdREAD	C=DAT1	1	get 1 nibble from buffer
	?C=0	A	is it zero?
	GOYES	sdPARSE_NEXT	yes? This one is already done
	DAT0=C	1	otherwise, write it.
sdPARSE_NEXT	D1=D1+	1	next nibble in buffer
	D0=D0+	1	next nibble in PICT
	B=B-1	A
	GONC	sdREAD	do next nibble
	D0=D0+	10	move to next PICT line
	D=D-1	A
	GONC	sdPARSE	do another line

	RTN		RTN from sdDISOLVE

* =MPY not supported in HP38G.
* Source used with permission

MPY	D=C	W
	C=0	W	result

bM0	SB=0		clear sticky bit
	ASRB		shift #1 right
	?SB=0		if bit was zero, don't add
	GOYES	bM1	
	C=C+D	W	accumulate answer

bM1	D=D+D	W	ready for next shift
	?A#0	W	any more?
	GOYES	bM0	yes
	A=C	W	put answer in A(W)
	RTNCC



* isINIT_SCN will draw the entire screen,
* leaving the playing field untouched.

isINIT_SCN	GOSUBL	srRCL9_A	ABUFF bitmap
	D0=A
	LCHEX	8
	DAT0=C	1
	D0=D0+	1
	LCHEX	#FFFFFFFFFFFF
	DAT0=C	12
	D0=D0+	12
	DAT0=C	12
	D0=D0+	12
	D0=D0+	9	now pointing to next line

	LCHEX	#C
	DAT0=C	1
	D0=D0+	1
	LCHEX	#F	the others are still FFFF...
	DAT0=C	12
	D0=D0+	12
	DAT0=C	12
	D0=D0+	12
	D0=D0+	9	now pointing to next line

	LAHEX	0003B	(60-1) lines
	LCHEX	#C
isLEFT_SIDE	DAT0=C	1
	D0=D0+	16	|
	D0=D0+	16	|
	D0=D0+	2	| move to next line
	A=A-1	A
	GONC	isLEFT_SIDE

	DAT0=C	1
	D0=D0+	1
	LCHEX	#F	the others are still FFFF...
	DAT0=C	12
	D0=D0+	12
	DAT0=C	12
	D0=D0+	12
	D0=D0+	9	now pointing to next line

	LCHEX	#8
	DAT0=C	1
	D0=D0+	1
	LCHEX	#F	the others are still FFF...
	DAT0=C	12
	D0=D0+	12
	DAT0=C	12

	GOSUB	isNEXT

	NIBHEX	1000000030000000
	NIBHEX	36C813603925A490
	NIBHEX	3925A4903925A490
	NIBHEX	3925A49036C81360
	NIBHEX	3000000030000000
	NIBHEX	BFFFFFF730000000
	NIBHEX	B0000C81B06A0252
	NIBHEX	B09A2252B0FA0252
	NIBHEX	B01A2252B7E40C81
	NIBHEX	30000000BFFFFFF7
	NIBHEX	3000000037000000
	NIBHEX	39CC94E03725A410
	NIBHEX	3925A4603925A480
	NIBHEX	37C4277030000000
	NIBHEX	3FFFFFF3BFFFFFF7
	NIBHEX	BFFFFFF73FFFFFF3
	NIBHEX	30000000BFFFFFF7
	NIBHEX	3000800030008000
	NIBHEX	3EF7800031088000
	NIBHEX	3108800031088000
	NIBHEX	310880003EF78000
	NIBHEX	3000800030008000
	NIBHEX	BFFFFFF730000000

* These are for the beta version.  This displays a little beta
* sign in the lower right-hand side.
*
*	NIBHEX	B9B39032BA09A055
*	NIBHEX	B919B055BA092055
*	NIBHEX	B939A03230000000
*	NIBHEX	B4274235B5522555
*	NIBHEX	B6522532B4224212
*	NIBHEX	3000000030000000

* These are for the new Diamonds 38 graphic
* A little diamond graphic with a 38 shows
* in the lower right hand area of screen.

	NIBHEX	BAA0AAA231515154
	NIBHEX	B0AAA02031155401
	NIBHEX	BA0AA22035044154
	NIBHEX	BA02822035154401
	NIBHEX	B8AAA02030555154
	NIBHEX	B8A2AAA230000000

* This is the rest of the screen (The lives left)

	NIBHEX	3E0783C13F9FC7E3
	NIBHEX	3F9FC7E33F9FC7E3
	NIBHEX	3E0783C110000000

isNEXT	C=RSTK		Get the address of the bitmap into C[A]
	D1=C		address of bitmap
	GOSUBL	srRCL9_C	get ABUFF bitmap again
	LAHEX	#00019	offset to right side
	C=C+A	A
	D0=C
	LAHEX	#0003F	(64-1) lines
isRIGHT_SIDE	C=DAT1	8	read 8 nibbles of picture
	DAT0=C	8	write them to screen
	D1=D1+	8	increment to next part
	D0=D0+	16	|
	D0=D0+	16	|
	D0=D0+	2	| move D0 to next line
	A=A-1	A	decrement counter
	GONC	isRIGHT_SIDE

	RTN		screen is done!


* dmDRAW_MENU draws the menu options into the playing field.
* It assumes that the field is already clear, and it does not draw any
* portion of the Diamonds logo.
* It will check for the current speed toggle var (sr41) and display
* (SLOW, NORMAL, FAST, or SUPER) depending on that var.

dmDRAW_MENU	GOSUB	dmNEXT

	NIBHEX	0000008F0F8FD1ECF0000000
	NIBHEX	000007CF9FDFB3FDF9300000
	NIBHEX	0000CFCF9FDFB3FDFBF00000
	NIBHEX	0000EFDFFFDFB7FDFBF30000
	NIBHEX	0000FF9FFFDFB7FDFBF70000
	NIBHEX	0000FFBFFFDDB7FEFBF70000
	NIBHEX	0089FEBFFFD8BFFECBFF0000
	NIBHEX	00CBFC7FFFD8BFFE8B9F0000
	NIBHEX	00E7F87FFFD8BFFE8B17C100
	NIBHEX	00FFED77FFDDBFFECB10E700
	NIBHEX	00FFEFF66FDFDDFEED30EF00
	NIBHEX	00EFDFF60FBFDDFEFD70CF10
	NIBHEX	00CFBFF60FBFDDFEF9F08F10
	NIBHEX	00CFB7F50FBFD9FEF0F83F30
	NIBHEX	008F77E30FBFD1FEF0FCFF30
	NIBHEX	0F1F7FC70EDFE06F7BFEFFC0
	NIBHEX	8FFEFEC7000000008F7CF7F1
	NIBHEX	CFFDFE83C7C372F08FB938F1
	NIBHEX	CFFBFD1049A45A210FB37EF3
	NIBHEX	EFF7FB1049A45A200CC3FEC7
	NIBHEX	E7CFEB0049A45AA100CFFEC7
	NIBHEX	E38FE30049A45A2100CF7EF7
	NIBHEX	E78FD30049A45A21008FBFF3
	NIBHEX	CF0FD100C7C3E1F0000FDFF1
	NIBHEX	0F3F100000000000000FEF00
	NIBHEX	0E7F100F87E472FC9000FF10
	NIBHEX	08FF108259A45A25900C7E10
	NIBHEX	00FF008249A5DA25B00C7E10
	NIBHEX	00EF00824FA65B25D008FF00
	NIBHEX	00C7008249A45A259008FF00
	NIBHEX	0087008259A45A259000F700
	NIBHEX	0003000FC9E472FC9000E100
	NIBHEX	000000000000000000000000
	NIBHEX	EFFFFFFFFFFFFFFFFFFFFFF7
	NIBHEX	000000000000000000000000

* [A] PLAY DIAMONDS
	NIBHEX	0CCC07289483762239E83000
	NIBHEX	04290924A484296B4B250000
	NIBHEX	04E9072CB2842FAA4D291000
	NIBHEX	042901242184292A49212000
	NIBHEX	0C2D01E52183792239EC1000
	NIBHEX	000000000000000000000000

* [B] SPEED:
	NIBHEX	0CEC0EECB770000000000000
	NIBHEX	042901258092000000000000
	NIBHEX	04E806EC9390000000000000
	NIBHEX	042908248092000000000000
	NIBHEX	0CEC072CB770000000000000
	NIBHEX	000000000000000000000000

* [C] KEYS
	NIBHEX	0CCC09E52700000000000000
	NIBHEX	04290524A000000000000000
	NIBHEX	042803E41300000000000000
	NIBHEX	042905280400000000000000
	NIBHEX	0CCC09E98300000000000000
	NIBHEX	000000000000000000000000

* [ON] EXIT
	NIBHEX	662D0F2ABF00000000000000
	NIBHEX	296901411200000000000000
	NIBHEX	29A907801200000000000000
	NIBHEX	292901411200000000000000
	NIBHEX	662D0F2A3200000000000000

dmNEXT	C=RSTK		Get the address of the bitmap into C[A]
	D1=C		address of menu options GROB
	GOSUBL	srRCL9_C	get ABUFF bitmap address
	LAHEX	#00067	offset to {#4h #3h}
	C=C+A	A
	D0=C

	LAHEX	#00039	(58-1) lines
dmNEXT_LINE	C=DAT1	12	read 12 nibbles of graphic
	DAT0=C	12	write 12 nibbles
	D1=D1+	12	increment GROB pointer
	D0=D0+	12	increment screen pointer
	C=DAT1	12	read 12 more nibbles
	DAT0=C	12	write 12 more
	D1=D1+	12	increment GROB pointer
	D0=D0+	12	|
	D0=D0+	10	| point to next line
	A=A-1	A
	GONC	dmNEXT_LINE	do the next line

	GOSUB	dmDRAW_SPEED

	NIBHEX	8B062200	SLOW
	NIBHEX	48092200
	NIBHEX	8909A200
	NIBHEX	0A096300
	NIBHEX	C9762200

	NIBHEX	42372231	NORMAL
	NIBHEX	CA496B41
	NIBHEX	4B47AA71
	NIBHEX	4A492A41
	NIBHEX	42392A4F

	NIBHEX	C33EE300	FAST
	NIBHEX	48418000
	NIBHEX	C9768000
	NIBHEX	48488000
	NIBHEX	48478000

	NIBHEX	8B47ED11	SUPER!
	NIBHEX	48492421
	NIBHEX	8947EC11
	NIBHEX	0A412420
	NIBHEX	C131E521

dmDRAW_SPEED	C=RSTK		Get the address of the bitmap into C[A]
	B=C	A	address of SLOW

	GOSUBL	srRCL41_C	get speed-toggle var
	LA(5)	SLOW_SPD
	?A=C	A	are we in SLOW speed?
	GOYES	dmGOT_SPEED

	LAHEX	#00028
	B=B+A	A	increment to NORMAL speed
	LA(5)	NORMAL_SPD
	?A=C	A
	GOYES	dmGOT_SPEED

	LAHEX	#00028
	B=B+A	A	increment to FAST speed
	LA(5)	FAST_SPD
	?A=C	A
	GOYES	dmGOT_SPEED

	LAHEX	#00028
	B=B+A	A	increment to SUPER speed

dmGOT_SPEED	C=B	A	get address
	D1=C	A	address of proper speed
	GOSUBL	srRCL9_C	get ABUFF bitmap address
	LAHEX	#005E5	offset to {#34h #2Ch}
	C=C+A	A
	D0=C

	LAHEX	#00004	(4+1) lines
dmSPEED_LINE	C=DAT1	8	read one line of graphic
	DAT0=C	8	write 8 nibbles
	D1=D1+	8	increment GROB pointer
	D0=D0+	12	|
	D0=D0+	12	| increment screen pointer
	D0=D0+	10	| to next line

	A=A-1	A
	GONC	dmSPEED_LINE	do the next line

	RTN		done with dmDRAW_MENU


* dmDRAW_HLP draws the help screen that can be reached from the
* main menu.  It assumes that the field is already clear.
* Added 7/14/1995.  This uses a different method of finding the internal
* bitmap data.  (Using a GOSUB and C=RSTK).  I recommend this method
* above the others used in Diamonds.  I know I could go and fix all the
* coding errors in Diamonds, but who has time?  

dmDRAW_HLP	GOSUB	dmDHNEXT	Go to the drawing portion.  A gosub will
*			Push the address of the data onto RSTK.

	NIBHEX	000F93FC197E4F1F00F87000
	NIBHEX	0005AA25B59A45A218459000
	NIBHEX	0005AA25559A55A200459000
	NIBHEX	0005AAE5559A652F00E87000
	NIBHEX	0005AA25159A452410459000
	NIBHEX	0005AA25159A45A418459000
	NIBHEX	000F9B3D197E4F1F00F87000
	NIBHEX	000000000000000000000000
	NIBHEX	000FFFFFFFFFFFFFFFFFF000
	NIBHEX	000000000000000000000000
	NIBHEX	00400000E000005200000000
	NIBHEX	004000001100001200000000
	NIBHEX	0076293759969C5FC0EC4900
	NIBHEX	084925A0DDB19252E112D610
	NIBHEX	084925A01480925220125210
	NIBHEX	0076C937E8B0EC5CC5EC4210
	NIBHEX	000000200000000000000000
	NIBHEX	000008100000000000000000
	NIBHEX	000000000000000000000000
	NIBHEX	000000000000000000000000
	NIBHEX	00000363487FE30000000000
	NIBHEX	000001724801800000000000
	NIBHEX	000009724837800000000000
	NIBHEX	000001724801800000000000
	NIBHEX	00000363CB71800000000000
	NIBHEX	000000000000000000000000
	NIBHEX	00000B13C9379E3000000000
	NIBHEX	000009324290980000000000
	NIBHEX	00000972C196F80000000000
	NIBHEX	000009324294980000000000
	NIBHEX	00000B134A37980000000000
	NIBHEX	000000000000000000000000
	NIBHEX	00063713C97728924871DB00
	NIBHEX	000251124A0924A248015800
	NIBHEX	00025312C9372C31483AC900
	NIBHEX	000251124A012421480A4800
	NIBHEX	000637734A71E521CB74CB70
	NIBHEX	000000000000000000000000
	NIBHEX	0000C05383392D189446ED30
	NIBHEX	0000405248496524A5492400
	NIBHEX	000046228949A524A629EC10
	NIBHEX	000040520A492524A4192400
	NIBHEX	0000C053C1362D1894162400
	NIBHEX	000000000000000000000000
	NIBHEX	0BB47733C139CD3000000000
	NIBHEX	098521524A49240000000000
	NIBHEX	09962332C979CC1000000000
	NIBHEX	098421524849050000000000
	NIBHEX	0BB427534846EC3000000000
	NIBHEX	000000000000000000000000
	NIBHEX	00000B738947F10000000000
	NIBHEX	000009724A42400000000000
	NIBHEX	000009724A42400000000000
	NIBHEX	000009724942400000000000
	NIBHEX	00000B738237400000000000

dmDHNEXT	C=RSTK		Get the address of the bitmap into C[A]
	D1=C
	GOSUBL	srRCL9_C	get ABUFF bitmap address
	LA(5)	103	offset to {#4h #3h}
	C=C+A	A
	D0=C

	LA(2)	(55-1)	(55-1) lines
dmDHLOOP	C=DAT1	12	read 12 nibbles of graphic
	DAT0=C	12	write 12 nibbles
	D1=D1+	12	increment GROB pointer
	D0=D0+	12	increment screen pointer
	C=DAT1	12	read 12 more nibbles
	DAT0=C	12	write 12 more
	D1=D1+	12	increment GROB pointer
	D0=D0+	12	|
	D0=D0+	10	| point to next line
	A=A-1	B
	GONC	dmDHLOOP	do the next line

dmDH_KEY	LCHEX	#1FF	| wait here until
	OUT=C		  | they stop pressing
	GOSBVL	=$jCINRTN | a key
	LAHEX	#0003F	  |
	A=A&C	A	  |
	?A#0	A	  |
	GOYES	dmDH_KEY	|

	LCHEX	#00800	about 10 seconds
	GOSUBL	waWAIT
	GOLONG	mnMENU	Return to Menu

* cfCLEAR will clear the entire playing field

cfCLEAR	GOSUBL	srRCL9_A	PICT GROB data @
	LCHEX	#00045	offset to field
	C=C+A	A
	D0=C
	LCHEX	#0003B	59+1 lines
cfCHEAT	A=0	W
cfERASE_LINE	DAT0=A	12	blank 12 nibbles
	D0=D0+	12	inc 12 nibbles
	DAT0=A	12	blank 12 more
	D0=D0+	12	you know.
	D0=D0+	10	move to next line
	C=C-1	A
	GONC	cfERASE_LINE	do next line
	RTN

* waWAIT delays, also waiting for a keypress.  Load C, field A with
* the amount to wait (000CC is about 1 second) and call waWAIT.
* If you press a key before the time is up, then the delay stops.
* If you press [S], then the sound is toggled, (and the delay
* stops)  If you press [ON] you are immediately returned to RPL.

waWAIT	B=C	A
waNEXT	LCHEX	#00013	a short delay
	GOSUBL	udDELAY

	LCHEX	#1FF
	OUT=C
	GOSBVL	=$jCINRTN
	LAHEX	#0003F	all keys
	A=A&C	A
	?A#0	A	have you pressed a key?
	RTNYES		yes? get out

	B=B-1	A
	GONC	waNEXT
	RTN

* DIV divides A, field W by C, field W.  The result is placed in
* field W of both registers A and C, and the remainder
* in B, field W.

DIV	P=	0
D_AGAIN	?C#0	S
	GOYES	D_NOTBIG
	?C>=A	W
	GOYES	D_NOTBIG
	CSL	W
	P=P+1
	GONC	D_AGAIN

D_NOTBIG	B=A	W
	A=0	W
	A=A-1	P
D_ADD	A=A+1	P
D_SUB	B=B-C	W
	GONC	D_ADD
	B=B+C	W
	P=P-1
	GOC	D_DONE
	CSR	W
	GONC	D_SUB
D_DONE	C=A	W
	P=	0
	RTNCC

ASLW5	ASL	W
	ASL	W
	ASL	W
	ASL	W
	ASL	W
	RTN

ASRW5	ASR	W
	ASR	W
	ASR	W
	ASR	W
	ASR	W
	RTN

CSLW5	CSL	W
	CSL	W
	CSL	W
	CSL	W
	CSL	W
	RTN

CSRW5	CSR	W
	CSR	W
	CSR	W
	CSR	W
	CSR	W
	RTN

ENDCODE

	FLUSHKEYS
	ATTNFLGCLR

	TWO #1+NDROP

	COLA Entry
;


NAMELESS _Entry
::
    TURNMENUOFF

    HARDBUFF ZEROZERO BINT_131d SIXTYFOUR
    GROB!ZERODRP

    NULL$ DUP
    "to start..."
    "Press ENTER"
    NULL$ DUPDUP

    SEVEN ZERO
    DO
	FOUR EIGHT INDEX@ #* Put5x7
    LOOP

    83 FIFTYSEVEN "V1.1(c)DM98" $>grob

    80 TWENTY
    ASSEMBLE
	CON(5)	=DOGROB
	CON(5)	15+((47+7)/8)*36*2
	CON(5)	36
	CON(5)	47
	NIBHEX	FFFFFFFFFFF7555555555555BAAAAAAAAAA655FFFFFF7555BA100000EAA655
	NIBHEX	100000A555BA1000002BA6551000002655BA1EFFF12CA6551600A12455BA1A
	NIBHEX	00512CA6551218A12455BA1220512CA65512CFF12455BA1240012CA6551240
	NIBHEX	012455BA1240012CA6551240012455BA1240012CA6551240012455BA124001
	NIBHEX	2CA6551240012455BA1240012CA65512CFF12455BA1245122CA65512CA0424
	NIBHEX	55BA1245082CA65512C0003455BA12CFFF3CA6553200000455BA6200000CA6
	NIBHEX	55D200000455BAA300000CA6555FFFFFF755BAAAAAAAAAA6FFFFFFFFFFF7
    RPL
    80 SIX "DIAMONDS" $>GROB

    XYGROBDISP XYGROBDISP XYGROBDISP

    SEVENTYEIGHT ONE 128 OVER
    OVER TWO OVER SEVENTEEN
    SEVENTYEIGHT OVER 127 OVER
    SEVENTYEIGHT TWO OVER SIXTEEN
    SEVENTYNINE EIGHTEEN 129 EIGHTEEN
    OVER TWO OVER SEVENTEEN

    SIX ZERO
    DO
	LINEON
    LOOP

    THIRTYEIGHT #>$ $>grob
    HARDBUFF 100 THIRTYSIX GROB!
;


NAMELESS _Main
::
    StndCheck
    ' Entry			( view entry )
    ' LeaveGraphView		( view exit )
    '				( view display )
    ::  DropJunk
	EnsureMenuOff
    ;
    '				( view hard key handlers )
    ::  {
	    {  kcEnter
	       ::  TakeOver
		   Action
	       ;
	    }
	    NULL{}
	    NULL{}
	    NULL{}
	    NULL{}
	    NULL{}
	}
	ONE KeyFace
    ;

    StndMenu
;

ASSEMBLE
endCode
RPL

ASSEMBLE
	Vfield DirCode,DirAlt
RPL
  { }

ASSEMBLE
	Vfield DirAlt,DirNot
RPL
 "DIAMONDS FOR THE HP38G\n ©1993 Doug R. Cannon\n<doug_cannon@juno.com>\n  ©'98 Detlef MÜller\n   <detlef@provi.de>\n   $Revision: 1.5 $"

ASSEMBLE
	Vfield DirNot,DirEnd
RPL
  { }

***	=Header.s 1.2 1

ASSEMBLE
	CLRLIST ALL
RPL



**miscdoc+**************************************************
**
** Defines for Topic Instance Bints
**
**+miscdoc**************************************************

DEFINE funcPTR#  ZERO
DEFINE polarPTR# ONE
DEFINE paramPTR# TWO
DEFINE seqPTR#   THREE
DEFINE statPTR#  FOUR
DEFINE solvePTR# FIVE
DEFINE otherPTR# SIX


**miscdoc+**************************************************
**
**      Equates for Property-List Bits
**
**      These equates (and the implied order of the properties)
**      must be consistent with the property-list bits for
**      macros as defined elsewhere.
**
**+miscdoc**************************************************
ASSEMBLE

* most significant nibble equates:

nonALG     EQU 8                not-allowed-in-algebraics flag
hasHELP    EQU 4                has-help-data flag
hasPROMPTM EQU 4                same as above
hasALIAS   EQU 2                has-algebraic-alias flag
hasPDATA   EQU 1                has-parse-data flag

* the remaining equates are only relevant for algebraic functions.
* next most significant nibble equates:

hasDER     EQU 8                has-derivative flag
hasINV     EQU 4                has-inverse flag
hasCOLCT   EQU 2                has-COLCT-data flag
hasEXPND   EQU 1                has-EXPND-data flag

* least significant nibble equates:

hasFORM    EQU 8                has-FORM-menu flag
hasINTG    EQU 4                has-Integral-data flag
hasWHERE   EQU 2                has-WHERE-code flag
hasVUNS    EQU 1                has-veryunsymin-code flag

RPL


*** Default for Shared Topic Variables
DEFINE DftXmin		% -6.5
DEFINE DftXmax		% 6.5
DEFINE DftYmin		% -3.1
DEFINE DftYmax		% 3.2
DEFINE DftHTick 	% 1
DEFINE DftVTick 	% 1
DEFINE DftHZoom 	% 4
DEFINE DftVZoom 	% 4
DEFINE DftAngle		# 2	( Rad )
DEFINE DftTStart	% 0
DEFINE DftTStep		% 0.1
DEFINE DftTZoom		% 4
DEFINE DftTFlags	0
DEFINE DftFormat	# 1
DEFINE DftDigits	# 0

*** Default for Polar
DEFINE DftThetaMin      % 0
DEFINE DftThetaMax      % 6.28318530718         ( %2PI )
DEFINE DftThetaStp      % 0.1308996939          ( %PI/24 )

*** Default for Paramatric
DEFINE DftTmin          % 0
DEFINE DftTmax          % 12
DEFINE DftPStep         % 0.1

*** Default for Sequence
DEFINE DftSeqXmin       % -2
DEFINE DftSeqXmax       % 24
DEFINE DftSeqYmin	% -2
DEFINE DftSeqYmax	% 10.6
DEFINE DftSeqNmin       % 1
DEFINE DftSeqNmax       % 24
DEFINE DftSeqType       # 1
DEFINE DftSeqTStart     % 1
DEFINE DftSeqTStep      % 1

*** Default for Solve
DEFINE DftSolveTcol     # 1
DEFINE DftSolveTrow     # 1

*** Default for Statistics
DEFINE DftStatXmin      % -2
DEFINE DftStatXmax      % 24
DEFINE DftStatYmin      % -2
DEFINE DftStatYmax      % 10.6
DEFINE DftStatType      # 1	( 1=1Var, 2=2Var Statistic )
DEFINE DftStatPlot	# 1	( 1=Histogram, 2=BoxWhisker )
DEFINE DftHisWidth	% 1
DEFINE DftHmin		% 0
DEFINE DftHmax		% 20

DEFINE DftStatMark	# 54321
DEFINE DftStatModel	# 11111


DEFINE kpNoShift	ONE
DEFINE kpLeftShift	TWO
DEFINE kpANoShift	FOUR
DEFINE kpALeftShift	FIVE


DEFINE kcSoftKey1	ONE
DEFINE kcSoftKey2	TWO
DEFINE kcSoftKey3	THREE
DEFINE kcSoftKey4	FOUR
DEFINE kcSoftKey5	FIVE
DEFINE kcSoftKey6	SIX

DEFINE kcPlotView	SEVEN
DEFINE kcSymbView	EIGHT
DEFINE kcNumView	NINE
DEFINE kcUpArrow	ELEVEN

DEFINE kcLibrary	THIRTEEN
DEFINE kcVarsMenu	FOURTEEN
DEFINE kcMathMenu	FIFTEEN
DEFINE kcLeftArrow	SIXTEEN
DEFINE kcDownArrow	SEVENTEEN
DEFINE kcRightArrow	EIGHTEEN

DEFINE kcHome		NINETEEN
DEFINE kcSin		TWENTY
DEFINE kcCos		TWENTYONE
DEFINE kcTan		TWENTYTWO
DEFINE kcXTTheta	TWENTYTHREE
DEFINE kcSqrt		TWENTYFOUR

DEFINE kcEnter		TWENTYFIVE
DEFINE kcLeftParen	TWENTYSIX
DEFINE kcRightParen	TWENTYSEVEN
DEFINE kcNegate		TWENTYEIGHT
DEFINE kcPower		TWENTYNINE

DEFINE kcAlpha		THIRTY
DEFINE kc7		THIRTYONE
DEFINE kc8		THIRTYTWO
DEFINE kc9		THIRTYTHREE
DEFINE kcDivide		THIRTYFOUR

DEFINE kcLeftShift	THIRTYFIVE
DEFINE kc4		THIRTYSIX
DEFINE kc5		THIRTYSEVEN
DEFINE kc6		THIRTYEIGHT
DEFINE kcTimes		THIRTYNINE

DEFINE kcDel		FORTY
DEFINE kc1		FORTYONE
DEFINE kc2		FORTYTWO
DEFINE kc3		FORTYTHREE
DEFINE kcMinus		FORTYFOUR

DEFINE kcOn		FORTYFIVE
DEFINE kc0		FORTYSIX
DEFINE kcPeriod		FORTYSEVEN
DEFINE kcComma		FORTYEIGHT
DEFINE kcPlus		FORTYNINE



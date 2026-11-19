@echo off

rem $Id: mkdia.btm 1.1 1998/07/31 22:00:02 Detlef Exp $
rem
rem $Log: mkdia.btm $
rem Revision 1.1  1998/07/31 22:00:02  Detlef
rem Initial revision
rem

echo OUTPUT    DIAM38.000>_LOADER.M
echo LLIST     DIAM38.LR>>_LOADER.M
echo SUPPRESS  XR>>_LOADER.M
echo OPTION    CODE>>_LOADER.M
echo SEARCH    SUPROM38.O>>_LOADER.M
echo REL       _DIAM38.O>>_LOADER.M
echo END>>_LOADER.M

echo HP38AscA A 11 HP38DIR.0004 Root >HP38DIR.CUR
echo HP38AscA B 10 DIAM38.0008 DiamondsH 12 LIB1537L.0008 LIB1537L >HP38DIR.000

RPLCOMP DIAM38.S _DIAM38.A
SASM -e -N _DIAM38.A
SLOAD -H _LOADER.M

DEL _*.* /Q

TYPE DIAM38.LR

PAUSE

DEL DIAM38.LR /Q

set _x=

:bye

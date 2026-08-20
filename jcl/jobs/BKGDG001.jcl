//BKGDG001 JOB (LABV2),'GDG DATE GUARD',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Guard against processing GDG(-1) as current.
//* OUT-OF-ORDER: header date != cycle -> RC=12 BK-E-CUTOFF.
//STEPGDG  EXEC PGM=BKGDG01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UGDGIN   DD   DSN=HUB.RGNEAST.EXTRACT.D0(0),DISP=SHR
//SYSIN    DD   *
HUB.RGNEAST.EXTRACT.G0001V00
/*
//SYSOUT   DD   SYSOUT=*


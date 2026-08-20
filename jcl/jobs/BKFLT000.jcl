//BKFLT000 JOB (LABV2),'AVAIL FLOAT',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Reg CC lab stub. Sort failure must not post — COND on this job
//* is independent; posting still gated by BKPST000.
//STEPSRT  EXEC PGM=SORT
//SYSOUT   DD   SYSOUT=*
//SORTIN   DD   DSN=HUB.DEP.IN.D0,DISP=SHR
//SORTOUT  DD   DSN=&&DEP,DISP=(NEW,PASS),SPACE=(TRK,(5,5)),UNIT=SYSDA
//SYSIN    DD   DSN=HUB.CTL(BKSRTCNT),DISP=SHR
//STEPFLT  EXEC PGM=BKFLT01,COND=(4,LT,STEPSRT)
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UDEPIN   DD   DSN=&&DEP,DISP=(OLD,DELETE,KEEP)
//SYSOUT   DD   SYSOUT=*


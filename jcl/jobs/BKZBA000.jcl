//BKZBA000 JOB (LABV2),'ZBA SWEEP',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* After inhibit, before GL. Parent NSF skips child cover (RC=4).
//STEPZBA  EXEC PGM=BKZBA01,COND=(12,LE)
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UZBARPT  DD   DSN=HUB.ZBA.RPT.D0(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1)),UNIT=SYSDA
//SYSOUT   DD   SYSOUT=*


//BKCTR000 JOB (LABV2),'CTR AGGREGATE',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Cash >= 10000 per CIF. RC=4 if none. Does not file CTR.
//STEPCTR  EXEC PGM=BKCTR01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UCTRRPT  DD   DSN=HUB.CTR.CAND.D0(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1)),UNIT=SYSDA
//SYSOUT   DD   SYSOUT=*


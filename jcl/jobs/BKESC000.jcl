//BKESC000 JOB (LABV2),'ESCROW DISB',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Do not overdraft escrow. Shortfall status N.
//STEPESC  EXEC PGM=BKESC01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UESCOUT  DD   DSN=HUB.ESC.DISB.D0(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1)),UNIT=SYSDA
//SYSOUT   DD   SYSOUT=*


//BKTAX000 JOB (LABV2),'1099 INT',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Year-end. Backup withholding 24% on B/C notice.
//STEPTAX  EXEC PGM=BKTAX01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UTAXOUT  DD   DSN=HUB.TAX.1099.D0(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(1,1)),UNIT=SYSDA
//SYSOUT   DD   SYSOUT=*


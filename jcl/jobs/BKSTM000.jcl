//BKSTM000 JOB (LABV2),'STATEMENTS',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* After post. Empty cycle RC=4.
//STEPSTM  EXEC PGM=BKSTM01,COND=((8,LE),(12,LE))
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//USTMOUT  DD   DSN=HUB.STMT.D0(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(5,5)),UNIT=SYSDA
//SYSOUT   DD   SYSOUT=*


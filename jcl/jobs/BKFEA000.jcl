//BKFEA000 JOB (LABV2),'SVC CHARGE',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Monthly analysis. Inhibit required. No EVEN on STEPFEE.
//STEPFEE  EXEC PGM=BKFEA01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UFEERPT  DD   DSN=HUB.FEE.RPT.D0(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1)),UNIT=SYSDA
//SYSOUT   DD   SYSOUT=*
//IFBAD    IF (STEPFEE.RC >= 12) THEN
//STEPNTF  EXEC PGM=BKNTF01,COND=ONLY
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
BK-E-ONLINEUP FEE
/*
//         ENDIF


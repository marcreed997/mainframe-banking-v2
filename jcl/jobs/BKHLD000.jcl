//BKHLD000 JOB (LABV2),'HOLD EXPIRY',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Must run after inhibit. LEVY/GARNISH never auto-expire.
//IFINH    IF (BKINH000.STEPCICS.RC <= 4) THEN
//STEPHLD  EXEC PGM=BKHLD02
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UHLDREP  DD   DSN=HUB.HOLD.EXP.D0(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1)),UNIT=SYSDA
//SYSOUT   DD   SYSOUT=*
//         ELSE
//STEPNTF  EXEC PGM=BKNTF01
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
BK-E-ONLINEUP HOLD
/*
//         ENDIF


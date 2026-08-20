//BKGL2000 JOB (LABV2),'GL PROVE',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Predecessor: BKRCN000 recon closed. RC=8 if recon not closed.
//STEPGL2  EXEC PGM=BKGL02
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UGLRPT   DD   DSN=HUB.GL.PROVE.D0(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1)),UNIT=SYSDA
//SYSOUT   DD   SYSOUT=*
//IFBAD    IF (STEPGL2.RC > 4) THEN
//STEPNTF  EXEC PGM=BKNTF01,COND=EVEN
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
BK-E-UNMATCHED GL
/*
//         ENDIF


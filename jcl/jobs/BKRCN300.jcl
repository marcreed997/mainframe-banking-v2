//BKRCN300 JOB (LABV2),'THREE WAY RCN',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Location vs hub vs GL. Sets RECON_CLOSED only if all match.
//STEPR3   EXEC PGM=BKRCN03
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UX3OUT   DD   DSN=HUB.RECON.X3.D0(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1)),UNIT=SYSDA
//SYSOUT   DD   SYSOUT=*
//IFINT    IF (STEPR3.RC >= 12) THEN
//STEPNTF  EXEC PGM=BKNTE01,COND=ONLY
//UDMP     DD   SYSOUT=*
//SYSIN    DD   *
BK-E-UNMATCHED 3WAY
/*
//         ENDIF


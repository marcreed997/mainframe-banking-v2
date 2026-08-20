//RCNVATM  JOB (LABV2),'BANK V2 VALIDATE ATMNET',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//* Predecessor: BKFILEMNET register. Out-of-order: post job
//* must see VALIDATED_IND=Y or RC=8.
//         JCLLIB ORDER=(HUB.PROCLIB)
//STEPVLD  EXEC BKVLDPR,LOC=ATMNET,CYCLE=&CYCLE,GEN=0
//IFBAD    IF (STEPVLD.STEPVLD.RC > 4) THEN
//STEPNTF  EXEC PGM=BKNTF01
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
HASH-FAIL
/*
//         ELSE
//STEPOK   EXEC PGM=IEFBR14
//         ENDIF

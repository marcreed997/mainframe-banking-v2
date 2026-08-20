//BKSORT00 JOB (LABV2),'BANK V2 DFSORT MERGE FILE',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//STEPSRT  EXEC PGM=SORT,COND=(8,LE)
//SYSOUT   DD   SYSOUT=*
//SORTIN   DD   DSN=HUB.MERGE.EXTRACT(0),DISP=SHR
//SORTOUT  DD   DSN=HUB.MERGE.SORTED(+1),
//             DISP=(NEW,CATLG,DELETE),SPACE=(CYL,(5,5),RLSE)
//SYSIN    DD   DSN=HUB.CNTL(BKSRTCNT),DISP=SHR
//IFSRT    IF (STEPSRT.RC > 4) THEN
//STEPN    EXEC PGM=BKNTF01
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
HASH-FAIL
/*
//         ENDIF

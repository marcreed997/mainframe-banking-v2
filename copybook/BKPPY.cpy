      *****************************************************************
      * BKPPY - Positive pay issued-check vs presentment
      *****************************************************************
       01  BK-PP-ISSUED.
           05  PP-ISS-ACC           PIC X(6).
           05  PP-ISS-SERIAL        PIC 9(10).
           05  PP-ISS-AMT           PIC S9(13)V99 COMP-3.
           05  PP-ISS-PAYEE         PIC X(40).
           05  PP-ISS-DTE           PIC X(10).
           05  PP-ISS-STATUS        PIC X.
               88  PP-OPEN          VALUE 'O'.
               88  PP-PAID          VALUE 'P'.
               88  PP-VOID          VALUE 'V'.
               88  PP-STOP          VALUE 'S'.
       01  BK-PP-PRESENT.
           05  PP-PR-ACC            PIC X(6).
           05  PP-PR-SERIAL         PIC 9(10).
           05  PP-PR-AMT            PIC S9(13)V99 COMP-3.
           05  PP-PR-ROUTING        PIC 9(9).
           05  PP-PR-TRACE          PIC X(26).
           05  PP-PR-DTE            PIC X(10).
       01  BK-PP-XCPT.
           05  PP-X-REASON          PIC X(12).
               88  PP-AMT-MISMATCH  VALUE 'AMT-MISMATCH'.
               88  PP-NOT-ISSUED    VALUE 'NOT-ISSUED'.
               88  PP-DUP-PAY       VALUE 'DUP-PAY'.
               88  PP-VOID-HIT      VALUE 'VOID-HIT'.
               88  PP-STOP-HIT      VALUE 'STOP-HIT'.
               88  PP-PAYEE-MIS     VALUE 'PAYEE-MIS'.
           05  PP-X-DECISION        PIC X.
               88  PP-PAY           VALUE 'P'.
               88  PP-RETURN        VALUE 'R'.
               88  PP-PEND          VALUE 'W'.
           05  PP-X-DECIDER         PIC X(8).

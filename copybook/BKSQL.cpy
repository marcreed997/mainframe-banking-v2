      *****************************************************************
      * BKSQL - SQLCODE mapping to RETURN-CODE contract
      *****************************************************************
       01  BK-SQL-MAP.
           05  SQL-OK               PIC S9(9) VALUE 0.
           05  SQL-NOTFND           PIC S9(9) VALUE +100.
           05  SQL-DUP              PIC S9(9) VALUE -803.
           05  SQL-DEADLOCK         PIC S9(9) VALUE -911.
           05  SQL-TIMEOUT          PIC S9(9) VALUE -913.
       01  BK-RC-CONTRACT.
           05  RC-OK                PIC S9(4) COMP VALUE 0.
           05  RC-WARN              PIC S9(4) COMP VALUE 4.
           05  RC-WAIT              PIC S9(4) COMP VALUE 8.
           05  RC-INTEGRITY         PIC S9(4) COMP VALUE 12.
           05  RC-SEVERE            PIC S9(4) COMP VALUE 16.

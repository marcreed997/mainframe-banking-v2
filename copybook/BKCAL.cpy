      *****************************************************************
      * BKCAL - Business-day / holiday / ACH window calendar
      *****************************************************************
       01  BK-CALENDAR.
           05  CAL-DTE              PIC X(10).
           05  CAL-DOW              PIC 9.
               88  CAL-SUN          VALUE 1.
               88  CAL-SAT          VALUE 7.
               88  CAL-WEEKDAY      VALUE 2 3 4 5 6.
           05  CAL-HOLIDAY-IND      PIC X.
               88  CAL-HOLIDAY      VALUE 'Y'.
               88  CAL-BUSINESS     VALUE 'N'.
           05  CAL-HOLIDAY-NAME     PIC X(24).
           05  CAL-FED-OPEN         PIC X.
           05  CAL-ACH-WINDOW       PIC X(8).
           05  CAL-NEXT-BUS         PIC X(10).
           05  CAL-PREV-BUS         PIC X(10).
           05  CAL-SAME-DAY-CUT     PIC X(8).
           05  CAL-WIRE-CUT         PIC X(8).

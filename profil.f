      PROGRAM PROFILE
C
C     THIS PROGRAM PROFILES EITHER RHO OR DEL SQ RHO ALONG A
C     USER DEFINED LINE FOR A MOLECULE.
C     THE OUTPUT CONSISTS OF DISTANCES AND THE CORRESPONDING 
C     FUNCTION VALUE.
C
C     JAMES R. CHEESEMAN   (MCMASTER UNIVERSITY MAY 1992)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
      PARAMETER (MCENT=50, MMO=100, MPRIMS=700, MPTS=200)
C
      CHARACTER*80 LINE,LINE1,LINE2,TITLE
      CHARACTER*40 WINP,WFN,WPRO
      CHARACTER*7 WORD
      CHARACTER*4 FINP /'.pfl'/, FWFN /'.wfn'/, FPRO /'.pro'/ 
C
      COMMON /UNITS/  IINP,IOUT,IWFN
C
      DIMENSION  START(3), ENDPT(3), XYZ(MPTS,3)
C
C     DATA IWFN /10/, IINP /15/, IOUT /13/
C
      CALL MAKNAME (1,WINP,ILEN,FINP)
      IF (ILEN .EQ. 0) STOP 'usage: profile vecfile wfnfile'
      CALL MAKNAME (1,WPRO,ILEN,FPRO)
      IF (ILEN .EQ. 0) STOP 'usage: profile vecfile wfnfile'
      CALL MAKNAME (2,WFN,ILEN,FWFN)
      IF (ILEN .EQ. 0) STOP 'usage: profile vecfile wfnfile'
C
      OPEN (IINP,FILE=WINP)
      OPEN (IOUT,FILE=WPRO)
      OPEN (IWFN,FILE=WFN)
C
      CALL RDPSI 
C
C    TITLE: 
C
      READ (IINP,1000) TITLE
C
C    NUMBER OF EQUALLY SPACED SEGEMNTS AND CUT OFF VALUE:
C
      READ (IINP,*) WORD,N,CUTOFF
C
C    STARTING POINT:
C
      READ (IINP,1010) LINE1
      LPST = 8
      DO 90 I = 1,3
        IF (NUMBER(LINE1,LPST,NUM,START(I)) .GT. 0) GOTO 3000
90    CONTINUE
C 
C    END POINT:
C
      READ (IINP,1010) LINE2
      LPST = 8
      DO 92 I = 1,3
        IF (NUMBER(LINE2,LPST,NUM,ENDPT(I)) .GT. 0) GOTO 4000
92    CONTINUE
C
C    READ IN DESIRED FUNCTION 
C
      READ (IINP,1010) LINE
      LPST = 8
      IF (NUMBER(LINE,LPST,IFUNC,DNUM) .GT. 0) GOTO 5000 
C
C
      DO 100 J=1,3
        XYZ(1,J) = START(J) 
        XYZ(N+1,J) = ENDPT(J)
100   CONTINUE
C
      DELX = XYZ(N+1,1) - XYZ(1,1)
      DELY = XYZ(N+1,2) - XYZ(1,2)
      DELZ = XYZ(N+1,3) - XYZ(1,3)
C
      DIST2 = (DELX)**2 + (DELY)**2 + (DELZ)**2 
      DIST = DSQRT(DIST2)
      EINCR = DIST/N
C
      A = DELX/N
      B = DELY/N
      C = DELZ/N
C
      DO 200 J=1,N
         XYZ(J,1) = XYZ(1,1) + A*(J-1) 
         XYZ(J,2) = XYZ(1,2) + B*(J-1) 
         XYZ(J,3) = XYZ(1,3) + C*(J-1) 
200   CONTINUE
C
C
C       CALL ROUTINE TO CALCULATE DESIRED FUNCTION
C       IFUNC=1 IS RHO, IFUNC=2 IS DEL SQ RHO
C
      IF (IFUNC .EQ. 1) CALL PRORHO(XYZ,N,CUTOFF,EINCR,TITLE,LINE1
     +,LINE2)
C
      IF (IFUNC .EQ. 2) CALL PRODEL(XYZ,N,CUTOFF,EINCR,TITLE,LINE1
     +,LINE2)
C
      STOP
C
C    FORMATS
C
1000  FORMAT(7X,A70)
1010  FORMAT(A80)
C2000  WRITE (6,2010)
C2010  FORMAT(' ERROR IN SEGMENT INCREMENT CARD ')
C      GOTO 4999
3000  WRITE (6,3010) 
3010  FORMAT(' ERROR IN STARTING POINT COORDINATES ')
      GOTO 4999
4000  WRITE (6,4010) 
4010  FORMAT(' ERROR IN END POINT COORDINATES ')
      GOTO 4999
5000  WRITE (6,5010)
5010  FORMAT(' ERROR IN FUNCTION CARD ' )
      GOTO 4999
4999  STOP
      END
      BLOCK DATA
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
      COMMON /UNITS/  IINP,IOUT,IWFN
C
      DATA IWFN /10/, IINP /15/, IOUT /13/
C
      END
      SUBROUTINE GAUS(XYZ,PTS,MM)
C
C    GAUS CALCULATES THE VALUES OF THE ZEROTH, THE FIRST, AND
C    2ND DERIVATIVES OF THE BASIS FUNCTIONS AT THE PTS POINTS
C    AS WELL AS THE VALUES OF THE ZEROTH, THE FIRST, AND 2ND
C    DERIVATIVES OF THE MO's AT THE PTS POINTS. 
C
       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
C    GLOBAL COMMONS
C
      PARAMETER (MCENT=50, MMO=100, MPRIMS=700, MPTS=200)
C
      COMMON /ATOMS/ XC(MCENT),YC(MCENT),ZC(MCENT),CHARG(MCENT),NCENT
      COMMON /ORBTL/ EORB(MMO),PO(MMO),NMO
      COMMON /PRIMS/ COO(MPRIMS,MMO),EXX(MPRIMS),ICT(MPRIMS),
     +       SUM(MPRIMS),ITP(10),NPRIMS,DIV(MPRIMS)
       COMMON /ZZZZ/ PSI(MPTS,MMO),GX(MPTS,MMO),GY(MPTS,MMO),
     + GZ(MPTS,MMO),D2(MPTS,MMO)
C
C    LOCAL ARRAYS
C
      DIMENSION XYZ(MPTS,3),DX(MPTS,MCENT),DY(MPTS,MCENT)
      DIMENSION DZ(MPTS,MCENT)
      DIMENSION R2(MPTS,MCENT),CHI(MPTS,MPRIMS),CHIX(MPTS,MPRIMS)
      DIMENSION CHIY(MPTS,MPRIMS)
      DIMENSION CHIZ(MPTS,MPRIMS),CHID2(MPTS,MPRIMS)
      INTEGER PTS
C
      DATA ZERO /0.0D+00/, ONE /1.0D+00/, TWO /2.0D+00/, FOUR /4.0D+00/
      DATA FIVE /5.0D+00/, SEVEN /7.0D+00/, THREE /3.0D+00/
C
C    IF ONLY THE MO VALUES ARE REQUIRED (MM = 1) THE SECOND SECTION
C    OF GAUS IS USED.  IF BOTH FIRST AND SECOND DERIVATIVES ARE
C    REQUIRED (MM = 0) ALSO THE FIRST SECTION OF GAUS IS USED.
C
      IF (MM .EQ. 1) GOTO 133
C
      DO 110 J = 1,NCENT
       DO 112 I=1,PTS 
        DX(I,J) = XYZ(I,1) - XC(J)
        DY(I,J) = XYZ(I,2) - YC(J)
        DZ(I,J) = XYZ(I,3) - ZC(J)
        R2(I,J)= DX(I,J)*DX(I,J)+DY(I,J)*DY(I,J)+DZ(I,J)*DZ(I,J)
112   CONTINUE
110   CONTINUE
C
C    CALCULATE THE VALUE OF THE BASIS FUNCITONS AND
C    THEIR DERIVATIVES AT THE PTS (XYZ)'s.
C
C
C       FOR S-TYPE
C
        DO 120 J = 1,ITP(1) 
        DO 122 I=1,PTS 
C
        A=SUM(J)*DEXP(-EXX(J)*R2(I,ICT(J)))
C
        CHI(I,J)=A*DIV(J)
        CHIX(I,J)=DX(I,ICT(J))*A
        CHIY(I,J)=DY(I,ICT(J))*A
        CHIZ(I,J)=DZ(I,ICT(J))*A
        CHID2(I,J)=(THREE+SUM(J)*R2(I,ICT(J)))*A
122     CONTINUE
120     CONTINUE
C
C       FOR Px-TYPE
C
        DO 140 J=ITP(1)+1,ITP(2)
        DO 142 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,ICT(J)))
        B=DX(I,ICT(J))*A*SUM(J)
C
        CHI(I,J)=A*DX(I,ICT(J))
        CHIX(I,J)=A+DX(I,ICT(J))*B
        CHIY(I,J)=DY(I,ICT(J))*B
        CHIZ(I,J)=DZ(I,ICT(J))*B
        CHID2(I,J)=(FIVE+SUM(J)*R2(I,ICT(J)))*B
142     CONTINUE
140     CONTINUE
C
C       FOR Py-TYPE
C
        DO 160 J=ITP(2)+1,ITP(3)
        DO 162 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,ICT(J)))
        B=DY(I,ICT(J))*A*SUM(J)
C
        CHI(I,J)=A*DY(I,ICT(J))
        CHIX(I,J)=DX(I,ICT(J))*B
        CHIY(I,J)=A+DY(I,ICT(J))*B
        CHIZ(I,J)=DZ(I,ICT(J))*B
        CHID2(I,J)=(FIVE+SUM(J)*R2(I,ICT(J)))*B
162     CONTINUE
160     CONTINUE
C
C       FOR Pz-TYPE
C
        DO 180 J=ITP(3)+1,ITP(4)
        DO 182 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,ICT(J)))
        B=DZ(I,ICT(J))*A*SUM(J)
C
        CHI(I,J)=A*DZ(I,ICT(J))
        CHIX(I,J)=DX(I,ICT(J))*B
        CHIY(I,J)=DY(I,ICT(J))*B
        CHIZ(I,J)=A+DZ(I,ICT(J))*B
        CHID2(I,J)=(FIVE+SUM(J)*R2(I,ICT(J)))*B
182     CONTINUE
180     CONTINUE
C
C       FOR Dxx-TYPE
C
        DO 220 J=ITP(4)+1,ITP(5)
        DO 222 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,ICT(J)))
        B=DX(I,ICT(J))*DX(I,ICT(J))*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=(TWO*A+B)*DX(I,ICT(J))
        CHIY(I,J)=DY(I,ICT(J))*B
        CHIZ(I,J)=DZ(I,ICT(J))*B
        CHID2(I,J)=TWO*A+(SEVEN+SUM(J)*R2(I,ICT(J)))*B
222     CONTINUE
220     CONTINUE
C
C       FOR Dyy-TYPE
C
        DO 240 J=ITP(5)+1,ITP(6)
        DO 242 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,ICT(J)))
        B=DY(I,ICT(J))*DY(I,ICT(J))*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=DX(I,ICT(J))*B
        CHIY(I,J)=(TWO*A+B)*DY(I,ICT(J))
        CHIZ(I,J)=DZ(I,ICT(J))*B
        CHID2(I,J)=TWO*A+(SEVEN+SUM(J)*R2(I,ICT(J)))*B
242     CONTINUE
240     CONTINUE
C
C       FOR Dzz-TYPE
C
        DO 260 J=ITP(6)+1,ITP(7)
        DO 262 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,ICT(J)))
        B=DZ(I,ICT(J))*DZ(I,ICT(J))*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=DX(I,ICT(J))*B
        CHIY(I,J)=DY(I,ICT(J))*B
        CHIZ(I,J)=(TWO*A+B)*DZ(I,ICT(J))
        CHID2(I,J)=TWO*A+(SEVEN+SUM(J)*R2(I,ICT(J)))*B
262     CONTINUE
260     CONTINUE
C
C       FOR Dxy-TYPE
C
        DO 280 J=ITP(7)+1,ITP(8)
        DO 282 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,ICT(J)))
        B=DX(I,ICT(J))*DY(I,ICT(J))*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=DX(I,ICT(J))*B+DY(I,ICT(J))*A
        CHIY(I,J)=DY(I,ICT(J))*B+DX(I,ICT(J))*A
        CHIZ(I,J)=DZ(I,ICT(J))*B
        CHID2(I,J)=(SEVEN+SUM(J)*R2(I,ICT(J)))*B
282     CONTINUE
280     CONTINUE
C
C       FOR Dxz-TYPE
C
        DO 320 J=ITP(8)+1,ITP(9)
        DO 322 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,ICT(J)))
        B=DX(I,ICT(J))*DZ(I,ICT(J))*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=DX(I,ICT(J))*B+DZ(I,ICT(J))*A
        CHIY(I,J)=DY(I,ICT(J))*B
        CHIZ(I,J)=DZ(I,ICT(J))*B+DX(I,ICT(J))*A
        CHID2(I,J)=(SEVEN+SUM(J)*R2(I,ICT(J)))*B
322     CONTINUE
320     CONTINUE
C
C       FOR Dyz-TYPE
C
        DO 340 J=ITP(9)+1,ITP(10)
        DO 342 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,ICT(J)))
        B=DY(I,ICT(J))*DZ(I,ICT(J))*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=DX(I,ICT(J))*B
        CHIY(I,J)=DY(I,ICT(J))*B+DZ(I,ICT(J))*A
        CHIZ(I,J)=DZ(I,ICT(J))*B+DY(I,ICT(J))*A
        CHID2(I,J)=(SEVEN+SUM(J)*R2(I,ICT(J)))*B
342     CONTINUE
340     CONTINUE
C
C     CALCULATE THE VALUES OF THE MO's AND THEIR FIRST AND SECOND
C     DERIVATIVE COMPONENTS AT THE PTS (XYZ)'s 
C
C     USE MATRIX MULTIPLICATION ROUTINE FOR STELLAR
C
C      CALL D$RMMULS$S(CHI,MPTS,COO,MPRIMS,PSI,MPTS,PTS,NMO,NPRIMS)
C      CALL D$RMMULS$S(CHIX,MPTS,COO,MPRIMS,GX,MPTS,PTS,NMO,NPRIMS)
C      CALL D$RMMULS$S(CHIY,MPTS,COO,MPRIMS,GY,MPTS,PTS,NMO,NPRIMS)
C      CALL D$RMMULS$S(CHIZ,MPTS,COO,MPRIMS,GZ,MPTS,PTS,NMO,NPRIMS)
C      CALL D$RMMULS$S(CHID2,MPTS,COO,MPRIMS,D2,MPTS,PTS,NMO,NPRIMS)
C
C
C     MATRIX-MATRIX MULTIPLICATION FOR CRAY AND RS6000 AND TRACE -
C     FOR RS6000 AND TRACE CALL dgemm INSTEAD OF sgemm
C 
      call dgemm ('n','n', pts, nmo, nprims, 1.0d0, chi, mpts, 
     1  coo, mprims, 0.d0, psi, mpts )
      call dgemm ('n','n', pts, nmo, nprims, 1.0d0, chix, mpts, 
     1  coo, mprims, 0.d0, gx, mpts )
      call dgemm ('n','n', pts, nmo, nprims, 1.0d0, chiy, mpts, 
     1  coo, mprims, 0.d0, gy, mpts )
      call dgemm ('n','n', pts, nmo, nprims, 1.0d0, chiz, mpts, 
     1  coo, mprims, 0.d0, gz, mpts )
      call dgemm ('n','n', pts, nmo, nprims, 1.0d0, chid2, mpts, 
     1  coo, mprims, 0.d0, d2, mpts )
C
C     USE LOOPS BELOW IF NO MATRIX MULTIPLICATION ROUTINES AVAILABLE
C
C    ZERO OUT ARRAYS IF NO MATRIX ROUTINES
C
C     DO 105 J = 1,NMO
C      DO 107 I=1,PTS 
C       PSI(I,J) = ZERO
C       GX(I,J) = ZERO
C       GY(I,J) = ZERO
C       GZ(I,J) = ZERO
C       D2(I,J) = ZERO
C107   CONTINUE 
C105   CONTINUE
C
C       DO 124 L = 1,NMO
C       DO 125 J = 1,NPRIMS
C       DO 126 I = 1,PTS
C         PSI(I,L) = PSI(I,L) + COO(J,L)*CHI(I,J)
C         GX(I,L) = GX(I,L) + COO(J,L)*CHIX(I,J)
C         GY(I,L) = GY(I,L) + COO(J,L)*CHIY(I,J)
C         GZ(I,L) = GZ(I,L) + COO(J,L)*CHIZ(I,J)
C         D2(I,L) = D2(I,L) + COO(J,L)*CHID2(I,J)
C126      CONTINUE
C125      CONTINUE
C124      CONTINUE
       GOTO 999
C
133   CONTINUE
C
      DO 410 J = 1,NCENT
       DO 412 I=1,PTS 
        DX(I,J) = XYZ(I,1) - XC(J)
        DY(I,J) = XYZ(I,2) - YC(J)
        DZ(I,J) = XYZ(I,3) - ZC(J)
        R2(I,J)= DX(I,J)*DX(I,J)+DY(I,J)*DY(I,J)+DZ(I,J)*DZ(I,J)
412   CONTINUE
410   CONTINUE
C
C    CALCULATE THE VALUE OF THE BASIS FUNCITONS AT THE PTS POINTS
C
C       FOR S-TYPE
C
        DO 420 J = 1,ITP(1) 
        DO 422 I=1,PTS 
C
        CHI(I,J)=DEXP(-EXX(J)*R2(I,ICT(J)))
C
422     CONTINUE
420     CONTINUE
C
C       FOR Px-TYPE
C
        DO 440 J=ITP(1)+1,ITP(2)
        DO 442 I=1,PTS
C
        CHI(I,J)=DX(I,ICT(J))*DEXP(-EXX(J)*R2(I,ICT(J)))
442     CONTINUE
440     CONTINUE
C
C       FOR Py-TYPE
C
        DO 460 J=ITP(2)+1,ITP(3)
        DO 462 I=1,PTS
C
        CHI(I,J)=DY(I,ICT(J))*DEXP(-EXX(J)*R2(I,ICT(J)))
462     CONTINUE
460     CONTINUE
C
C       FOR Pz-TYPE
C
        DO 480 J=ITP(3)+1,ITP(4)
        DO 482 I=1,PTS
C
        CHI(I,J)=DZ(I,ICT(J))*DEXP(-EXX(J)*R2(I,ICT(J)))
482     CONTINUE
480     CONTINUE
C
C       FOR Dxx-TYPE
C
        DO 520 J=ITP(4)+1,ITP(5)
        DO 522 I=1,PTS
C
        CHI(I,J)=DX(I,ICT(J))*DX(I,ICT(J))*DEXP(-EXX(J)*R2(I,ICT(J)))
522     CONTINUE
520     CONTINUE
C
C       FOR Dyy-TYPE
C
        DO 540 J=ITP(5)+1,ITP(6)
        DO 542 I=1,PTS
C
        CHI(I,J)=DY(I,ICT(J))*DY(I,ICT(J))*DEXP(-EXX(J)*R2(I,ICT(J)))
542     CONTINUE
540     CONTINUE
C
C       FOR Dzz-TYPE
C
        DO 560 J=ITP(6)+1,ITP(7)
        DO 562 I=1,PTS
C
        CHI(I,J)=DZ(I,ICT(J))*DZ(I,ICT(J))*DEXP(-EXX(J)*R2(I,ICT(J)))
562     CONTINUE
560     CONTINUE
C
C       FOR Dxy-TYPE
C
        DO 580 J=ITP(7)+1,ITP(8)
        DO 582 I=1,PTS
C
        CHI(I,J)=DX(I,ICT(J))*DY(I,ICT(J))*DEXP(-EXX(J)*R2(I,ICT(J)))
582     CONTINUE
580     CONTINUE
C
C       FOR Dxz-TYPE
C
        DO 620 J=ITP(8)+1,ITP(9)
        DO 622 I=1,PTS
C
        CHI(I,J)=DX(I,ICT(J))*DZ(I,ICT(J))*DEXP(-EXX(J)*R2(I,ICT(J)))
622     CONTINUE
620     CONTINUE
C
C       FOR Dyz-TYPE
C
        DO 640 J=ITP(9)+1,ITP(10)
        DO 642 I=1,PTS
C
        CHI(I,J)=DY(I,ICT(J))*DZ(I,ICT(J))*DEXP(-EXX(J)*R2(I,ICT(J)))
642     CONTINUE
640     CONTINUE
C
C     USE MATRIX MULTIPLICATION ROUTINE FOR STELLAR
C
C       CALL D$RMMULS$S(CHI,MPTS,COO,MPRIMS,PSI,MPTS,PTS,NMO,NPRIMS)
C
C
C     MATRIX-MATRIX MULTIPLICATION FOR CRAY AND RS6000 AND TRACE -
C     FOR RS6000 AND TRACE CALL dgemm INSTEAD OF sgemm
C 
      call dgemm ('n','n', pts, nmo, nprims, 1.0d0, chi, mpts, 
     1  coo, mprims, 0.d0, psi, mpts )
C
C     USE LOOPS BELOW IF NO MATRIX MULTIPLICATION ROUTINES AVAILABLE
C
C        DO 233 L=1,NMO
C        DO 234 I=1,PTS
C        PSI(I,L)=ZERO
C234     CONTINUE
C233     CONTINUE
C
C       DO 224 L = 1,NMO
C       DO 225 J = 1,NPRIMS
C       DO 226 I = 1,PTS
C         PSI(I,L) = PSI(I,L) + COO(J,L)*CHI(I,J)
C226      CONTINUE
C225      CONTINUE
C224      CONTINUE
C
999     RETURN
        END
      SUBROUTINE MAKNAME (I,STRING,L,EXT)
C
      CHARACTER*(*) STRING,EXT
      INTEGER I,J,L
C
      CALL GETARG (I,STRING)
C
      J=LEN(STRING)
C
      DO 10 N=1,J
         IF (STRING(N:N) .EQ. ' ') THEN
            L=N-1
            STRING=STRING(1:L)//EXT
            RETURN
         ENDIF
10    CONTINUE
      STOP 'Failed to make a filename.'
      RETURN 
      END 
        FUNCTION        NUMBER	(LINE, LPST, NUM, DEC)
C
C CONVERTS A CHARACTER STRING OF NUMBERS INTO ACTUAL NUMBERS EITHER
C INTEGERS OR DECIMAL MAY BE READ.
C NUMBER = 1 IF ALL THE REMAINING CHARACTERS ARE BLANK
C        = 2 IF CHARACTERS ARE NOT RECOGNISED AS A NUMBER, LPST IS RESET
C SKK ================================================================== SKK

        DOUBLE PRECISION DEC, TEN
        CHARACTER*(*)   LINE
        CHARACTER       BLANK, COMMA, DOT, MINUS, L
        CHARACTER       CTEN(0:9)
        DATA    CTEN    /'0','1','2','3','4','5','6','7','8','9'/
        PARAMETER       (BLANK = ' ', COMMA = ',')
        PARAMETER       (DOT   = '.', MINUS = '-')
        INTEGER         ITEN
        PARAMETER       (ITEN = 10, TEN = 10.0D0)
        NUM     = 0
        DEC     = 0.0D0
        NP      = 0
        ND      = 0
        MS      = 0
        NUMBER	= 0
        LPEND   = LEN (LINE)
5       IF (LINE(LPST:LPST) .EQ. BLANK) THEN
                LPST    = LPST + 1
                IF (LPST .GT. LPEND) THEN
                        NUMBER	= 1
                        RETURN
                END IF
                GOTO 5
        END IF
        LBEFOR  = LPST

        DO 1 I  = LBEFOR, LPEND
        LPST    = I
        L       = LINE(I:I)
        IF (L .EQ. BLANK .OR. L .EQ. COMMA) THEN
                GOTO 2
        ELSE IF (L .EQ. MINUS) THEN
                MS      = 1
                GOTO 1
        ELSE IF (L .EQ. DOT) THEN
                NP      = 1
                GOTO 1
        END IF
        DO 3 J  = 0, 9
        IF (L .EQ. CTEN(J)) THEN
                N       = J
                GOTO 4
        END IF
3       CONTINUE
        NUMBER	= 2
        LPST    = LBEFOR
        RETURN

4       IF (NP .EQ. 1) THEN
                ND      = ND + 1
                DEC     = DEC + DFLOAT(N)/TEN**ND
        ELSE
                NUM     = NUM*ITEN + N
        END IF
1       CONTINUE

2       DEC     = DFLOAT(NUM) + DEC
        IF (MS .EQ. 0) RETURN
        DEC     = -DEC
        NUM     = -NUM
        RETURN
        END
      SUBROUTINE PRODEL(XYZ,N,CUTOFF,EINCR,TITLE,LINE1,LINE2)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
      PARAMETER (MCENT=50, MMO=100, MPRIMS=700, MPTS=200)
C
      COMMON /ORBTL/ EORB(MMO),PO(MMO),NMO
      COMMON /ZZZZ/ PSI(MPTS,MMO),GX(MPTS,MMO),GY(MPTS,MMO),
     + GZ(MPTS,MMO),D2(MPTS,MMO)
C
      COMMON /UNITS/  IINP,IOUT,IWFN
C
      CHARACTER*80 LINE1,LINE2,TITLE
      REAL DELSQP(MPTS), RVECP(MPTS), ZDELSQ(MPTS) 
      DIMENSION  XYZ(MPTS,3), DELSQ(MPTS), RVEC(MPTS) 
C
C
      MM = 0
      NT = N+1
C
      CALL GAUS(XYZ,NT,MM)
C
      DO 120 I=1,NMO
       DO 110 J=1,NT
      DELSQ(J) = DELSQ(J)+2.0D0*PO(I)*(PSI(J,I)*D2(J,I)
     +           + (GX(J,I)**2 + GY(J,I)**2 + GZ(J,I)**2))
110   CONTINUE
120   CONTINUE
C
      RVEC(1) = 0.0D0
C
       DO 130 J=2,NT
        RVEC(J) = RVEC(J-1) + EINCR
130    CONTINUE
C
      DO 140 J=1,NT
       IF (DELSQ(J).GT. CUTOFF) THEN
       DELSQ(J) = CUTOFF
       ENDIF
       IF (DELSQ(J).LT. -CUTOFF) THEN
       DELSQ(J) = -CUTOFF
       ENDIF
140   CONTINUE
C
      DO 160 J = 1,NT
          DELSQP(J) = SNGL(DELSQ(J))
          RVECP(J) = SNGL(RVEC(J))
          ZDELSQ(J) = 0.0
160    CONTINUE
C
C
C     OUTPUT DISTANCES (RVECP) AND FUNCTION VALUES (DELSQP)
C     FOR EXTERNAL PLOTTING
C
      WRITE(IOUT,1000) TITLE
      WRITE(IOUT,1000) LINE1 
      WRITE(IOUT,1000) LINE2 
      WRITE(IOUT,1001)
      WRITE(IOUT,1002) (XYZ(J,1),XYZ(J,2),XYZ(J,3),
     +RVECP(J),DELSQP(J), J=1,NT)
1000  FORMAT(A80)
1001  FORMAT(/,5X,'X',9X,'Y',9X,'Z',9X,'DISTANCE',3X,'DELSQ RHO VAL' )
1002  FORMAT(3F10.6,2X,F10.6,4X,F10.6)
C
C
C
C        MULTIPLY THE VALUES OF DEL SQUARE RHO BY -1 SO THAT THE PLOT
C        AXES LOOK GOOD. (AXIS1N MULTIPLIES EACH TIC VALUE BY -1)
C
C      NEG = -1
C
C     DO 170 J = 1,NT
C         DELSQP(J) = SNGL((DELSQ(J)*NEG))
C         RVECP(J) = SNGL(RVEC(J))
C         ZDELSQ(J) = 0.0
C170    CONTINUE
C
C     CALL PLOTS(53,0,13)
C
C     CALL SCALE(RVECP,6.0,NT,1)
C     CALL AXIS1(1.5,0.5,1H ,-1,6.0,0.0,RVECP(NT+1),
C    +          RVECP(NT+2))
C
C     CALL SCALE(DELSQP,7.0,NT,1)
C     CALL AXIS1N(1.5,0.5,1H ,1,7.0,90.0,DELSQP(NT+1),
C    +          DELSQP(NT+2))
C
C
C     ZDELSQ(NT+1) = DELSQP(NT+1)
C     ZDELSQ(NT+2) = DELSQP(NT+2)
C
C     CALL ORIGIN(1.5,0.5,0)
C     CALL LINEP(RVECP,DELSQP,NT,1,0,2)
C
C
C   PLOT SYMBOL FOR DEL SQ RHO, R AND TITLE
C
C     CALL SYMBOL(-1.0,3.0,0.4,140,0.0,0)
C     CALL SYMBOL(-0.7,3.2,0.1,50,0.0,0)
C     CALL SYMBOL(-0.65,3.0,0.2,133,0.0,0)
C
C     CALL SYMBOL(3.0,-1.0,0.2,82,0.0,0)
C
C     CALL SYMBOL(1.5,7.2,0.15,TITLE,0.0,80)
C
C  DRAW ZERO LINE
C
C     CALL ORIGIN(1.5,0.5,0)
C     CALL LINEP(RVECP,ZDELSQ,NT,1,0,2)
C
C     CALL PLOT (0.,0.,999)
C
      RETURN
      END
      SUBROUTINE PRORHO(XYZ,N,CUTOFF,EINCR,TITLE,LINE1,LINE2)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
      PARAMETER (MCENT=50, MMO=100, MPRIMS=700, MPTS=200)
C
      COMMON /ORBTL/ EORB(MMO),PO(MMO),NMO
      COMMON /ZZZZ/ PSI(MPTS,MMO),GX(MPTS,MMO),GY(MPTS,MMO),
     + GZ(MPTS,MMO),D2(MPTS,MMO)
C
      COMMON /UNITS/  IINP,IOUT,IWFN
C
      CHARACTER*80 LINE1,LINE2,TITLE
      REAL RHOP(MPTS), RVECP(MPTS), ZRHO(MPTS) 
      DIMENSION  XYZ(MPTS,3), RHO(MPTS), RVEC(MPTS) 
C
      MM = 1
      NT = N+1
C
      CALL GAUS(XYZ,NT,MM)
C
      DO 120 I=1,NMO
       DO 110 J=1,NT
      RHO(J) = RHO(J) + PO(I)*PSI(J,I)*PSI(J,I)
110   CONTINUE
120   CONTINUE
C
      RVEC(1) = 0.0D0
C
       DO 130 J=2,NT
        RVEC(J) = RVEC(J-1) + EINCR
130    CONTINUE
C
      DO 140 J=1,NT
       IF (RHO(J).GT. CUTOFF) THEN
       RHO(J) = CUTOFF
       ENDIF
140   CONTINUE
C
      DO 160 J = 1,NT
          RHOP(J) = SNGL(RHO(J))
          RVECP(J) = SNGL(RVEC(J))
          ZRHO(J) = 0.0
160    CONTINUE
C
C     OUTPUT DISTANCES (RVECP) AND FUNCTION VALUES (RHOP)
C     FOR EXTERNAL PLOTTING
C
      WRITE(IOUT,1000) TITLE
      WRITE(IOUT,1000) LINE1 
      WRITE(IOUT,1000) LINE2 
      WRITE(IOUT,1001)
      WRITE(IOUT,1002) (XYZ(J,1),XYZ(J,2),XYZ(J,3),
     +RVECP(J),RHOP(J), J=1,NT)
1000  FORMAT(A80)
1001  FORMAT(/,5X,'X',9X,'Y',9X,'Z',9X,'DISTANCE',4X,' RHO VAL' )
1002  FORMAT(3F10.6,2X,F10.6,4X,F10.6)
C
C
C     CALL PLOTS(53,0,13)
C
C     CALL SCALE(RVECP,6.0,NT,1)
C     CALL AXIS1(1.5,0.5,1H ,-1,6.0,0.0,RVECP(NT+1),
C    +          RVECP(NT+2))
C
C     CALL SCALE(RHOP,7.0,NT,1)
C     CALL AXIS1(1.5,0.5,1H ,1,7.0,90.0,RHOP(NT+1),
C    +          RHOP(NT+2))
C
C
C     ZRHO(NT+1) = RHOP(NT+1)
C     ZRHO(NT+2) = RHOP(NT+2)
C
C     CALL ORIGIN(1.5,0.5,0)
C     CALL LINEP(RVECP,RHOP,NT,1,0,2)
C
C
C   PLOT SYMBOL FOR RHO, R AND TITLE
C
C     CALL SYMBOL(-1.0,3.0,0.4,140,0.0,0)
C     CALL SYMBOL(-0.7,3.2,0.1,50,0.0,0)
C     CALL SYMBOL(-0.65,3.0,0.2,133,0.0,0)
C
C     CALL SYMBOL(3.0,-1.0,0.2,82,0.0,0)
C
C     CALL SYMBOL(1.5,7.2,0.15,TITLE,0.0,80)
C
C  DRAW ZERO LINE
C
C     CALL ORIGIN(1.5,0.5,0)
C     CALL LINEP(RVECP,ZRHO,NT,1,0,2)
C
C     CALL PLOT (0.,0.,999)
C
      RETURN
      END
      SUBROUTINE RDPSI
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
C  RDPSI READS AIMPAC WAVEFUNCTION FILE.  
C
C   INPUT CONSISTS OF;
C     MODE   - WAVEFUNCTION TYPE (SLATER OR GAUSSIAN)
C     NMO    - NO. OF MOLECULAR ORBITALS
C     NPRIMS - NO. OF (PRIMITIVE) BASIS FUNCTIONS
C     NCENT  - NO. OF NUCLEI
C
C  THEN FOR EACH NUCLEUS;
C     XC/YC/ZC   - COORDINATES
C     CHARG      - ATOMIC NUMBER
C
C  AND FOR EACH BASIS FUNCTION;
C     ICENT  - THE NO. OF THE NUCLEUS ON WHICH IT IS CENTERED
C     ITYPE  - FUNCTION TYPE (SEE ARRAYS LABELS AND LABELG)
C     EX     - EXPONENT
C
C  AND FOR EACH MOLECULAR ORBITAL;
C     PO    - OCCUPATION NUMBER
C     EORB  - ORBITAL ENERGY
C     CO    - COEFFICIENTS OF PRIMITIVE BASIS FUNCTIONS  
C             INCLUDING ALL NORMALIZATION AND CONTRACTION COEFFICIENTS
C
C  FOLOWED BY;
C     TOTE  - MOLECULAR ENERGY
C     GAMMA - VIRIAL RATIO (V/T)
C
      CHARACTER*80 WFNTTL,JOBTTL,LINE
      CHARACTER*8 ATNAM
C
      PARAMETER (MCENT=50, MMO=100, MPRIMS=700, MPTS=200)
C
      COMMON /ATOMS/ XC(MCENT),YC(MCENT),ZC(MCENT),CHARG(MCENT),NCENT
      COMMON /ORBTL/ EORB(MMO),PO(MMO),NMO
      COMMON /PRIMS/ COO(MPRIMS,MMO),EXX(MPRIMS),ICT(MPRIMS),
     +       SUM(MPRIMS),ITP(10),NPRIMS,DIV(MPRIMS)
C
      COMMON /STRING/ WFNTTL,JOBTTL,ATNAM(MCENT),NAT
      COMMON /VALUES/ THRESH1,THRESH2,GAMMA,TOTE
      COMMON /UNITS/ INPT,IOUT,IWFN,IDBG
C
      DIMENSION ITYPE(MPRIMS),CO(MPRIMS,MMO)
      DIMENSION ICENT(MPRIMS),EX(MPRIMS)
C
C    THE ITYPE ARRAY REPRESENTS THE FOLLOWING GAUSSIAN ORBITAL TYPES:
C     S
C     PX, PY, PZ 
C     DXX, DYY, DZZ, DXY, DXZ, DYZ
C     FXXX, FYYY, FZZZ, FXXY, FXXZ, FYYZ, FXYY, FXZZ, FYZZ, FXYZ
C
C    READ IN WAVEFUNCTION TITLE
C
      READ(IWFN,101) WFNTTL
C
C    READ IN MODE, NUMBER OF MOLECULAR ORBITALS, NUMBER OF PRIMITIVES,
C    AND NUMBER OF ATOMIC CENTERS
C
      READ(IWFN,102) MODE,NMO,NPRIMS,NCENT
C
      IF (NMO .GT. MMO) STOP 'Too many MOs'
      IF (NPRIMS .GT. MPRIMS) STOP 'Too many primitives'
      IF (NCENT .GT. MCENT) STOP 'Too many nuclei'
C    READ IN ATOM NAMES, CARTESIAN COORDINATES, AND NUMBER OF
C    ELECTRONS PER ATOM
C
      DO 100 I = 1,NCENT
        READ(IWFN,103) ATNAM(I),J,XC(J),YC(J),ZC(J),CHARG(J)
100   CONTINUE
C
C    READ IN FUNCTION CENTERS, FUNCTION TYPES, AND EXPONENTS
C
      READ(IWFN,104) (ICENT(I),I=1,NPRIMS)
      READ(IWFN,104) (ITYPE(I),I=1,NPRIMS)
      READ(IWFN,105) (EX(I),I=1,NPRIMS)
C
C    LOOP OVER MOLECULAR ORBITALS READING ORBITAL OCCUPANICES,
C    ORBITAL ENERGIES, AND COEFFICIENTS
C
      DO 110 I = 1,NMO
        READ(IWFN,106) PO(I),EORB(I)
        READ(IWFN,107) (CO(J,I),J=1,NPRIMS)
110   CONTINUE
C
      READ(IWFN,101) LINE
C
C    READ IN ENERGY AND -(V/T), THE VIRIAL RATIO
C
      READ(IWFN,109) TOTE,GAMMA
C
      N=0
      DO 160 K=1,10
      DO 170 J=1,NPRIMS
      IF(ITYPE(J).EQ.K) THEN
      N=N+1
      EXX(N)=EX(J)
      ICT(N)=ICENT(J)
      SUM(N)=-2.0*EX(J)
      DIV(N)=1./SUM(N)
      DO 180 L=1,NMO
      COO(N,L)=CO(J,L)
180   CONTINUE
      ENDIF
170   CONTINUE
      ITP(K)=N
160   CONTINUE 
C
      RETURN
C    FORMATS
C
101   FORMAT (A80)
102   FORMAT (4X,A4,12X,3(I3,17X))
103   FORMAT (A8,11X,I3,2X,3F12.8,10X,F5.1)
104   FORMAT (20X,20I3)
105   FORMAT (10X,5E14.7)
106   FORMAT (35X,F12.8,15X,F12.8)
107   FORMAT (5E16.8)
109   FORMAT (17X,F20.12,18X,F13.8)
      END


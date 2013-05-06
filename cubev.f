      PROGRAM CUBEV
C
C    VERSION 94 Revision A
C
C    CUBEV CUTS A CUBE FROM THREE SPACE AND CALCUALTES
C    THE DESIRED FUNCTION AT POINTS IN THE CUBE.
C    THE POSSIBLE FUNCTIONS ARE:
C
C    1   RHO
C    2   DEL**2(RHO)
C    3   G, A KINETIC ENERGY DENSITY
C
C     CUBE TO CUBEV  APRIL 1992 JAMES R. CHEESEMAN
C
C     CLEANED UP, KINETIC ENERGY DENSITY ADDED, F-FUnctions
C     Added  TAK Jan. 1994
C
C     TO REDIMENSION CUBEV TO HANDLE MORE MO's, PRIMITIVES AND NUCLEI
C     CHANGE THE VALUES MMO, MPRIMS AND MCENT IN THE PARAMETER
C     STATEMENTS.  TO HANDLE LARGER CUBES, CHANGE THE PARAMETER MPTS.
C
C     To create a 100X100X100 cube of rho values about the origin in 
C     the frame of the wavefunction with X,Y, And Z axes defined as 
C     in the wavefunction, the input file (c4h4.inf) for a c4h4 job, for 
C     example, would look like:
C
C     TITLE: C4H4 6-31G** CUBE
C     PLOT:  10.0 0.1
C     CENTR:  0. 0. 0.
C     PLANE:  1 0. 0. 0.
C     FUNC:   1
C
C     To run:   cubev c4h4 c4h4
C
C     where the first argument corresponds to the input file (c4h4.inf)
C     and the second to the wavefunction file (c4h4.wfn)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)                               
      PARAMETER (MCENT=50)
      CHARACTER*80 WFNTTL,LINE,JOBTTL
      CHARACTER*8 ATNAM,WORD
      CHARACTER*40 WINP,WOUT,WFN
      CHARACTER*4 FINP, FOUT, FWFN
      PARAMETER(FINP='.inf', FOUT='.qub', FWFN='.wfn') 
      COMMON /ATOMS/ XC(MCENT),YC(MCENT),ZC(MCENT),CHARG(MCENT),NCENT
      COMMON /STRING/ WFNTTL,JOBTTL,ATNAM(MCENT),NAT
      COMMON /UNITS/ INPT,IOUT,IWFN,IDBG
      COMMON /VALUES/ THRESH1,THRESH2,GAMMA,TOTE
      DIMENSION A(3,3),IR(MCENT),CX(3),E(3),CT(3),XS(3,MCENT),
     $          X(3,MCENT),XY(4)                          
      DATA ISRF /2/, INPT /20/, IOUT /30/, IWFN /10/, IDBG /13/
C
      CALL MAKNAME(1,WINP,ILEN,FINP)
      IF (ILEN .EQ. 0) STOP 'usage: cube inffile wfnfile '
      CALL MAKNAME(2,WFN,ILEN,FWFN)
      IF (ILEN .EQ. 0) STOP 'usage: cube inffile wfnfile '
      CALL MAKNAME(1,WOUT,ILEN,FOUT)
C
      OPEN (INPT,FILE=WINP)
      OPEN (IOUT,FILE=WOUT)
      OPEN (IWFN,FILE=WFN)
C
C    READ WAVEFUNCTION FILE
C
      CALL RDPSI
C
C    INPUT PARAMETERS FOR CUBEV:
C
C    READS ARE DONE USING THE FUNCTION NUMBER UPON THE
C    INPUT STRING.  LPST IS THE POSITION FROM WHICH THE READ
C    IS DONE.  IT'S VALUE IS UPDATED ONCE THE STRING IS FOUND.
C    THE NUMBER IF RETURNED BOTH AS AN INTEGER (INUM) AND
C    REAL*8 (DNUM).  ONE NEED MERELY REPLACE INUM OR DNUM WITH
C    THE VARIABLE DESIRED TO BE READ.  THE FUNCTION RETURNS A
C    VALUE OF ZERO IF SUCCESFULL FINDING THE STRING OF INTEREST
C    AND A VALUE OF ONE IF AN ERROR CONDITION OCCURED.
C
C             NUMBER(STRING,LPST,INUM,DNUM)
C
C     UNFORMATTED READ CODE IS DUE TO DR. SIMON K KEARSLEY
C
C    TTLE:
      READ(INPT,1600) TITLE                                               
C
C    PLOT:   INPUT CUBE EDGE SIZE (IN AU) AND INCREMENT.  THIS
C    EFFECTIVELY DESCIBES THE COARSENESS OF THE CUBE.  THE
C    SAMPLING IS DONE AT (XY(1)/XY(2))**3) POINTS ON AND WITHIN
C    THE CUBE.
C
      READ (20,200) LINE                                                
      LPST = 8                                                          
      DO 100 I = 1,2                                                    
      IF (NUMBER(LINE,LPST,NUM,XY(I)) .GT. 0) GOTO 990                  
100   CONTINUE                                                          
C
C    CNTR:   DEFINE CENTER OF CUBE
C
      READ (20,200) LINE                                                
      LPST = 8                                                          
      DO 110 I = 1,3                                                    
      IF (NUMBER(LINE,LPST,NUM,CX(I)) .GT. 0) GOTO 992                  
110   CONTINUE                                                          
C
C    PLANE:  DEFINE ORIENTATION OF CUBE AROUND CENTER BY ROTATING A
C    PLANE INTO THE XY PLANE AND THEN (IF EULER ANGLES ARE USED) ROTATING 
C    ABOUT THE XY PLANE.  THE REQUIRED ROTATION MATRIX IS GENERATED 
C    BY FINDING THE INERTIAL AXIS OF THE ATOMS INPUT IN IR.  TO DEFINE 
C    THE PLANE OF INTEREST, ONE NEED ONLY INCLUDE THOSE ATOMS THAT DEFINE
C    THE PLANE.  IF THE PLANE IS DEFINED BY MORE THAN THREE ATOMS, IT 
C    IS BEST TO USE DUMMY ATOM INPUT.  TO USE A DUMMY ATOM, INPUT A 
C    NEGATIVE INTEGER INTO IR.  THE ABSOLUTE VALUE OF THE INTEGER WILL 
C    DESCRIBE WHICH OF THE FOLLOWING DUMMY LINES CORRESPONDS TO THE 
C    DESCRIBED ATOM.  
 
C    MORE THAN THREE ATOMS OR DUMMY ATOMS CAN BE INPUT IF
C    DESIRED, BUT IT IS RARELY NECESSARY...
C    CODE FOR GENERATION OF INERTIAL AXIS IS DUE TO DR. SIMON K
C    KEARSLEY
C
      READ (20,200) LINE                                                
      LPST = 8                                                          
      IF (NUMBER(LINE,LPST,IEG,DNUM) .GT. 0) GOTO 1100
      IF (IEG .EQ. 0) THEN
      J = 1                                                             
120   IF (NUMBER(LINE,LPST,IR(J),DNUM) .GT. 0) GOTO 10                  
      J = J + 1                                                         
      GOTO 120                                                          
C
C    DECIDE IF DUMMY ATOMS WERE USED AND THEN READ IN THEIR
C    COORDINATES TO XS(3,N)
C
10    DO 130 I = 1,J                                                    
      IF (IR(I) .LT. 0) THEN                                            
      LPST = 8                                                          
      READ (20,200) LINE                                                
      DO 140 K = 1,3                                                    
      IF (NUMBER(LINE,LPST,NUM,XS(K,ABS(IR(I)))) .GT. 0) GOTO 996       
140   CONTINUE                                                          
      END IF                                                            
130   CONTINUE                                                          
C
C    GENERATE REQUIRED ROTATION MATRIX
C
      DO 160 J = 1,NCENT                                                
        X(1,J) = XC(J)                                              
        X(2,J) = YC(J)                                             
        X(3,J) = ZC(J)                                             
160   CONTINUE                                                          
C
      CALL GROCKLE(NCENT,X,IR,XS,A)
C
      ELSE IF (IEG .EQ. 1) THEN
C
      DO 170 J = 1,3
        IF (NUMBER(LINE,LPST,NUM,E(J)) .GT. 0) GOTO 1110
170   CONTINUE
C
C     If euler angles are used to define the orientation of the cube:
C     the first angle is the rotation about the molecular z-axis.  The
C     second angle is rotation about the molecular x-axis.  The third
C     angle is the rotation about the axis perpendicular to the resulting
C     XY plane.
C     
      CALL EULER (E,A)
C
      END IF
C
C    READ IN DESIRED FUNCTION 
C
      LPST = 8
      READ (20,200) LINE
      IF (NUMBER(LINE,LPST,IFUNC,DNUM) .GT. 0) GOTO 998
C
C   CALL ROUTINE TO CALCULATE DESIRED FUNCTION
C
      NX=IDINT(XY(1)/XY(2))
      WRITE (IOUT,*) NX,NX,NX
C
      IF(IFUNC .EQ. 1) 
     +   CALL CUBRHO (A,CX,XY)
C
      IF(IFUNC .EQ. 2) 
     +   CALL CUBD2R (A,CX,XY)
C
      IF(IFUNC .EQ. 3) 
     +   CALL CUBKEG (A,CX,XY)
C
      STOP                                                              
C
C  INPUT ERROR CODES
990   WRITE (6,991)                                                     
991   FORMAT(' ERROR IN PLOT ATTRIBUTES CARD ')                         
      GOTO 1010                                                         
992   WRITE (6,993)                                                     
993   FORMAT(' ERROR IN PLOT CENTER CARD ')                             
      GOTO 1010                                                         
994   WRITE (6,995)                                                     
995   FORMAT(' ERROR IN ATOMS THAT DEFINE PLANE ')                      
      GOTO 1010                                                         
996   WRITE (6,997)                                                     
997   FORMAT(' ERROR IN DUMMY ATOM INPUT CARD ')                        
      GOTO 1010                                                         
998   WRITE (6,999)                                                     
999   FORMAT(' ERROR IN FUNCTION INPUT CARD ')                          
      GOTO 1010
1100  WRITE (6,1105)
1105  FORMAT(' ERROR IN CHOICE OF ORIENTATION PROCEDURE ')
      GOTO 1010
1110  WRITE (6,1115)
1115  FORMAT(' ERROR IN EULER ANGLE ')
1010  STOP                                                              
C
C  FORMATS
  200 FORMAT(A80)                                                       
 1600 FORMAT(7X,A70)                                                    
      END
      SUBROUTINE CUBD2R(A,CX,XY)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (MCENT=50, MMO=100, MPRIMS=400, MPTS=400)
      COMMON /ATOMS/ XC(MCENT),YC(MCENT),ZC(MCENT),CHARG(MCENT),NCENT
      COMMON /ORBTL/ EORB(MMO),PO(MMO),NMO
       COMMON /ZZZZ/ PSI(MPTS,MMO),GX(MPTS,MMO),GY(MPTS,MMO),
     + GZ(MPTS,MMO),D2(MPTS,MMO)
      COMMON /UNITS/ INPT,IOUT,IWFN,IDBG
      DIMENSION A(3,3),CX(3),XY(4),XYZ(MPTS,3),SUMR(MPTS)
      Save Zero,Two
      Data Zero/0.0d0/,Two/2.0d0/
C
C    CALCULATE NUMBER OF STEPS IN X,Y AND Z FOR THIS CUBE AS WELL AS
C    INCREMENT MARKERS FOR CENTERING PLOT
C
      IXSTP = IDINT(XY(1)/XY(2))
      IYSTP = IXSTP
      IZSTP = IXSTP
      XCN = -XY(1)/Two
      YCN = XCN
      ZCN = XCN
      ZCNT = ZCN
C
      DO 1500 IZ = 1,IZSTP 
C
C    RESET Y INCREMENT
C
      YCNT = YCN 
C
      DO 1400 IY = 1,IYSTP
C
C    RESET X INCREMENT
C
        XCNT = XCN
C
        DO 1300 I = 1,IXSTP
C
          SUMR(I)=Zero
C     BACK TRANSFORM PLANE INTO ORIGINAL MOLECULAR SYSTEM
C
          XYZ(I,1)=A(1,1)*XCNT+A(1,2)*YCNT+A(1,3)*ZCNT+CX(1)
          XYZ(I,2)=A(2,1)*XCNT+A(2,2)*YCNT+A(2,3)*ZCNT+CX(2)
          XYZ(I,3)=A(3,1)*XCNT+A(3,2)*YCNT+A(3,3)*ZCNT+CX(3)
C
        XCNT=XCNT+XY(2)
1300    CONTINUE
C
       CALL GAUS(XYZ,IXSTP,0)
C
        DO 904 J=1,NMO
        DO 905 I = 1,IXSTP
        SUMR(I)=SUMR(I)+Two*PO(J)*(PSI(I,J)*D2(I,J)
     +          +(GX(I,J)**2+GY(I,J)**2+GZ(I,J)**2))
905     CONTINUE
904     CONTINUE
C
        Write(Iout,*) (SNGL(SUMR(I)),I=1,ixstp)
C
C    INCREMENT Y VALUE
C
        YCNT=YCNT+XY(2)
C
1400  CONTINUE
C
C    INCREMENT Z VALUE
C
	ZCNT=ZCNT+XY(2)
C
1500    CONTINUE
C
      RETURN 
      END
      SUBROUTINE CUBKEG(A,CX,XY)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (MCENT=50, MMO=100, MPRIMS=400, MPTS=400)
      COMMON /ATOMS/ XC(MCENT),YC(MCENT),ZC(MCENT),CHARG(MCENT),NCENT
      COMMON /ORBTL/ EORB(MMO),PO(MMO),NMO
       COMMON /ZZZZ/ PSI(MPTS,MMO),GX(MPTS,MMO),GY(MPTS,MMO),
     + GZ(MPTS,MMO),D2(MPTS,MMO)
      COMMON /UNITS/ INPT,IOUT,IWFN,IDBG
      DIMENSION A(3,3),CX(3),XY(4),XYZ(MPTS,3),SUMR(MPTS)
      Save Zero,Two,pt5
      Data Zero/0.0d0/,Two/2.0d0/,pt5/0.5d0/
C
C    CALCULATE NUMBER OF STEPS IN X,Y AND Z FOR THIS CUBE AS WELL AS
C    INCREMENT MARKERS FOR CENTERING PLOT
C
      IXSTP = IDINT(XY(1)/XY(2))
      IYSTP = IXSTP
      IZSTP = IXSTP
      XCN = -XY(1)/Two
      YCN = XCN
      ZCN = XCN
      ZCNT = ZCN
C
      DO 1500 IZ = 1,IZSTP 
C
C    RESET Y INCREMENT
C
      YCNT = YCN 
C
      DO 1400 IY = 1,IYSTP
C
C    RESET X INCREMENT
C
        XCNT = XCN
C
        DO 1300 I = 1,IXSTP
C
          SUMR(I)=Zero
C     BACK TRANSFORM PLANE INTO ORIGINAL MOLECULAR SYSTEM
C
          XYZ(I,1)=A(1,1)*XCNT+A(1,2)*YCNT+A(1,3)*ZCNT+CX(1)
          XYZ(I,2)=A(2,1)*XCNT+A(2,2)*YCNT+A(2,3)*ZCNT+CX(2)
          XYZ(I,3)=A(3,1)*XCNT+A(3,2)*YCNT+A(3,3)*ZCNT+CX(3)
C
        XCNT=XCNT+XY(2)
1300    CONTINUE
C
       CALL GAUS(XYZ,IXSTP,0)
C
        DO 904 J=1,NMO
        DO 905 I = 1,IXSTP
        SUMR(I)=SUMR(I)+PT5*PO(J)*(GX(I,J)**2+GY(I,J)**2+GZ(I,J)**2)
905     CONTINUE
904     CONTINUE
C
        Write(Iout,*) (SNGL(SUMR(I)),I=1,ixstp)
C
C    INCREMENT Y VALUE
C
        YCNT=YCNT+XY(2)
C
1400  CONTINUE
C
C    INCREMENT Z VALUE
C
	ZCNT=ZCNT+XY(2)
C
1500    CONTINUE
C
      RETURN 
      END
      SUBROUTINE CUBRHO (A,CX,XY)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (MCENT=50, MMO=100, MPRIMS=400, MPTS=400)
      COMMON /ATOMS/ XC(MCENT),YC(MCENT),ZC(MCENT),CHARG(MCENT),NCENT
      COMMON /ORBTL/ EORB(MMO),PO(MMO),NMO
       COMMON /ZZZZ/ PSI(MPTS,MMO),GX(MPTS,MMO),GY(MPTS,MMO),
     + GZ(MPTS,MMO),D2(MPTS,MMO)
      COMMON /UNITS/ INPT,IOUT,IWFN,IDBG
      DIMENSION A(3,3),CX(3),XY(4),XYZ(MPTS,3),SUMR(MPTS)
      save zero,two
      DATA Zero/0.0d0/,Two/2.0d0/
C
C    CALCULATE NUMBER OF STEPS IN X,Y AND Z FOR THIS CUBE AS WELL AS
C    INCREMENT MARKERS FOR CENTERING PLOT
C
      IXSTP = IDINT(XY(1)/XY(2))
      IYSTP = IXSTP
      IZSTP = IXSTP
      XCN = -XY(1)/TWO
      YCN = XCN
      ZCN = XCN
      ZCNT = ZCN
C
      DO 1500 IZ = 1,IZSTP 
C
C    RESET Y INCREMENT
C
      YCNT = YCN 
C
      DO 1400 IY = 1,IYSTP
C
C    RESET X INCREMENT
C
        XCNT = XCN
C
        DO 1300 I = 1,IXSTP
C
          SUMR(I)=Zero
C     BACK TRANSFORM PLANE INTO ORIGINAL MOLECULAR SYSTEM
C
          XYZ(I,1)=A(1,1)*XCNT+A(1,2)*YCNT+A(1,3)*ZCNT+CX(1)
          XYZ(I,2)=A(2,1)*XCNT+A(2,2)*YCNT+A(2,3)*ZCNT+CX(2)
          XYZ(I,3)=A(3,1)*XCNT+A(3,2)*YCNT+A(3,3)*ZCNT+CX(3)
C
        XCNT=XCNT+XY(2)
1300    CONTINUE
C
       CALL GAUS(XYZ,IXSTP,1)
C
C
        DO 904 J=1,NMO
        DO 905 I = 1,IXSTP
          SUMR(I)=SUMR(I)+PO(J)*PSI(I,J)*PSI(I,J)
905     CONTINUE
904     CONTINUE
C
        WRITE(IOUT,*)(SNGL(SUMR(I)),I=1,IXSTP)
C
C    INCREMENT Y VALUE
C
        YCNT=YCNT+XY(2)
C
1400  CONTINUE
C
C    INCREMENT Z VALUE
C
	ZCNT=ZCNT+XY(2)
C
1500    CONTINUE
C
      RETURN 
      END
      SUBROUTINE EULER (E,A)
C 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C 
C    CALCULATE THE ROTATION MATRICES FOR TRANSFORMATIONS 
C    BETWEEN THE X"Y" PLANE AND THE MOLECULAR COORDINATE 
C    SYSTEM.
C
      DIMENSION E(3), A(9)
C
      Save One,Two
      DATA One/1.0d0/,Two/2.0d0/
C
      Pi=Dacos(-one)
      radian=Two*pi/360
C
      E1 = E(1)*RADIAN
      E2 = E(2)*RADIAN
      E3 = E(3)*RADIAN
C
      SA = DSIN(E1)
      SB = DSIN(E2)
      SC = DSIN(E3)
      CA = DCOS(E1)
      CB = DCOS(E2)
      CC = DCOS(E3)
C
      A(1) =  CC*CA - CB*SA*SC
      A(2) =  CC*SA + CB*CA*SC
      A(3) =  SC*SB
      A(4) = -SC*CA - CB*SA*CC
      A(5) = -SC*SA + CB*CA*CC
      A(6) =  CC*SB
      A(7) =  SB*SA
      A(8) = -SB*CA
      A(9) =  CB
C
      RETURN
      END
      SUBROUTINE GAUS(XYZ,PTS,MM)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
      DOUBLE PRECISION NINE
      INTEGER PTS
      PARAMETER(MCENT=50,MMO=100,MPRIMS=400,MPTS=400,NTYPE=20)
      COMMON /ATOMS/ XC(MCENT),YC(MCENT),ZC(MCENT),CHARG(MCENT),NCENT
      COMMON /ORBTL/ EORB(MMO),PO(MMO),NMO
      COMMON /PRIMS/ DIV(MPRIMS),COO(MPRIMS,MMO),EXX(MPRIMS),
     +ICT(MPRIMS),SUM(MPRIMS),ITP(NTYPE),NPRIMS
      COMMON /ZZZZ/ PSI(MPTS,MMO),GX(MPTS,MMO),GY(MPTS,MMO),
     +GZ(MPTS,MMO),D2(MPTS,MMO)
      DIMENSION XYZ(MPTS,3),DX(MPTS,MCENT),DY(MPTS,MCENT),
     +DZ(MPTS,MCENT),R2(MPTS,MCENT),CHI(MPTS,MPRIMS),
     +CHIX(MPTS,MPRIMS),CHIY(MPTS,MPRIMS),CHIZ(MPTS,MPRIMS),
     +CHID2(MPTS,MPRIMS),CHIMAX(MPRIMS)
      Save zero,one,two,four,five,seven,three,six,nine,cutoff
      DATA ZERO /0.D0/,ONE/1.D0/,TWO/2.D0/,FOUR/4.D0/,FIVE/5.D0/,
     +SEVEN/7.D0/,THREE/3.D0/,SIX/6.D0/,NINE/9.D0/,CUTOFF/1.0d-10/
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
C       FOR S-TYPE
C
        DO 120 J = 1,ITP(1) 
        IS=ict(j)
        DO 122 I=1,PTS 
        A=SUM(J)*DEXP(-EXX(J)*R2(I,is))
        CHI(I,J)=A*DIV(J)
        CHIX(I,J)=DX(I,is)*A
        CHIY(I,J)=DY(I,is)*A
        CHIZ(I,J)=DZ(I,is)*A
        CHID2(I,J)=(THREE+SUM(J)*R2(I,is))*A
122     CONTINUE
120     CONTINUE
C
C       FOR Px-TYPE
C
        DO 140 J=ITP(1)+1,ITP(2)
        IS=ict(j)
        DO 142 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        B=DX(I,is)*A*SUM(J)
C
        CHI(I,J)=A*DX(I,is)
        CHIX(I,J)=A+DX(I,is)*B
        CHIY(I,J)=DY(I,is)*B
        CHIZ(I,J)=DZ(I,is)*B
        CHID2(I,J)=(FIVE+SUM(J)*R2(I,is))*B
142     CONTINUE
140     CONTINUE
C
C       FOR Py-TYPE
C
        DO 160 J=ITP(2)+1,ITP(3)
        IS=ict(j)
        DO 162 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        B=DY(I,is)*A*SUM(J)
C
        CHI(I,J)=A*DY(I,is)
        CHIX(I,J)=DX(I,is)*B
        CHIY(I,J)=A+DY(I,is)*B
        CHIZ(I,J)=DZ(I,is)*B
        CHID2(I,J)=(FIVE+SUM(J)*R2(I,is))*B
162     CONTINUE
160     CONTINUE
C
C       FOR Pz-TYPE
C
        DO 180 J=ITP(3)+1,ITP(4)
        IS=ict(j)
        DO 182 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        B=DZ(I,is)*A*SUM(J)
C
        CHI(I,J)=A*DZ(I,is)
        CHIX(I,J)=DX(I,is)*B
        CHIY(I,J)=DY(I,is)*B
        CHIZ(I,J)=A+DZ(I,is)*B
        CHID2(I,J)=(FIVE+SUM(J)*R2(I,is))*B
182     CONTINUE
180     CONTINUE
C
C       FOR Dxx-TYPE
C
        DO 220 J=ITP(4)+1,ITP(5)
        IS=ict(j)
        DO 222 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        B=DX(I,is)*DX(I,is)*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=(TWO*A+B)*DX(I,is)
        CHIY(I,J)=DY(I,is)*B
        CHIZ(I,J)=DZ(I,is)*B
        CHID2(I,J)=TWO*A+(SEVEN+SUM(J)*R2(I,is))*B
222     CONTINUE
220     CONTINUE
C
C       FOR Dyy-TYPE
C
        DO 240 J=ITP(5)+1,ITP(6)
        IS=ict(j)
        DO 242 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        B=DY(I,is)*DY(I,is)*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=DX(I,is)*B
        CHIY(I,J)=(TWO*A+B)*DY(I,is)
        CHIZ(I,J)=DZ(I,is)*B
        CHID2(I,J)=TWO*A+(SEVEN+SUM(J)*R2(I,is))*B
242     CONTINUE
240     CONTINUE
C
C       FOR Dzz-TYPE
C
        DO 260 J=ITP(6)+1,ITP(7)
        IS=ict(j)
        DO 262 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        B=DZ(I,is)*DZ(I,is)*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=DX(I,is)*B
        CHIY(I,J)=DY(I,is)*B
        CHIZ(I,J)=(TWO*A+B)*DZ(I,is)
        CHID2(I,J)=TWO*A+(SEVEN+SUM(J)*R2(I,is))*B
262     CONTINUE
260     CONTINUE
C
C       FOR Dxy-TYPE
C
        DO 280 J=ITP(7)+1,ITP(8)
        IS=ict(j)
        DO 282 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        B=DX(I,is)*DY(I,is)*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=DX(I,is)*B+DY(I,is)*A
        CHIY(I,J)=DY(I,is)*B+DX(I,is)*A
        CHIZ(I,J)=DZ(I,is)*B
        CHID2(I,J)=(SEVEN+SUM(J)*R2(I,is))*B
282     CONTINUE
280     CONTINUE
C
C       FOR Dxz-TYPE
C
        DO 320 J=ITP(8)+1,ITP(9)
        IS=ict(j)
        DO 322 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        B=DX(I,is)*DZ(I,is)*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=DX(I,is)*B+DZ(I,is)*A
        CHIY(I,J)=DY(I,is)*B
        CHIZ(I,J)=DZ(I,is)*B+DX(I,is)*A
        CHID2(I,J)=(SEVEN+SUM(J)*R2(I,is))*B
322     CONTINUE
320     CONTINUE
C
C       FOR Dyz-TYPE
C
        DO 340 J=ITP(9)+1,ITP(10)
        IS=ict(j)
        DO 342 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        B=DY(I,is)*DZ(I,is)*A*SUM(J)
C
        CHI(I,J)=B*DIV(J)
        CHIX(I,J)=DX(I,is)*B
        CHIY(I,J)=DY(I,is)*B+DZ(I,is)*A
        CHIZ(I,J)=DZ(I,is)*B+DY(I,is)*A
        CHID2(I,J)=(SEVEN+SUM(J)*R2(I,is))*B
342     CONTINUE
340     CONTINUE
C
C       FOR Fxxx-TYPE
C
        DO 501 J=ITP(10)+1,ITP(11)
        IS=ict(j)
        DO 502 I=1,PTS
 
        A=DEXP(-EXX(J)*R2(I,is))
        B=DX(I,is)*DX(I,is)*A
C
        CHI(I,J)=B*DX(I,is)
        CHIX(I,J)=(THREE + SUM(J)*DX(I,is)*DX(I,is))*B
        CHIY(I,J)=SUM(J)*DY(I,is)*CHI(I,J)
        CHIZ(I,J)=SUM(J)*DZ(I,is)*CHI(I,J)
        CHID2(I,J)=SIX*A*DX(I,is)+
     1             (NINE+SUM(J)*R2(I,is))*CHI(I,J)*SUM(J)
 502    CONTINUE
 501    CONTINUE
C
C       FOR Fyyy-TYPE
C
        DO 511 J=ITP(11)+1,ITP(12)
        IS=ict(j)
        DO 512 I=1,PTS
        A=DEXP(-EXX(J)*R2(I,is))
        B=DY(I,is)*DY(I,is)*A
C
        CHI(I,J)=B*DY(I,is)
        CHIX(I,J)=SUM(J)*DX(I,is)*CHI(I,J)
        CHIY(I,J)=(THREE + SUM(J)*DY(I,is)*DY(I,is))*B
        CHIZ(I,J)=SUM(J)*DZ(I,is)*CHI(I,J)
        CHID2(I,J)=SIX*A*DY(I,is)+
     1             (NINE+SUM(J)*R2(I,is))*CHI(I,J)*SUM(J)
C
 512    CONTINUE
 511    CONTINUE
C
C       FOR Fzzz-TYPE
C
        DO 521 J=ITP(12)+1,ITP(13)
        IS=ict(j)
        DO 523 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        B=DZ(I,is)*DZ(I,is)*A
C
        CHI(I,J)=B*DZ(I,is)
        CHIX(I,J)=SUM(J)*DX(I,is)*CHI(I,J)
        CHIY(I,J)=SUM(J)*DY(I,is)*CHI(I,J)
        CHIZ(I,J)=(THREE + SUM(J)*DZ(I,is)*DZ(I,is))*B
        CHID2(I,J)=SIX*A*DZ(I,is)+
     1             (NINE+SUM(J)*R2(I,is))*CHI(I,J)*SUM(J)
C
 523    CONTINUE
 521    CONTINUE
C
C       FOR Fxxy-TYPE
C
        DO 531 J=ITP(13)+1,ITP(14)
        IS=ict(j)
        DO 532 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        BXY=DX(I,is)*DY(I,is)*A
        BXX=DX(I,is)*DX(I,is)*A
C
        CHI(I,J)=BXY*DX(I,is)
        CHIX(I,J)=(TWO + SUM(J)*DX(I,is)*DX(I,is))*BXY
        CHIY(I,J)=(ONE + SUM(J)*DY(I,is)*DY(I,is))*BXX
        CHIZ(I,J)=SUM(J)*DZ(I,is)*CHI(I,J)
        CHID2(I,J)=TWO*A*DY(I,is)+
     1             (NINE+SUM(J)*R2(I,is))*CHI(I,J)*SUM(J)
C
 532    CONTINUE
 531    CONTINUE
C
C       FOR Fxxz-TYPE
C
        DO 541 J=ITP(14)+1,ITP(15)
        IS=ict(j)
        DO 543 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        BXZ=DX(I,is)*DZ(I,is)*A
        BXX=DX(I,is)*DX(I,is)*A
C
        CHI(I,J)=BXZ*DX(I,is)
        CHIX(I,J)=(TWO + SUM(J)*DX(I,is)*DX(I,is))*BXZ
        CHIY(I,J)=SUM(J)*DY(I,is)*CHI(I,J)
        CHIZ(I,J)=(ONE + SUM(J)*DZ(I,is)*DZ(I,is))*BXX
        CHID2(I,J)=TWO*A*DZ(I,is)+
     1             (NINE+SUM(J)*R2(I,is))*CHI(I,J)*SUM(J)
C
 543    CONTINUE
 541    CONTINUE
C
C       FOR Fyyz-TYPE
C
        DO 561 J=ITP(15)+1,ITP(16)
        IS=ict(j)
        DO 563 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        BYZ=DZ(I,is)*DY(I,is)*A
        BYY=DY(I,is)*DY(I,is)*A
C
        CHI(I,J)=BYZ*DY(I,is)
        CHIX(I,J)=SUM(J)*DX(I,is)*CHI(I,J)
        CHIY(I,J)=(TWO + SUM(J)*DY(I,is)*DY(I,is))*BYZ
        CHIZ(I,J)=(ONE + SUM(J)*DZ(I,is)*DZ(I,is))*BYY
        CHID2(I,J)=TWO*A*DZ(I,is)+
     1             (NINE+SUM(J)*R2(I,is))*CHI(I,J)*SUM(J)
C
 563    CONTINUE
 561    CONTINUE
C
C       FOR Fxyy-TYPE
C
        DO 551 J=ITP(16)+1,ITP(17)
        IS=ict(j)
        DO 552 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        BXY=DX(I,is)*DY(I,is)*A
        BYY=DY(I,is)*DY(I,is)*A
C
        CHI(I,J)=BXY*DY(I,is)
        CHIX(I,J)=(ONE + SUM(J)*DX(I,is)*DX(I,is))*BYY
        CHIY(I,J)=(TWO + SUM(J)*DY(I,is)*DY(I,is))*BXY
        CHIZ(I,J)=SUM(J)*DZ(I,is)*CHI(I,J)
        CHID2(I,J)=TWO*A*DX(I,is)+
     1             (NINE+SUM(J)*R2(I,is))*CHI(I,J)*SUM(J)
C
 552    CONTINUE
 551    CONTINUE
C
C       FOR Fxzz-TYPE
C
        DO 571 J=ITP(17)+1,ITP(18)
        IS=ict(j)
        DO 572 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        BXZ=DZ(I,is)*DX(I,is)*A
        BZZ=DZ(I,is)*DZ(I,is)*A
C
        CHI(I,J)=BXZ*DZ(I,is)
        CHIX(I,J)=(ONE + SUM(J)*DX(I,is)*DX(I,is))*BZZ
        CHIY(I,J)=SUM(J)*DY(I,is)*CHI(I,J)
        CHIZ(I,J)=(TWO + SUM(J)*DZ(I,is)*DZ(I,is))*BXZ
        CHID2(I,J)=TWO*A*DX(I,is)+
     1             (NINE+SUM(J)*R2(I,is))*CHI(I,J)*SUM(J)
C
 572    CONTINUE
 571    CONTINUE
C
C       FOR Fyzz-TYPE
C
        DO 581 J=ITP(18)+1,ITP(19)
        IS=ict(j)
        DO 583 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        BYZ=DZ(I,is)*DY(I,is)*A
        BZZ=DZ(I,is)*DZ(I,is)*A
C
        CHI(I,J)=BYZ*DZ(I,is)
        CHIX(I,J)=SUM(J)*DX(I,is)*CHI(I,J)
        CHIY(I,J)=(ONE + SUM(J)*DY(I,is)*DY(I,is))*BZZ
        CHIZ(I,J)=(TWO + SUM(J)*DZ(I,is)*DZ(I,is))*BYZ
        CHID2(I,J)=TWO*A*DY(I,is)+
     1             (NINE+SUM(J)*R2(I,is))*CHI(I,J)*SUM(J)
C
 583    CONTINUE
 581    CONTINUE
C
C       FOR Fxyz-TYPE
C
        DO 591 J=ITP(19)+1,ITP(20)
        IS=ict(j)
        DO 592 I=1,PTS
C
        A=DEXP(-EXX(J)*R2(I,is))
        BXY=DX(I,is)*DY(I,is)*A
        BYZ=DZ(I,is)*DY(I,is)*A
        BXZ=DX(I,is)*DZ(I,is)*A
C
        CHI(I,J)=DX(I,is)*BYZ
        CHIX(I,J)=(ONE + SUM(J)*DX(I,is)*DX(I,is))*BYZ
        CHIY(I,J)=(ONE + SUM(J)*DY(I,is)*DY(I,is))*BXZ
        CHIZ(I,J)=(ONE + SUM(J)*DZ(I,is)*DZ(I,is))*BXY
        CHID2(I,J)=(NINE+SUM(J)*R2(I,is))*CHI(I,J)*SUM(J)
C
 592    CONTINUE
 591    CONTINUE
C
       DO 103 J=1,Nprims
       temp=zero
       DO 104 I=1,PTs
       check=DMax1(Dabs(CHi(I,J)),Dabs(CHiX(I,j)),Dabs(CHIY(I,J)),
     + Dabs(CHIZ(I,j)),Dabs(CHID2(I,J)),Temp)
       If(Check.gt.temp)temp=check
104    Continue
       chimax(j)=temp
103    Continue
C
       DO 105 L = 1,NMO
       DO 107 I=1,PTS 
       PSI(I,L) = ZERO
       GX(I,L) = ZERO
       GY(I,L) = ZERO
       GZ(I,L) = ZERO
       D2(I,L) = ZERO
107    CONTINUE 
C
       DO 125 J = 1,NPRIMS
       check=dabs(chimax(j)*coo(J,L))
       IF(check.gt.cutoff)THEN
       TEMP=COO(J,L)
       DO 126 I = 1,PTS
       PSI(I,L) = PSI(I,L) + TEMP*CHI(I,J)
       GX(I,L) = GX(I,L) + TEMP*CHIX(I,J)
       GY(I,L) = GY(I,L) + TEMP*CHIY(I,J)
       GZ(I,L) = GZ(I,L) + TEMP*CHIZ(I,J)
       D2(I,L) = D2(I,L) + TEMP*CHID2(I,J)
126    CONTINUE
       ENDIF
125    CONTINUE
105    CONTINUE
C
       GOTO 999
C
133     CONTINUE
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
C       FOR S-TYPE
C
        DO 420 J = 1,ITP(1) 
        is=ict(j)
        DO 422 I=1,PTS 
        CHI(I,J)=DEXP(-EXX(J)*R2(I,is))
422     CONTINUE
420     CONTINUE
C
C       FOR Px-TYPE
C
        DO 440 J=ITP(1)+1,ITP(2)
        is=ict(j)
        DO 442 I=1,PTS
        CHI(I,J)=DX(I,is)*DEXP(-EXX(J)*R2(I,is))
442     CONTINUE
440     CONTINUE
C
C       FOR Py-TYPE
C
        DO 460 J=ITP(2)+1,ITP(3)
        is=ict(j)
        DO 462 I=1,PTS
C
        CHI(I,J)=DY(I,is)*DEXP(-EXX(J)*R2(I,is))
462     CONTINUE
460     CONTINUE
C
C       FOR Pz-TYPE
C
        DO 480 J=ITP(3)+1,ITP(4)
        is=ict(j)
        DO 482 I=1,PTS
        CHI(I,J)=DZ(I,is)*DEXP(-EXX(J)*R2(I,is))
482     CONTINUE
480     CONTINUE
C
C       FOR Dxx-TYPE
C
        DO 520 J=ITP(4)+1,ITP(5)
        is=ict(j)
        DO 522 I=1,PTS
        CHI(I,J)=DX(I,is)*DX(I,is)*DEXP(-EXX(J)*R2(I,is))
522     CONTINUE
520     CONTINUE
C
C       FOR Dyy-TYPE
C
        DO 540 J=ITP(5)+1,ITP(6)
        is=ict(j)
        DO 542 I=1,PTS
        CHI(I,J)=DY(I,is)*DY(I,is)*DEXP(-EXX(J)*R2(I,is))
542     CONTINUE
540     CONTINUE
C
C       FOR Dzz-TYPE
C
        DO 560 J=ITP(6)+1,ITP(7)
        is=ict(j)
        DO 562 I=1,PTS
        CHI(I,J)=DZ(I,is)*DZ(I,is)*DEXP(-EXX(J)*R2(I,is))
562     CONTINUE
560     CONTINUE
C
C       FOR Dxy-TYPE
C
        DO 580 J=ITP(7)+1,ITP(8)
        is=ict(j)
        DO 582 I=1,PTS
        CHI(I,J)=DX(I,is)*DY(I,is)*DEXP(-EXX(J)*R2(I,is))
582     CONTINUE
580     CONTINUE
C
C       FOR Dxz-TYPE
C
        DO 620 J=ITP(8)+1,ITP(9)
        is=ict(j)
        DO 622 I=1,PTS
        CHI(I,J)=DX(I,is)*DZ(I,is)*DEXP(-EXX(J)*R2(I,is))
622     CONTINUE
620     CONTINUE
C
C       FOR Dyz-TYPE
C
        DO 640 J=ITP(9)+1,ITP(10)
        is=ict(j)
        DO 642 I=1,PTS
        CHI(I,J)=DY(I,is)*DZ(I,is)*DEXP(-EXX(J)*R2(I,is))
642     CONTINUE
640     CONTINUE
C
C       FOR Fxxx-TYPE
C
        DO 503 J=ITP(10)+1,ITP(11)
        is=ict(j)
        DO 504 I=1,PTS
        CHI(I,J)=DEXP(-EXX(J)*R2(I,is))*DX(I,is)**3
 504    CONTINUE
 503    CONTINUE
C
C       FOR Fyyy-TYPE
C
        DO 513 J=ITP(11)+1,ITP(12)
        is=ict(j)
        DO 514 I=1,PTS
        CHI(I,J)=DEXP(-EXX(J)*R2(I,is))*DY(I,is)**3
 514    CONTINUE
 513    CONTINUE
C
C       FOR Fzzz-TYPE
C
        DO 524 J=ITP(12)+1,ITP(13)
        is=ict(j)
        DO 525 I=1,PTS
        CHI(I,J)=DEXP(-EXX(J)*R2(I,is))*DZ(I,is)**3
 525    CONTINUE
 524    CONTINUE
C
C       FOR Fxxy-TYPE
C
        DO 533 J=ITP(13)+1,ITP(14)
        is=ict(j)
        DO 534 I=1,PTS
        CHI(I,J)=Dexp(-Exx(j)*r2(I,is))*DY(I,is)*DX(I,is)**2
 534    CONTINUE
 533    CONTINUE
C
C       FOR Fxxz-TYPE
C
        DO 544 J=ITP(14)+1,ITP(15)
        is=ict(j)
        DO 545 I=1,PTS
        CHI(I,J)=Dexp(-Exx(j)*r2(I,is))*DZ(I,is)*DX(I,is)**2
 545    CONTINUE
 544    CONTINUE
C
C       FOR Fxyy-TYPE
C
        DO 553 J=ITP(16)+1,ITP(17)
        is=ict(j)
        DO 554 I=1,PTS
        CHI(I,J)=Dexp(-Exx(j)*r2(I,is))*DX(I,is)*DY(I,is)**2
 554    CONTINUE
 553    CONTINUE
C
C       FOR Fyyz-TYPE
C
        DO 564 J=ITP(15)+1,ITP(16)
        is=ict(j)
        DO 565 I=1,PTS
        CHI(I,J)=Dexp(-Exx(j)*r2(I,is))*DZ(I,is)*DY(I,is)**2
 565    CONTINUE
 564    CONTINUE
C
C       FOR Fxzz-TYPE
C
        DO 573 J=ITP(17)+1,ITP(18)
        is=ict(j)
        DO 574 I=1,PTS
        CHI(I,J)=Dexp(-Exx(j)*r2(I,is))*DX(I,is)*DZ(I,is)**2
 574    CONTINUE
 573    CONTINUE
C
C       FOR Fyzz-TYPE
C
        DO 584 J=ITP(18)+1,ITP(19)
        is=ict(j)
        DO 585 I=1,PTS
        CHI(I,J)=Dexp(-Exx(j)*r2(I,is))*DY(I,is)*DZ(I,is)**2
 585    CONTINUE
 584    CONTINUE
C
C       FOR Fxyz-TYPE
C
        DO 593 J=ITP(19)+1,ITP(20)
        is=ict(j)
        DO 594 I=1,PTS
        CHI(I,J)=Dexp(-Exx(j)*r2(I,is))*DX(I,is)*DY(I,is)*DZ(I,is)
 594    CONTINUE
 593    CONTINUE
C
       DO 603 J=1,Nprims
       temp=zero
       DO 604 I=1,PTs
       check=DMax1(Dabs(CHi(I,J)),Temp)
       If(Check.gt.temp)temp=check
604    Continue
       chimax(j)=temp
603    Continue
C
       DO 605 L = 1,NMO
       DO 607 I=1,PTS 
       PSI(I,L) = ZERO
607    CONTINUE 
C
       DO 625 J = 1,NPRIMS
       check=dabs(chimax(j)*coo(J,L))
       IF(check.gt.cutoff)THEN
       TEMP=COO(J,L)
       DO 626 I = 1,PTS
       PSI(I,L) = PSI(I,L) + TEMP*CHI(I,J)
626    CONTINUE
       ENDIF
625    CONTINUE
605    CONTINUE
C
       GOTO 999
C
999    RETURN
       END
      SUBROUTINE GROCKLE (N, X, IR, S, E)
      IMPLICIT DOUBLE PRECISION (A-H, O-Z)
      DIMENSION X(3,N), S(3,N), C(3), E(3,3), EV(3), R(3,3)
      INTEGER IR(N)
      Save Zero,one
      Data ZERO /0.0D0/, ONE/1.0d0/
C
C    ZERO OUT CENTROID AND EIGENVECTORS
C
      C(1) = ZERO
      C(2) = ZERO
      C(3) = ZERO
      E(1,1) = ZERO
      E(1,2) = ZERO
      E(1,3) = ZERO
      E(2,2) = ZERO
      E(2,3) = ZERO
      E(3,3) = ZERO
C
C    CENTROID OF FRAGMENT
C
      M = ZERO
      DO 100 I = 1, N
      IF (IR(I) .GT. 0) THEN
        C(1) = C(1) + X(1,IR(I))
        C(2) = C(2) + X(2,IR(I))
        C(3) = C(3) + X(3,IR(I))
	M = M + 1
      ELSE IF (IR(I) .LT. 0) THEN
        C(1) = C(1) + S(1,-IR(I))
        C(2) = C(2) + S(2,-IR(I))
        C(3) = C(3) + S(3,-IR(I))
	M = M + 1
      END IF
100     CONTINUE
C
      DD = One/DFLOAT(M)
      C(1) = DD*C(1)
      C(2) = DD*C(2)
      C(3) = DD*C(3)
C
C    CALCULATE INERTIAL MATRIX.
C
      DO 200 I = 1, N
      IF (IR(I) .GT. 0) THEN
        X1 = X(1,IR(I)) - C(1)
        X2 = X(2,IR(I)) - C(2)
        X3 = X(3,IR(I)) - C(3)
      ELSE IF (IR(I) .LT. 0) THEN
        X1 = S(1,-IR(I)) - C(1)
        X2 = S(2,-IR(I)) - C(2)
        X3 = S(3,-IR(I)) - C(3)
      END IF
      E(1,1) = E(1,1) + X2**2 + X3**2
      E(2,2) = E(2,2) + X1**2 + X3**2
      E(3,3) = E(3,3) + X1**2 + X2**2
      E(1,2) = E(1,2) - X1*X2
      E(1,3) = E(1,3) - X1*X3
      E(2,3) = E(2,3) - X2*X3
      X1 = ZERO
      X2 = ZERO
      X3 = ZERO
200     CONTINUE
C
      E(2,1) = E(1,2)
      E(3,1) = E(1,3)
      E(3,2) = E(2,3)
C
C    GENERATES EIGENVALUES AND EIGENVECTORS OF THE INERTIAL MATRIX.
C
      CALL TRACE(E, EV, C, 3, IFAIL)
C
C    CHECK FOR RIGHT HAND CONVENTION FOR EIGEN-AXES
C
      DET = E(1,1)*(E(2,2)*E(3,3) - E(3,2)*E(2,3)) +
     +      E(1,2)*(E(3,1)*E(2,3) - E(2,1)*E(3,3)) +
     +      E(1,3)*(E(2,1)*E(3,2) - E(3,1)*E(2,2))
C
      IF (DET .LT. ZERO) THEN
        E(1,2) = -E(1,2)
        E(2,2) = -E(2,2)
        E(3,2) = -E(3,2)
      END IF
C
      RETURN
      END
      SUBROUTINE MAKNAME(I,STRING,L,EXT)
      CHARACTER*(*) STRING,EXT
      INTEGER I,J
      CALL GETARG(I,STRING)
      J = LEN(STRING)
      DO 10 N = 1,J
        IF(STRING(N:N) .EQ. ' ') THEN
          L = N - 1
          STRING = STRING(1:L)//EXT
          RETURN
        ENDIF
10    CONTINUE
      STOP ' FAILED TO MAKE A FILE NAME '
      RETURN
      END

C SKK ================================================================== SKK
C
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
      PARAMETER(MCENT=50,MMO=100,MPRIMS=400,MPTS=400,NTYPE=20)
      COMMON /ATOMS/ XC(MCENT),YC(MCENT),ZC(MCENT),CHARG(MCENT),NCENT
      COMMON /ORBTL/ EORB(MMO),PO(MMO),NMO
      COMMON /PRIMS/ DIV(MPRIMS),COO(MPRIMS,MMO),EXX(MPRIMS),
     +ICT(MPRIMS),SUM(MPRIMS),ITP(NTYPE),NPRIMS
      COMMON /STRING/ WFNTTL,JOBTTL,ATNAM(MCENT),NAT
      COMMON /VALUES/ THRESH1,THRESH2,GAMMA,TOTE
      COMMON /UNITS/ INPT,IOUT,IWFN,IDBG
      DIMENSION ITYPE(MPRIMS),CO(MPRIMS,MMO),ICENT(MPRIMS),EX(MPRIMS)
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
      DO 160 K=1,NTYPE
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
        SUBROUTINE      TQLGRM	(N, D, E, Z, IERR)
        IMPLICIT        DOUBLE PRECISION (A-H, O-Z)
        DIMENSION       D(N), E(N), Z(N,N)
	PARAMETER (AMACH = 16.0E-13)
	PARAMETER (ZERO = 0.0D0, ONE = 1.0D0)
C
        IERR    = 0
        IF (N .EQ. 1) RETURN
C
	DO 30 I = 2,N
	E(I-1)  = E(I)
30	CONTINUE

        F       = ZERO
        B       = ZERO
        E(N)    = ZERO

	DO 31 L = 1,N
	J       = 0
	H       = AMACH*(DABS(D(L)) + DABS(E(L)))
	IF (B .LT. H) B = H

   		DO 32 M = L,N
		IF (DABS(E(M)) .LE. B) GOTO 120
32		CONTINUE

120	IF (M .EQ. L) GOTO 220

130	IF (J .EQ. 30) THEN
		IERR    = L
		RETURN
	END IF

	J       = J + 1
	L1      = L + 1
	G       = D(L)
	P       = (D(L1) - G)/(2*E(L))
	IF (DABS(P*AMACH) .GT. ONE) THEN
		R       = P
	ELSE
		R       = DSQRT(P*P + 1)
	END IF
	D(L)    = E(L)/(P + DSIGN(R,P))
	H       = G - D(L)

		DO 33 I = L1,N
		D(I)    = D(I) - H
33		CONTINUE

	F       = F + H
	P       = D(M)
	C       = ONE
	S       = ZERO
	MML     = M - L

		DO 34 II = 1,MML
		I       = M - II
		G       = C*E(I)
		H       = C*P
		IF (DABS(P) .GE. DABS(E(I))) THEN
			C       = E(I)/P
			R       = DSQRT(C*C + 1)
			E(I+1)  = S*P*R
			S       = C/R
			C       = ONE/R
		ELSE
			C       = P/E(I)
			R       = DSQRT(C*C + 1)
			E(I+1)  = S*E(I)*R
			S       = 1.D0/R
			C       = C*S
		END IF
		P       = C*D(I) - S*G
		D(I+1)  = H + S*(C*G + S*D(I))

			DO 35 K = 1,N
			H       = Z(K,I+1)
			Z(K,I+1)= S*Z(K,I) + C*H
			Z(K,I)  = C*Z(K,I) - S*H
35			CONTINUE

34		CONTINUE

	E(L)    = S*P
	D(L)    = C*P
	IF (DABS(E(L)) .GT. B) GOTO 130

220	D(L)    = D(L) + F
31	CONTINUE

	DO 300 II = 2,N
	I       = II - 1
	K       = I
	P       = D(I)

		DO 260 J = II,N
		IF (D(J) .GE. P) GOTO 260
		K       = J
		P       = D(J)
260		CONTINUE

	IF (K .EQ. I) GOTO 300
	D(K)    = D(I)
	D(I)    = P

		DO 37 J = 1,N
		P       = Z(J,I)
		Z(J,I)  = Z(J,K)
		Z(J,K)  = P
37		CONTINUE

300	CONTINUE
        RETURN
        END
        SUBROUTINE	TRACE	(H, E, W, N, IERR)
C
C TRACE CALLS TREDIG AND TLQGRM TO DIAGONALIZE A SYMMETRIC REAL MATRIX.
C THE MATRIX IS PASSED DOWN IN H AND IS REPLACED BY THE EIGENVECTORS.
C THE EIGENVALUES IN E ARE STORED SMALLEST FIRST.
C THE WORK STORE W SHOULD BE AT LEAST OF DIMENSION N.
C SKK ==================================================================
C
        IMPLICIT        DOUBLE PRECISION (A-H, O-Z)
        DIMENSION       H(N,N), E(N), W(N)
C
        CALL TREDIG	(N, E, W, H)
        CALL TQLGRM	(N, E, W, H, IERR)
C
        RETURN
        END
        SUBROUTINE      TREDIG	(N, D, E, Z)
        IMPLICIT        DOUBLE PRECISION (A-H, O-Z)
        DIMENSION       D(N), E(N), Z(N,N)
	PARAMETER	(ZERO = 0.0D0, ONE = 1.0D0)

        IF (N .EQ. 1) GOTO 320

	DO 30 II = 2,N
	I       = N + 2 - II
	L       = I - 1
	H       = ZERO
	SCALE   = ZERO

	IF (L .LT. 2) GOTO 130

		DO 31 K = 1,L
		SCALE   = SCALE + DABS(Z(I,K))
31              CONTINUE

	IF (SCALE .NE. ZERO) GOTO 140
130     E(I)    = Z(I,L)
        GOTO 290

140	RSCALE	= ONE/SCALE
		DO 32 K = 1,L
		Z(I,K)  = Z(I,K)*RSCALE
		H       = H + Z(I,K)*Z(I,K)
32		CONTINUE
	F       = Z(I,L)
	G       = -DSIGN(DSQRT(H),F)
	E(I)    = SCALE*G
	H       = H - F*G
	Z(I,L)  = F - G
	F       = ZERO
	RH	= ONE/H
	RHSCALE	= RH*RSCALE	

		DO 33 J = 1,L
		Z(J,I)  = Z(I,J)*RHSCALE
		G       = ZERO

			DO 34 K = 1,J
			G       = G + Z(J,K)*Z(I,K)
34                      CONTINUE

		JP1     = J + 1
		IF (L .LT. JP1) GOTO 220

			DO 35 K = JP1,L
			G       = G + Z(K,J)*Z(I,K)
35                      CONTINUE

220		E(J)    = G*RH
		F       = F + E(J)*Z(I,J)
33		CONTINUE

	HH      = F/(H + H)

		DO 36 J = 1,L
		F       = Z(I,J)
		G       = E(J) - HH*F
		E(J)    = G
			DO 37 K = 1,J
			Z(J,K)  = Z(J,K) - F*E(K) - G*Z(I,K)
37			CONTINUE
36		CONTINUE

		DO 38 K	= 1,L
		Z(I,K)  =  SCALE*Z(I,K)
38		CONTINUE

290	D(I)    = H
30	CONTINUE

320     D(1)    = ZERO
        E(1)    = ZERO

	DO 500 I = 1,N
	L       = I - 1
	IF (D(I) .EQ. ZERO) GOTO 380

		DO 40 J	= 1,L
		G       = ZERO

			DO 41 K	= 1,L
			G       = G + Z(I,K)*Z(K,J)
41			CONTINUE

			DO 42 K = 1,L
			Z(K,J)  = Z(K,J) - G*Z(K,I)
42			CONTINUE

40		CONTINUE

380	D(I)    = Z(I,I)
	Z(I,I)  = ONE
	IF(L .LT. 1) GOTO 500

		DO 43 J	= 1,L
		Z(J,I)  = ZERO
		Z(I,J)  = ZERO
43		CONTINUE

500	CONTINUE
        RETURN
        END

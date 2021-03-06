C!<license>
C!    Copyright (C) 1996, 1997, 1998, 2001, 2007, 2009 State of California,
C!    Department of Water Resources.
C!    This file is part of DSM2.

C!    The Delta Simulation Model 2 (DSM2) is free software: 
C!    you can redistribute it and/or modify
C!    it under the terms of the GNU General Public License as published by
C!    the Free Software Foundation, either version 3 of the License, or
C!    (at your option) any later version.

C!    DSM2 is distributed in the hope that it will be useful,
C!    but WITHOUT ANY WARRANTY; without even the implied warranty of
C!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C!    GNU General Public License for more details.

C!    You should have received a copy of the GNU General Public License
C!    along with DSM2.  If not, see <http://www.gnu.org/licenses>.
C!</license>

      SUBROUTINE BLTMINIT

C     + + + PURPOSE + + +
C     This is used for initializing all of the variables inside BLTM,
C     Also read the input data

C     + + + LOCAL VARIABLE DEFINITIONS + + +
C     A(I)       average area in each subreach I (sq m)
C     CJ(L)      conc. of L at junction M
C     DQQ(N)     dispersion factor for branch N (D/U*U*DT)
C     DQV       minimum dispersive velocity (m/s or ft/s)
C     DT      time step size (hours)
C     DVD(N)     unknown volume in outflow at d/s end
C     DVU(N)     unknown volume in outflow at u/s end
C     FLOW(N,M,I)    flow field at grid I averaged over time step
C-----M=1 for discharge (cu m/s or ft/s)
C-----M=2 for cross sectional area (sq m or ft)
C-----M=3 for top width (m or ft)
C-----M=4 for trib. flow (cu m/s or ft/s)
C     DX(N,I)     length of subreach I in branch N
C     GPDC(L,K,N)    increase of L in parcel N,K due to reaction LR(L)
C     GPDF(L,K,N)    increase of L in parcel N,K due to dispersion
C     GPH(N,K)     time in hours since parcel K entered branch N
C     GPT(L,K,N)     concentration of constituent L in parcel N,K
C     GPTD(N,L)    flux of L at ds end of branch N
C     GPTI(L,K,N)    conc. of L as parcel K entered branch N
C     GPTR(L,K,N)    increase of L in parcel N,K due to tribs.
C     GPTU(N,L)    flux of L at us end of branch N
C     GPV(N,K)     volume of parcel K in branch N
C     GTRIB(L,I,N)   conc. of L in trib. at grid I of branch N
C-----(tribs can not occur at first or last grid of branch)
C     GVU(N,I)     volume of parcel u/s of grid I in branch N
C     HR      hour of the day
C     IDAY    days since model started
C     IENG    input units: 0=metric (except river miles), 1=english
C     INX     number of subreaches
C     IOUT(N,I)    flag (1 = output) for grid I in branch N
C     IPPR(N)      initial number of parcels per reach in branch N
C     IPX(K)     subreach in  which the u/s boundary of parcel K is located
C     IRC     code for reading data in FINK (1=read data, 0=no read)
C     ITDDS   tdds use (0=no, 1=flow only, 2=flow and boundary conditions)
C     JTIME       time step
C     JCD(M)     code for junction mixing (0=mixed, 2=not mixed)
C     JNCD(N)    d/s junction no. for branch N (number interior first)
C     JNCU(N)    u/s junction no. for branch N (number interior first)
C     JGO     number of time steps between output prints for grids
C     JPO     number of time steps between output prints for parces
C     JTS     number of time steps from midnight to start of model
C     K       parcel number
C     KAI(I)     parcel at grid I
C     L       constituent number
C     LABEL(10)   name of constituents (4 letters max)
C     LR(L)      index denoting that the decay of constituent L
C-----due to the presence of constituent LR(L) is tracked
C     NBC     number of boundary conditions,
C     NBRCH   number of branchs
C     NEQ     number of equations (constituents)
C     NHR     number of time steps to be modeled
C     NIPX(N,K)    subreach in which the upstream boundary of parcel N,K is
C     NKAI(N,I)    parcel at branch N, grid I
C     NS(N)      number of parcels in branch N
C     NXSEC(N)   number of grids in branch N
C     PDC(L,K)     change in initial concentration due to a specific reaction
C     PDF(L,K)     change in initial concentration due to dispersion
C     PH(K)      time parcel K entered reach in hours from day 0
C     PT(L,K)      conc. of constituent L in parcel K
C     PTD(L)     conc. of constituent L in parcel K, d/s, avg'd over time step
C     PTI(L,K)     initial concentration of constituent L in parcel K
C     PTR(L,K)     change in initial concentration due to tributary inflow
C     PTU(L)     conc. of constituent L in parcel K, u/s, avg'd over time step
C     PV(K)      volume of parcel K
C     PX(K)      location of upstream boundry of parcel in grid units
C     Q(I)   river flow at grid I (cu m/s or ft/s), trib inflow occurs just u/s of grid
C     QI     minimum flow of interest (flows<QI are considered zero).
C     QT(I)      tributary inflow at grid I (cu m/s or ft/s) enter just u/s of grid
C     RPT(L)     initial concentration of L in reach
C     TITLE(20)   title of program (80 characters)
C     TRIB(L,I)    concentration of constituent L in trib at grid I
C-----(tribs can not occur at first or last grid)
C     VJ      inflow volume to junction M
C     VU(I)      volume of parcel u/s of grid I
C     W(I)       average top width in subreach I (m or ft)
C     X(N,I)       distance of grid I from u/s of branch N (input in miles)
C     XFACT        conversion from miles to feet or meters, depending on IENG

C***  BEGIN DIMENSIONING DEFINITION

C     NOBR     Maximum number of branches allowed in model
C     MAX_NODES     Maximum number of internal junctions allowed in model
C     NOSC     Maximum number of cross sections (grids) allowed in branch
C     NOPR     Maximum number of parcels allowed in branch
C-----(NOPR should be at least 20 + 2 times NOSC)
      use IO_Units
	use groups, only: GROUP_ALL
      use grid_data
      use common_qual
      use common_tide
      use logging
      use runtime_data
      use iopath_data
      IMPLICIT NONE
      INCLUDE 'param.inc'

      INCLUDE 'bltm1.inc'
      INCLUDE 'bltm3.inc'
      INCLUDE 'bltm2.inc'

C     + + + LOCAL VARIABLES + + +C

      INTEGER I,I1,II,INX,
     &     JN,K,L,M, NN,
     &     IPPR(NOBR),IENG,KK
      REAL*8 DX(NOBR,NOSC),
     &     RPT(NOSC,MAX_CONSTITUENT),XFACT

      LOGICAL RESTART           ! true if restart input filename given
      INTEGER LOB
      INTEGER XNO
      REAL*8 XLENGTH
      
      if (print_level .ge. 3) then
         open (ihout,file='heat.out')
         open (irhout,file='resheat.out')
         open (idoout,file='do.out')
         open (irdoout,file='resdo.out')

         write(ihout,113)
         write(irhout,113)
         write(idoout,116)
         write(irdoout,117)

 113     format(//,40x,'heat components'/)
         
         write(ihout,114)
         write(irhout,115)
 114     format (' Date     Hour  Br     SWsolar  LWsolar   BackRad    Evap    Conduct     Net heat   Temp    E (in/mon)'/)
 115     format (' Date    Hour  ResNo    SWsolar  LWsolar   BackRad   Evap     Conduct    Net heat   Temp    E (in/mon)'/)
 116     format(/,'Date    Hour   Br     osf     oss    k2/day do-sat  DO       reaer  velocity   k2min  benth'/)
 117     format(/,'Date    Hour  ResNo   osf     oss    k2/day  do-sat DO       reaer  velocity   k2min   benth, depth'/)
      endif
C     + + + INPUT FORMATS + + +
 1000 FORMAT (L1,20A4)
 1010 FORMAT (10X,10I7)
 1020 FORMAT (10X,10F7.2)
 1030 FORMAT (10X,I7,3X,A5)
 1040 FORMAT (10X,I7,F7.2,3I7,F10.0)
 1050 FORMAT (10X,F7.3,I7,F7.3,10F6.3)
 1055 FORMAT (24X,F7.1,10F6.2)
 1100 FORMAT (15X,4E18.5)
 1110 FORMAT (3I5)
 1120 FORMAT (8f10.4)
C     + + + OUTPUT FORMATS + + +
 2000 FORMAT (20X,20A4,/)
 2040 FORMAT (' BOUNDARY CONDITIONS READ FROM TDDB')
 2050 FORMAT (' FLOW FIELD READ FROM BLTM.FLW')
 2060 FORMAT (' FLOW FIELD READ FROM TDDB')

C     zero arrays and preliminaries

      DO 5 N=1,MAX_NODES
         JCD(N)=0
 5    CONTINUE
      DO 60 N=1,NOBR
         IPPR(N)=1
         DO 30 I=1,NOSC
            GVU(N,I)=0.0
            NKAI(N,I)=0
            DO 10 M=1,4
               FLOW(N,M,I)=0.0
 10         CONTINUE
            IOUT(N,I)=0
            DX(N,I)=0.0
            X(N,I)=0.0
            DO 20 L=1,MAX_CONSTITUENT
               GTRIB(L,I,N)=0.0
 20         CONTINUE
 30      CONTINUE
         DO 50 K=1,NOPR
            NIPX(N,K)=0
            GPV(N,K)=0.0
            DO 40 L=1,MAX_CONSTITUENT
               GPT(L,K,N)=0.0
 40         CONTINUE
 50      CONTINUE
 60   CONTINUE

C     read common input

      NHR=(END_JULMIN-START_JULMIN)/TIME_STEP
      JTS=0
      JGO=400
      JPO=48
      IENG=1
       
      !DQV=1.d-3
      DQV=0

      DT=dble(TIME_STEP)/60.

      JHR=INT(1./DT)
      IF(ABS(JHR*DT - 1.) .GT. 1.E-4)THEN
         PRINT*,' DT=',DT
         PRINT*,' SELECT A DELTA T THAT WOULD BE DIVISIBLE WITH 1 HOUR'
c         call exit(2)
      ENDIF

      IF (IO_FILES(QUAL,IO_RESTART,IO_READ).USE) THEN ! restart input file requested
         RESTART=.TRUE.
         call restart_file(IO_READ)
      ELSE                      ! no restart input file
         RESTART=.FALSE.
         DO I=1,NRESER
             do L=1,neq
	         if (constituents(l).group_ndx .eq. GROUP_ALL)then
	            ! do not intialize pseuedo constituents
	            cres(i,l)=init_conc
	         else
	            cres(i,l)=0.d0
	         end if
               !CRES(I,L)=INIT_CONC
            ENDDO
         ENDDO
      ENDIF

      JULMIN=START_JULMIN
      call read_mult_tide
      CALL INTERPX

      DO 120 N=1,NBRCH
         NXSEC(N)=2
         IPPR(N)=8

C--------Fixme: Line Below assumes rectangular prismatic channel

         NN=INT2EXT(N)
         XLENGTH=CHAN_GEOM(N).LENGTH
         XNO=CHAN_GEOM(N).XSECT(1)
c         B(N)=XSECT_GEOM(XNO).WIDTH
	   B(N)=0.5*(AChan(1,N)/HChan(1,N) + AChan(2,N)/HChan(2,N))

 991     FORMAT(I5,2X,2I5)
C--------Figure out the largest junction id#

         IF(NJUNC.LT.JNCU(N)) NJUNC=JNCU(N)
         IF(NJUNC.LT.JNCD(N)) NJUNC=JNCD(N)

         JUNCFLG(JNCU(N))=1
         JUNCFLG(JNCD(N))=1

         IF (IPPR(N) .LE. 0) IPPR(N)=1
         IF (IPPR(N)*(NXSEC(N)-1) .GT. (NOPR-2))
     &        IPPR(N)=(NOPR-2)/(NXSEC(N)-1)
         MAXPARCEL(N)=NOPR-2*(NXSEC(N)-1)
         I1=NXSEC(N)
         XFACT=5280.00

C--------XLENGTH=dble(INT(XLENGTH/XFACT*1000.+0.5))/1000.
         XLENGTH=XLENGTH/XFACT  !NEEDS TO BE CHANGED LATER

C--------Modify number of parcels

!         LOB=XLENGTH*XFACT/B(N)
         LOB=XLENGTH*XFACT/DX0       
         IF(LOB.GT.(NOPR-2))LOB=NOPR-2
         IF(LOB.LT.8)LOB=8
C---         DQQ(N)=DQQ(N)*1500.D0
         
         
         IPPR(N)=LOB/(I1-1)

         DO I=1,I1
            IF(I.EQ.1)THEN
               X(N,I)=0.
            ELSEIF(I.EQ.2)THEN
               X(N,I)=XLENGTH
            ELSE
               write(unit_error,*) 'Software problem #1 in bltminit.f'
               call exit(2)
            ENDIF
            IF(I.NE.I1)THEN
               DO L=1,NEQ
                  IF(RESTART)THEN
                     RPT(I,L)=CSTART(N,L)
                  ELSE
	               if (constituents(l).group_ndx .eq. GROUP_ALL)then
                        RPT(I,L)=INIT_CONC
                     else
	                  rpt(i,l)=0.
	               end if
                  ENDIF
               ENDDO
            ELSE
               DO L=1,NEQ
                  RPT(I,L)=0.
               ENDDO
            ENDIF
            IF (I .LT. I1) THEN
               DO II=(I-1)*IPPR(N)+1,I*IPPR(N)
                  DO L=1,NEQ
                     GPT(L,II,N)=RPT(I,L)
                  ENDDO
               ENDDO
            END IF
         ENDDO
 120  CONTINUE

      DO N=1,NBRCH
         JN=JNCU(N)
         NUMUP(JN)=NUMUP(JN)+1
         LISTUP(JN,NUMUP(JN))=N

         JN=JNCD(N)
         NUMDOWN(JN)=NUMDOWN(JN)+1
         LISTDOWN(JN,NUMDOWN(JN))=N
      ENDDO

      JULMIN=START_JULMIN



C     make preliminary compt. and write init.conditions
      XFACT=5280.00
      DO 230 N=1,NBRCH
         INX=NXSEC(N)-1
         DO 210 I=1,INX
            DX(N,I)=(X(N,I+1)-X(N,I))*XFACT
            DO 205 KK=1,IPPR(N)
               K=(I-1)*IPPR(N)+KK
               NIPX(N,K)=I
               IF (KK .EQ. 1) NIPX(N,K)=I-1
               PX(K,N)=dble(I)+dble(KK-1)/dble(IPPR(N))
               GPV(N,K) =Achan_Avg(N)*DX(N,I)/dble(IPPR(N))
 205        CONTINUE
ccc           if(N.le.5) write(*,*) ' N & Achan Average=', N, Achan_Avg(N)
            NKAI(N,I)=1+(I-1)*IPPR(N)
            GVU(N,I)=0.0
 210     CONTINUE
         NIPX(N,1)=1
         NS(N)=INX*IPPR(N)
         NKAI(N,NXSEC(N))=NS(N)
         GVU(N,NXSEC(N))=GPV(N,NS(N))
         IF(JPO.EQ.0)GO TO 230
         JTIME=0
 230  CONTINUE
      QI=1.

c-----Check for missing junction#'s
      CALL CHECKERROR
c-----create the lookup table for temperature factors
      if (no_of_nonconserve_constituent .gt. 0) then

         CALL TEMPFACTORS(miss_val_r)
      end if
 
      RETURN
      END

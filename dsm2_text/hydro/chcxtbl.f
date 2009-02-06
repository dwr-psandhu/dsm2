C!    Copyright (C) 1996, 1997, 1998 State of California,
C!    Department of Water Resources.
C!
C!    Delta Simulation Model 2 (DSM2): A River, Estuary, and Land
C!    numerical model.  No protection claimed in original FOURPT and
C!    Branched Lagrangian Transport Model (BLTM) code written by the
C!    United States Geological Survey.  Protection claimed in the
C!    routines and files listed in the accompanying file "Protect.txt".
C!    If you did not receive a copy of this file contact Tara Smith,
C!    below.
C!
C!    This program is licensed to you under the terms of the GNU General
C!    Public License, version 2, as published by the Free Software
C!    Foundation.
C!
C!    You should have received a copy of the GNU General Public License
C!    along with this program; if not, contact Tara Smith, below,
C!    or the Free Software Foundation, 675 Mass Ave, Cambridge, MA
C!    02139, USA.
C!
C!    THIS SOFTWARE AND DOCUMENTATION ARE PROVIDED BY THE CALIFORNIA
C!    DEPARTMENT OF WATER RESOURCES AND CONTRIBUTORS "AS IS" AND ANY
C!    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
C!    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
C!    PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE CALIFORNIA
C!    DEPARTMENT OF WATER RESOURCES OR ITS CONTRIBUTORS BE LIABLE FOR
C!    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
C!    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
C!    OR SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA OR PROFITS; OR
C!    BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
C!    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
C!    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
C!    USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
C!    DAMAGE.
C!
C!    For more information about DSM2, contact:
C!
C!    Tara Smith
C!    California Dept. of Water Resources
C!    Division of Planning, Delta Modeling Section
C!    1416 Ninth Street
C!    Sacramento, CA  95814
C!    916-653-9885
C!    tara@water.ca.gov
C!
C!    or see our home page: http://baydeltaoffice.water.ca.gov/modeling/deltamodeling/


*===== BOF chcxtbl ======================================================

************************************************************************
*
*     This file is a FORTRAN module for estimating hydraulic properties
*     of multiple non-prismatic channels.  Width, Beta, 1/effective Manning's n,
*     area-weighted sinuosity, discharge-weighted sinuosity, and wetted
*     perimeter are interpolated linearly with respect to depth and downstream
*     distance.  Area and sinuosity-weighted conveyance at a location are
*     computed from the interpolated values.  For the purposes of this module,
*     a cross section may be viewed as a sequence of one or more adjoining
*     trapezoids.  Lines delimiting the trapezoids correspond to data lines
*     in the tabular input to the module.  Conceptually, the channel is formed
*     by the straight-line connection (from cross section to cross section
*     within a particular branch) of corresponding extremities of lines
*     delimiting trapeziods within individual cross sections.  Thus, each
*     cross section within a branch must be constructed of the same number
*     of trapezoids.  Branches are independent.  Data input to this module
*     are formatted according to the table format obtained from the hydraulic
*     information exchange program (HYDIE) when the HYDRAUX-output-table
*     option is specified.
*
*     Program note: Only functions or subroutines marked "public" should be
*                   used outside of this module as those marked "private"
*                   may not be supported by future revisions of this module
*                   or replacement modules.  Likewise, no data or common
*                   blocks contained within this module should be accessed
*                   by routines outside of this module accept through the
*                   use of "public" functions or subroutines contained
*                   within this module.
*
*
*
*   Programmed by:   Lew DeLong
*   Date programmed: January, 1990
*   Modified by:     Lew DeLong
*   Last modified:   July, 1991
*   Version 93.01, January, 1993
*
*
*   Public routines:
*
*     LOGICAL FUNCTION InitializeChannelProperties (DUNIT,FILDAT)
*            - initializes the module (reads properties file).
*
*     LOGICAL FUNCTION EchoChannelProperties (DUNIT,FILDAT)
*            - write properties data to a file.
*
*     LOGICAL FUNCTION AdjustChannelWidths ()
*            - adjust widths consistent with areas.
*
*     REAL*8FUNCTION BtmElev (X)
*            - returns channel-bottom elevation.
*
*     REAL*8FUNCTION BtmSlope (X)
*            - returns channel-bottom slope.
*
*     REAL*8FUNCTION ChannelWidth (X,H)
*            - returns channel width.
*
*     REAL*8FUNCTION dChannelWidth (X,H)
*            - returns d(Width)/dH.
*
*     REAL*8FUNCTION CxArea (X,H)
*            - returns cross-sectional area.
*
*     REAL*8FUNCTION Conveyance (X,H)
*            - returns sinuosity-weighted conveyance.
*
*     REAL*8FUNCTION dConveyance (X,H)
*            - returns d(Conveyance)/dH.
*
*     REAL*8FUNCTION Beta (X,H)
*            - returns momentum coefficient.
*
*     REAL*8FUNCTION dBeta (X,H)
*            - returns d(Beta)/dH
*
*     REAL*8FUNCTION AreaWtSinuosity (X,H)
*            - returns area-weighted sinuosity.
*
*     REAL*8FUNCTION dAreaWtSinuosity (X,H)
*            - returns d(AreaWtSinuosity)/dH.
*
*     REAL*8FUNCTION QWtSinuosity (X,H)
*            - returns discharge-weighted sinuosity.
*
*     REAL*8FUNCTION dQWtSinuosity (X,H)
*            - returns d(QWtSinuosity)/dH.
*
*     REAL*8FUNCTION dCxAreadX (X,H)
*            - returns d(CxArea)/dX, with constant water-surface.
*
*     REAL*8FUNCTION CxCentroid (X,H)
*            - returns distance from water surface to centroid.
*
*     REAL*8FUNCTION dCxCentroid (X,H)
*            - returns d(CxCentroid)/dH
*
*     REAL*8FUNCTION dChannelWidthdX (X,H)
*            - returns d(Width/dX), with constant elevation.
*
*
*     SUBROUTINE GXDistance( in: NumberOfLocations  out: UserLocation )
*            - gets an array of user cross-section downstream coordinates.
*
*     + + + Public arguments + + +
*
*     X      - current downstream distance
*     H      - current depth of flow
*
*     NumberOfLocations - maximum number of elements in a requested list
*                         of user cross-section coordinates.
*     UserLocation - an array of user cross-section coordinates.
*
*   Module data:
*
*    'network.inc'
*     MaxChannels - maximum number of channels.
*     NumCh - current number of channels.
*     Branch - current selected or active channel.
*     MaxLocations - maximum number of locations (computational or user).
*
*    'chcxtbl.inc'
*
*     MaxTables        - maximum number of tables.
*     MaxLinesPerTable - maximum number of lines per table.
*     MaxLines         - maximum total number of lines in tables.
*
*     FirstTable(m) - table number of first table for a branch.
*     LastTable(m)  - table number of last table of a branch.
*     Lines(m) - number of lines per table for the curren branch.
*     m - branch number.
*
*     Offset(i) - pointer to first line of a table in properties arrays.
*     XDistance(i) - downstream-distance coordinate.
*     Datum(i) - elevation of bottom of the channel.
*     i - table number, same as user cross-section sequence number.
*
*     Depth(j) - depth of flow.
*     Width(j) - width of channel.
*     A(j)     - cross-sectional area.
*     K(j)     - sinuosity-weighted conveyance.
*     P(j)     - wetted perimeter.
*     N(j)     - 1/effective Manning's "n".
*     Bta(j)   - momentum coefficient.
*     MA(j)    - area-weighted sinuosity.
*     MQ(j)    - discharge-weighted sinuosity.
*     j - line number.
*
*     N1 - adjacent upstream cross section.
*     N2 - adjacent downstream cross section.
*
*     NP(k)       - pointers to table positions in adjacent upstream and downstream
*                   property tables bracketing the estimation point.
*     Shape(k)    - local bilinear shape function for the estimation point.
*     dShapeDX(k) - derivative of Shape with respect to the local depth coordinate.
*     k = degree of freedom.
*
*     DegreesOfFreedom - maximum number of degrees of freedom,
*                        four for bilinear interpolation.
*
*     Xi - stream-wise local coordinate of the estimation point.
*     Eta - depth-wise local coordinate of the estimation point.
*     dH - global depth corresponding to a local depth of 1 at the
*          estimation point.
*
*     PreviousBranch - branch of previous estimation point.
*     PreviousX      - int( X location ) at previous estimation point.
*     PreviousH100   - int( 100.0*depth ) at previous estimation point.
*
*
*
*
*     Program Note:
*
*     By convention, the order for addressing known points bracketing
*     the interpolation point is the following:
*
*              4      <------------       3
*                                         ^
*                         *               |         downstream ----->
*                                         |
*
*              1      ------------>       2
*
*
*              ^                          ^
*             (N1)                       (N2)
*
************************************************************************



*=======================================================================
*   Public: UserStreamLocations
*=======================================================================

      SUBROUTINE UserStreamLocations
     &     ( NumberOfLocations, LocationID,
     &     UserLocation                  )

      IMPLICIT NONE

*   Purpose:
*     Get an array of downstream coordinates for the user cross sections
*     in the current channel.

*   Arguments:
      INTEGER NumberOfLocations
      REAL*8   UserLocation( NumberOfLocations )
      CHARACTER*16 LocationID( NumberOfLocations )

*   Argument definitions:
*     NumberOfLocations - dimension of UserLocation().
*     UserLocation(i) - downstream user-supplied cross-section location.
*     LocationID(i) - location identifiers.
*     i - user cross-section sequence number.

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER I, J, Locations, L
      LOGICAL Match
      CHARACTER*255 String1, String2

*   Routines by module:

***** Channel-schematic module:
      INTEGER  NumberOfUserStreamLocations
      EXTERNAL NumberOfUserStreamLocations
      EXTERNAL GetUserStreamLocationIDs

***** String manipulation:
      CHARACTER*255   LeftTrim, RightTrim
      EXTERNAL        LeftTrim, RightTrim

*   Programmed by: Lew DeLong
*   Date:          July 1991
*   Modified by:   Lew DeLong
*   Last modified: July 1993
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      Match = .TRUE.

      Locations = NumberOfUserStreamLocations()

      IF( Locations .LE. NumberOfLocations ) THEN

*--------Search for IDs and get corresponding locations.

         CALL GetUserStreamLocationIDs(Locations, LocationID)

         DO 200 I=1,Locations

*-----------Check for range error.

            IF( LastTable(Branch) .GT. MaxTables ) THEN
               WRITE(unit_error,*) ' #### error{1}(UserStreamLocations)'
               WRITE(unit_error,*) ' Branch...',Branch
               WRITE(unit_error,*) ' MaxTables exceeded...'
               WRITE(unit_error,*) ' ',LastTable(Branch),'>',MaxTables
            END IF

*-----------Look for cross-section ID.

            DO 100 J=FirstTable(Branch),LastTable(Branch)

               L = J
               IF( LocationID(I) .EQ. ID(J) ) GO TO 102

 100        CONTINUE

*-----------Failed to find ID, remove leading and trailing
*         blanks and try again.

            String1 = LeftTrim( LocationID(I) )
            String1 = RightTrim( String1 )
            DO 101 J=FirstTable(Branch),LastTable(Branch)

               L = J
               String2 = LeftTrim( ID(J) )
               String2 = RightTrim( String2 )
               IF( String1 .EQ. String2 ) GO TO 102

 101        CONTINUE

            WRITE(unit_error,*) ' #### error{2}(UserStreamLocations)'
            WRITE(unit_error,*) ' Branch...',Branch
            WRITE(unit_error,*) ' No match for...',LocationID(I)
            Match = .FALSE.
            UserLocation(J) = -9999999999.99
            GO TO 200

 102        CONTINUE

*-----------Match for ID found, get location.

            UserLocation(I) = XDistance(L)

 200     CONTINUE

         IF( Match ) THEN
         ELSE

            WRITE(unit_error,*) ' '
            WRITE(unit_error,*) '            ID                Location'
            DO 300 I=1,Locations

               WRITE(*,'(I5,2X,A16,2X,F14.2)')
     &              I, LocationID(I), UserLocation(I)

 300        CONTINUE
            WRITE(unit_error,*) ' '

            WRITE(unit_error,*) 'Abnormal program end.'
            STOP
         END IF

      ELSE
         WRITE(unit_error,*) ' Locations...', Locations
         WRITE(unit_error,*) ' NumberOfLocations...', NumberOfLocations
         WRITE(unit_error,*) ' #### error{3}(UserStreamLocations)'
         WRITE(unit_error,*) ' Branch...',Branch
         WRITE(unit_error,*)
     &        ' Number of user locations exceeds passed dimension.'
         WRITE(unit_error,*) ' MaxLocations too small...'
         WRITE(unit_error,*) ' Abnormal program end.'
         STOP

      END IF

      RETURN
      END

*=======================================================================
*   Public: BtmElev
*=======================================================================

      REAL*8 FUNCTION BtmElev(X)

      IMPLICIT NONE

*   Purpose:
*     Estimate channel-bottom elevation in the current channel
*     at X downstream distance.

*   Arguments:
      REAL*8    X

*   Argument definitions:
*     X - downstream distance in current channel.

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

      include '../input/fixed/common.f'
      include '../input/fixed/common_irreg_geom.f'

*   Local Variables:
      integer
     &     channo               ! dsm channel number
     &     ,vsecno              ! virtual cross-section number (within channel)

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction, SetXi
      EXTERNAL CxShapeFunction,SetXi
      REAL*8     HermBtmElev
      EXTERNAL HermBtmElev

*   Programmed by: Lew DeLong
*   Date:          OCT   1993
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      channo=int2ext(Branch)
      vsecno = nint(X / virt_deltax(channo))+1
      BtmElev = virt_min_elev(minelev_index(channo)+vsecno-1)

      RETURN
      END

*=======================================================================
*   Public: BtmSlope
*=======================================================================

      REAL*8 FUNCTION BtmSlope(X)

      IMPLICIT NONE

*   Purpose:
*     Estimate channel-bottom slope in the current channel
*     at X downstream distance.

*   Arguments:
      REAL*8    X

*   Argument definitions:
*     X - downstream distance in current channel.

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

      include '../input/fixed/common.f'

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction, SetXi
      EXTERNAL CxShapeFunction, SetXi
      REAL*8     HermBtmSlope
      EXTERNAL HermBtmSlope

*   Intrinsics:
      INTEGER   INT
      INTRINSIC INT

c-----to use bottom elevations at ends

c@@@   channo=int2ext(Branch)
c@@@   deltaz = chan_geom(channo).BottomElev(1)-chan_geom(channo).BottomElev(2)
c@@@   btmslope=deltaz/float(chan_geom(channo).length)

c-----to see if bottom slope has any effect--it currently has no effect
      btmslope = 9999999999.99

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Lew Delong
*   Last modified: October 10, 1993
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

c@@@   IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
c@@@      BtmSlope=0.
c@@@      RETURN
c@@@   ELSEIF(Branch.NE.PreviousBranch.OR.INT(X).NE.PreviousX) THEN
c@@@      PreviousBranch = Branch
c@@@      PreviousX   = INT(X)

*--------Determine relative longitudinal location of a point,
*       within a branch.

c@@@      IF(SetXi(X)) THEN
c@@@      ELSE
c@@@         WRITE(*,*) '*** error(BtmSlope)..branch,X',Branch,X
c@@@         WRITE(*,*) 'Could not determine relative x location.'
c@@@         WRITE(*,*) 'Stopping...'
c@@@         STOP
c@@@      END IF
c@@@   END IF
c@@@   IF( .NOT. HermiteBtm ) THEN
c@@@      BtmSlope = (Datum(N2)-Datum(N1))/(XDistance(N2)-XDistance(N1))
c@@@   ELSE
c@@@      BtmSlope = HermBtmSlope()
c@@@   END IF

c@@@      BtmSlope=0

      RETURN
      END

*=======================================================================
*   Public: ChannelWidth
*=======================================================================

      REAL*8 FUNCTION ChannelWidth(X,H)

      IMPLICIT NONE

*   Purpose:
*     Estimate channel width in the current channel at X downstream distance and
*     at H distance above the lowest point in the cross section.

*   Arguments:
      REAL*8    X,H

*   Argument definitions:
*     X      - downstream distance in current channel.
*     H      - distance, above lowest point in channel, at which the
*              channel width is to be computed.

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

      include '../input/fixed/common.f'
      include '../input/fixed/common_irreg_geom.f'

*   Functions:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Subroutines:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993
      
c-----local variables
      REAL*8 
     &     x1                   ! interpolation variables
     &     ,x2
     &     ,y1
     &     ,y2
     &     ,interp              ! interpolation function
      integer
     &     vsecno               ! number of virtual section (within channel)
     &     ,virtelev            ! number of virtual elevation (within channel)
     &     ,veindex             ! index of virtual elevation array
     &     ,channo              ! dsm channel number
     &     ,dindex              ! function to calculate xsect prop. array index
     &     ,di                  ! stores value of dindex

c-----statement function to calculate indices of virtual data arrays
      dindex(channo,vsecno,virtelev)
     &     =chan_index(channo) + (vsecno-1)*num_layers(channo) + virtelev-1
c-----statement function to interpolate wrt two points
      interp(x1,x2,y1,y2,H) =-((y2-y1)/(x2-x1))*(x2-H) + y2 

      call find_layer_index(
     &     X
     &     ,H
     &     ,Branch
     &     ,channo
     &     ,vsecno
     &     ,virtelev
     &     ,veindex
     &     )

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
c@@@         ChannelWidth =RectangleWidth(Branch,1)
c@@@      ELSEIF(CxShapeFunction(X,H)) THEN
c@@@         ChannelWidth = 0.0
c@@@C------DOF IS ALWAYS 4
c@@@         DO 100 I=1,DegreesOfFreedom
c@@@C---------SHAPE() ARE INTERPOLATION FACTORS

      di=dindex(channo,vsecno,virtelev)
      x1=virt_elevation(veindex)
      x2=virt_elevation(veindex+1)
      y1=virt_width(di)
      y2=virt_width(di+1)
      ChannelWidth = interp(x1,x2,y1,y2,H)
      if (x1.eq.x2) then
         write(unit_error,*) 'ChannelWidth division by zero'
      endif

c@@@ 100  CONTINUE
c@@@      ELSE
c@@@         WRITE(unit_error,*) '*** error(ChannelWidth)',Branch,X,H
c@@@         STOP
c@@@      END IF

      RETURN
      END


*=======================================================================
*   Public: CxArea
*=======================================================================

      REAL*8 FUNCTION CxArea(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate cross-sectional area in the current channel, at X downstream
*     distance, limited by the lowest point in the channel and a
*     distance H above the lowest point.

*   Arguments:
      REAL*8    X, H              ! h-height of trapezoid

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/common.f'
      include '../input/fixed/common_irreg_geom.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      REAL*8     ChannelWidth
      EXTERNAL CxShapeFunction, ChannelWidth
      REAL*8 
     &     x1                   ! interpolation variables
     &     ,x2
     &     ,y1
     &     ,y2
      integer
     &     vsecno               ! number of virtual section (within channel)
     &     ,virtelev            ! number of virtual elevation (within channel)
     &     ,veindex             ! index of virtual elevation array
     &     ,channo              ! dsm channel number
     &     ,dindex              ! function to calculate xsect prop. array index
     &     ,di                  ! stores value of dindex
      REAL*8 
     &     a1                   ! area of lower layer
     &     ,b1                  ! width of lower layer (base of trapezoid)
     &     ,b2                  ! interpolated width (trapezoid top width)

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

c-----statement function to calculate indices of virtual data arrays
      dindex(channo,vsecno,virtelev)
     &     =chan_index(channo) + (vsecno-1)*num_layers(channo) + virtelev-1


      call find_layer_index(
     &     X
     &     ,H
     &     ,Branch
     &     ,channo
     &     ,vsecno
     &     ,virtelev
     &     ,veindex
     &     )

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
c@@@         CxArea = RectangleWidth(Branch,1)*H
c@@@      ELSEIF(CxShapeFunction(X,H)) THEN
c@@@         XiM = 1.0-Xi
c@@@         CxArea = 0.0
c@@@         L1 = Offset(N1)
c@@@         L2 = Offset(N2)

         di=dindex(channo,vsecno,virtelev)
         x1=virt_elevation(veindex)
         x2=H
         a1=virt_area(di)
         b1=virt_width(di)
         b2=ChannelWidth(X,H)
         CxArea = a1+(0.5*(b1+b2))*(x2-x1)

c@@@      ELSE
c@@@         WRITE(unit_error,*) '*** error(CxArea)',Branch,X,H
c@@@         STOP
c@@@      END IF

      RETURN
      END



*=======================================================================
*   Public: CxCentroid
*=======================================================================

      REAL*8 FUNCTION CxCentroid(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate distance from the water surface to the cross-section
*     centroid, in the current channel, at X downstream distance,
*     limited by the lowest point in the channel and a
*     distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/common.f'
      include '../input/fixed/common_irreg_geom.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local variables:
      REAL*8 Small
      PARAMETER (Small = 1.00E-6)

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      REAL*8     CxArea
      EXTERNAL CxShapeFunction, ChannelWidth, CxArea
      REAL*8 
     &     x1                   ! interpolation variables
     &     ,x2
     &     ,y1
     &     ,y2
      integer
     &     vsecno               ! number of virtual section (within channel)
     &     ,virtelev            ! number of virtual elevation (within channel)
     &     ,veindex             ! index of virtual elevation array
     &     ,channo              ! dsm channel number
     &     ,dindex              ! function to calculate xsect prop. array index
     &     ,di                  ! stores value of dindex
      REAL*8 
     &     trap_height          ! height of trapezoid
     &     ,trap_top_width      ! top width of trapezoid
     &     ,trap_bot_width      ! bottom width of trapezoid
     &     ,ChannelWidth        ! function that interpolates top width
     &     ,Aprev               ! area of lower layer
     &     ,Arect               ! area of rectangular region
     &     ,Atria               ! area of triangular region
     &     ,Cprev               ! Z centroid of lower layer
     &     ,Crect               ! Z centroid of rectangular region
     &     ,Ctria               ! Z centroid of triangular region

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Barry Wicktom, Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

c-----statement function to calculate indices of virtual data arrays
      dindex(channo,vsecno,virtelev)
     &     =chan_index(channo) + (vsecno-1)*num_layers(channo) + virtelev-1

      call find_layer_index(
     &     X
     &     ,H
     &     ,Branch
     &     ,channo
     &     ,vsecno
     &     ,virtelev
     &     ,veindex
     &     )

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
c@@@         CxCentroid=H/2.
c@@@      ELSEIF (CxArea(X,H).GT.Small) THEN
c@@@
c@@@         IF(CxShapeFunction(X,H)) THEN
c@@@            XiM = 1.0-Xi
c@@@            CxCentroid = 0.0
c@@@            DX = XDistance(N2)-XDistance(N1)
c@@@
c@@@            L1 = Offset(N1)
c@@@            L2 = Offset(N2)
c@@@
c@@@            Z1 =  H - XiM*Depth(L1) - Xi*Depth(L2)
c@@@            WZ1 =  XiM*Width(L1) + Xi*Width(L2)

      di=dindex(channo,vsecno,virtelev)
      trap_height=  H -virt_elevation(veindex)
      trap_top_width = ChannelWidth(X,H)
      trap_bot_width = virt_width(di)

      if (virtelev .eq. 1) then
         Aprev = 0.0
      elseif (virtelev .gt. 1) then
         Aprev = virt_area(di-1)
      endif

      Arect = min(trap_top_width,trap_bot_width ) * trap_height
      Atria = abs( 0.5 * (trap_top_width-trap_bot_width)*trap_height)
      Cprev = virt_z_centroid(di-1)
      Crect = virt_elevation(veindex) + trap_height/2
      if ( trap_top_width .gt. trap_bot_width) then
         Ctria = virt_elevation(veindex) + (2/3)*trap_height
      elseif ( trap_top_width .lt. trap_bot_width ) then
         Ctria = virt_elevation(veindex) + (1/3)*trap_height
      elseif ( trap_top_width .eq. trap_bot_width ) then
         Ctria = 0.0
      endif
      CxCentroid = H-(
     &     ((Aprev*Cprev) + (Arect*Crect) + (Atria*Ctria)) / (Aprev+Arect+Atria)
     &     )

      if (aprev+arect+atria.eq. 0.0) then
         write(unit_error,*) 'cxcentroid division by zero'
      endif

c@@@         ELSE
c@@@            WRITE(unit_error,*) '*** error(CxCentroid)',Branch,X,H
c@@@            STOP
c@@@         END IF
c@@@
c@@@      ELSE
c@@@         CxCentroid = 0.0
c@@@      ENDIF
      return
      end

*=======================================================================
*   Public: dCxCentroid
*=======================================================================

      REAL*8 FUNCTION dCxCentroid(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate d(centroid distance from surface)/dH,
*     in the current channel, at X downstream distance,
*     limited by the lowest point in the channel and a
*     distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/common.f'
      include '../input/fixed/common_irreg_geom.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local variables:
      REAL*8 Small
      PARAMETER (Small = 1.00E-6)
c@@@      INTEGER I, L1, L2
c@@@      REAL*8    XiM, DX
c@@@      REAL*8    Z1, Z2, WZ1, WZ2, Z2MZ1
      REAL*8 
     &     x1                   ! interpolation variables
     &     ,x2
     &     ,y1
     &     ,y2


      integer
     &     vsecno               ! number of virtual section (within channel)
     &     ,virtelev            ! number of virtual elevation (within channel)
     &     ,veindex             ! index of virtual elevation array
     &     ,channo              ! dsm channel number
     &     ,dindex              ! function to calculate xsect prop. array index
     &     ,di                  ! stores value of dindex

*   Routines by module:

***** Local:
      LOGICAL CxShapeFunction
      REAL*8    ChannelWidth, CxArea, CxCentroid, dChannelWidth
      EXTERNAL CxShapeFunction, ChannelWidth, CxArea
      EXTERNAL CxCentroid, dChannelWidth

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Barry Wicktom, Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

c-----statement function to calculate indices of virtual data arrays
      dindex(channo,vsecno,virtelev)
     &     =chan_index(channo) + (vsecno-1)*num_layers(channo) + virtelev-1

      call find_layer_index(
     &     X
     &     ,H
     &     ,Branch
     &     ,channo
     &     ,vsecno
     &     ,virtelev
     &     ,veindex
     &     )

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
c@@@         dCxCentroid =0.5
c@@@      ELSEIF (CxArea(X,H).GT.Small) THEN

c@@@         IF(CxShapeFunction(X,H)) THEN
c@@@            XiM = 1.0-Xi
c@@@            dCxCentroid = 0.0
c@@@            DX = XDistance(N2)-XDistance(N1)
c@@@            L1 = Offset(N1)
c@@@            L2 = Offset(N2)
c@@@            Z1 =     H - XiM*Depth(L1) - Xi*Depth(L2)
c@@@            WZ1 =    XiM*Width(L1) + Xi*Width(L2)

      di=dindex(channo,vsecno,virtelev)
      x1=virt_elevation(veindex)
      x2=virt_elevation(veindex+1)
      y1=virt_z_centroid(di)
      y2=virt_z_centroid(di+1)

      dCxCentroid = H- (y2-y1)/(x2-x1)

      if (x1.eq.x2) then
         write(unit_error,*) 'dCxcentroid division by zero'
      endif
c@@@         ELSE
c@@@            WRITE(unit_error,*) '*** error(dCxCentroid)',Branch,X,H
c@@@            STOP
c@@@         END IF
*       WRITE(unit_error,*) 'dCxCentroid =',dCxCentroid

c@@@      ELSE
c@@@         dCxCentroid = 0.0
c@@@      ENDIF
      RETURN
      END


*=======================================================================
*   Public: Conveyance
*=======================================================================

      REAL*8 FUNCTION Conveyance(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate sinuosity-weighted conveyance in the current channel,
*     at X downstream distance, limited by the lowest point in the channel
*     and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      REAL*8 R53,R23
      PARAMETER (R53 = 5.0/3.0, R23 = 2.0/3.0)
      REAL*8 Small
      PARAMETER (Small = 1.00E-6)

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      REAL*8     CxArea, WetPerimeter, EffectiveN
      EXTERNAL CxArea, WetPerimeter, EffectiveN, CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          August 1994
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996

*-----Implementation -----------------------------------------------------

      IF (WetPerimeter(X,H).GT.Small) THEN

c@@@         IF(CxShapeFunction(X,H)) THEN
            Conveyance = 1.486*(CxArea(X,H))**R53 *
     &           (EffectiveN(X,H)/(WetPerimeter(X,H))**R23)
c@@@         ELSE
c@@@            WRITE(unit_error,*) '*** error(Conveyance)',Branch,X,H
c@@@            STOP
c@@@         END IF

      ELSE
         Conveyance = 0.0
      ENDIF

      RETURN
      END

*=======================================================================
*   Public: dConveyance
*=======================================================================

      REAL*8 FUNCTION dConveyance(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate d(sinuosity-weighted conveyance)/dH in the current channel,
*     at X downstream distance, limited by the lowest point in the channel
*     and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H
     &     ,EN,Ar,Per

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/common.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      REAL*8 R53,R23
      PARAMETER (R53 = 5.0/3.0, R23 = 2.0/3.0)
      REAL*8 Small
      PARAMETER (Small = 1.00E-6)

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      REAL*8     Conveyance, CxArea, ChannelWidth
      REAL*8     EffectiveN, dEffectiveN
      REAL*8     WetPerimeter, dWetPerimeter
      EXTERNAL CxShapeFunction, Conveyance, CxArea, ChannelWidth
      EXTERNAL EffectiveN, dEffectiveN, WetPerimeter, dWetPerimeter

***** Schematic data:
      INTEGER  CurrentChannel
      EXTERNAL CurrentChannel

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          August 1994
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996

*-----Implementation -----------------------------------------------------

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
c@@@         dConveyance = 0.
c@@@         RETURN
c@@@      ELSEIF (WetPerimeter(X,H).GT.Small) THEN
      if (wetperimeter(x,h).gt.small) then

         EN=EffectiveN(X,H)
         Ar=CxArea(X,H)
         Per=WetPerimeter(X,H)

         dConveyance = 1.486 * (
     &        R53 * ChannelWidth(X,H) * EN
     &        * ( Ar / Per )**R23
     &
     &        - R23 * dWetPerimeter(X,H) * EN
     &        * ( Ar  / Per )**R53
     &
     &        + dEffectiveN(X,H) * Ar**R53
     &        /  Per**R23
     &        )
c@@@         IF(CxShapeFunction(X,H)) THEN
c@@@            dConveyance = 1.486 * (
c@@@     &           R53 * ChannelWidth(X,H) * EffectiveN(X,H)
c@@@     &           * ( CxArea(X,H) / WetPerimeter(X,H) )**R23
c@@@     &
c@@@     &           - R23 * dWetPerimeter(X,H) * EffectiveN(X,H)
c@@@     &           * ( CxArea(X,H)  / WetPerimeter(X,H) )**R53
c@@@     &
c@@@     &           + dEffectiveN(X,H) * CxArea(X,H)**R53
c@@@     &           /  WetPerimeter(X,H)**R23
c@@@     &           )

c@@@         ELSE
c@@@            WRITE(unit_error,*) '*** error(dConveyance)',Branch,X,H
c@@@            STOP
c@@@         END IF

      ELSE
         dConveyance = 0.0
      ENDIF

      IF( dConveyance .LT. 0.0 ) THEN
         IF( H .GT. 0.5 ) THEN
            dConveyance = Conveyance(X,H+.5) - Conveyance(X,H-.5)
         ELSE
            dConveyance = Conveyance(X,H+1.) - Conveyance(X,H)
         END IF
         IF( dConveyance .LT. 0.0 ) THEN
            WRITE(unit_error,610) int2ext(CurrentChannel()),X,H,
     &           ChannelWidth(X,H),CxArea(X,H),Conveyance(X,H),
     &           EffectiveN(X,H),dEffectiveN(X,H),
     &           WetPerimeter(X,H), dWetPerimeter(X,H)
 610        format(/'Error in dConveyance; negative gradient with depth,'
     &           /' suggest reworking adjacent cross section(s).'
     &           /' Channel...',i3
     &           /' X, H...',2f10.2,1p
     &           /' Width, Area, Conveyance...',3g10.3,
     &           /' one over effective n, 1/(dn/dZ)...',2g10.3
     &           /' P, dP/dZ...',2g10.3)
            call exit(2)
         END IF
      END IF

      RETURN
      END

*=======================================================================
*   Public: EffectiveN
*=======================================================================

      REAL*8 FUNCTION EffectiveN(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate one over effective Manning's "n" in the current channel,
*     at X downstream distance,  for the area limited by the lowest point
*     in the channel and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
c@@@      INTEGER I

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
         EffectiveN = OneOverManning(Branch)
c@@@      ELSEIF(CxShapeFunction(X,H)) THEN
c@@@         EffectiveN = 0.0
c@@@         DO 100 I=1,DegreesOfFreedom
c@@@            EffectiveN = EffectiveN+Shape(I)*N(NP(I))
c@@@ 100     CONTINUE
c@@@      ELSE
c@@@         WRITE(unit_error,*) '*** error(EffectiveN)',Branch,X,H
c@@@         STOP
c@@@      END IF

      RETURN
      END

*=======================================================================
*   Public: dEffectiveN
*=======================================================================

      REAL*8 FUNCTION dEffectiveN(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate d(EffectiveN)/dH in the current channel,
*     at X downstream distance,  for the area limited by the lowest point
*     in the channel and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
c@@@      INTEGER I

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
         dEffectiveN = 0.
c@@@         RETURN
c@@@      ELSEIF(CxShapeFunction(X,H)) THEN
c@@@         dEffectiveN = 0.0
c@@@         DO 100 I=1,DegreesOfFreedom
c@@@            dEffectiveN = dEffectiveN+dShapeDX(I)*N(NP(I))
c@@@ 100     CONTINUE
c@@@      ELSE
c@@@         WRITE(unit_error,*) '*** error(dEffectiveN)',Branch,X,H
c@@@         STOP
c@@@      END IF
c@@@      dEffectiveN = dEffectiveN/dH

      RETURN
      END


*=======================================================================
*   Public: WetPerimeter
*=======================================================================

      REAL*8 FUNCTION WetPerimeter(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate wetted perimeter of a cross section in the current channel,
*     at X downstream distance, limited by the lowest point in the channel
*     and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/common.f'
      include '../input/fixed/common_irreg_geom.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
c@@@      INTEGER I

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      REAL*8 
     &     x1                   ! interpolation variables
     &     ,x2
     &     ,y1
     &     ,y2
     &     ,interp              ! interpolation function
      integer
     &     vsecno               ! number of virtual section (within channel)
     &     ,virtelev            ! number of virtual elevation (within channel)
     &     ,veindex             ! index of virtual elevation array
     &     ,channo              ! dsm channel number
     &     ,dindex              ! function to calculate xsect prop. array index
     &     ,di                  ! stores value of dindex

c-----statement function to calculate indices of virtual data arrays
      dindex(channo,vsecno,virtelev)
     &     =chan_index(channo) + (vsecno-1)*num_layers(channo) + virtelev-1
c-----statement function to interpolate wrt two points
      interp(x1,x2,y1,y2,H) =-((y2-y1)/(x2-x1))*(x2-H) + y2 

      call find_layer_index(
     &     X
     &     ,H
     &     ,Branch
     &     ,channo
     &     ,vsecno
     &     ,virtelev
     &     ,veindex
     &     )

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
c@@@         WetPerimeter = RectangleWidth(Branch,1)+2.*H
c@@@      ELSEIF(CxShapeFunction(X,H)) THEN
c@@@         WetPerimeter = 0.0

      di=dindex(channo,vsecno,virtelev)
      x1=virt_elevation(veindex)
      x2=virt_elevation(veindex+1)
      y1=virt_wet_p(di)
      y2=virt_wet_p(di+1)
      WetPerimeter = interp(x1,x2,y1,y2,H)

      if (x1-x2.eq. 0.0) then
         write(unit_error,*) 'wetperimeter division by zero'
      endif

c@@@      ELSE
c@@@         WRITE(unit_error,*) '*** error(WetPerimeter)',Branch,X,H
c@@@         STOP
c@@@      END IF
      RETURN
      END

*=======================================================================
*   Public: dWetPerimeter
*=======================================================================

      REAL*8 FUNCTION dWetPerimeter(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate d(WetPerimeter)/dH of a cross section in the current channel,
*     at X downstream distance, limited by the lowest point in the channel
*     and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/common.f'
      include '../input/fixed/common_irreg_geom.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      REAL*8 
     &     x1                   ! interpolation variables
     &     ,x2
     &     ,y1
     &     ,y2
      integer
     &     vsecno               ! number of virtual section (within channel)
     &     ,virtelev            ! number of virtual elevation (within channel)
     &     ,veindex             ! index of virtual elevation array
     &     ,channo              ! dsm channel number
     &     ,dindex              ! function to calculate xsect prop. array index
     &     ,di                  ! stores value of dindex

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

c-----statement function to calculate indices of virtual data arrays
      dindex(channo,vsecno,virtelev)
     &     =chan_index(channo) + (vsecno-1)*num_layers(channo) + virtelev-1

      call find_layer_index(
     &     X
     &     ,H
     &     ,Branch
     &     ,channo
     &     ,vsecno
     &     ,virtelev
     &     ,veindex
     &     )

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
c@@@         dWetPerimeter = 2.
c@@@         RETURN
c@@@      ELSEIF(CxShapeFunction(X,H)) THEN
c@@@         dWetPerimeter = 0.0

      di=dindex(channo,vsecno,virtelev)
      x1=virt_elevation(veindex)
      x2=virt_elevation(veindex+1)
      y1=virt_wet_p(di)
      y2=virt_wet_p(di+1)

      dWetPerimeter = (y2-y1)/(x2-x1)
         if (x2-x1.eq. 0.0) then
            write(unit_error,*) 'dwetperimeter division by zero'
         endif
c@@@      ELSE
c@@@         WRITE(unit_error,*) '*** error(dWetPerimeter)',Branch,X,H
c@@@         STOP
c@@@      END IF
      RETURN
      END

*=======================================================================
*   Public: Beta
*=======================================================================

      REAL*8 FUNCTION Beta(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate the momentum coefficient in the current channel,
*     at X downstream distance, limited by the lowest point in the channel
*     and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
c@@@      INTEGER I

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
         Beta = 1.
c@@@      ELSEIF(CxShapeFunction(X,H)) THEN
c@@@         Beta = 0.0
c@@@         DO 100 I=1,DegreesOfFreedom
c@@@            Beta = Beta+Shape(I)*Bta(NP(I))
c@@@ 100     CONTINUE
c@@@      ELSE
c@@@         WRITE(unit_error,*) '*** error(Beta)',Branch,X,H
c@@@         STOP
c@@@      END IF

      RETURN
      END

*=======================================================================
*   Public: dBeta
*=======================================================================

      REAL*8 FUNCTION dBeta(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate d(Beta)/dH in the current channel,
*     at X downstream distance, limited by the lowest point in the channel
*     and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
c@@@      INTEGER I

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

c@@@      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
c@@@         dBeta = 0.0
c@@@         RETURN
c@@@      ELSEIF(CxShapeFunction(X,H)) THEN
         dBeta = 0.0
c@@@         DO 100 I=1,DegreesOfFreedom
c@@@            dBeta = dBeta+dShapeDX(I)*Bta(NP(I))
c@@@ 100     CONTINUE
c@@@      ELSE
c@@@         WRITE(unit_error,*) '*** error(dBeta)',Branch,X,H
c@@@         STOP
c@@@      END IF

c@@@      dBeta = dBeta/dH

      RETURN
      END

*=======================================================================
*   Public: AreaWtSinuosity
*=======================================================================

      REAL*8 FUNCTION AreaWtSinuosity(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate area-weighted sinuosity in the current channel,
*     at X downstream distance,  for the area limited by the lowest point
*     in the channel and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER I

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
         AreaWtSinuosity = 1.0
      ELSEIF(CxShapeFunction(X,H)) THEN
         AreaWtSinuosity = 0.0
         DO 100 I=1,DegreesOfFreedom
            AreaWtSinuosity = AreaWtSinuosity+Shape(I)*MA(NP(I))
 100     CONTINUE
      ELSE
         WRITE(unit_error,*) '*** error(AreaWtSinuosity)',Branch,X,H
         STOP
      END IF

      RETURN
      END

*=======================================================================
*   Public: dAreaWtSinuosity
*=======================================================================

      REAL*8 FUNCTION dAreaWtSinuosity(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate d(area-weighted sinuosity)/dH in the current channel,
*     at X downstream distance,  for the area limited by the lowest point
*     in the channel and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER I

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
         dAreaWtSinuosity = 0.0
         RETURN
      ELSEIF(CxShapeFunction(X,H)) THEN
         dAreaWtSinuosity = 0.0
         DO 100 I=1,DegreesOfFreedom
            dAreaWtSinuosity = dAreaWtSinuosity+dShapeDX(I)*MA(NP(I))
 100     CONTINUE
      ELSE
         WRITE(unit_error,*) '*** error(dAreaWtSinuosity)',Branch,X,H
         STOP
      END IF

      dAreaWtSinuosity = dAreaWtSinuosity/dH

      RETURN
      END

*=======================================================================
*   Public: QWtSinuosity
*=======================================================================

      REAL*8 FUNCTION QWtSinuosity(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate discharge-weighted sinuosity in the current channel,
*     at X downstream distance,  for the area limited by the lowest point
*     in the channel and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER I

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
         QWtSinuosity = 1.0
      ELSEIF(CxShapeFunction(X,H)) THEN
         QWtSinuosity = 0.0
         DO 100 I=1,DegreesOfFreedom
            QWtSinuosity = QWtSinuosity+Shape(I)*MQ(NP(I))
 100     CONTINUE
      ELSE
         WRITE(unit_error,*) '*** error(QWtSinuosity)',Branch,X,H
         STOP
      END IF

      RETURN
      END

*=======================================================================
*   Public: dQWtSinuosity
*=======================================================================

      REAL*8 FUNCTION dQWtSinuosity(X, H)

      IMPLICIT NONE

*   Purpose:
*     Estimate d(discharge-weighted sinuosity)/dH in the current channel,
*     at X downstream distance,  for the area limited by the lowest point
*     in the channel and a distance H above the lowest point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER I

*   Routines by module:

***** Local:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      IF(Rectangular(Branch).AND.Prismatic(Branch))THEN
         dQWtSinuosity = 0.0
         RETURN
      ELSEIF(CxShapeFunction(X,H)) THEN
         dQWtSinuosity = 0.0
         DO 100 I=1,DegreesOfFreedom
            dQWtSinuosity = dQWtSinuosity+dShapeDX(I)*MQ(NP(I))
 100     CONTINUE
      ELSE
         WRITE(unit_error,*) '*** error(dQWtSinuosity)',Branch,X,H
         STOP
      END IF
      dQWtSinuosity = dQWtSinuosity/dH

      RETURN
      END

*=======================================================================
*   Private: CxShapeFunction
*=======================================================================

      LOGICAL FUNCTION CxShapeFunction(X, H)

      IMPLICIT NONE

*   Purpose:
*     Compute common factors governing the interpolation of hydraulic
*     properties at a point.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:

      LOGICAL ok

*   Routines by module:

***** Local:
      LOGICAL  SetXi, SetEta, BiLinearShapeFunction

***** Buffered output:
      EXTERNAL SetXi, SetEta, BiLinearShapeFunction

***** Channel status:
      LOGICAL  WriteNetworkRestartFile
      EXTERNAL WriteNetworkRestartFile

***** Schematic data:
      LOGICAL  CloseChannel
      EXTERNAL CloseChannel

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      CxShapeFunction = .FALSE.

      IF(     Branch .NE. PreviousBranch
     &     .OR.
     &     INT(X) .NE. PreviousX
     &     .OR.
     &     INT(100.0*H) .NE. PreviousH100   ) THEN

         PreviousBranch = Branch
         PreviousX      = INT(X)
         PreviousH100   = INT(100.0*H)

*--------Determine relative longitudinal location of a point
*       within a branch.

         IF(SetXi(X)) THEN

*-----------Determine relative vertical location of the point.
            IF(SetEta(X,H)) THEN

*--------------Compute bi-linear shape functions.
               IF(BiLinearShapeFunction()) THEN
               END IF

            ELSE

               ok = CloseChannel()
               WRITE(unit_error,*) ' Flushing series buffer...'

*--------------Write network restart file.
               WRITE(unit_error,*) ' Writing restart file if requested...'
               ok = WriteNetworkRestartFile()

               WRITE(unit_error,*) '*** error(CxShapeFunction)..branch,X',Branch,X
               WRITE(unit_error,*) ' '
               WRITE(unit_error,*) ' Abnormal program end.'
               CALL EXIT(2)
            END IF
         ELSE
            WRITE(unit_error,*) '*** error(CxShapeFunction)..branch,X',Branch,X
            WRITE(unit_error,*) ' '
            WRITE(unit_error,*) ' Abnormal program end.'
            STOP
         END IF
      END IF

      CxShapeFunction = .TRUE.

      RETURN
      END

*=======================================================================
*   Private: SetXi
*=======================================================================

      LOGICAL FUNCTION SetXi(X)

      IMPLICIT NONE

*   Purpose:
*     Locate current point in relation to X locations of existing tables.

*   Arguments:
      REAL*8    X

*   Argument definitions:
*     X - downstream distance.

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER I, II

*   Routines by module:

***** Local:

*   Intrinsics:
      INTEGER   INT
      INTRINSIC INT

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified: Sept  1993
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      SetXi = .FALSE.

      DO 100 II=FirstTable(Branch),LastTable(Branch)
         I = II
         IF( X .LT. XDistance(I) ) GO TO 200
 100  CONTINUE

      IF(INT(X).NE.INT(XDistance(LastTable(Branch)))) THEN
         WRITE(unit_error,*) ' *** warning(SetXi)'
         WRITE(unit_error,*) X,' > maximum XDistance = ',
     &        XDistance( LastTable(Branch) )
      END IF

 200  CONTINUE

      IF( INT(X) .NE. INT(XDistance(FirstTable(Branch))) ) THEN
         IF( I .NE. FirstTable(Branch) ) THEN
            N1 = I-1
            N2 = I
            Xi = (X-XDistance(N1))/(XDistance(N2)-XDistance(N1))
         ELSE
            WRITE(unit_error,*) '*** error(SetXi)'
            WRITE(unit_error,*) X, '< minimum XDistance = ',
     &           XDistance(FirstTable(Branch))
            Xi = 0.0
         END IF
      ELSE

         N1 = FirstTable(Branch)
         N2 = N1 + 1
         Xi = 0.0

      END IF

      DegreesOfFreedom = 4

      SetXi = .TRUE.

      RETURN
      END

*=======================================================================
*   Private: SetEta
*=======================================================================

      LOGICAL FUNCTION SetEta(X, H)

      IMPLICIT NONE

*   Purpose:
*     Locate current point (H) in relation to depths tabulated at
*     XDistance(N1) and XDistance(N2).  N1 and N2 must be current.

*   Arguments:
      REAL*8    X, H

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER I, L1, L2
      REAL*8    XiM

*   Routines by module:

***** Local:

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      SetEta = .FALSE.
      XiM = 1.0-Xi

*---- Determine which pair of upstream-downstream points bracket the
*     interpolation point on the top and then exit the loop.

      L1 = Offset(N1)-1
      L2 = Offset(N2)-1
      DO 100 I=1,Lines(Branch)
         L1 = L1+1
         L2 = L2+1

         IF(H .LT. (XiM*Depth(L1)+Xi*Depth(L2))) GO TO 200
 100  CONTINUE

      IF(H .GT. (XiM*Depth(L1)+Xi*Depth(L2) + 1.0) ) THEN
         WRITE(unit_error,*) ' '
         WRITE(unit_error,*) ' *** warning(SetEta)'
         WRITE(unit_error,*) ' Channel =',Branch,' X = ',X
         WRITE(unit_error,*) ' ',H,' > maximum tabulated depth,'
         WRITE(unit_error,*) ' (the line connecting ',Depth(L1),
     &        ' and ',Depth(L2),') ...'
      END IF

 200  CONTINUE

      IF(I.NE.1) THEN
         NP(1) = L1-1
         NP(2) = L2-1
         NP(3) = L2
         NP(4) = L1
         dH =      XiM*(Depth(NP(4))-Depth(NP(1)))
     &        +Xi*(Depth(NP(3))-Depth(NP(2)))
         Eta = (H-XiM*Depth(NP(1))-Xi*Depth(NP(2)))/dH

         IF(Eta.LT.-1.0E-06) THEN
            WRITE(unit_error,*) ' '
            WRITE(unit_error,*) 'SetEta...'
            WRITE(unit_error,*) 'eta = ',Eta
            WRITE(unit_error,*) 'depths = '
            WRITE(*,'(4F12.2)') (Depth(NP(I)),I=1,4)
            WRITE(unit_error,*) 'dH = ',dH,'  Xi = ',Xi
         END IF

      ELSE
         WRITE(unit_error,*) ' '
         WRITE(unit_error,*) '*** error(SetEta)'
         WRITE(unit_error,*) ' Channel =',Branch,' X = ',X
         WRITE(unit_error,*) ' ',H, '< minimum depth,'
         WRITE(unit_error,*) ' (the average of ',Depth(Offset(N1)),' and ',
     &        Depth(Offset(N2)),') ...'

         RETURN
      END IF

      SetEta = .TRUE.

      RETURN
      END

*=======================================================================
*   Private: BiLinearShapeFunction
*=======================================================================

      LOGICAL FUNCTION BiLinearShapeFunction()

      IMPLICIT NONE

*   Purpose:
*     Compute bi-linear shape functions in local coordinates.

*   Arguments:

*   Argument definitions:

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:

*   Routines by module:

***** Local:
      real*8 fact,sum
      integer i

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      Shape(1)    = (1.0-Xi)*(1.0-Eta)
      dShapeDX(1) = -1.0+Xi
      Shape(2)    = Xi*(1.0-Eta)
      dShapeDX(2) = -Xi

      IF(DegreesOfFreedom.EQ.4) THEN
         Shape(3)    = Xi*Eta
         dShapeDX(3) = Xi
         Shape(4)    = (1.0-Xi)*Eta
         dShapeDX(4) = 1.0-Xi
         sum=Shape(1)+Shape(2)+Shape(3)+Shape(4)
         if(abs(sum-1.).gt.1.e-8)then
            fact=(1.-sum)/4.
            do i=1,4
               Shape(i)=Shape(i)+fact
            enddo
         endif
      END IF

      BiLinearShapeFunction = .TRUE.

      RETURN
      END

*=======================================================================
*   Private: ReadCxProperties
*=======================================================================

      LOGICAL FUNCTION ReadCxProperties
     &     ( INUNIT,M,NPRT,
     &     DUM,LNUM,USR,
     &     ICARD         )

      IMPLICIT NONE

*   Purpose:
*     Read hydraulic properties and geometry for 1 cross section.

*   Arguments:
      INTEGER INUNIT, USR, LNUM, M, NPRT
      CHARACTER*80 DUM
      CHARACTER*2 ICARD

*   Argument definitions:
*     INUNIT - FORTRAN unit number
*     M      - current branch number
*     NPRT   - screen output index
*              [0] no screen output
*              [1] write to screen
*     DUM    - a line read from properties input file
*     LNUM   - current line number
*     USR    - current cross-section number
*     ICARD  - record index
*              [CH] branch header
*              [HY] cross-section header
*              [DP] properties record

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER I, J, NPT, BRN
      REAL*8    R(8), R23, R53
      PARAMETER (R23 = 2.0/3.0, R53 = 5.0/3.0)
      LOGICAL FIRST, FirstLine

*   Variable definitions:
*     R      - hydraulic properties of channel
*              [1] depth
*              [2] area
*              [3] conveyance
*              [4] beta
*              [5] area-weighted sinuosity
*              [6] conveyance-weighted sinuosity
*              [7] width
*              [8] wetted perimeter

*   Routines by module:

***** Local:

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      ReadCxProperties = .FALSE.

      NPT=0
      READ(DUM,'(A2)') ICARD

      IF(ICARD.EQ.'CH') THEN
         READ(DUM,'(2X,I10)') BRN
         FIRST = .TRUE.

         IF(BRN.NE.M) THEN
            WRITE(unit_error,*) 'Branch numbers are not in correct sequence.'
            WRITE(unit_error,*) BRN,' changed to ',M,'....'
            BRN = M
         END IF

         IF(NPRT .GT. 0 ) THEN
            WRITE(unit_error,*) ' '
            WRITE(unit_error,*) ' '
            WRITE(unit_error,*) 'Currently reading...'
            WRITE(*,'(A80)') DUM
         END IF
         FirstTable(BRN) = USR+1
         READ(INUNIT,'(80A)',END=50) DUM
         READ(DUM,'(A2)') ICARD
         GO TO 60
 50      CONTINUE

         WRITE(unit_error,*)'***error(ReadCxProperties) unexpected end of file.'
         WRITE(unit_error,*) 'Branch',BRN
         ICARD = 'EN'

 60      CONTINUE
      END IF

      IF(ICARD.EQ.'HY') THEN
         USR = USR+1

         FirstLine = .TRUE.

         IF(USR.GT.MaxTables) THEN
            WRITE(unit_error,*) '***error (ReadCxProperties)'
            WRITE(unit_error,*) 'Maximum number of tables (',
     &           MaxTables,') exceeded.'
            WRITE(unit_error,*) 'Returning...'
         END IF

         READ(DUM,'(3X,A16,1X,F10.0,1X,F10.0)')
     &        ID(USR),XDistance(USR),Datum(USR)

         IF(NPRT.GT.0) THEN
            WRITE(*,'(I10,F16.2)') USR,XDistance(USR)
         END IF

         Offset(USR) = LNUM+1

         IF((LNUM+Lines(BRN)) .GT. MaxLines) THEN
            WRITE(unit_error,*) '***error (ReadCxProperties)'
            WRITE(unit_error,*) 'Maximum number of lines exceeded...'
            WRITE(unit_error,*) 'Cross section ',USR
            WRITE(unit_error,*) 'Current line number = ',LNUM
            WRITE(unit_error,*) 'Returning...'
            RETURN
         END IF

      ELSE
         WRITE(unit_error,*) '***ERROR (ReadCxProperties) expecting HY record.'
         WRITE(unit_error,*) 'Returning...'
         ReadCxProperties = .FALSE.
         RETURN
      END IF

      DO 100 I =1,Lines(BRN)+1
         READ(INUNIT,'(80A)',END=102) DUM
         READ(DUM,'(A2)') ICARD

         IF(ICARD.NE.'DP') THEN

            IF(FIRST) THEN
               FIRST = .FALSE.
               Lines(BRN) = NPT
            ELSE

               IF(Lines(BRN).GT.MaxLinesPerTable) THEN
                  WRITE(unit_error,*) '***error (ReadCxProperties)'
                  WRITE(unit_error,*) 'Lines per table exceeded.'
                  WRITE(unit_error,*) 'Current = ',Lines(BRN),
     &                 ', MaxLinesPerTable = ',MaxLinesPerTable
                  WRITE(unit_error,*) 'Returning...'
                  RETURN
               END IF

            END IF
            GO TO 102

         ELSE IF(ICARD.EQ.'DP') THEN
            LNUM = LNUM+1
            NPT = NPT+1

            IF(NPT.LE.Lines(BRN)) THEN
               READ(DUM,
     &              '(3X,F10.0,2(1X,E13.6),  3(1X,F5.0),   2(1X,F7.0))')
*               depth,   area,K     beta,Ma,Mq      width,Wp
     &              (R(J),J=1,8)

               IF(NPRT.GT.1) THEN
                  WRITE(*,
     &                 '(3X,F10.2,2(1X,E13.6),  3(1X,F5.2),   2(1X,F7.2))')
     &                 (R(J),J=1,8)
               END IF

*--------------Assign hydraulic properties.
               Depth(LNUM) = R(1)
               A(LNUM)     = R(2)
               K(LNUM)     = R(3)
               Bta(LNUM)   = R(4)
               MA(LNUM)    = R(5)
               MQ(LNUM)    = R(6)
               Width(LNUM) = R(7)
               P(LNUM)     = R(8)

*--------------Check for adverse conveyance gradient with depth.
               IF( .NOT. FirstLine ) THEN

                  IF( K(LNUM) .LE. K(LNUM-1) ) THEN
                     WRITE(unit_error,*) ' ***error (ReadCxProperties) adverse ',
     &                    'conveyance gradient,'
                     WRITE(unit_error,*) ' Channel...',M, ' Cross section...',ID(USR),
     &                    ' conveyance...',K(LNUM)
                  END IF

               ELSE
                  FirstLine = .FALSE.
               END IF

*--------------Compute one over effective n.
               IF(A(LNUM).GT.0.1) THEN
                  N(LNUM) = (P(LNUM)**R23*K(LNUM))/(1.486*A(LNUM)**R53)
               ELSE
                  N(LNUM) = 0.0
               END IF

            ELSE
               WRITE(unit_error,*) 'Too many lines...'
               WRITE(unit_error,*) 'I = ',I,'  Lines = ',Lines(BRN)
            END IF

         END IF

 100  CONTINUE
      WRITE(unit_error,*) '***ERROR (ReadCxProperties)'
      WRITE(unit_error,*)
     &     'Maximum number of lines per table (',Lines(BRN),') exceeded.'
      WRITE(unit_error,*) 'Last line read...'
      WRITE(*,'(A80)') DUM
      WRITE(unit_error,*) 'I = ',I,' NPT = ',NPT,'LNUM = ',LNUM
      WRITE(unit_error,*) 'Returning ...'
      ReadCxProperties = .FALSE.
      RETURN
 102  CONTINUE

      IF(ICARD.EQ.'DP') THEN
         ICARD = 'EN'
      END IF

      LastTable(BRN) = USR
      IF(NPT.EQ.Lines(BRN)) THEN

*--------The following statements correct for zero values of
*         momentum & sinuosity coefficients when the first
*         value in the input table is at zero area.

         IF(Bta(Offset(USR)).LT.1.0E-06)
     &        Bta(Offset(USR)) = Bta(Offset(USR)+1)
         IF(MA(Offset(USR)).LT.1.0E-06)
     &        MA(Offset(USR)) = MA(Offset(USR)+1)
         IF(MQ(Offset(USR)).LT.1.0E-06)
     &        MQ(Offset(USR)) = MQ(Offset(USR)+1)
         IF(N(Offset(USR)).LT.1.0E-06)
     &        N(Offset(USR)) = N(Offset(USR)+1)

         ReadCxProperties = .TRUE.

      ELSE IF(NPT.LT.Lines(BRN)) THEN
         WRITE(unit_error,*) '***ERROR (ReadCxProperties)'
         WRITE(unit_error,*) 'Fewer than expected (',Lines(BRN),
     &        ') lines per cross section.'
      END IF

      RETURN
      END

*=======================================================================
*   Private: Read1stCxLine
*=======================================================================

      LOGICAL FUNCTION Read1stCxLine
     &     (
     &     NPRT,DUM)

      IMPLICIT NONE

*   Purpose:
*     Open a flat file and read an 80-character record.

*   Arguments:
      INTEGER NPRT
      CHARACTER*80  DUM

*   Argument definitions:
*     NPRT - index for output,
*            [0] no output,
*            [1] echo input.
*     DUM  - an 80-character record read from the file INAME.

      include '../input/fixed/misc.f'

*   Module data:

*   Local Variables:
      INTEGER INUNIT
      CHARACTER*12 INNAME, InternalFileName

*   Routines by module:

***** Master File:
      INTEGER GetFileUnit
      CHARACTER*12 GetFileName

***** File utilities:
      LOGICAL  OpenOldText
      EXTERNAL OpenOldText

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      InternalFileName = 'cxgeom.dat'

      INUNIT = GetFileUnit(InternalFileName)
      INNAME = GetFileName(InternalFileName)

      IF(OpenOldText(INUNIT,INNAME)) THEN
         READ(INUNIT,'(A80)') DUM
         READ(DUM,*)     NPRT
         READ(INUNIT,'(80A)') DUM
         Read1stCxLine = .TRUE.
      ELSE
         WRITE(unit_error,*) '***ERROR (Read1stCxLine) file not opened.'
         WRITE(*,'(A)') INNAME
         WRITE(unit_error,*) 'Returning...'
         Read1stCxLine = .FALSE.
      END IF

      RETURN
      END

*=======================================================================
*   Private: RiverFtToDownStream
*=======================================================================

      LOGICAL FUNCTION RiverFtToDownStream(M)

      IMPLICIT NONE

*   Purpose:
*     Convert river feet to downstream distance.

*   Arguments:
      INTEGER M

*   Argument definitions:
*     M - branch number.

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER I, J

*   Routines by module:

***** Local:

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      IF( (XDistance(LastTable(M))-XDistance(FirstTable(M)))
     &     .LT. 1.0E-06 ) THEN

         DO 100 I=FirstTable(M),LastTable(M)
            XDistance(I) = -XDistance(I)
 100     CONTINUE

      END IF

      DO 200 I=FirstTable(M)+1,LastTable(M)
         IF( (XDistance(I)-XDistance(I-1)) .LT. 1.0E-06 ) THEN
            WRITE(unit_error,*) '***ERROR (RiverFtToDownStream)'
            WRITE(unit_error,*) 'X coordinates out of order...'
            WRITE(unit_error,*) 'Branch',Branch
            WRITE(*,'(I5,F15.2)')
     &           (J,XDistance(J),J=FirstTable(M),LastTable(M))
            RiverFtToDownStream = .FALSE.
            RETURN
         END IF

 200  CONTINUE

      RiverFtToDownStream = .TRUE.

      RETURN
      END

*======================================================================
*   Public: AdjustChannelWidths
*=======================================================================

      LOGICAL FUNCTION AdjustChannelWidths()

      IMPLICIT NONE

*   Purpose:
*     Compute and tabulate cross-section widths consistent with
*     cross-sectional tabulated areas.
*

*   Arguments:

*   Argument definitions:

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER I, II, ONE, TWO, M, END, CxCount, LineCount
      INTEGER J
      REAL*8    dB( MaxLinesPerTable )

*   Routines by module:

***** Local:

*   Intrinsics:
      INTEGER   INT
      INTRINSIC INT

*   Programmed by: Lew DeLong
*   Date:          Jan   1994

*-----Implementation -----------------------------------------------------

      AdjustChannelWidths = .FALSE.
      CxCount = 0
      LineCount = 0

      DO 300 M=1,NumCh
         DO 200 II=FirstTable(M),LastTable(M)

            CxCount = CxCount + 1

*-----------Compute change in bottom width.
            ONE = Offset(II)
            TWO = ONE+1
            dB(1) = ( A(TWO) - A(ONE)
     &           - .5*(Width(ONE)+Width(TWO))*(Depth(TWO)-Depth(ONE))
     &           ) / ( 2.0*(Depth(TWO)-Depth(ONE)) )

*-----------Check for negative widths and reset if necessary.

            IF( Width(ONE)+dB(1) .GT. 0.0 ) THEN
            ELSE

               dB(1) = 0.0

            END IF

*-----------Equate wetted perimeter, at the channel bottom, to bottom width.
            P(ONE) = Width(ONE) + dB(1)

*-----------Equate values of sinuosity and beta at the bottom of the channel
*         to those at the top of the lowest trapezoid.
            Bta(ONE) = Bta(TWO)
            MA(ONE)  = MA(TWO)
            MQ(ONE)  = MQ(TWO)

*-----------Compute change in widths at the top of second and higher trapezoids.
            IF(Lines(M).GE.3) THEN
               END   = ONE+Lines(M)-2
               J = 1
               DO 100 I=TWO,END

                  J = J + 1
                  dB(J) = (A(I+1)-A(I-1))/(Depth(I+1)-Depth(I-1))
     &                 -.25*(Width(I-1)+2.0*Width(I)+Width(I+1))

 100           CONTINUE
            END IF

            J = J + 1
            I = END + 1
            dB(J) = ( A(I) - A(I-1)
     &           - .5*(Width(I)+Width(I-1))*(Depth(I)-Depth(I-1))
     &           ) / ( 2.0*(Depth(I)-Depth(I-1)) )

            J = 0
            DO 110 I=ONE,END+1
               J = J + 1
               Width(I) = Width(I) + dB(J)
 110        CONTINUE

            IF( Print ) THEN
               WRITE(unit_error,*) ' '
               WRITE(unit_error,*) ' Cross section...',ID(CxCount)
               WRITE(unit_error,*) '  Depth     Adjusted Width 1/Effective n'
               DO 150 I=1,Lines(M)
                  LineCount = LineCount + 1
                  WRITE(*,'(F6.2,6X,F10.2,4X,F6.3)')
     &                 Depth(LineCount), Width(LineCount), N(LineCount)
 150           CONTINUE
            END IF

 200     CONTINUE
 300  CONTINUE

      AdjustChannelWidths = .TRUE.

      RETURN
      END

*=======================================================================
*   Public: SingleTrap
*=======================================================================

      LOGICAL FUNCTION SingleTrap()

      IMPLICIT NONE

*   Purpose:
*     Roughly approximate tabulated properties with a single trapezoid
*     write resulting cross-section properties in a form suitable for
*     use with the simple trapezoidal-properties module.
*

*   Arguments:

*   Argument definitions:

      include '../input/fixed/misc.f'

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'

*   Local Variables:
      INTEGER II, M, UN, TopLine
      REAL*8    MaxArea, MaxDepth, MaxWidth, BottomWidth, dWdH
      REAL*8    ApproxN
      CHARACTER*12 FileName

*   Routines by module:

***** Local:

***** File utilities:
      LOGICAL  OpenNewText
      EXTERNAL OpenNewText

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1993
*   Modified by:
*   Last modified:
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      SingleTrap = .FALSE.

      UN = 57
      FileName = 'geomtrap.dat'

      IF( OpenNewText( UN, FileName ) ) THEN
         WRITE(UN,*) '0', ' / output index ( 0 - no echo, 1 - echo ).'
      ELSE
         WRITE(unit_error,*) ' Could not open ', FileName
         WRITE(unit_error,*) ' Approximate single trapezoids not computed.'
         RETURN
      END IF

      DO 300 M=1,NumCh
         WRITE(UN,*) ' '
         WRITE(UN,*) M,' / channel number.'
         II = FirstTable(M)
         ApproxN = N( Offset(II) + Lines(II) - 1 )
         II = LastTable(M)
         ApproxN =  0.5 * (
     &        ApproxN + N( Offset(II) + Lines(II) - 1 )
     &        )

         WRITE(UN,*) ApproxN,' / 1/effective n.'

         DO 200 II=FirstTable(M),LastTable(M),LastTable(M)-FirstTable(M)

*-----------Compute bottom width.

            TopLine = Offset(II) + Lines(II) - 1
            MaxArea = A( TopLine )
            MaxWidth = Width( TopLine )
            MaxDepth = Depth( TopLine )
            BottomWidth = 2.0 * MaxArea / MaxDepth - MaxWidth

*-----------Check for negative widths and recompute if necessary.

            IF( BottomWidth .GE. 0.0 ) THEN

               dWdH = (MaxWidth - BottomWidth) / MaxDepth

            ELSE

               BottomWidth = 0.0
               dWdH = 2.0 * MaxArea / ( MaxDepth ** 2 )

            END IF

*-----------Write properties.

            WRITE(UN,*) ID(II), ' / ID.'
            WRITE(UN,*) XDistance(II), BottomWidth, Datum(II), dWdH

 200     CONTINUE

 300  CONTINUE

      SingleTrap = .TRUE.

      RETURN
      END

*== Public (InitChnlBtmHermites) ================================================

      LOGICAL FUNCTION InitChnlBtmHermites()

      IMPLICIT NONE

*   Purpose:  Initialize values necessary for interpolating
*             channel bottom elevation and slope using
*             hermite cubics.

*   Arguments:

*   Argument definitions:

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'
      INCLUDE 'herman.inc'

*   Local Variables:
      INTEGER I, J, M
      INTEGER Points, FirstPoint

*   Routines by module:

***** Local:

      EXTERNAL HMMM, HGRAD

***** Schematic data:
      INTEGER  NumberOfChannels
      EXTERNAL NumberOfChannels

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          Oct   1993
*   Modified by:
*   Last modified:

*-----Implementation -----------------------------------------------------

      InitChnlBtmHermites = .FALSE.

*---- Set known values.

      J = -1
      DO 100 I=1,MaxTables
         J = J + 2
         XHerm(J) = XDistance(I)
         ZHerm(J) = Datum(I)
 100  CONTINUE

*---- Estimate gradients.

      DO 500 M=1,NumberOfChannels()

         Points = 2 * (LastTable(M) - FirstTable(M) + 1)
         FirstPoint = 2 * FirstTable(M) - 1
         CALL HMMM( Points, XHerm(FirstPoint) )
*       write(*,'(I4,2F12.4)') (I,XHerm(I),XHerm(I+1),I=1,Points,2)
         CALL HMMM( Points, ZHerm(FirstPoint) )
*       write(*,'(I4,2F12.4)') (I,ZHerm(I),ZHerm(I+1),I=1,Points,2)
         CALL HGRAD( Points,XHerm(FirstPoint),ZHerm(FirstPoint) )
*       write(*,'(I4,2F12.4)') (I,XHerm(I),XHerm(I+1),I=1,Points,2)

 500  CONTINUE

*     write(*,'(I4,4F12.4)')
*    #     ( I,XHerm(I),XHerm(I+1),ZHerm(I),ZHerm(I+1),
*    #      I=1,Points,2 )

      InitChnlBtmHermites = .TRUE.

      RETURN
      END

*== Public (HermBtmElev) ================================================

      REAL*8 FUNCTION HermBtmElev()

      IMPLICIT NONE

*   Purpose:  Compute bottom elevation using Hermite interpolation.

*   Arguments:

*   Argument definitions:

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'
      INCLUDE 'herman.inc'

*   Local Variables:
      INTEGER m
      REAL*8    dX

*   Routines by module:

***** Local:

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          Oct   1993
*   Modified by:
*   Last modified:

*-----Implementation -----------------------------------------------------

      dX = XDistance(N2) - XDistance(N1)
      m = 2 * N1 - 1

      HermBtmElev =
     &     (Xi-1.0)**2 * (2.0*Xi+1.0) * ZHerm(m  )
     &     +  Xi * (Xi-1.0)**2 * dX     * ZHerm(m+1)
     &     -  Xi**2 * (2.0*Xi-3.0)      * ZHerm(m+2)
     &     +  Xi**2 * (Xi-1.0) * dX     * ZHerm(m+3)

      RETURN
      END

*== Public (HermBtmSlope) ================================================

      REAL*8 FUNCTION HermBtmSlope()

      IMPLICIT NONE

*   Purpose:  Compute bottom slope using Hermite interpolation.

*   Arguments:

*   Argument definitions:

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'chcxtbl.inc'
      INCLUDE 'herman.inc'

*   Local Variables:
      INTEGER m
      REAL*8    dX

*   Routines by module:

***** Local:

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          Oct   1993
*   Modified by:
*   Last modified:

*-----Implementation -----------------------------------------------------

      dX = XDistance(N2) - XDistance(N1)
      m = 2 * N1 - 1

      HermBtmSlope =
     &     6.0*Xi * (Xi-1.0) / dX    * ZHerm(m  )
     &     +  (Xi-1.0) * (3.0*Xi-1.0)   * ZHerm(m+1)
     &     -  6.0*Xi * (Xi-1.0) / dX    * ZHerm(m+2)
     &     +  Xi * (3.0*Xi-2.0)         * ZHerm(m+3)

      RETURN
      END

      SUBROUTINE   HMMM
     &     (NPT,
     &     HDATA)

C     + + + PURPOSE + + +

C     Compute mean incremental changes in a sequence of numbers.
C     The numbers are input as the odd elements of HDATA(). Mean
C     incremental changes are computed and stored as even elements.

C     + + + DUMMY ARGUMENTS + + +
      INTEGER   NPT
      REAL*8   HDATA(NPT)

C     + + + ARGUMENT DEFINITIONS + + +
C     NPT    - total number of elements in HDATA()
C     HDATA  - floating point array, odd elements of which
C-----are the sequence of numbers from which mean incremental
C-----changes will be computed

C     + + + LOCAL VARIABLES + + +
      INTEGER   I,MPT
      REAL*8   D,E,XP,XM,TEST

C     + + + INTRINSICS + + +
      INTRINSIC ABS

C     + + + END SPECIFICATIONS + + +

      HDATA(2)=HDATA(3)-HDATA(1)
      XM=HDATA(2)
      MPT=NPT-2
      IF(MPT.GT.3) THEN
         DO 100 I=3,MPT,2
            XP=HDATA(I+2)-HDATA(I)
            D=XP+XM
            E=XP*XM
            TEST=ABS(D)
            IF(TEST.GT.1.0E-30.AND.E.GT.0.0) THEN
               HDATA(I+1)=2.0*E/D
            ELSE
               HDATA(I+1)=0.0
            END IF
            XM=XP
 100     CONTINUE
         HDATA(NPT)=XP
      ELSE
         HDATA(4)=HDATA(2)
      END IF

      RETURN
      END

      SUBROUTINE  HGRAD
     &     (NPT,
     &     HX,HY)

C     + + + PURPOSE + + +
C     Compute an array of gradients from previously
C     computed incremental changes. Mean incremental changes in the values
C     stored in odd elements of the arrays are input in corresponding
C     even elements of the arrays. Thus:
C     .
C-----Gradient = dY/dX = HY(even)/HX(even),
C     .
C-----and are stored as
C     .
C-----HY(even) = gradient.

C     + + + DUMMY ARGUMENTS + + +
      INTEGER   NPT
      REAL*8   HX(NPT),HY(NPT)

C     + + + ARGUMENT DEFINITIONS + + +
C     NPT    - number of elements in HX() & HY() arrays
C     HX     - array of floating-point values, even elements are mean
C-----mean incremental change in values stored in odd elements.
C     HY     - array of floating-point values similar to HX()

C     + + + LOCAL VARIABLES + + +
      INTEGER   I

C     + + + END SPECIFICATIONS + + +

      DO 100 I=2,NPT,2
         HY(I)=HY(I)/HX(I)
 100  CONTINUE

      RETURN
      END

      subroutine find_layer_index(
     &     X
     &     ,H
     &     ,Branch
     &     ,channo
     &     ,vsecno
     &     ,virtelev
     &     ,veindex
     &     )

      implicit none

      include '../input/fixed/common.f'
      include '../input/fixed/common_irreg_geom.f'



      integer
     &     Branch               ! hydro channel number
     &     ,channo              ! dsm channel number
     &     ,virtelev            ! virtual elevation number (within channel)
     &     ,vsecno              ! virtual xsect number (within channel)
     &     ,veindex             ! virtual elevation index
     &     ,previous_elev_index(max_virt_xsects) ! used to store elevation index
      real*8
     &     X                    ! distance along channel (from FourPt)
     &    ,H                   ! distance above channel bottom (from FourPt)

      save previous_elev_index

      data previous_elev_index /max_virt_xsects * 1/


c-----find the index of elevation of layer that is below H, and the
c-----virtual xsect number

      channo=int2ext(Branch)

c-----Check for negative depth

      if (H.le.0.) then
         write(unit_error,910) channo,H
 910     format(' Error...channel', i4,' dried up; H=',f10.3)
         call exit(13)
      endif

      vsecno = nint(X / virt_deltax(channo))+1
      virtelev=previous_elev_index(minelev_index(channo)+vsecno-1)

c-----if upper level is below or at same elevation as H, move up
      do while (virtelev .lt. num_layers(channo) .and.
     &     virt_elevation(elev_index(channo)+virtelev) .le. H)
         virtelev=virtelev+1
      enddo
c-----if lower level is above H, move down
      do while (virtelev .gt. 1 .and.
     &     virt_elevation(elev_index(channo)+virtelev-1) .gt. H)
         virtelev=virtelev-1
      enddo



      previous_elev_index(minelev_index(channo)+vsecno-1) = virtelev
      veindex=elev_index(channo)+virtelev-1
      if (h .gt. virt_elevation(elev_index(channo)+num_layers(channo)-1)) then
         write(unit_error,*) 'Error in find_layer_index'
         write(unit_error,610) channo,
     &        virt_elevation(elev_index(channo)+num_layers(channo)-1),h
 610     format('Top elevation in cross-section is too low.'
     &        /'Change variable ''max_layer_height'' in common_irreg_geom.f.'
     &        /'Chan no. ',i3,' Chan top elev=',f6.2,' H=',f6.2)
         call exit(2)
      endif

      return
      end

*===== EOF chcxtbl ======================================================
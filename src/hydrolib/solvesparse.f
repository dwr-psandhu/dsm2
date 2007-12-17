C!    DSM2 - SPARSE LIBRARY INTERFACE COPYRIGHT
C!    Copyright (C) 1998-1999 Eli Ateljevich
C!    
C!    Note that the routines below, which contain part of an interface to
C!    the SPARSE matrix library, were created by Eli Ateljevich.
C!    
C!    The SPARSE matrix library was created by Kenneth S. Kundert and
C!    the University of California for which copyright information is
C!    given below.

C!    This program is licensed to you under the terms of the GNU General
C!    Public License, version 2, as published by the Free Software
C!    Foundation.
C!    
C!    You should have received a copy of the GNU General Public License
C!    along with this program; if not, contact Dr. Paul Hutton, below,
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
C!    Dr. Paul Hutton
C!    California Dept. of Water Resources
C!    Division of Planning, Delta Modeling Section
C!    1416 Ninth Street
C!    Sacramento, CA  95814
C!    916-653-5601
C!    hutton@water.ca.gov
C!    
C!    or see our home page: http://wwwdelmod.water.ca.gov/
C!    
C!    For information about the solver routines, contact:
C!    Eli Ateljevich
C!    (510) 843-1569
C!    
*****-SPARSE COPYRIGHT *************
*  Revision and copyright information.
*     
*  Copyright (c) 1985,86,87,88
*  by Kenneth S. Kundert and the University of California.
*     
*  Permission to use, copy, modify, and distribute this software and
*  its documentation for any purpose and without fee is hereby granted,
*  provided that the copyright notices appear in all copies and
*  supporting documentation and that the authors and the University of
*  California are properly credited.  The authors and the University of
*  California make no representations as to the suitability of this
*  software for any purpose.  It is provided `as is', without express
*  or implied warranty.
*     
************************************************************************

*== Public (InitializeSolver) ==========================================

      logical function InitializeSolver()
      use IO_Units
      use Gates, only: NGate,GateArray
      implicit none

*   Purpose: Initialize the solution matrix

*   Arguments:

*   Argument definitions:

*   Module data:
      include 'network.inc'
      include '../fixed/common.f' ! only nreser
      include 'solver.inc'
      include 'chconnec.inc'

*   Local Variables:
      integer,parameter :: Zero=0
      integer error             ! error indicator for matrix allocation routine
      integer rowcounter        ! counter for reservoir rows and gate rows
      integer i                 ! loop index 

*   Routines:

      integer, external ::  TotalStreamLocations
      integer, external :: sfcreate
      logical,external ::  ReserveMatrix

*-----Implementation -----------------------------------------------------

      InitializeSolver = .FALSE.

      TotalChanRows = 2*TotalStreamLocations()
      rowcounter=0
      do i=1,nreser
         rowcounter=rowcounter+res_geom(i).nnodes+1   
      end do
      TotalChanResRows=TotalChanRows + rowcounter
      rowcounter=0
      do i=1,ngate
         rowcounter=rowcounter+GateArray(i).nDevice
      end do

      Equations = TotalChanResRows + rowcounter
      Matrix = sfCreate(Equations,Zero,Error)
      RowScale=1.D0

*-----Initialize Matrix Scale Factors
      do i=1,Equations
         if (Mod(i,2) .eq. 0 .and. i .le. TotalChanRows ) Then
            ColumnScale(i)=ZscaleFactor
         else
            ColumnScale(i)=1.0
         end If
      end do

*-----Set up matrix-shape indicies.
      if( ReserveMatrix() ) then
      else
         write(UNIT_ERROR,*) ' ReserveMatrix failed...'
         return
      end if

*-----Initialize 'first iteration' index.

      InitializeSolver = .TRUE.

      return
      end

*== Public (CloseSolver) ==========================================

      LOGICAL FUNCTION CloseSolver()

      IMPLICIT NONE

*   Purpose: Close and deallocate
*   the matrix solver in SPARSE.

*   Arguments:

*   Argument definitions:

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'solver.inc'

*   Programmed by:   Lew DeLong
*   Date:            July 1990
*   Modified by:     Eli Ateljevich
*   Date:			   July 1998
*     

*-----Implementation -----------------------------------------------------

      CloseSolver = .FALSE.
      Call sfDestroy(Matrix)
      CloseSolver = .TRUE.

      RETURN
      END

*== Public (InitializeMatrix) ==========================================

      LOGICAL FUNCTION InitializeMatrix()

      IMPLICIT NONE

*   Purpose:  Fourpoint allows for two levels of solution.. In the first,
*-----both the coefficient matrix and the RHS are updated and
*             solved. In the second, only the RHS is updated.

*   Arguments:

*   Argument definitions:

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'solver.inc'

*   Local Variables:
c-----INTEGER I

*   Routines by module:

***** Local:
      LOGICAL  ForwardElim
      EXTERNAL ForwardElim

*   Programmed by: Lew DeLong
*   Date:          January 1991
*   Modified by:   Lew DeLong
*   Last modified: April 1992
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      InitializeMatrix = .FALSE.

      IF( ForwardElim() ) THEN
         call sfClear(Matrix)
 100     CONTINUE
      END IF

      InitializeMatrix = .TRUE.

      RETURN
      END

*== Public (StoreAtLocation) ==========================================

      LOGICAL FUNCTION StoreAtLocation(Location, Val)

      IMPLICIT NONE

*   Purpose:  Store a value in the coeficient matrix at a location
*             corresponding to an integer pointer (Location)

*             This Function has no counterpart in SPARSE
*             Functionality is largely redundant with AddAtLocation
*-----It is kept here to allow control using ForwElim()
*             Values are stored only if complete forward elimination
*             is to be performed on the coefficient matrix, indicated
*             by ForwardElim() = .TRUE..

*   Arguments:
      INTEGER Location
      DOUBLE PRECISION Value
      REAL*8 Val
*   Argument definitions:
*     Location  - a pointer to the desired location in the
*-----coef matrix

*     Value  - value to be stored. Incoming number may not be
*     Double precision, but must be stored as double precision
*     for SPARSE solver.

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'solver.inc'

*   Local Variables:
c-----INTEGER N

*   Routines by module:

      LOGICAL  ForwardElim
      EXTERNAL ForwardElim

*   Programmed by: Lew DeLong
*   Date:          February 1991
*   Modified by:   Eli Ateljevich
*   Last modified: July 1998
*   Version 98.01, July, 1998

*-----Implementation -----------------------------------------------------

      Value=0
      IF( ForwardElim() ) THEN
         Value=Val

         Call sfAdd1Real(Location,Value)
      END IF

      StoreAtLocation = .TRUE.

      RETURN
      END

*== Public (AddAtLocation) ============================================

      LOGICAL FUNCTION AddAtLocation(Location, Val)

      IMPLICIT NONE

*   Purpose:  Add a value to the coeficient matrix at a location
*             corresponding to Row and Offset from the diagonal in
*             the virtual matrix.

*   Arguments:
      INTEGER Location
      REAL*8 Val
      DOUBLE PRECISION VALUE
      LOGICAL ForwardElim
      External ForwardElim

*   Argument definitions:
*     Location  - a pointer to the desired location in the
*-----coef matrix

*     Value  - value to be stored. Incoming number may not be
*     Double precision, but must be stored as double precision
*     for SPARSE solver.

*   Module data:
      INCLUDE 'network.inc'
      INCLUDE 'solver.inc'

*   Local Variables:

*   Routines by module:

*   Programmed by: Lew DeLong
*   Date:          February 1991
*   Modified by:   Eli Ateljevich
*   Last modified: July, 1998
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      If (ForwardElim())Then
         Value = Val

         Call sfAdd1Real(Location,Value)

      End If
      AddAtLocation = .TRUE.

      RETURN
      END

*== Public (SolveFourPt) ============================================

      LOGICAL FUNCTION SolveFourPt()
      Use IO_Units
      IMPLICIT NONE

      INCLUDE 'network.inc'
      INCLUDE 'solver.inc'
c@@@     INCLUDE '../fixed/misc.f'
      INCLUDE '../fixed/common.f'
      INCLUDE 'chstatus.inc'

*   Purpose:  Interface to SPARSE solver for solution
*             of incremental change in flow/stage

*   Arguments:
      INTEGER I,IterSinceOrder,Iter,Counter
      logical,save :: FirstTime =.true.
      logical,save :: FirstBackTrack
      logical,save :: LastBackTrack
      Integer MaxNormLoc
      real*8,save :: prevBackLInfNorm

      SAVE IterSinceOrder
      LOGICAL Scaled
      real*8, parameter :: CLOSE_L2=1.D0
      real*8, parameter :: MIN_RESCALE=(1.D0/16.D0)
*   Local Variables
      logical lasttime
      INTEGER Error

      LOGICAL ForwardElim
      EXTERNAL ForwardElim

      INTEGER NetworkIteration,NetworkTimeStep,MaxNetworkIterations
      EXTERNAL NetworkIteration,NetworkTimeStep,MaxNetworkIterations

      INTEGER sfOrderAndFactor,sfFactor,sfFileMatrix,sfFileVector
      EXTERNAL sfOrderAndFactor,sfFactor,sfFileMatrix,sfFileVector

*   Argument definitions:
*     Location  - a pointer to the desired location in the
*-----coef matrix

*   Programmed by: Eli Ateljevich
*   Last modified: July, 1998
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

      SolveFourPt = .FALSE.

*-----Create RHS vector of proper size and precision
      If ( FirstTime .OR. (Mod(IterSinceOrder,2000) .le. 1))Then
         Scaled = .True.
         FirstTime = .False.
      Else
         Scaled = .true.
c@@@        If ( ForwardElim() )Scaled = .False.
      End If

      If (NetworkIteration().eq.1)then
         firstbacktrack=.true.
         lastbacktrack=.false.
         LastLInfNorm=Huge(1.D0)
         LastL2Norm=Huge(1.D0)
         Rescale=1.
      End If

      Do  100 I=1,Equations
         XX(I) = XOld(I) + XAdj(I)
         If(Scaled)XX(I) = XX(I)*RowScale(i)
 100  Continue

      L2Norm=DOT_PRODUCT(XX,XX)
      maxNormLoc=maxloc(abs(XX),1)
      LInfNorm=abs(XX(maxNormLoc))

c@@@     write(unit_screen,"('Iteration: ',i5,1x'Max resid:',f17.6,
c@@@    &   ' at row ',i8,/,'L2: ',f17.6,2x,'Last L2',f17.6,2x,'Row Scale',f16.8)") 
c@@@    &   NetworkIteration(),LInfNorm,maxNormLoc,L2Norm,
c@@@    &   Min(LastL2Norm,9999999.99),RowScale(maxNormLoc)
      
      NormClose=(L2Norm .LT. CLOSE_L2) ! .and. LInfNorm .lt. 5.D-1)
c@@@     if (NetworkIteration() .eq. 19)then
c@@@       do i=1,Equations
c@@@    write(59,"(i5,': ',f18.5,',',f18.5,',',f18.5)")i,xadj(i),xold(i),xx(i)
c@@@  end do

c@@@       call sfFileMatrix( Matrix, 0, 1, 1 )
c@@@   	  Pause
c@@@     end if
      

      lasttime=(NetworkIteration() .eq. MaxNetworkIterations())
c@@@     if (lasttime)then
c@@@ print*,'*****************Maxiter********************',
c@@@    &      ' ',current_date,' *********'
c@@@      call solver_diagnostics(maxNormLoc)
c@@@      print*,"L2 norm: ",L2Norm, "LInf norm", LInfNorm	 
c@@@     end if

      If ( (L2Norm .lt. LastL2Norm .or. L2Norm .lt. CLOSE_L2) !.and.
                                !  &   (LInfNorm .lt. 5.D-1 .or. LInfNorm .lt. LastLInfNorm)  
     &     .or. Rescale .le. MIN_RESCALE  .or. lasttime !)
     &     ) then

      If( ForwardElim() ) Then
         If( Scaled ) Then
            Call sfScale(Matrix,RowScale,ColumnScale)
            Error=sfOrderAndFactor(Matrix,XX,1.D-7,0.D0,1)
         Else
            Error=sfFactor(Matrix)
         End If
         if(error .ne. 0)then
            write(unit_error,
     &           "('Error in linear algebra. SPARSE returned error code: ',i5)")
     &           error
            call exit(3)
         end if
      End If
      Call sfSolve(Matrix,XX,X)

c@@@   print*,"Outer iteration, rescale=",rescale
      X=X*Rescale
      Rescale=min(1.,Rescale*2)
      if (lasttime) rescale=1.
      IterSinceOrder = IterSinceOrder+1

*-----Need to unscale result
      If(Scaled)Then
*--------Need to unscale result
         Do I=1,Equations
            X(I) = X(I) * ColumnScale(I)
         End Do
      End If
      FirstBacktrack=.true.
      LastLInfNorm=LInfNorm
      PrevBackLInfNorm=LInfNorm
      LastL2Norm=L2Norm
      lastbacktrack=.false.
      Else
         
c@@@   print*,"Backtrack, rescale= ",Rescale
         lastbacktrack=.true.
         Rescale=0.5*Rescale
         X=0.5*X
         if(firstbacktrack)then
            X=-X
            firstbacktrack=.false.
         end if
         PrevBackLInfNorm=LInfNorm
      End If

      SolveFourPt=.True.
      RETURN
      END

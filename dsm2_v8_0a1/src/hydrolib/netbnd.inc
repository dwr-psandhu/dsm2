C!    Copyright (C) 1996, 1997, 1998 State of California,
C!    Department of Water Resources.
C!
C!    Delta Simulation Model 2 (DSM2): A River, Estuary, and Land
C!    numerical model.  No protection claimed in original FOURPT and
C!    Branched Lagrangian Transport Model (BLTM) code written by the
C!    United States Geological Survey.  Protection claimed in the
C!    routines and files listed in the accompanying file "Protect.txt".
C!    If you did not receive a copy of this file contact Dr. Paul
C!    Hutton, below.
C!
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

*===== BOF netbnd =====================================================
*   Version 93.01, January, 1993

*     Note: "network.inc" must appear prior to this include file.

      INTEGER BndValues, NetBndValUnit
      INTEGER Channel(2*MaxChannels)
      INTEGER StartSeconds, bdt
      INTEGER OldTime, NewTime, CurrentTime
      REAL*8 Old(2*MaxChannels), New(2*MaxChannels)
      REAL*8 Current(2*MaxChannels),StreamBndValue(2*MaxChannels)
      LOGICAL ReadBoundaryValues

      COMMON / NetBndVal_i / BndValues, NetBndValUnit, Channel,
     &     StartSeconds, bdt,
     &     OldTime, NewTime, CurrentTime,
     &     ReadBoundaryValues
	   COMMON / NetBndVal_r /
     &     Old, New, Current,StreamBndValue
      SAVE   / NetBndVal_i/ , /NetBndVal_r/

*   Definitions:
*     BndValues - number of values to be read each time step.
*     NetBndValUnit - FORTRAN unit number.
*     Channel(i) - channel number, + upstream or - downstream end.
*     StartSeconds - starting elapse time, in seconds.
*     bdT - boundary-value time-series time increment.
*     OldTime - currently the time corresponding to oldest set of
*               boundary values in memory.
*     NewTime - currently the time corresponding to newest set of
*               boundary values in memory.
*     CurrentTime - current Network time, in seconds.
*     Old(i) - boundary values at OldTime.
*     New(i) - boundary values at NewTime.
*     Current(i) - boundary values at CurrentTime.
*     StreamBndValue(k) - boundary value computed from equation, possibly
*                         one upstream and one downstream value,
*                         sequentially, odd "k" are upstream,
*                         even are downstream.
*     ReadBoundaryValues - indicator,
*                          [.TRUE.] read values.
*                          [.FALSE.] don't read values.
*
*===== EOF netbnd =====================================================
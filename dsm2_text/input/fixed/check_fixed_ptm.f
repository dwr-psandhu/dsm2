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


      subroutine check_fixed_ptm(istat)

c-----Check the PTM fixed input for omissions and errors before starting
c-----the model run.  Supply default values where possible.

      implicit none

      include 'common.f'
      include 'common_ptm.inc'
      
      include '../../hydro/network.inc'
      include '../../hydro/netcntrl.inc'
      include '../../hydro/chconnec.inc'
      include '../../hydro/chnluser.inc'
      include '../../hydro/chcxrec1.inc'
      include '../time-varying/dss.inc'
      include '../time-varying/readdss.inc'
      include '../time-varying/writedss.inc'
      include '../time-varying/common_tide.f'
      include '../time-varying/common_qual_bin.inc'

c-----Local variables

      logical
     &     nodeexist            ! true if node exists in network

      integer
     &     istat                ! status of call (returned)
     &     ,m                   ! indices
     &     ,nodeindex           ! node index used for iterating through nodes

      integer*4
     &     cdt2jmin             ! character date/time to julian minute
     &     ,incr_intvl          ! increment julian minute by interval function

      character
     &     diff2dates*14        ! return DSS date given start and diff
     &     ,jmin2cdt*14         ! julian minute to character date/time function
     &     ,tmpdate*14          ! temporary date for comparison

 605  format(/a,' date incorrect: ',a)

 606  format(/'Invalid ',a,' date of ',a,' in tidefile:'
     &     /a)

 607  format(/'Warning - Value for ',a,' not supplied - set to ',l5)

 608  format(/'Warning - Value for ',a,' not supplied - set to ',f8.3)

 609  format(/'Warning - Value for ',a,' not supplied - set to ',i5)

 620  format(/'Too many upstream channels at node ',i3,' :',i5,
     &     ' max allowed: ',i4)

 621  format(/'Too many downstream channels at node ',i3,' :',i5,
     &     ' max allowed: ',i4)

 642  format(/a,i4,' does not have a name or channel number.')

 643  format(/'Invalide insertion at node ',i3,': node does not exist.') 

 644  format(/'Path name ',a,' does not have a translation.')

 645  format(/a,' does not have a translation.')

 646  format(/a,a)

 647  format(/'Qaul binary starts on ',a,' it does not contain the date :',a)
! 647  format(/'Warning - Value for ',a,' not supplied - set to ',a)
! 648  format(/'Warning - Value for ',a,' not supplied - set to ',a)

 648  format(/'Qaul binary ends on ',a,' it does not contain the date :',a)
c-----adjust areas
      do m=1,max_reservoirs
         res_geom(m).area = res_geom(m).area*1e06
      enddo

c-----adjust totals
c-----npass_node=npass_node-1
      nchanres=nchanres-1
      npartno=npartno-1

c-----Check scalar variables

      if (ptm_time_step_int .eq. 0) then
         ptm_time_step = 15
         write(unit_error,607)'ptm_time_step  ',ptm_time_step
      else
         ptm_time_step = incr_intvl(0,time_step_intvl_ptm,IGNORE_BOUNDARY)
      endif

      if (ptm_ivert_int .eq. 0) then
         ptm_ivert=.true.
         write(unit_error,607)'ptm_ivert ',ptm_ivert
      endif

      if (ptm_itrans_int .eq. 0) then
         ptm_itrans=.true.
         write(unit_error,607)'ptm_itrans ',ptm_itrans
      endif

      if (ptm_iey_int .eq. 0) then
         ptm_iey=.true.
         write(unit_error,607)'ptm_iey',ptm_iey
      endif

      if (ptm_iez_int .eq. 0) then
         ptm_iez=.true.
         write(unit_error,607)'ptm_iez',ptm_iez
      endif

      if (ptm_flux_percent_int .eq. 0) then
         ptm_flux_percent=.true.
         write(unit_error,607)'ptm_flux_percent',ptm_flux_percent
      endif

      if (ptm_group_percent_int .eq. 0) then
         ptm_group_percent=.true.
         write(unit_error,607)'ptm_group_percent',ptm_group_percent
      endif

      if (ptm_flux_cumulative_int .eq. 0) then
         ptm_flux_cumulative=.true.
         write(unit_error,607)'ptm_flux_cumulative',ptm_flux_cumulative
      endif

      if (ptm_iprof_int .eq. 0) then
         ptm_iprof=.false.
      endif

      if (ptm_igroup_int .eq. 0) then
         ptm_igroup=.false.
      endif

      if (ptm_no_animated .eq. 0) then
         ptm_no_animated=100
         write(unit_error,609)'ptm_no_animated',ptm_no_animated
      endif

      if (ptm_trans_a_coef_int .eq. 0) then
         ptm_trans_a_coef=1.62
         write(unit_error,608)'ptm_trans_a_coef',ptm_trans_a_coef
      endif

      if (ptm_trans_b_coef_int .eq. 0) then
         ptm_trans_b_coef=-2.22
         write(unit_error,608)'ptm_trans_b_coef',ptm_trans_b_coef
      endif

      if (ptm_trans_c_coef_int .eq. 0) then
         ptm_trans_c_coef=0.60
         write(unit_error,608)'ptm_trans_c_coef',ptm_trans_c_coef
      endif

c-----Check times for injection
c-----calculate ending time if injection length, rather than
c-----start/end injection times are given
      do m=1,npartno
c--------Commented for testing purposes Aaron Miller----------
         if (part_injection(m).start_dt(:3) .eq. 'run') then
            part_injection(m).start_dt=run_start_dt
         endif
c-------------------------------------------------------------
         if (part_injection(m).slength .ne. ' ') then
c-----------injection start length should be in form: '20hour' or '5day'
c-----------or, 'runtime' means no offset length
            if (part_injection(m).slength(:3) .eq. 'run') then
               part_injection(m).start_dt=run_start_dt
            else
               part_injection(m).start_dt=
     &              diff2dates(run_start_dt,part_injection(m).slength)
            endif
         endif
         if (part_injection(m).length .ne. ' ') then
c-----------injection length should be in form: '20hour' or '5day'
            part_injection(m).start_julmin=
     &           cdt2jmin(part_injection(m).start_dt)
            part_injection(m).end_dt=
     &           diff2dates(part_injection(m).start_dt,part_injection(m).length)
         endif
         part_injection(m).start_julmin=cdt2jmin(part_injection(m).start_dt)
c--------check if injection date is before model start date;
c--------if so, zero out the injected particles
         if (part_injection(m).start_julmin .lt. start_julmin) then
            part_injection(m).nparts=0
         endif
         part_injection(m).end_julmin=cdt2jmin(part_injection(m).end_dt)
         part_injection(m).length_julmin=
     &        part_injection(m).end_julmin-part_injection(m).start_julmin
c--------check if injection node exists
         nodeexist = .false.
         nodeindex = 0
         do while (.not. nodeexist .and. nodeindex .le. max_nodes)
            if ((part_injection(m).node .eq. chan_geom(nodeindex).upnode) .or.
     &           (part_injection(m).node .eq. chan_geom(nodeindex).downnode)) then
               nodeexist = .true.
            else
               nodeindex = nodeindex + 1
            endif
         enddo
         if (.not. nodeexist) then
            write (unit_error, 643) part_injection(m).node
            goto 900
         endif
      enddo

c-----check that quality tide file includes full runtime

      if (qual_bin_file.filename .ne. ' ') then
         if(qual_bin_file.start_julmin_file .gt. start_julmin) then
            tmpdate = jmin2cdt(start_julmin)
            write (unit_error, 647) qual_bin_file.start_dt,tmpdate
            goto 900
         elseif(qual_bin_file.end_julmin_file .lt. end_julmin) then
            tmpdate = jmin2cdt(end_julmin)
            write (unit_error, 648) qual_bin_file.end_dt,tmpdate
            goto 900
         endif
      endif


c-----update flux information such as getting object_no from accounting names
c-----end update flux information
         
c-----get type and name to node number or reservoir number translation
c@@@      transNumber = 0
c@@@      do m=1,ntypes
c@@@         if(type_spec(m).type .ne. 32 .and. ! fixme: ???
c@@@     &        type_spec(m).match .eq. 'e') then
c@@@            transNumber = transNumber + 1
c@@@            translationInfo(transNumber).name = type_spec(m).string
c@@@            translationInfo(transNumber).type = type_spec(m).type
c@@@            k=1
c@@@            do while (index(type_spec(m).string,translations(k).from_name) .le. 0 .and.
c@@@     &           ( k .le. ntrans) )
c@@@               k=k+1
c@@@            enddo
c@@@            if (k .gt. ntrans) then
c@@@               write(unit_error,645) type_spec(m).string
c@@@               goto 900
c@@@            else
c@@@               if (translations(k).node_no .eq. 0) then
c@@@                  if(translations(k).res_name .ne. ' ') then
c@@@                     translationInfo(transNumber).reservoirNumber =
c@@@     &                    getReservoirNumber(translations(k).res_name)
c@@@                     translationInfo(transNumber).nodeNumber = 0
c@@@                  else
c@@@                     write(unit_error,646)
c@@@     &                    'No node number for translation',type_spec(m).string
c@@@                     goto 900
c@@@                  endif
c@@@               else
c@@@                  translationInfo(transNumber).nodeNumber = translations(k).node_no
c@@@                  translationInfo(transNumber).reservoirNumber = 0
c@@@               endif
c@@@            endif
c@@@
c@@@         endif
c@@@      enddo

      return

 900  continue                  !here for fatal error
      istat= -1

      return
      end

!       function getReservoirNumber(name)
!       implicit none
!       integer getReservoirNumber
!       character*80 name
!       include 'common.f'

!       integer k,ri,rn
!       integer lnblnk

!       k=1
!       ri = lnblnk(res_geom(k).name)
!       rn = lnblnk(name)
!       do while(k .le. nreser .and. res_geom(k).name(1:ri) .eq. name(1:rn) )
!          k=k+1
!       enddo
!       getReservoirNumber = k
!       if (k .gt. nreser) getReservoirNumber = -1
!       end

!       function getWaterbodyNumber(WBFlux)

! c-----Returns the waterbody number

!       implicit none

!       integer*2 getWaterbodyNumber,getTypeWBNumber
!       include 'common.f'
!       record /WaterBody_flux_type_s/ WBFlux

!       if(WBFlux.object_no .ne. 0) then
!          if(WbFlux.object_no .le. max_channels .and.
!      &        WBFlux.type .eq. obj_channel)
!      &        getWaterbodyNumber = WBFlux.object_no
!       else if(WBFlux.object_no .eq. 0) then
!          getWaterbodyNumber = -1
!       else if(WBFlux.obj_name .ne. ' ') then
!          getWaterbodyNumber = getTypeWBNumber(WBFlux.obj_name, WBFlux.object)
!       endif
!       end

!       function getTypeWBNumber(name, Type)

!       implicit none

!       integer*2 getTypeWBNumber, getReservoirNumber, getBoundaryNumber
!       include 'common.f'
!       integer ri,rn
!       integer lnblnk
!       integer multp
!       include '../../ptm/ptm-fortran.inc'
!       integer i,shift
!       byte Type
!       character*(*) name
!       if (name(1:1) .eq. '-') then
!          multp = -1
!          name=name(2:lnblnk(name))
!       else
!          multp = 1
!       endif
!       getTypeWBNumber=0
!       if (Type .eq. diversion) then
!          shift = max_channels+max_reservoirs
!       else if(Type .eq. pump) then
!          shift = max_channels+max_reservoirs+max_nodes
!       else if(Type .eq. rim) then
!          shift =  max_channels+max_reservoirs+max_nodes+max_reservoirs
!       else if (Type .eq. reservoirr) then
!          shift = max_channels
!       endif
!       if (Type .eq. reservoirr) then
!          getTypeWBNumber = getReservoirNumber(name)+max_channels
!       else
!          do i=1, transNumber
!             if (translationInfo(i).type .eq. Type) then
!                ri = lnblnk(translationInfo(i).name)
!                rn = lnblnk(name)
!                if (translationInfo(i).name(1:ri) .eq. name(1:rn)) then
!                   if(type .eq. pump) then
!                      getTypeWBNumber =
!      &                    translationInfo(i).reservoirNumber+shift
!                   else if (type .eq. rim) then
!                      getTypeWBNumber =
!      &                    getBoundaryNumber(i)+shift
!                   else
!                      getTypeWBNumber =
!      &                    translationInfo(i).nodeNumber+shift
!                   endif
!                endif
!             endif
!          enddo
!       endif
!       getTypeWBNumber = multp*getTypeWBNumber
!       end

!       integer function getBoundaryNumber( k)
!       implicit none
!       integer k
!       include 'common.f'
!       include '../../ptm/ptm-fortran.inc'
!       integer i
!       getBoundaryNumber=0
!       do i=1,k
!          if(translationInfo(i).type .eq. rim)
!      &        getBoundaryNumber = getBoundaryNumber+1
!       enddo

!       end
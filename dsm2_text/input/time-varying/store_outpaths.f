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


      subroutine store_outpaths(lflush)

c-----Write output data periodically to temporary files.
c-----Initialize the temporary files first with init_store_outpaths.

      implicit none

      include '../fixed/common.f'
      include 'dss.inc'
      include 'writedss.inc'

      logical
     &     lflush               ! true to force data flush to scratch files
     &     ,lupdate             ! true to update value arrays

      integer*4
     &     last_update          ! julian minute of last update

c-----the storage index pointer for each block of data
      integer
     &     ndx_minutes15
     &     ,ndx_hours1
     &     ,ndx_days1
     &     ,ndx_weeks1
     &     ,ndx_months1
     &     ,ndx_years1

      save ndx_minutes15, ndx_hours1, ndx_days1,
     &     ndx_weeks1, ndx_months1, ndx_years1,
     &     last_update

      data  ndx_minutes15 /1/, ndx_hours1 /1/, ndx_days1 /1/
     &     ,ndx_weeks1 /1/, ndx_months1 /1/, ndx_years1 /1/
     &     ,last_update /0/

      lupdate=.not. (julmin .eq. last_update)

      if (npthsout_min15 .gt. 0) then
         call store_outpaths_gen(max_out_min,
     &        mins15,npthsout_min15,ptout_min15,
     &        julstout_minutes15,ndx_minutes15,
     &        jmin_15min,jmin_15min_prev,nave_min15,
     &        dataout_minutes15,unit_min15,
     &        lflush,lupdate)
      endif

      if (npthsout_hour1 .gt. 0) then
         call store_outpaths_gen(max_out_hour,
     &        hrs,npthsout_hour1,ptout_hour1,
     &        julstout_hours1,ndx_hours1,
     &        jmin_1hour,jmin_1hour_prev,nave_hour1,
     &        dataout_hours,unit_hour1,
     &        lflush,lupdate)
      endif

      if (npthsout_day1 .gt. 0) then
         call store_outpaths_gen(max_out_day,
     &        dys,npthsout_day1,ptout_day1,
     &        julstout_days1,ndx_days1,
     &        jmin_1day,jmin_1day_prev,nave_day1,
     &        dataout_days,unit_day1,
     &        lflush,lupdate)
      endif

      if (npthsout_week1 .gt. 0) then
         call store_outpaths_gen(max_out_week,
     &        wks,npthsout_week1,ptout_week1,
     &        julstout_weeks1,ndx_weeks1,
     &        jmin_1week,jmin_1week_prev,nave_week1,
     &        dataout_weeks,unit_week1,
     &        lflush,lupdate)
      endif

      if (npthsout_month1 .gt. 0) then
         call store_outpaths_gen(max_out_month,
     &        mths,npthsout_month1,ptout_month1,
     &        julstout_months1,ndx_months1,
     &        jmin_1month,jmin_1month_prev,nave_month1,
     &        dataout_months,unit_month1,
     &        lflush,lupdate)
      endif

      if (npthsout_year1 .gt. 0) then
         call store_outpaths_gen(max_out_year,
     &        yrs,npthsout_year1,ptout_year1,
     &        julstout_years1,ndx_years1,
     &        jmin_1year,jmin_1year_prev,nave_year1,
     &        dataout_years,unit_year1,
     &        lflush,lupdate)
      endif

      last_update=julmin

      return
      end

      subroutine store_outpaths_gen (
     &     outpaths_dim
     &     ,block_dim
     &     ,npaths
     &     ,outpath_ptr
     &     ,jul_start
     &     ,store_ndx
     &     ,jmin_eop
     &     ,jmin_eop_prev
     &     ,nave_intvl
     &     ,outdata_arr
     &     ,unit
     &     ,lflush
     &     ,lupdate
     &     )

c-----General store outpaths.  This fills output buffer arrays and
c-----writes temp file.

      implicit none

c-----subroutine arguments

      integer
     &     outpaths_dim         ! output paths array dimension
     &     ,block_dim           ! data block array dimension

      integer
     &     npaths               ! number of output paths for this interval
     &     ,outpath_ptr(outpaths_dim) ! pointer array to output pathnames
     &     ,store_ndx           ! end array index for output buffers (data blocks)
     &     ,nave_intvl(outpaths_dim) ! number of values in the interval average
     &     ,unit                ! write unit number

      integer*4
     &     jul_start            ! julian minute of start of data for this path
     &     ,jmin_eop            ! julian minute of end-of-period for this interval
     &     ,jmin_eop_prev       ! previous value of jmin_eop

      REAL*8
     &     outdata_arr(0:block_dim,outpaths_dim) ! output data array

      logical
     &     lflush               ! true to force data flush to scratch files
     &     ,lupdate             ! true to update value arrays

      include '../fixed/common.f'

c-----local variables

      logical
     &     lnewndx              ! this julmin first one in time interval
     &     ,lendndx             ! this julmin last one in time interval

      integer
     &     i,j                  ! array indices
     &     ,ptr                 ! array pointer
     &     ,nvals               ! number of values to write to disk

      REAL*8
     &     value                ! output value
     &     ,get_output          ! function to get the output value for each DSM2 module

      character
     &     jmin2cdt*14          ! convert from julian minute to char date/time
     &     ,ctmp*14             ! temp string

c-----data will be stored at end-of-period; for example, for 1HOUR:
c-----from 05JUN1994 0101 to 05JUN1994 0200 (inclusive) all pertains
c-----to the 05JUN1994 0200 time block.

      lnewndx=.false.
      if (julmin .ne. start_julmin .and.
     &     (julmin-jmin_eop_prev .le. time_step)) then
c--------current model time just crossed a data time interval
         lnewndx=.true.
         store_ndx=store_ndx+1
      endif

      lendndx=.false.
      if (julmin+time_step .gt. jmin_eop) lendndx=.true.

      if (.not. lupdate) goto 100

c-----put value into output buffer
      do i=1,npaths
         ptr=outpath_ptr(i)
         value=get_output(ptr)  ! get the desired output variable for each DSM2 module
         if (pathoutput(ptr).per_type .eq. per_type_per_aver .or.
     &        pathoutput(ptr).per_type .eq. per_type_per_cum) then ! period average
            outdata_arr(store_ndx,i)=outdata_arr(store_ndx,i)
     &           *float(nave_intvl(i))+value
            if (lnewndx) nave_intvl(i)=0
            nave_intvl(i)=nave_intvl(i)+1
            outdata_arr(store_ndx,i)=outdata_arr(store_ndx,i)
     &           /float(nave_intvl(i))
         else if (pathoutput(ptr).per_type .eq. per_type_per_min) then ! period minimum
            outdata_arr(store_ndx,i)=min(outdata_arr(store_ndx,i),value)
         else if (pathoutput(ptr).per_type .eq. per_type_per_max) then ! period maximum
            outdata_arr(store_ndx,i)=max(outdata_arr(store_ndx,i),value)
         else if (pathoutput(ptr).per_type .eq. per_type_inst_val) then ! instantaneous, no averaging
            if (julmin .eq. jmin_eop) then ! at end of DSS interval, no interpolation needed
               outdata_arr(store_ndx,i)=value
            else if (lnewndx .and.
     &              julmin .gt. prev_julmin .and. ! skip recycled julmin
     &              prev_julmin .ne. jmin_eop_prev) then ! just crossed interval, interpolate between time steps
               outdata_arr(store_ndx-1,i)=( (value-outdata_arr(0,i)) *
     &              float(jmin_eop-(jmin_eop-jmin_eop_prev)-prev_julmin)) /
     &              (julmin-prev_julmin) + outdata_arr(0,i)
            endif
         else if (pathoutput(ptr).per_type .eq. per_type_inst_cum) then ! instantaneous cumulative value
            outdata_arr(store_ndx,i)=value
         endif
         outdata_arr(0,i)=value ! outdata_arr(0,...) stores value of previous time step
      enddo

 100  continue

c-----if flush request, or the output buffer will overflow and it's the
c-----end of a DSS time interval, then write to temporary file
      if (lflush .or.
     &     (lendndx .and. store_ndx .eq. block_dim)) then
         if (.not. lendndx) then ! last value incomplete, don't write out
            nvals=store_ndx-1
         else                   ! last value is complete
            nvals=store_ndx
         endif
         write(unit) nvals      ! number of values written
         ctmp=jmin2cdt(jul_start) ! date/time of start of data block
         write(unit) ctmp
         do i=1,npaths
            ptr=outpath_ptr(i)
            write(unit) (outdata_arr(j,i), j=1,nvals)

            if (.not. lendndx) then ! move incomplete value to start of array
               outdata_arr(1,i)=outdata_arr(store_ndx,i)
               store_ndx=1
            else
               outdata_arr(1,i)=0.0
               store_ndx=0
            endif

            do j=2,block_dim
               outdata_arr(j,i)=0.0
            enddo
         enddo
c--------set julian minute of start of next data block
         jul_start=jul_start+(jmin_eop-jmin_eop_prev)*nvals
      endif

      return
      end
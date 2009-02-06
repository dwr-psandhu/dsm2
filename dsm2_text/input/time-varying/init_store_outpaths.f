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


      subroutine init_store_outpaths(istat)

c-----Initialization for storing time-varying output data in temporary
c-----files.

      implicit none

      include '../fixed/common.f'
      include 'dss.inc'
      include 'writedss.inc'

c-----local variables

      character
     &     tmp_dir*50           ! scratch file directory
     &     ,dir_arr(4)*30       ! list of possible scratch directories
     &     ,tmp_file*80         ! scratch file name
     &     ,ctmp*11             ! scratch variable

      integer
     &     istat                ! file status
     &     ,ptr                 ! array pointer
     &     ,getdir              ! get directory function

      integer*4
     &     incr_intvl           ! increment julmin minute function

 610  format(/'Error opening binary scratch output file.')

c-----For each interval with output data, create a scratch file
c-----and write header info.

c-----scratch directory; if not specified in user input, try /tmp (unix),
c-----then \temp (peecee)
      dir_arr(1)=temp_dir
      dir_arr(2)='/tmp'
      dir_arr(3)='c:' // backslash // 'temp'
      dir_arr(4)=miss_val_c     ! array list must end with this
      ptr=getdir(dir_arr)
      if (ptr .ne. 0) then
         tmp_dir=dir_arr(ptr)
      else
 605     format(/a,3(/a))
         write(unit_error,605) 'Could not find a valid directory in this list:',
     &        (dir_arr(ptr),ptr=1,3)
         goto 901
      endif

      ctmp='-' // crid // '.bin'

      if (npthsout_min15 .gt. 0) then
         call mkfilename(tmp_dir, 'tmp_min15' // ctmp, tmp_file)
         scratch_file_array(1)=tmp_file
         open (
     &        unit=unit_min15
     &        ,file=tmp_file
     &        ,form='unformatted'
     &        ,iostat=istat
     &        ,err=901
     &        )
         write (unit=unit_min15) npthsout_min15
         do ptr=1,npthsout_min15
            write (unit=unit_min15) pathoutput(ptout_min15(ptr))
         enddo
         julstout_minutes15=incr_intvl(start_julmin,'15min',
     &        NEAREST_BOUNDARY)
      else
         scratch_file_array(1)=miss_val_c
      endif

      if (npthsout_hour1 .gt. 0) then
         call mkfilename(tmp_dir, 'tmp_hour1' // ctmp, tmp_file)
         scratch_file_array(2)=tmp_file
         open (
     &        unit=unit_hour1
     &        ,file=tmp_file
     &        ,form='unformatted'
     &        ,iostat=istat
     &        ,err=901
     &        )
         write (unit=unit_hour1) npthsout_hour1
         do ptr=1,npthsout_hour1
            write (unit=unit_hour1) pathoutput(ptout_hour1(ptr))
         enddo
         julstout_hours1=incr_intvl(start_julmin,'1hour',
     &        NEAREST_BOUNDARY)
      else
         scratch_file_array(2)=miss_val_c
      endif

      if (npthsout_day1 .gt. 0) then
         call mkfilename(tmp_dir, 'tmp_day1' // ctmp, tmp_file)
         scratch_file_array(3)=tmp_file
         open (
     &        unit=unit_day1
     &        ,file=tmp_file
     &        ,form='unformatted'
     &        ,iostat=istat
     &        ,err=901
     &        )
         write (unit=unit_day1) npthsout_day1
         do ptr=1,npthsout_day1
            write (unit=unit_day1) pathoutput(ptout_day1(ptr))
         enddo
         julstout_days1=incr_intvl(start_julmin,'1day',
     &        NEAREST_BOUNDARY)
      else
         scratch_file_array(3)=miss_val_c
      endif

      if (npthsout_week1 .gt. 0) then
         call mkfilename(tmp_dir, 'tmp_week1' // ctmp, tmp_file)
         scratch_file_array(4)=tmp_file
         open (
     &        unit=unit_week1
     &        ,file=tmp_file
     &        ,form='unformatted'
     &        ,iostat=istat
     &        ,err=901
     &        )
         write (unit=unit_week1) npthsout_week1
         do ptr=1,npthsout_week1
            write (unit=unit_week1) pathoutput(ptout_week1(ptr))
         enddo
         julstout_weeks1=incr_intvl(start_julmin,'1week',
     &        NEAREST_BOUNDARY)
      else
         scratch_file_array(4)=miss_val_c
      endif

      if (npthsout_month1 .gt. 0) then
         call mkfilename(tmp_dir, 'tmp_month1' // ctmp, tmp_file)
         scratch_file_array(5)=tmp_file
         open (
     &        unit=unit_month1
     &        ,file=tmp_file
     &        ,form='unformatted'
     &        ,iostat=istat
     &        ,err=901
     &        )
         write (unit=unit_month1) npthsout_month1
         do ptr=1,npthsout_month1
            write (unit=unit_month1) pathoutput(ptout_month1(ptr))
         enddo
         julstout_months1=incr_intvl(start_julmin,'1month',
     &        NEAREST_BOUNDARY)
      else
         scratch_file_array(5)=miss_val_c
      endif

      if (npthsout_year1 .gt. 0) then
         call mkfilename(tmp_dir, 'tmp_year1' // ctmp, tmp_file)
         scratch_file_array(6)=tmp_file
         open (
     &        unit=unit_year1
     &        ,file=tmp_file
     &        ,form='unformatted'
     &        ,iostat=istat
     &        ,err=901
     &        )
         write (unit=unit_year1) npthsout_year1
         do ptr=1,npthsout_year1
            write (unit=unit_year1) pathoutput(ptout_year1(ptr))
         enddo
         julstout_years1=incr_intvl(start_julmin,'1year',
     &        NEAREST_BOUNDARY)
      else
         scratch_file_array(6)=miss_val_c
      endif

      return

 901  continue                  ! scratch file open error
      write(unit_error, 610)
      call exit(2)

      return
      end

      integer function getdir(dir_arr)

c-----Find a usable directory from the given list; return the
c-----array index of the one to use.  The list must end with
c-----miss_val_c.

      implicit none

      include '../fixed/misc.f'

c-----argument
      character*(*) dir_arr(*)  ! list of directory names to try

c-----local variables
      integer
     &     ndx                  ! directory array index
     &     ,nlen                ! character length
     &     ,statarr(13)         ! file status array
     &     ,stat                ! file status intrinsic function
     &     ,istat               ! file status value
     &     ,lnblnk              ! intrinsic function

      ndx=1
      do while (dir_arr(ndx) .ne. miss_val_c)
         nlen=lnblnk(dir_arr(ndx))
         if (nlen .eq. 0) goto 100
         istat=stat(dir_arr(ndx),statarr)
c@@@         if (statarr(1) .eq. '4000'X) then ! this directory name ok
         if (istat .eq. 0) then ! this directory name ok
            getdir=ndx
            return
         endif
 100     continue
         ndx=ndx+1
      enddo

      getdir=0
      return
      end

      subroutine mkfilename(
     &     dir,
     &     file,
     &     dirfile
     &     )

c-----Make a full filename (directory + filename) from directory name
c-----and filename.

      implicit none

      include '../fixed/misc.f'

c-----arguments
      character*(*)
     &     dir                  ! directory name
     &     ,file                ! filename
     &     ,dirfile             ! directory+filename

c-----local variables
      integer
     &     nlen                 ! length of character string
     &     ,ndx                 ! array index
     &     ,lnblnk              ! intrinsic
     &     ,index               ! intrinsic

      character
     &     dirchar              ! directory delimiter (/ or \)

      nlen=lnblnk(dir)
c-----try to find / or \ in directory name
      ndx=index(dir,'/')
      if (ndx .gt. 0) then      ! unix
         dirchar=dir(ndx:ndx)
      else
         ndx=index(dir,backslash)
         if (ndx .gt. 0) then   ! pc
            dirchar=dir(ndx:ndx)
         else                   ! unknown
            dirchar='/'
         endif
      endif
c-----directory name must end in either / or \ before
c-----appending filename
      if (dir(nlen:nlen) .ne. dirchar) then
         nlen=nlen+1
         dir(nlen:nlen)=dirchar
      endif

      dirfile=dir(:nlen) // file

      return
      end
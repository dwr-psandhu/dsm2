C!<license>
C!    Copyright (C) 1996, 1997, 1998, 2001, 2007 State of California,
C!    Department of Water Resources.
C!    This file is part of DSM2.

C!    DSM2 is free software: you can redistribute it and/or modify
C!    it under the terms of the GNU General Public !<license as published by
C!    the Free Software Foundation, either version 3 of the !<license, or
C!    (at your option) any later version.

C!    DSM2 is distributed in the hope that it will be useful,
C!    but WITHOUT ANY WARRANTY; without even the implied warranty of
C!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C!    GNU General Public !<license for more details.

C!    You should have received a copy of the GNU General Public !<license
C!    along with DSM2.  If not, see <http://www.gnu.org/!<licenses/>.
C!</license>

      subroutine readtvd (
     &     inpaths_dim,block_dim
     &     ,npaths
     &     ,inpath_ptr
     &     ,indata
     &     )
      use io_units
      use type_defs
      use runtime_data
      use constants
      
      use iopath_data
      implicit none

c-----Retrieve time-varying data from DSS, if necessary, and then
c-----process further (interpolate, fillin missing, ...)

c-----common blocks

      include '../hydrolib/network.inc'
      include '../hydrolib/netbnd.inc'
      include '../hydrolib/chconnec.inc'

c-----subroutine arguments

      integer
     &     inpaths_dim          ! input paths array dimension
     &     ,block_dim           ! data block array dimension

      integer
     &     npaths               ! number of input paths for this interval
     &     ,inpath_ptr(inpaths_dim) ! pointer array to global input pathnames

      type(dataqual_t) ::
     &     indata(block_dim,inpaths_dim) ! raw input data structure array

c-----local variables

      type(dataqual_t) :: last_value(max_inputpaths) 
      type(dataqual_t) :: tmpval

      logical check_dataqual    ! function to test quality of data
     &     ,interpolate_value   ! true to interpolate this path's final value

      integer
     &     ptr                  ! path pointer to all paths
     &     ,i                   ! path index to paths for this interval
     &     ,lnm                 ! last non-missing value index
     &     ,ndx,ndx2            ! array index to use for data now, and for interpolated value
     &     ,ndx_next,ndx_prev_curr ! array indices of data forward, and back of or at, current time step
     &     ,last_ndx_next(max_inputpaths) ! last timestep's ndx_next
     &     ,bufndx_nosync,bufndx_sync ! functions to return index in data buffer corresponding to a julian minute
     &     ,bufndx_next_nosync,bufndx_next_sync ! variables to hold this interval's bufndx
     &     ,getndx              ! get final data buffer index to use
     &     ,nmins_intvl         ! nominal number of minutes in a path's interval
     &     ,find_miss           ! function to find first missing value in data
     &     ,nvals               ! number of values in a regular-interval time block
     &     ,istat               ! status

      integer*4
     &     jul_next,jul_prev_curr ! julian minutes of data forward, and back of or at, current time step
     &     ,jul,jul2            ! julian minute corresponding to ndx, ndx2
     &     ,js_data             ! julian minute to start new data
     &     ,jm_next             ! current julian minute to next boundary
     &     ,cdt2jmin            ! character date/time to julian minute
     &     ,timediff_dat        ! time difference between two data points
     &     ,timediff_val        ! time difference between current time and data point
     &     ,incr_intvl          ! increment time interval function

      REAL*8 val1,val2            ! values used for interpolating

      character*14 datetime1,datetime2,jmin2cdt
      character*5 current_sync  ! synchronize string for model time
      character*8 per_type      ! per-aver or inst-val
      character*32 ce           ! DSS E part

      type(dataqual_t) ::  indata_tmp

      data last_ndx_next /max_inputpaths * 1/
      save last_ndx_next,last_value
      external jmin2cdt

 610  format(/a,' data in path:'/a
     &     /' At data time: ',a,' model time: ',a
     &     /' Using replacement value of ',1p g10.3,' from ',a,
     &     /' or a lower priority path')
 615  format(/'Missing or rejected data for interpolation in path:'/a
     &     /' At data time: ',a,' model time: ',a
     &     /' Using replacement value of ',1p g10.3,' from ',a)
 611  format(/'Missing or rejected data in path:'
     &     /' ',a
     &     /' at data time: ',a,' model time: ',a
     &     /' Cannot continue.')
 613  format(/'Software error in readtvd: Bad ndx_prev_curr for path:'
     &     /' ',a
     &     /' at data time: ',a,' model time: ',a
     &     /' Cannot continue.')
 620  format(/'Error in reading time-varying data:'
     &     /'Current time is ',a,'; earliest data time for '/a
     &     /'is ',a)
 625  format(/'Error in reading time-varying data:'
     &     /'Current time is ',a,'; all data times for '/a
     &     /' are before this time.')
 626  format(/'Error in reading time-varying data:'
     &     /'Current time is ',a,'; data synchronization request for '/a
     &     /' could not be satisfied.')
 630  format(/'Unrecognized data period type: ',a
     &     /' for path: ',a)


c-----Check if new data needs to be read from DSS to arrays
      do i=1,npaths
         ptr=inpath_ptr(i)
         pathinput(ptr).replace=.false.
         if (pathinput(ptr).constant_value .eq. miss_val_r) then ! get value from dss file
            if ( (julmin+pathinput(ptr).diff_julmin .ge.
     &           indata(block_dim,i).julmin ) .or.
     &           prev_julmin .eq. start_julmin) then
               js_data=julmin+pathinput(ptr).diff_julmin
               call readdss(ptr,js_data,inpaths_dim,block_dim,indata,
     &              per_type)
               if (per_type .eq. ' ') then ! none, assume instantaneous
                  pathinput(ptr).per_type=per_type_inst_val
               else if (per_type .eq. per_type_names(per_type_inst_val)) then
                  pathinput(ptr).per_type=per_type_inst_val
               else if (per_type .eq. per_type_names(per_type_per_aver)) then
                  pathinput(ptr).per_type=per_type_per_aver
               else if (per_type .eq. per_type_names(per_type_inst_cum)) then
                  pathinput(ptr).per_type=per_type_inst_cum
               else if (per_type .eq. per_type_names(per_type_per_cum)) then
                  pathinput(ptr).per_type=per_type_per_cum
               else
                  write(unit_error,630) per_type,
     &                 trim(pathinput(ptr).path)
                  call exit(2)
               endif
            endif
         endif
      enddo

c-----force initial calculation of buffer indices
      bufndx_next_sync=-1
      bufndx_next_nosync=-1

      do i=1,npaths
         ptr=inpath_ptr(i)
         if (pathinput(ptr).constant_value .ne. miss_val_r) then ! use constant value
            pathinput(ptr).value=pathinput(ptr).constant_value
            tmpval.data=pathinput(ptr).value
            tmpval.flag=pathinput(ptr).value_flag
            call set_dataqual(tmpval,GOOD_DATA)
            pathinput(ptr).value_flag=tmpval.flag
            goto 100
         endif

c--------use value from DSS file

c--------should this path's value be interpolated?
c--------don't interpolate if not requested or gate values
c         if (
c     &        pathinput(ptr).fillin .eq. fill_interp
c     &        .and. pathinput(ptr).per_type .ne. per_type_inst_val) then
c         print*,pathinput(ptr).name, " is weird"
c         end if
         interpolate_value=(pathinput(ptr).fillin .eq. fill_interp .or.
     &        (pathinput(ptr).fillin .eq. fill_bydata .and.
     &        (pathinput(ptr).per_type .eq. per_type_inst_val .or.
     &        pathinput(ptr).per_type .eq. per_type_inst_cum))) .and.
     &        index(pathinput(ptr).path, 'GATE') .eq. 0

c--------if this path has a different start date offset than the previous
c--------path, force recalculation of buffer indices
         if (i .gt. 1) then
            if(
     &         pathinput(inpath_ptr(i-1)).diff_julmin .ne.
     &         pathinput(ptr).diff_julmin) then
              bufndx_next_sync=-1
              bufndx_next_nosync=-1
            end if
         endif

c--------ndx_next is index in dss buffer for data forward of current
c--------time step; depends on whether data is to be synced or not
c--------calculate this once each for synchronized and non-synchronized
c--------paths, for regular data; for irregular, calc for every path

        if (bufndx_next_nosync .eq. -1 .or.
     &           pathinput(ptr).interval(:3) .eq. 'ir-') then
               ndx_next=bufndx_nosync(indata, julmin+pathinput(ptr).
     &              diff_julmin, i, last_ndx_next(ptr),
     &              block_dim, inpaths_dim)
               bufndx_next_nosync=ndx_next
         else
               ndx_next=bufndx_next_nosync
         endif


        if (ndx_next .eq. -1) then
c--------------if the 'last' value is wanted, finding newer data doesn't matter
            if (interpolate_value) then
               write(unit_error,625) trim(current_date),trim(pathinput(ptr).path)
               call exit(2)
            else             ! simply use last data available
               ndx_next=block_dim ! readdss.f copies last value to end of buffer
            endif
         endif
         jul_next=indata(ndx_next,i).julmin

c--------if interpolation wanted, but next value is bad (and not generic
c--------data), turn off interpolation and try to replace this value
c--------later
         if (interpolate_value .and.
     &        (check_dataqual(indata(ndx_next,i),MISS_OR_REJ_DATA) .and.
     &        pathinput(ptr).start_date .ne. generic_date)) then
            interpolate_value=.false.
            pathinput(ptr).replace=.true.
         endif

c--------fixme: check this if statement
         if (ndx_next .eq. 1 .and.
     &        pathinput(ptr).interval(:3) .eq. 'ir-') then 
            ! all irregular data for this path is after current time
               datetime1=jmin2cdt(indata(1,i).julmin)
               write(unit_error,620) trim(current_date),trim(pathinput(ptr).path)
               call exit(2)
         endif

c--------index in dss buffer for data at previous or current time step
         if (ndx_next .ge. 2) then
            ndx_prev_curr=ndx_next-1
         else                   ! this shouldn't happen
            datetime1=jmin2cdt(indata(ndx_next,i).julmin)
            write(unit_error,613)
     &           trim(pathinput(ptr).path),
     &           datetime1,current_date
            call exit(2)
         endif
c--------julian minute of previous or current data value
         jul_prev_curr=indata(ndx_prev_curr,i).julmin

c--------ndx points to which data value to use
         ndx=getndx(julmin, jul_next, jul_prev_curr, ndx_next,
     &        ndx_prev_curr, pathinput(ptr).per_type, interpolate_value)

         indata_tmp=indata(ndx,i) ! in case indata missing value is replaced later

c--------initialize last_value to use for missing data
         if (prev_julmin .eq. start_julmin) then
            last_value(ptr).data=miss_val_r
            call set_dataqual(last_value(ptr),REJECT_DATA)
         endif

c--------for interpolated value, need second value
         if (interpolate_value) then
            if (ndx .eq. ndx_next) then
               ndx2=ndx_prev_curr
            else
               ndx2=ndx_next
            endif
            jul=indata(ndx,i).julmin
            jul2=indata(ndx2,i).julmin
            timediff_dat=jul2-jul
            timediff_val=julmin - (jul-pathinput(ptr).diff_julmin)
            tmpval=indata(ndx2,i)
            val1=indata(ndx,i).data
            val2=indata(ndx2,i).data
         endif
         jul_next=indata(ndx_next,i).julmin
         jul_prev_curr=indata(ndx_prev_curr,i).julmin


c--------check for questionable, missing, or rejected data
         if (check_dataqual(indata(ndx,i),QUESTION_DATA) .or.
     &        check_dataqual(indata(ndx,i),MISS_OR_REJ_DATA)) then ! bad data...
            datetime1=jmin2cdt(jul_prev_curr)
c-----------continue if user requests it and good data is available
c-----------to fill in; or continue if the path is part of a priority list
c-----------(a last check will be made for bogus data just before use)
            if ( (cont_question .or. cont_missing) .and.
     &           (.not. check_dataqual(last_value(ptr),QUESTION_DATA) .and.
     &           .not. check_dataqual(last_value(ptr),MISS_OR_REJ_DATA)) 
     &           ) then
               if (
     &              warn_question .and.
     &              check_dataqual(indata(ndx,i),QUESTION_DATA) .and.
     &              .not. check_dataqual(last_value(ptr),MISS_OR_REJ_DATA)) then
                  datetime2=jmin2cdt(last_value(ptr).julmin)
                  write(unit_screen, 610)
     &                 'Questionable',
     &                 trim(pathinput(ptr).path),
     &                 datetime1,current_date,last_value(ptr).data,
     &                 datetime2
               endif
               if (
     &              warn_missing .and.
     &              check_dataqual(indata(ndx,i),MISS_OR_REJ_DATA) .and.
     &              .not. check_dataqual(last_value(ptr),MISS_OR_REJ_DATA)) then
                  datetime2=jmin2cdt(last_value(ptr).julmin)
                  write(unit_screen, 610)
     &                 'Missing or rejected',
     &                 trim(pathinput(ptr).path),
     &                 datetime1,current_date,last_value(ptr).data,
     &                 datetime2
               endif
               pathinput(ptr).replace=.true. ! later try to replace this
               indata(ndx,i)=last_value(ptr)
               if (interpolate_value) then
                  val1=indata(ndx,i).data
               endif
            else                ! don't continue on quest/miss/rej data, and no replacement data available
                  write(unit_error, 611)
     &                 trim(pathinput(ptr).path),
     &                 datetime1,current_date
                  call exit(2)
            endif
         endif

c--------check for missing data of other index
         if (interpolate_value .and. check_dataqual(tmpval,MISS_OR_REJ_DATA)) then
c-----------if generic date, missing value means recycle to first value
c-----------assume that the full range of data can fit into a data block
            if (pathinput(ptr).start_date .eq. generic_date) then
               val2=indata(1,i).data
            else                ! not generic
               datetime1=jmin2cdt(jul2)
c--------------continue if user requests it and good data is available
c--------------to fill in, or the path is for replacement only
               if ( (cont_missing .and.
     &              .not. check_dataqual(last_value(ptr),MISS_OR_REJ_DATA)) 
     &             ) then
                  pathinput(ptr).replace=.true. ! later try to replace this
                  val2=last_value(ptr).data
                  if (warn_missing) then
                     datetime2=jmin2cdt(last_value(ptr).julmin)
                     write(unit_screen, 615)
     &                    trim(pathinput(ptr).path),
     &                    datetime1,current_date,last_value(ptr).data,
     &                    datetime2
                  endif
               else
                  write(unit_error, 611)
     &                 trim(pathinput(ptr).path),
     &                 datetime1,current_date
                  call exit(2)
               endif
            endif
         endif
         last_value(ptr)=indata(ndx,i) ! in case we wish to replace missing data

         if (interpolate_value) then
c-----------interpolate to end of time step
            pathinput(ptr).value= val1 + (val2-val1) *
     &           float(timediff_val) / float(timediff_dat)
            pathinput(ptr).value_flag=indata(ndx,i).flag
         else                   ! don't interpolate
            pathinput(ptr).value=indata(ndx,i).data
            pathinput(ptr).value_flag=indata(ndx,i).flag
         endif

         if (pathinput(ptr).start_date .ne. generic_date) then ! kluge upon kluge
            indata(ndx,i)=indata_tmp
         endif

 100     continue

c--------change sign if desired
         if (pathinput(ptr).sign .eq. -1) then
            pathinput(ptr).value=-abs(pathinput(ptr).value)
         else if (pathinput(ptr).sign .eq. 1) then
            pathinput(ptr).value=abs(pathinput(ptr).value)
         endif
c--------change value if desired
         if (pathinput(ptr).value_in .eq. pathinput(ptr).value)
     &        pathinput(ptr).value=pathinput(ptr).value_out

         last_ndx_next(ptr)=ndx_next

      enddo

      return
      end

      integer function bufndx_nosync(indata, jm, path, last_ndx,
     &     max_v, max_paths)
      use constants
      use type_defs
c-----Find index in julian minute array that is less than
c-----target julian minute.

      implicit none

c-----arguments and local variables
      integer
     &     last_ndx             ! bufndx value from last timestep
     &     ,max_v               ! max number of data and time values
     &     ,max_paths           ! max number of paths
     &     ,i                   ! loop index
     &     ,path                ! path index

      type(dataqual_t)
     &     indata(max_v,max_paths) ! input data structure array

      integer*4
     &     jm                   ! current julian minute

      do i=1, max_v
         if (indata(i,path).julmin .gt. jm) then
            bufndx_nosync=i
            return
         endif
      enddo

      bufndx_nosync=-1          ! all data is old

      return
      end

      integer function bufndx_sync(indata, path, sync_str, e_part,
     &     last_ndx, max_v, max_paths)
      use constants
      use type_defs
c
c-----Find index in julian minute array that matches the DSS part to
c-----synchronize with the current time

      implicit none

 
c-----arguments and local variables
      integer
     &     last_ndx             ! bufndx value from last timestep
     &     ,max_v               ! max number of data and time values
     &     ,max_paths           ! max number of paths
     &     ,i                   ! loop index
     &     ,path                ! path index

      type(dataqual_t)
     &     indata(max_v,max_paths) ! input data structure array

      character*(*)
     &     sync_str*(*)         ! string from current model to synchronize with
     &     ,e_part              ! synchronize on e_part in data time

      character*14
     &     jmv_cdt*14           ! character dates for jmv_cdt
     &     ,jmin2cdt            ! julian minute to character function

      character*5
     &     jmv_intvl            ! interval strings for jmv_cdt

c-----check last timestep's value, probably still good
      jmv_cdt=jmin2cdt(indata(last_ndx,path).julmin)
      call get_intvl(jmv_cdt, e_part, jmv_intvl)
      if (sync_str .eq. jmv_intvl) then
         bufndx_sync=last_ndx
         return
      else
         do i=1, max_v
            jmv_cdt=jmin2cdt(indata(i,path).julmin)
            call get_intvl(jmv_cdt, e_part, jmv_intvl)
            if (sync_str .eq. jmv_intvl) then
               bufndx_sync=i
               return
            endif
         enddo
      endif

      bufndx_sync=-1            ! couldn't synchronize

      return
      end

      integer function getndx(julmin, jul_next, jul_prev_curr,
     &     ndx_next, ndx_prev_curr, per_type, interpolated)

c-----Return either next or previous data index as the base index to
c-----use for correct data for this timestep.
      use constants
      implicit none


      logical interpolated      ! true if this path's value is to be interpolated

      integer*4
     &     julmin               ! current julian minute
     &     ,jul_next,jul_prev_curr ! julian minutes of data forward, and back of or at, current time step

      integer
     &     ndx_next,ndx_prev_curr ! array indices of data forward, and back of or at, current time step
     &     ,per_type            ! per-average, instantaneous, etc.

c-----for instantaneous values, use previous or current,
c-----whether interpolated or not;
c-----for period average values, use next or current if
c-----not interpolated, use previous if interpolated
c-----fixme: for interpolated period average, really the
c-----other ndx to use should change midway thru the time period
      getndx=-9999
c-----always use prev_curr index if current time and data time are equal
      if (julmin .eq. jul_prev_curr) then
         getndx=ndx_prev_curr
      else
         if (per_type .eq. per_type_inst_val .or.
     &        per_type .eq. per_type_inst_cum) then ! instantaneous
            getndx=ndx_prev_curr
         else if (per_type .eq. per_type_per_aver .or.
     &           per_type .eq. per_type_per_cum) then ! period average
            if (.not. interpolated) then
               getndx=ndx_next
            else
               getndx=ndx_prev_curr
            endif
         endif
      endif

      return
      end

      integer function find_miss(indata, path, max_v, max_paths)

c-----Find first missing value in data vector for path
      use IO_Units
      use constants
      use type_defs
      implicit none


      logical check_dataqual    ! function to test whether data is 'missing'

      integer
     &     max_v                ! max number of data and time values
     &     ,max_paths           ! max number of paths
     &     ,path                ! path index

      type(dataqual_t)
     &     indata(max_v,max_paths) ! input data structure array

      do find_miss=1, max_v
         if (check_dataqual(indata(find_miss,path),MISS_OR_REJ_DATA)) return
      enddo

      find_miss=max_v

      return
      end

      logical function check_dataqual(value,qualflag)

c-----Check the quality of data.
      use IO_Units
      use constants
      use type_defs
      implicit none


      type(dataqual_t) value ! data value to be tested [INPUT]
      integer qualflag          ! type of quality flag to check [INPUT]
      logical
     &     btest                ! external bit checking function

      if (qualflag .eq. SCREENED_DATA) then
         check_dataqual=btest(value.flag,SCREENED_BIT) .or.
     &        value.data .eq. -901. .or. ! missing data is considered as screened
     &        value.data .eq. -902.
      else if (qualflag .eq. GOOD_DATA) then
         check_dataqual=btest(value.flag,GOOD_BIT)
      else if (qualflag .eq. MISSING_DATA) then
         check_dataqual=value.data .eq. -901. .or.
     &        value.data .eq. -902. .or.
     &        btest(value.flag,MISSING_BIT)
      else if (qualflag .eq. QUESTION_DATA) then
         check_dataqual=btest(value.flag,QUESTION_BIT)
      else if (qualflag .eq. REJECT_DATA) then
         check_dataqual=btest(value.flag,REJECT_BIT)
      else if (qualflag .eq. MISS_OR_REJ_DATA) then
         check_dataqual=value.data .eq. -901. .or.
     &        value.data .eq. -902. .or.
     &        btest(value.flag,MISSING_BIT) .or.
     &        btest(value.flag,REJECT_BIT)
      else                      ! unknown incoming flag
         write(unit_error,*) 'Software error in check_dataqual; ',
     &        'unknown qualflag value: ', qualflag
      endif

      return
      end

      subroutine set_dataqual(value,qualflag)
      use type_defs
      use constants
c-----Set the quality data flags.
      use IO_Units
      implicit none


      type(dataqual_t) :: value ! data value to be set [INPUT, OUTPUT]
      integer qualflag          ! type of quality flag to check [INPUT]

      value.flag=and(value.flag,0)
      value.flag=ibset(value.flag,SCREENED_BIT)
      if (qualflag .eq. GOOD_DATA) then
         value.flag=ibset(value.flag,GOOD_BIT)
      else if (qualflag .eq. MISSING_DATA) then
         value.data=miss_val_r
         value.flag=ibset(value.flag,MISSING_BIT)
      else if (qualflag .eq. QUESTION_DATA) then
         value.flag=ibset(value.flag,QUESTION_BIT)
      else if (qualflag .eq. REJECT_DATA) then
         value.flag=ibset(value.flag,REJECT_BIT)
      else                      ! unknown incoming flag
         write(unit_error,*) 'Software error in set_dataqual; ',
     &        'unknown qualflag value: ', qualflag
      endif

      return
      end


      subroutine get_inp_data(ptr)

c-----Get input data from buffers for computations
      use IO_Units
      use type_defs
      use iopath_data
      use runtime_data
      implicit none

c-----common blocks


      integer
     &     ptr                  ! pathname array index

      logical
     &     check_dataqual       ! function checks quality of data

      type(dataqual_t) dataqual

 610  format(/'No replacement path given for '
     &     /a
     &     /' however bad value encountered at model time ',a)
 612  format(/'Error in get_inp_data: Missing data in path/file:'
     &     /' ',a
     &     /' ',a
     &     /' at model time: ',a
     &     /' Cannot continue.')
 613  format(/a/a/'at model time: ',a)



c-----last check for missing data
      dataqual.data=pathinput(ptr).value
      dataqual.flag=pathinput(ptr).value_flag
      if (check_dataqual(dataqual,MISS_OR_REJ_DATA)) then
         write(unit_error, 612)
     &        trim(pathinput(ptr).path),trim(pathinput(ptr).filename),
     &        current_date
         call exit(2)
      endif

c-----warning msgs about questionable or unscreened data;
c-----check to continue run
      if (.not. check_dataqual(dataqual,SCREENED_DATA)) then
         if (warn_unchecked .or. .not. cont_unchecked) then
            write(unit_error,613) 'Warning: unchecked data: ',
     &           trim(pathinput(ptr).path),
     &           current_date
         endif
         if (.not. cont_unchecked) then
            write(unit_error,*) 'Fatal error.'
            call exit(2)
         else if (warn_unchecked) then
            write(unit_error,*) 'Using current value.'
         endif
      endif

      if (check_dataqual(dataqual,QUESTION_DATA)) then
         if (warn_question .or. .not. cont_question) then
            write(unit_error,613) 'Warning: questionable data: ',
     &           trim(pathinput(ptr).path),
     &           current_date
         endif
         if (.not. cont_question) then
            write(unit_error,*) 'Fatal error.'
            call exit(2)
         else if (warn_question) then
            write(unit_error,*) 'Using current value.'
         endif
      endif

c-----use this value for all time steps?
      if (pathinput(ptr).fillin .eq. fill_first) then
         pathinput(ptr).constant_value=pathinput(ptr).value
      endif

      return
      end
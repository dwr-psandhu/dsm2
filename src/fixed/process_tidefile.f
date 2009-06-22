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

      subroutine process_tidefile(start_date, end_date, filename)

c-----process a character line into data arrays for
c-----tide file info.
      use io_units
      use constants
      use common_tide
      implicit none


      include '../hydrolib/network.inc'

      logical
     &     ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault

c-----local variables

      logical
     &     binarytf_fn          ! determine if tidefile is HDF5 or binary fortran
      integer
     &     i                    ! index

      integer*4
     &     incr_intvl           ! increment julian minute by interval function

      character*16  :: start_date
      character*16  :: end_date
      character*128 :: filename
      character*80  :: cstring


c! The optional starting and ending datetimes specify when to use
c! each tidefile; they override the timestamp in the tidefile
c! itself.  If not given, the timestamp in the tidefile
c! will be used for the start datetime, and it will be used to
c! the end of the tidefile or model run. 

c! Keywords used for the starting and ending datetimes can be used to
c! simplify chaining together tidefiles.

c! Start datetime keyword explanation:
c! runtime: start time in tidefiles; if not succesful
c!      	exit with error (same as if no start time given)
c! previous:	use this tidefile right when the previous tidefile ends
c! none:	field placeholder (doesn't do anything; same as if field
c!    		not given)

c! End datetime keywords:
c! length:	use all of tidefile, to its end
c! none:	see above
      nintides = nintides + 1
      if (nintides .gt. max_tide_files) then
         write(unit_error,630)
     &        'Too many tidefiles specified; max allowed is:'
     &        ,max_tide_files
 630     format(/a,i5)
         call exit(-1)
      endif

      tide_files(nintides).start_date=start_date
      tide_files(nintides).end_date=end_date
      tide_files(nintides).filename=filename
      if (index(start_date,'runtime') .gt. 0) then
         tide_files(nintides).start_date=' '
      elseif ( index(start_date,'prev') .gt. 0) then
         if (nintides .ne. 1) then
             tide_files(nintides).start_date='last'
         else             ! can't have 'last' for first tide file
              write(unit_error, '(a)')
     &         'Cannot use "last" or "prev" keyword for first tidefile.'
              call exit(-1)
         endif
      else
         tide_files(nintides).start_date(1:9)=start_date(1:9)
          write(unit_error,*)
     &     "Tidefile specification has invalid start_date field"
      endif

      if (index(end_date,'len') .gt. 0) then
         tide_files(nintides).end_date='length'
      elseif (index(end_date,'run') .gt. 0) then
         tide_files(nintides).start_date=' '
      else  ! is a time
         tide_files(nintides).end_date=end_date
      endif
      nintides=nintides+1
      return
      end subroutine


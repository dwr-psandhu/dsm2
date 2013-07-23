!>@ingroup process_io
module process_gtm_tidefile

    contains
    
    !> process a character line into data arrays for
    !> tide file info.    
    subroutine process_tidefile(start_date, end_date, filename)

      use common_dsm2_vars
      
      implicit none

      logical :: ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault

      !local variables
      integer :: i                    ! index
      integer*4 :: incr_intvl,  &     ! increment julian minute by interval function
                   jmin,        &
                   cdt2jmin           ! character date/time to julian minute
      character*16  :: start_date
      character*16  :: end_date
      character*128 :: filename
      character*80  :: cstring

      ! The optional starting and ending datetimes specify when to use
      ! each tidefile; they override the timestamp in the tidefile
      ! itself.  If not given, the timestamp in the tidefile
      ! will be used for the start datetime, and it will be used to
      ! the end of the tidefile or model run. 

      ! Keywords used for the starting and ending datetimes can be used to
      ! simplify chaining together tidefiles.

      ! Start datetime keyword explanation:
      ! runtime: start time in tidefiles; if not succesful
      !      	exit with error (same as if no start time given)
      ! previous:	use this tidefile right when the previous tidefile ends
      ! none:	field placeholder (doesn't do anything; same as if field
      !    		not given)

      ! End datetime keywords:
      ! length:	use all of tidefile, to its end
      ! none:	see above
      nintides = nintides + 1
      if (nintides .gt. max_tide_files) then
         write(unit_error,630)                                 &
              'Too many tidefiles specified; max allowed is:'  &
              ,max_tide_files
 630     format(/a,i5)
         call exit(-1)
      endif
      tide_files(nintides).start_date=start_date
      tide_files(nintides).end_date=end_date
      tide_files(nintides).filename=filename
      call get_tidefile_dates(nintides)
      if (index(start_date,'runtime') .gt. 0) then
         tide_files(nintides).start_date=' '
         tide_files(nintides).start_julmin=tide_files(nintides).start_julmin_file
      elseif ( index(start_date,'prev') .gt. 0) then
         if (nintides .ne. 1) then
             tide_files(nintides).start_date='last'
             tide_files(nintides).start_julmin=tide_files(nintides-1).end_julmin
         else             ! can't have 'last' for first tide file
              write(unit_error, '(a)')                             &
               'Cannot use "last" or "prev" keyword for first tidefile.'
              call exit(-1)
         endif
      else
         tide_files(nintides).start_date(1:9)=start_date(1:9)
         tide_files(nintides).start_julmin=cdt2jmin(tide_files(nintides).start_date)
         write(unit_error,*)                                       &
              "Tidefile specification has invalid start_date field"
      endif

      if (index(tide_files(nintides).end_date,'len') .gt. 0) then
         tide_files(nintides).end_julmin=tide_files(nintides).end_julmin_file
      else  ! is a time
         tide_files(nintides).end_date=end_date
         tide_files(nintides).end_julmin=cdt2jmin(end_date)
         if (tide_files(nintides).end_julmin .ne. miss_val_i) then 
            ! valid datetime string input
            tide_files(nintides).end_julmin=                      &
                min(cdt2jmin(tide_files(nintides).end_date), end_julmin)
         else
            jmin=incr_intvl(tide_files(nintides).start_julmin,    &
                  tide_files(nintides).end_date, TO_BOUNDARY)
            if (jmin .eq. miss_val_i) then
                write(unit_error,606) 'ending',tide_files(nintides).end_date, &
                          trim(tide_files(nintides).filename)
 606            format(/'Invalid ',a,' date of ',a,' in tidefile:'/a)
                call exit(-3)     
             endif
             tide_files(nintides).end_julmin=min(jmin,end_julmin)
         end if                        
      endif
      if (tide_files(nintides).start_julmin .lt. tide_files(nintides).start_julmin_file     &
                .or.                                                                        &
          tide_files(nintides).end_julmin .gt. tide_files(nintides).end_julmin_file) then
	    write(unit_error,*)"Tidefile contents do not span " //                              &
                "assigned start and end dates: ", tide_files(nintides).filename
          call exit(-3)
	  end if
      return
    end subroutine

end module
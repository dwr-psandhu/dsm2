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

      subroutine input_tidefile(field_names, mxflds, nfields, nflds,
     &     ifld, rifld, line, ibegf, ilenf, istat)

c-----process a character line into data arrays for
c-----tide file info.
      Use IO_Units
      implicit none

      include 'common.f'
      include '../hydrolib/network.inc'
      include '../hdf_tidefile/common_tide.f'

      logical
     &     ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault

c-----local variables

      logical
     &     binarytf_fn          ! determine if tidefile is HDF5 or binary fortran
      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,istat               ! conversion status of this line (output)

      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)

      integer
     &     i                    ! index

      integer*4
     &     incr_intvl           ! increment julian minute by interval function

      character
     &     cstring*80           ! string field

      character
     &     input_line*250       ! raw input line
      common /input_lines/ input_line
      data nintides /1/

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
c! last:	same as 'previous'
c! none:	field placeholder (doesn't do anything; same as if field
c!    		not given)

c! End datetime keywords:
c! length:	use all of tidefile, to its end
c! none:	see above

      if (ldefault) then
         nintides=0
      else
         if (nintides .eq. 0) nintides=1
      endif

      i=1
      tide_files(nintides).start_date=' '
      tide_files(nintides).end_date=' '
      do while (i .le. nfields)
         cstring=' '
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)

         if (rifld(i) .eq. tide_fname) then
            tide_files(nintides).filename=
     &           input_line(ibegf(i):ibegf(i)+ilenf(i)-1) ! use raw input to preserve case
c-----------determine if binary or HDF5 tidefile
            tide_files(nintides).binarytf=
     &           binarytf_fn(tide_files(nintides).filename)
         else if (rifld(i) .eq. tide_sdate) then ! starting date for this tidefile
            if (index(cstring,'gen') .gt. 0) then
               tide_files(nintides).start_date=generic_date
            else if (index(cstring,'runtime') .gt. 0) then
               tide_files(nintides).start_date=' '
            else if ( (index(cstring,'prev') .gt. 0) .or.
     &              (index(cstring,'last') .gt. 0) ) then
               if (nintides .ne. 1) then
                  tide_files(nintides).start_date='last'
               else             ! can't have 'last' for first tide file
                  write(unit_error, '(a)')
     &                 'Cannot use "last" or "prev" keyword for first tidefile.'
                  istat=-1
                  goto 900
               endif
            else
               if (index(cstring, 'none') .le. 0)
     &              tide_files(nintides).start_date(1:9)=cstring(1:9)
            endif
         else if ( (rifld(i) .eq. tide_stime)) then ! starting time
            if (index(cstring,'gen') .gt. 0) then
               tide_files(nintides).start_date=generic_date
            elseif ( (index(cstring,'prev') .gt. 0) .or.
     &              (index(cstring,'last') .gt. 0) ) then
               if (nintides .ne. 1) then
                  tide_files(nintides).start_date='last'
               else             ! can't have 'last' for first tide file
                  write(unit_error, '(a)')
     &                 'Cannot use "last" keyword for first tidefile.'
                  istat=-1
                  goto 900
               endif
            else
               if (index(cstring, 'none') .le. 0)
     &              tide_files(nintides).start_date(11:14)=cstring(1:4)
            endif
         else if (rifld(i) .eq. tide_edate) then ! ending date for this tidefile
            if (index(cstring,'len') .gt. 0) then
               tide_files(nintides).end_date='length'
            else if (index(cstring,'run') .gt. 0) then
               tide_files(nintides).start_date=' '
            else if (index(cstring, 'none') .le. 0) then
               if (incr_intvl(0,cstring,IGNORE_BOUNDARY) .eq. miss_val_i) then ! not a time length
                  tide_files(nintides).end_date(1:9)=cstring(1:9)
               else             ! is a time length
                  tide_files(nintides).end_date=cstring ! take the full string
               endif
            endif
            if (tide_files(nintides).end_date .eq. ' ') then
               tide_files(nintides).end_date='length'
            endif
         else if (rifld(i) .eq. tide_etime) then ! ending time
            if (index(cstring,'len') .gt. 0) then
               tide_files(nintides).end_date='length'
            else if (index(cstring, 'none') .le. 0) then
               if (incr_intvl(0,cstring,IGNORE_BOUNDARY) .eq. miss_val_i) then ! not a time length
                  tide_files(nintides).end_date(11:14)=cstring(1:4)
               else             ! is a time length
                  tide_files(nintides).end_date=cstring ! take the full string
               endif
            endif
            if (tide_files(nintides).end_date .eq. ' ') then
               tide_files(nintides).end_date='length'
            endif
         endif
         i=i+1
      enddo

      nintides=nintides+1
      if (nintides .gt. max_tide_files) then
         write(unit_error,630)
     &        'Too many tidefiles specified; max allowed is:'
     &        ,max_tide_files
 630     format(/a,i5)
         istat=-1
         goto 900
      endif

      return

 900  continue
      return

      end

      subroutine input_qualbin(field_names, mxflds, nfields, nflds,
     &     ifld, rifld, line, ibegf, ilenf, istat)

c-----process a character line into data arrays for
c-----tide file info.

      implicit none

      include 'common.f'
      include '../hdf_tidefile/common_qual_bin.inc'

      logical
     &     ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault

c-----local variables

      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,istat               ! conversion status of this line (output)

      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)

      integer
     &     i                    ! index

      integer*4
     &     incr_intvl           ! increment julian minute by interval function

      character
     &     cstring*80           ! string field

      character
     &     input_line*250       ! raw input line
      common /input_lines/ input_line

      i=1
      do while (i .le. nfields)
         cstring=' '
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)

         if (rifld(i) .eq. binary_fname) then
            qual_bin_file.filename=
     &           input_line(ibegf(i):ibegf(i)+ilenf(i)-1) ! use raw input to preserve case
         endif
         i=i+1
      enddo

      return

      end

      subroutine input_outputpath(field_names, mxflds, nfields, nflds,
     &     ifld, rifld, line, ibegf, ilenf, istat)

c-----process a character line into data arrays for
c-----print out info: names and type of data to print
      Use IO_Units
	Use Groups, only : GROUP_ALL
      implicit none
      
      include 'common.f'

      logical
     &     ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault

c-----local variables

      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,istat               ! conversion status of this line (output)
     &     ,loccarr             ! function to return array location of string

      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)

      integer
     &     itmp                 ! index
     &     ,i                   ! index
     &     ,ext2int             ! function converting ext chan number to internal
     &     ,ext2intnode         ! function converting ext node number to internal
     &     ,name_to_objno       ! function converting an object name to object number
      

      character
     &     cstring*80           ! string field
     &     ,ctmp*80             ! temporary char variable

      character
     &     input_line*250       ! raw input line
      common /input_lines/ input_line

      data noutpaths /0/

 610  format(/a)
 620  format(/a
     &     /'Input string is: ',a)
 630  format(/a,i5)

      if (ldefault) then
         noutpaths=0
      endif

      noutpaths=noutpaths+1
      if (noutpaths .gt. max_outputpaths) then
         write(unit_error,630)
     &        'Too many pathoutput paths specified; max allowed is:'
     &        ,max_outputpaths
         istat=-1
         goto 900
      endif
c-----default source group is from all sources
      pathoutput(noutpaths).source_group_ndx=GROUP_ALL

      i=1
      do while (i .le. nfields)
         cstring=' '
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)

         if (rifld(i) .eq. outpath_name) then
            pathoutput(noutpaths).name=cstring
            pathoutput(noutpaths).object_name=cstring
         else if (rifld(i) .eq. outpath_filename) then
            pathoutput(noutpaths).filename=
     &           input_line(ibegf(i):ibegf(i)+ilenf(i)-1) ! use raw input to preserve case
            if (index(pathoutput(noutpaths).filename, '.dss') .gt. 0) then
c--------------accumulate unique dss output filenames
               itmp=loccarr(pathoutput(noutpaths).filename,outfilenames
     &              ,max_dssoutfiles, EXACT_MATCH)
               if (itmp .lt. 0) then
                  if (abs(itmp) .le. max_dssoutfiles) then
                     outfilenames(abs(itmp))=pathoutput(noutpaths).filename
                     pathoutput(noutpaths).ndx_file=abs(itmp)
                  else
                     write(unit_error,610)
     &                    'Maximum number of unique DSS output files exceeded'
                     goto 900
                  endif
               else
                  pathoutput(noutpaths).ndx_file=itmp
               endif
            endif
         else if (rifld(i) .eq. outpath_chan) then
            read(cstring,'(i5)',err=810) pathoutput(noutpaths).object_no
            pathoutput(noutpaths).object_no=ext2int(pathoutput(noutpaths).object_no)
            pathoutput(noutpaths).object=obj_channel
            if (pathoutput(noutpaths).object_no .le. 0) then
               write(unit_error, 630)
     &              'Invalid output channel number given:',
     &              pathoutput(noutpaths).object_no
               istat=-1
               goto 900
            endif
         else if (rifld(i) .eq. outpath_dist) then
            pathoutput(noutpaths).object=obj_channel
            if (index(cstring,'len') .gt. 0) then
               pathoutput(noutpaths).chan_dist=chan_length
            else
               read(cstring,'(i10)',err=810) pathoutput(noutpaths).chan_dist
            endif
         else if (rifld(i) .eq. outpath_node) then
            read(cstring,'(i5)',err=810) pathoutput(noutpaths).object_no
            pathoutput(noutpaths).object_no=ext2intnode(pathoutput(noutpaths).object_no)
            pathoutput(noutpaths).object=obj_node
         else if (rifld(i) .eq. outpath_res_name) then
            pathoutput(noutpaths).object=obj_reservoir
            pathoutput(noutpaths).object_name=cstring
         else if (rifld(i) .eq. outpath_res_node) then
            pathoutput(noutpaths).object=obj_reservoir
            if (cstring .ne. 'none') then
               read(cstring,'(i5)',err=810) pathoutput(noutpaths).res_node_no
               pathoutput(noutpaths).res_node_no=ext2intnode(pathoutput(noutpaths).res_node_no) 
            else
               pathoutput(noutpaths).res_node_no=0
            endif
         else if (rifld(i) .eq. outpath_type .or.
     &            rifld(i) .eq. outpath_variable ) then
            pathoutput(noutpaths).meas_type=cstring
            if (index(cstring, 'flow') .gt. 0 .or.
     &           index(cstring, 'pump') .gt. 0) then
               pathoutput(noutpaths).units='cfs'
            else if (cstring(1:3) .eq. 'vel') then
               pathoutput(noutpaths).meas_type='vel'
               pathoutput(noutpaths).units='ft/s'
            else if (cstring .eq. 'stage') then
               pathoutput(noutpaths).units='feet'
            else if (cstring .eq. 'tds') then
               pathoutput(noutpaths).units='ppm'
            else if (cstring .eq. 'ec') then
               pathoutput(noutpaths).units='umhos/cm'
            else if (cstring .eq. 'do') then
               pathoutput(noutpaths).units='mg/l'
            else if (cstring .eq. 'nh3-n') then
               pathoutput(noutpaths).units='mg/l'
            else if (cstring .eq. 'org-n') then
               pathoutput(noutpaths).units='mg/l'
            else if (cstring .eq. 'no2-n') then
               pathoutput(noutpaths).units='mg/l'
            else if (cstring .eq. 'no3-n') then
               pathoutput(noutpaths).units='mg/l'
            else if (cstring .eq. 'bod') then
               pathoutput(noutpaths).units='mg/l'
            else if (cstring .eq. 'org-p') then
               pathoutput(noutpaths).units='mg/l'
            else if (cstring .eq. 'po4-p') then
               pathoutput(noutpaths).units='mg/l'
            else if (cstring .eq. 'algae') then
               pathoutput(noutpaths).units='mg/l'
            else if (cstring .eq. 'temp') then
               pathoutput(noutpaths).units='deg c'
            else                ! unidentified output type; default part per million
               pathoutput(noutpaths).units='ppm'
            endif
         else if (rifld(i) .eq. outpath_from_name .or.
     &	        rifld(i) .eq. outpath_source_group  ) then
            pathoutput(noutpaths).source_group_ndx=name_to_objno(obj_group,cstring)
         else if (rifld(i) .eq. outpath_interval) then
            call split_epart(cstring,itmp,ctmp)
            if (itmp .ne. miss_val_i) then ! valid interval, parse it
               pathoutput(noutpaths).no_intervals=itmp
               pathoutput(noutpaths).interval=ctmp
            else
               write(unit_error,610)
     &              'Unknown input interval: ' // cstring
               istat=-1
               goto 900
            endif
         else if (rifld(i) .eq. outpath_period) then
            pathoutput(noutpaths).per_type=per_type_inst_val ! assume instantaneous
            if (index(cstring,'av') .ne. 0)
     &           pathoutput(noutpaths).per_type=per_type_per_aver
            if (index(cstring,'min') .ne. 0)
     &           pathoutput(noutpaths).per_type=per_type_per_min
            if (index(cstring,'max') .ne. 0)
     &           pathoutput(noutpaths).per_type=per_type_per_max
         else if (rifld(i) .eq. outpath_modifier) then
            if (cstring(1:4) .eq. 'none') then
               pathoutput(noutpaths).modifier=' '
            else
               pathoutput(noutpaths).modifier=cstring
            endif
         endif
         pathoutput(noutpaths).use=.true.
         i=i+1
      enddo

      return

c-----char-to-value conversion errors

 810  continue
      write(unit_error, 620) 'Conversion error on field ' //
     &     field_names(rifld(i)), cstring

      istat=-2

 900  continue                  ! fatal error

      return
      end

      subroutine input_iofiles(field_names, mxflds, nfields, nflds, ifld,
     &     rifld, line, ibegf, ilenf, istat)

c-----process a character line into data arrays for
c-----output file names
      Use IO_Units
      implicit none

      include 'common.f'
      include 'common_ptm.inc'
c-----local variables

      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,istat               ! conversion status of this line (output)

      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)

      integer
     &     i,i1,i2,i3           ! indices

      character*10
     &     cstring1             ! string for model
     &     ,cstring2            ! string for type
     &     ,cstring3            ! string for io
     &     ,cstring4            ! string for interval
      character*80
     &     cstring5             ! string for filename

      character
     &     input_line*250       ! raw input line
      common /input_lines/ input_line

 610  format(/a)
 620  format(/'Invalid value given in ',a,' field: ',a)

c-----model, type, and io are required for each line
      if (ifld(io_model) .eq. 0) then
         write(unit_error, 610)
     &        'No model given.'
         istat=-1
         goto 900
      endif

      if (ifld(io_type) .eq. 0) then
         write(unit_error, 610)
     &        'No type given.'
         istat=-1
         goto 900
      endif

      if (ifld(io_io) .eq. 0) then
         write(unit_error, 610)
     &        'No io method given.'
         istat=-1
         goto 900
      endif

      i=ifld(io_model)
      cstring1=' '
      cstring1=line(ibegf(i):ibegf(i)+ilenf(i)-1)

      i=ifld(io_type)
      cstring2=' '
      cstring2=line(ibegf(i):ibegf(i)+ilenf(i)-1)

      i=ifld(io_io)
      cstring3=' '
      cstring3=line(ibegf(i):ibegf(i)+ilenf(i)-1)

      cstring4=' '
      if (ifld(io_interval) .gt. 0) then
         i=ifld(io_interval)
         cstring4=line(ibegf(i):ibegf(i)+ilenf(i)-1)
      endif

      cstring5=' '
      if (ifld(io_filename) .gt. 0) then
         i=ifld(io_filename)
         cstring5=input_line(ibegf(i):ibegf(i)+ilenf(i)-1) ! use raw input to preserve case
      endif

c-----fill in structure

      if (cstring1(1:3) .eq. 'out') then
         output_filename=cstring5
         return
      else if (cstring1(1:3) .eq. 'hyd') then
         i1=hydro
      else if (cstring1(1:3) .eq. 'qua') then
         i1=qual
      else if (cstring1(1:3) .eq. 'ptm') then
         i1=ptm
      else
         write(unit_error, 620) 'model', cstring1
         istat=-1
         goto 900
      endif

      if (cstring2(1:3) .eq. 'res') then
         i2=io_restart
      else if (cstring2(1:3) .eq. 'bin' .or.
     &        cstring2(1:3) .eq. 'tid') then
         i2=io_tide
      else if (cstring2(1:3) .eq. 'hdf') then
         i2=io_hdf5
      else if (cstring2(1:3) .eq. 'ani') then
         i2=io_animation
      else if (cstring2(1:3) .eq. 'tra') then
         i2=io_trace
      else if (cstring2(1:3) .eq. 'beh') then
         i2=io_behavior
      else if (cstring2(1:3) .eq. 'gro') then
         i2=io_group
         ptm_igroup_int=1
         ptm_igroup=.true.
      else
         write(unit_error, 620) 'type', cstring2
         istat=-1
         goto 900
      endif

      if (cstring3(1:2) .eq. 'in') then
         i3=io_read
      else if (cstring3(1:3) .eq. 'out') then
         i3=io_write
      else
         write(unit_error, 620) 'io', cstring3
         istat=-1
         goto 900
      endif

      if (cstring4 .ne. ' ' .and.
     &     cstring4(1:4) .ne. 'none') then
         io_files(i1,i2,i3).interval=cstring4
      endif

      io_files(i1,i2,i3).use=.true.
      io_files(i1,i2,i3).filename=cstring5

      return

 900  continue

      return

      end

      subroutine input_quadrature(field_names, mxflds, nfields, nflds,
     &     ifld, rifld, line, ibegf, ilenf, istat)

c-----process a character line into data arrays for
c-----quadrature integration info
      Use IO_Units
      implicit none

      include 'common.f'

      logical
     &     ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault

      include '../hydrolib/network.inc'
      include '../hydrolib/netcntrl.inc'

c-----local variables

      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,istat               ! conversion status of this line (output)
     &     ,i                   ! array index

      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)

      character
     &     cstring*15           ! string field

      data nquadpts /1/

 620  format(/a
     &     /'Input string is: ',a)
 630  format(/a,f10.2)

      if (ldefault) then
         nquadpts=0
      else
         if (nquadpts .eq. 0) nquadpts=1
      endif

      i=q_pt
      cstring=line(ibegf(ifld(i)):ibegf(ifld(i)) +
     &     ilenf(ifld(i))-1)
      read(cstring,'(f10.0)',err=810) quadpt(nquadpts)
      i=q_wt
      cstring=line(ibegf(ifld(i)):ibegf(ifld(i)) +
     &     ilenf(ifld(i))-1)
      read(cstring,'(f10.0)',err=810) quadwt(nquadpts)

      if (
     &     quadpt(nquadpts) .gt. 1.0 .or.
     &     quadpt(nquadpts) .lt. 0.0) then
         write(unit_error,630)
     &        'Quad Point out of bounds:',quadpt(nquadpts)
         goto 900
      endif

      nquadpts=nquadpts+1
      if (nquadpts .gt. maxquadpts) then
         write(unit_error,630)
     &        'Too many quadpts specified; max allowed is:'
     &        ,maxquadpts
         istat=-1
         goto 900
      endif

      return

c-----char-to-value conversion errors

 810  continue
      write(unit_error, 620) 'Conversion error on field ' //
     &     field_names(ifld(i)), cstring

 900  continue

      istat=-2

      return
      end

      subroutine input_envvar(field_names, mxflds, nfields, nflds,
     &     ifld, rifld, line, ibegf, ilenf, istat)

c-----process a character line into data arrays for
c-----pseudo environment variable info
      Use IO_Units
      implicit none

      include 'common.f'

      character
     &     input_line*250       ! raw input line
      common /input_lines/ input_line

c-----local variables

      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,istat               ! conversion status of this line (output)
     &     ,i,j                 ! array indices
     &     ,nenvvars            ! number of env vars

      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)
      character*130 new_name
      save nenvvars
      data nenvvars /1/

 610  format(/a)
 630  format(/a,i3)

c-----name required for each line; empty value indicates erase it
      if (ifld(envvar_name) .eq. 0) then
         write(unit_error, 610) 'No environment variable name given.'
         istat=-1
         goto 900
      endif
      i=ifld(envvar_name)
      new_name = input_line(ibegf(ifld(i)):ibegf(ifld(i)) +
     &     ilenf(ifld(i))-1)
      do j = 1, nenvvars
         if(new_name .eq. envvars(j).name) then
            i=ifld(envvar_value)
	    envvars(j).value = input_line(ibegf(ifld(i)):ibegf(ifld(i)) +
     &           ilenf(ifld(i))-1)
	    return
         endif
      enddo

      envvars(nenvvars).name=new_name
      if (ifld(envvar_value) .eq. 0) then ! no value
         envvars(nenvvars).value=' '
      else
         i=ifld(envvar_value)
         envvars(nenvvars).value=input_line(ibegf(ifld(i)):ibegf(ifld(i)) +
     &        ilenf(ifld(i))-1)
      endif
      nenvvars=nenvvars+1
      if (nenvvars .gt. max_envvars) then
         write(unit_error,630)
     &        'Too many envvars specified; max allowed is:'
     &        ,max_envvars
         istat=-1
         goto 900
      endif

      return

 900  continue

      istat=-2

      return
      end

      subroutine input_scalar(field_names, mxflds, nfields, nflds, ifld,
     &     rifld, line, ibegf, ilenf, istat)

      use PhysicalConstants
      use IO_Units

c-----process a character line into data arrays for scalar info

      implicit none

      include '../hydrolib/network.inc'
      include '../hydrolib/netcntrl.inc'
      include '../hydrolib/chconnec.inc'

      include 'common.f'
      include 'common_qual.inc'
      include 'common_ptm.inc'
      logical
     &     ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault

c-----local variables

      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,istat               ! conversion status of this line (output)

      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)

      character
     &     cstring1*48          ! string field for keyword or value
     &     ,cstring2*48         ! string field for keyword or value
     &     ,ctmp*48             ! scratch character variable

      data nprints /1/

c-----defaults

      data
     &     variabledensity /.false./
     &     ,variablesinuosity /.false./
     &     ,theta /0.6/
     &     ,maxiterations /50/
     &     ,luinc /1/
     &     ,toleranceq /0.0005/
     &     ,tolerancez /0.0005/

 610  format(/'Unrecognized line in SCALAR section:'
     &     /a)
 615  format(/'Theta must be between 0.5 and 1.0:',f5.2)
 620  format(/a,' ',a/a)
 630  format(/a)

	if (nfields .ne. 2) return  ! must have two fields
      cstring1=line(ibegf(1):ibegf(1)+ilenf(1)-1)
      cstring2=line(ibegf(2):ibegf(2)+ilenf(2)-1)

c-----run start date and time can be a DSS date (e.g. 01jan1994 0100),
c-----or 'restart' (use date from restart file), or
c-----'tide' (use date from tidefile)
      if (cstring1 .eq. 'run_start_date') then
         run_start_date(1:9)=cstring2(1:9)
      else if (cstring1 .eq. 'run_start_time') then
         run_start_date(11:14)=cstring2(1:4)
      else if (cstring1 .eq. 'run_end_date') then
         run_end_date(1:9)=cstring2(1:9)
      else if (cstring1 .eq. 'run_end_time') then
         run_end_date(11:14)=cstring2(1:4)
      else if (cstring1 .eq. 'run_length') then
         run_length=cstring2
      else if (cstring1 .eq. 'tf_start_date') then
         tf_start_date(1:9)=cstring2(1:9)
      else if (cstring1 .eq. 'tf_start_time') then
         tf_start_date(11:14)=cstring2(1:4)
      else if (cstring1 .eq. 'database') then
         call set_database_name(cstring2(1:32))
      else if (cstring1 .eq. 'model_name') then
         call set_model_name(cstring2(1:48))
      else if (cstring1 .eq. 'print_start_date') then
         if (nprints .eq. 0) nprints=1
         print_start_date(nprints)(1:9)=cstring2(1:9)
         nprints=nprints+1
      else if (cstring1 .eq. 'print_start_time') then
         if (nprints .eq. 0) nprints=1
         print_start_date(nprints)(11:14)=cstring2(1:4)
      else if (cstring1 .eq. 'flush_output') then
         flush_intvl=cstring2
      else if (cstring1 .eq. 'binary_output') then
         read(cstring2,'(l2)', err=810) binary_output
      else if (cstring1 .eq. 'dss_direct') then
         read(cstring2,'(l2)', err=810) dss_direct
      else if (cstring1 .eq. 'hydro_time_step') then
         time_step_intvl_hydro=cstring2
      else if (cstring1 .eq. 'qual_time_step') then
         time_step_intvl_qual=cstring2
      else if (cstring1 .eq. 'ptm_time_step') then
         ptm_time_step_int=1
         time_step_intvl_ptm=cstring2
      else if (cstring1 .eq. 'mass_tracking') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) mass_tracking
      else if (cstring1 .eq. 'init_conc') then
         field_names(1)=cstring1
         read(cstring2,'(f10.0)', err=810) init_conc
      else if (cstring1 .eq. 'dispersion') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) dispersion
c--------global rates for non-conserative const.
      else if (cstring1 .eq. 'algaefract_n') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) algaefract_n
      else if (cstring1 .eq. 'algaefract_p') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) algaefract_p
      else if (cstring1 .eq. 'oxy_photo') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) oxy_photo
      else if (cstring1 .eq. 'oxy_resp') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) oxy_resp
      else if (cstring1 .eq. 'oxy_nh3') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) oxy_nh3
      else if (cstring1 .eq. 'oxy_no2') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) oxy_no2
      else if (cstring1 .eq. 'alg_chl_ratio') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) alg_chl_ratio
      else if (cstring1 .eq. 'pref_factor') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) pref_factor
      else if (cstring1 .eq. 'klight_half') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) klight_half
      else if (cstring1 .eq. 'knit_half') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) knit_half
      else if (cstring1 .eq. 'kpho_half') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) kpho_half
      else if (cstring1 .eq. 'lambda0') then
         field_names(1)=cstring1
         read(cstring2,'(f8.2)', err=810) lambda0
      else if (cstring1 .eq. 'lambda1') then
         field_names(1)=cstring1
         read(cstring2,'(f8.4)', err=810) lambda1
      else if (cstring1 .eq. 'lambda2') then
         field_names(1)=cstring1
         read(cstring2,'(f8.4)', err=810) lambda2
c--------heat and temperature related parameters
      else if (cstring1 .eq. 'elev') then
         field_names(1)=cstring1
         read(cstring2,'(f8.2)', err=810) elev
      else if (cstring1 .eq. 'lat') then
         field_names(1)=cstring1
         read(cstring2,'(f8.2)', err=810) lat
      else if (cstring1 .eq. 'long') then
         field_names(1)=cstring1
         read(cstring2,'(f8.2)', err=810) longitude
      else if (cstring1 .eq. 'long_std_merid') then
         field_names(1)=cstring1
         read(cstring2,'(f8.2)', err=810) long_std_merid
      else if (cstring1 .eq. 'dust_attcoeff') then
         field_names(1)=cstring1
         read(cstring2,'(f8.2)', err=810) dust_attcoeff
      else if (cstring1 .eq. 'evapcoeff_a') then
         field_names(1)=cstring1
         read(cstring2,'(f10.5)', err=810) evapcoeff_a
      else if (cstring1 .eq. 'evapcoeff_b') then
         field_names(1)=cstring1
         read(cstring2,'(f10.5)', err=810) evapcoeff_b
      else if (cstring1 .eq. 'temp_bod_decay') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_bod_decay)
      else if (cstring1 .eq. 'temp_bod_set') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_bod_set)
      else if (cstring1 .eq. 'temp_reaer') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_reaer)
      else if (cstring1 .eq. 'temp_do_ben') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_do_ben)
      else if (cstring1 .eq. 'temp_orgn_decay') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_orgn_decay)
      else if (cstring1 .eq. 'temp_orgn_set') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_orgn_set)
      else if (cstring1 .eq. 'temp_nh3_decay') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_nh3_decay)
      else if (cstring1 .eq. 'temp_nh3_ben') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_nh3_ben)
      else if (cstring1 .eq. 'temp_no2_decay') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_no2_decay)
      else if (cstring1 .eq. 'temp_orgp_decay') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_orgp_decay)
      else if (cstring1 .eq. 'temp_orgp_set') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_orgp_set)
      else if (cstring1 .eq. 'temp_po4_ben') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_po4_ben)
      else if (cstring1 .eq. 'temp_alg_grow') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_alg_grow)
      else if (cstring1 .eq. 'temp_alg_resp') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_alg_resp)
      else if (cstring1 .eq. 'temp_alg_set') then
         field_names(1)=cstring1
         read(cstring2,'(f8.3)', err=810) thet(temp_alg_set)
      else if (cstring1 .eq. 'display_intvl') then
         display_intvl=cstring2
      else if (cstring1 .eq. 'deltax') then
c--------keyword 'length' means use channel length for each delta x
         if (index(cstring2, 'len') .eq. 0) then
            field_names(1)=cstring1
            read(cstring2,'(f10.0)', err=810) deltax_requested
         else
            deltax_requested=0.0
         endif
      else if (cstring1 .eq. 'levee_slope') then
         field_names(1)=cstring1
         read(cstring2,'(f10.0)', err=810) levee_slope
      else if (cstring1 .eq. 'theta') then
         field_names(1)=cstring1
         read(cstring2,'(f10.0)', err=810) theta
         if (
     &        theta .lt. 0.5 .or.
     &        theta .gt. 1.0
     &        ) then
            write(unit_error, 615) theta
            istat=-1
            goto 900
         endif
      else if (cstring1 .eq. 'terms') then
         ctmp=cstring2
         terms=0
         if (ctmp(1:3) .eq. 'dyn') then
            terms=1             ! dynamic wave
         else
            write(unit_error, 620)
     &           'You selected solution method:',
     &           trim(ctmp),
     &           'Only dynamic supported.'
            istat=-1
            goto 900
         endif
      else if (cstring1 .eq. 'vardensity') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) variabledensity
         if (variabledensity .and. terms .ne. 1) then
            variabledensity=.false.
            write(unit_error, 630)
     &           'Warning: Variable Density allowed only with dynamic wave.'
         endif
      else if (cstring1 .eq. 'varsinuosity') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) variablesinuosity
         if (variablesinuosity .and. terms .eq. 3) then
            variablesinuosity=.false.
            write(unit_error, 630)
     &           'Warning: variable sinuosity not allowed with kinematic wave.'
         endif
      else if (cstring1 .eq. 'gravity') then
         field_names(1)=cstring1
         read(cstring2,'(f10.0)', err=810) gravity
      else if (cstring1 .eq. 'toleranceq') then
         field_names(1)=cstring1
         read(cstring2,'(f10.0)', err=810) toleranceq
      else if (cstring1 .eq. 'tolerancez') then
         field_names(1)=cstring1
         read(cstring2,'(f10.0)', err=810) tolerancez
      else if (cstring1 .eq. 'maxiter') then
         field_names(1)=cstring1
         read(cstring2,'(i5)', err=810) maxiterations
      else if (cstring1 .eq. 'luinc') then
         field_names(1)=cstring1
         read(cstring2,'(i5)', err=810) luinc
      else if (cstring1 .eq. 'repeating_tide') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) repeating_tide
      else if (cstring1 .eq. 'warmup_run') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) warmup_run
      else if (cstring1 .eq. 'max_tides') then
         field_names(1)=cstring1
         read(cstring2,'(i5)', err=810) max_tides
      else if (cstring1 .eq. 'tide_length') then
         tide_cycle_length=cstring2
      else if (cstring1 .eq. 'toler_stage') then
         field_names(1)=cstring1
         read(cstring2,'(f10.0)', err=810) repeat_stage_tol
      else if (cstring1 .eq. 'toler_flow') then
         field_names(1)=cstring1
         read(cstring2,'(f10.0)', err=810) repeat_flow_tol
      else if (cstring1 .eq. 'printlevel') then
         field_names(1)=cstring1
         read(cstring2,'(i5)', err=810) print_level
      else if (cstring1 .eq. 'temp_dir') then
         temp_dir=cstring2
      else if (cstring1 .eq. 'checkdata') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) check_input_data
      else if (cstring1 .eq. 'cont_missing') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) cont_missing
      else if (cstring1 .eq. 'cont_unchecked') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) cont_unchecked
      else if (cstring1 .eq. 'cont_question') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) cont_question
      else if (cstring1 .eq. 'cont_bad') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) cont_bad
      else if (cstring1 .eq. 'warn_missing') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) warn_missing
      else if (cstring1 .eq. 'warn_unchecked') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) warn_unchecked
      else if (cstring1 .eq. 'warn_question') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) warn_question
      else if (cstring1 .eq. 'warn_bad') then
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) warn_bad
      else if (cstring1 .eq. 'ptm_ivert') then
         ptm_ivert_int=1
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) ptm_ivert
      else if (cstring1 .eq. 'ptm_itrans') then
         ptm_itrans_int=1
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) ptm_itrans
      else if (cstring1 .eq. 'ptm_iey') then
         ptm_iey_int=1
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) ptm_iey
      else if (cstring1 .eq. 'ptm_iez') then
         ptm_iez_int=1
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) ptm_iez
      else if (cstring1 .eq. 'ptm_flux_percent') then
         ptm_flux_percent_int=1
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) ptm_flux_percent
      else if (cstring1 .eq. 'ptm_group_percent') then
         ptm_group_percent_int=1
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) ptm_group_percent
      else if (cstring1 .eq. 'ptm_flux_cumulative') then
         ptm_flux_cumulative_int=1
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) ptm_flux_cumulative
      else if (cstring1 .eq. 'ptm_random_seed') then
         ptm_random_seed_int=1
         field_names(1)=cstring1
         read(cstring2,'(i5)', err=810) ptm_random_seed
      else if (cstring1 .eq. 'ptm_no_animated') then
         ptm_no_animated_int=1
         field_names(1)=cstring1
         read(cstring2,'(i5)', err=810) ptm_no_animated
      else if (cstring1 .eq. 'ptm_trans_constant') then
         ptm_trans_constant_int=1
         field_names(1)=cstring1
         read(cstring2,'(f7.4)', err=810) ptm_trans_constant
      else if (cstring1 .eq. 'ptm_vert_constant') then
         ptm_vert_constant_int=1
         field_names(1)=cstring1
         read(cstring2,'(f7.4)', err=810) ptm_vert_constant
      else if (cstring1 .eq. 'ptm_iprof') then
         ptm_iprof_int=1
         field_names(1)=cstring1
         read(cstring2,'(l2)', err=810) ptm_iprof
      else if (cstring1 .eq. 'ptm_trans_a_coef') then
         ptm_trans_a_coef_int=1
         field_names(1)=cstring1
         read(cstring2,'(f7.4)', err=810) ptm_trans_a_coef
      else if (cstring1 .eq. 'ptm_trans_b_coef') then
         ptm_trans_b_coef_int=1
         field_names(1)=cstring1
         read(cstring2,'(f7.4)', err=810) ptm_trans_b_coef
      else if (cstring1 .eq. 'ptm_trans_c_coef') then
         ptm_trans_c_coef_int=1
         field_names(1)=cstring1
         read(cstring2,'(f7.4)', err=810) ptm_trans_c_coef
      else if (cstring1 .eq. 'ptm_shear_vel') then
	   write(unit_error)"ptm_shear_vel not used in this version of PTM"
	   istat=-1
	   goto 900
      else
         write(unit_error, 610) line
         istat=-1
         goto 900
      endif
      return
c-----char-to-value conversion errors
 810  continue
      write(unit_error, 620) 'Conversion error on field ' //
     &     field_names(1), cstring1 // '  ' // cstring2
      istat=-2

 900  continue                  ! fatal error
      return
      end

      subroutine input_particle_flux(field_names, mxflds, nfields, nflds,
     &     ifld, rifld, line, ibegf, ilenf, idelmt, istat)

c-----process a character line into data arrays for particle flux counting
      use IO_Units
	use Groups, only: GROUP_ANY_INDEX
      implicit none

      include 'common.f'
      include 'common_ptm.inc'

      logical
     &     ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault

c-----local variables

      logical
     &     new_object           ! true if a new waterbody object type is being processed

      integer
     &     objtype              ! type of waterbody object
     &     ,mxflds              ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,idelmt(mxflds)      ! type of delimiter for each field
     &     ,istat               ! conversion status of this line (output)
     &     ,lfldndx             ! array index for line fields
     &     ,objndx              ! array index for object IDs
     &     ,kfldndx             ! array index for field keywords
     &     ,i                   ! array index
     &     ,loc                 ! array location number
     &     ,loccarr             ! function to return array location of string
     &     ,itmp                ! index

      integer,external :: name_to_objno,obj_type_code


      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)

      character
     &     cstring*40           ! string field
     &     ,ctmp*80             ! temporary char variable
     &     ,objtmp*32

      character
     &     input_line*250       ! raw input line
      common /input_lines/ input_line

 610  format(/a)

 620  format(/a
     &     /'Input string is: ',a)
 630  format(/a,i5)

      if (ldefault) then
         noutpaths=0
      else
         noutpaths=noutpaths+1
      endif

      lfldndx=1
      kfldndx=1
      pathoutput(noutpaths).object=obj_flux

      do while (lfldndx .le. nfields)
         cstring=' '
         cstring=line(ibegf(lfldndx):ibegf(lfldndx)+ilenf(lfldndx)-1)
         if (rifld(kfldndx) .eq. ptm_interval) then
            call split_epart(cstring,itmp,ctmp)
            if (itmp .ne. miss_val_i) then ! valid interval, parse it
               pathoutput(noutpaths).no_intervals=itmp
               pathoutput(noutpaths).interval=ctmp
            else
               write(unit_error,610)
     &              'Unknown input interval: ' // cstring
               istat=-1
               goto 900
            endif
         else if (rifld(kfldndx) .eq. ptm_filename) then
            pathoutput(noutpaths).filename=
     &           input_line(ibegf(lfldndx):ibegf(lfldndx)+ilenf(lfldndx)-1) ! use raw input to preserve case
            if (index(pathoutput(noutpaths).filename, '.dss') .gt. 0) then
c--------------accumulate unique dss output filenames
               itmp=loccarr(pathoutput(noutpaths).filename,outfilenames
     &              ,max_dssoutfiles, EXACT_MATCH)
               if (itmp .lt. 0) then
                  if (abs(itmp) .le. max_dssoutfiles) then
                     outfilenames(abs(itmp))=pathoutput(noutpaths).filename
                     pathoutput(noutpaths).ndx_file=abs(itmp)
                  else
                     write(unit_error,610)
     &                    'Maximum number of unique DSS output files exceeded'
                     goto 900
                  endif
               else
                  pathoutput(noutpaths).ndx_file=itmp
               endif
            endif
         else if (rifld(kfldndx) .eq. ptm_modifier) then
            if (cstring(1:4) .eq. 'none') then
               pathoutput(noutpaths).modifier=' '
            else
               pathoutput(noutpaths).modifier=cstring
            endif
         else if (rifld(kfldndx) .eq. b_part) then
            pathoutput(noutpaths).b_part=cstring
c-----------the fields ptm_from_wb and ptm_to_wb must be delimited
c-----------with 'delimiter'; also, object IDs for each object type
c-----------are separated with commas, while different objects are
c-----------separated with spaces--the delimiter type array tells us which
         else if (rifld(kfldndx) .eq. ptm_from_wb) then
	      
            objtmp=' '
	      objtmp=cstring(1:(index(cstring,":")-1))

	      pathoutput(noutpaths).flux_from_type
     &              =obj_type_code(objtmp)
            objtmp=' '
	      objtmp=cstring((index(cstring,":")+1):len_trim(cstring))
            if(trim(objtmp) .eq. 'all' .and. 
     &        pathoutput(noutpaths).flux_from_type .ne. obj_group)then
	         pathoutput(noutpaths).flux_from_ndx=GROUP_ANY_INDEX
            else    
		     pathoutput(noutpaths).flux_from_ndx=name_to_objno(
     &              pathoutput(noutpaths).flux_from_type,objtmp)
	      end if
            if( pathoutput(noutpaths).flux_from_ndx .eq. miss_val_i)then
	         write(unit_error, 650)trim(cstring)
 650                 format(/'Unrecognized object name: ',a)
               istat=-1
	         goto 900
	      end if
         else if (rifld(kfldndx) .eq. ptm_to_wb) then
	      objtmp=' '
		  objtmp=cstring(1:(index(cstring,":")-1))
	      pathoutput(noutpaths).flux_to_type
     &              =obj_type_code(objtmp)
	      objtmp=' '
            objtmp=cstring((index(cstring,":")+1):len_trim(cstring))
            if(trim(objtmp) .eq. 'all' .and. 
     &        pathoutput(noutpaths).flux_to_type .ne. obj_group)then
	         pathoutput(noutpaths).flux_to_ndx=GROUP_ANY_INDEX

            else    

	         pathoutput(noutpaths).flux_to_ndx=name_to_objno(
     &              pathoutput(noutpaths).flux_to_type,objtmp)
	      end if

            if( pathoutput(noutpaths).flux_to_ndx .eq. miss_val_i)then
	         write(unit_error, 650)trim(cstring)
               istat=-1
	         goto 900
	      end if

            objndx=1
         endif
         lfldndx=lfldndx+1
         kfldndx=kfldndx+1
      enddo

      pathoutput(noutpaths).meas_type='ptm_flux'
      pathoutput(noutpaths).units='percent'
      pathoutput(noutpaths).per_type=per_type_inst_cum


c      noutpaths=noutpaths+1
      if (noutpaths .gt. max_outputpaths) then
      write(unit_error,630)
     &             'Too many particle_flux paths specified; max allowed is:'
     &             ,max_outputpaths
              istat=-1
      endif

      return

 810  continue
      write(unit_error, 620) 'Conversion error on field ' //
     &          field_names(rifld(kfldndx)), cstring

       istat=-2

 900   continue

      return
      end

      subroutine input_group_output(field_names, mxflds, nfields, nflds,
     &     ifld, rifld, line, ibegf, ilenf, idelmt, istat)
 
c-----process a character line into data arrays for particle group output
      use IO_Units
      implicit none
 
      include 'common.f'
      include 'common_ptm.inc'
 
      logical
     &     ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault
 
c-----local variables
 
      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,idelmt(mxflds)      ! type of delimiter for each field
     &     ,istat               ! conversion status of this line (output)
     &     ,i                   ! array index
     &     ,loc                 ! array location number
     &     ,loccarr             ! function to return array location of string
     &     ,itmp                ! index
 
      integer,external :: name_to_objno
      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)
 
      character
     &     cstring*32           ! string field
     &     ,ctmp*80             ! temporary char variable
 
      character
     &     input_line*250       ! raw input line
      common /input_lines/ input_line
 
 610  format(/a)
 
 620  format(/a
     &     /'Input string is: ',a)
 630  format(/a,i5)
 
      if (ldefault) then
         noutpaths=0
      else
         noutpaths=noutpaths+1
      endif

      i=1
	ptm_igroup=.true.  ! fixme: what does this do?
 
      do while (i .le. nfields)
         cstring=' '
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)
 
         if (rifld(i) .eq. ptm_interval) then
            call split_epart(cstring,itmp,ctmp)
            if (itmp .ne. miss_val_i) then ! valid interval, parse it
               pathoutput(noutpaths).no_intervals=itmp
               pathoutput(noutpaths).interval=ctmp
            else
               write(unit_error,610)
     &              'Unknown input interval: ' // cstring
               istat=-1
               goto 900
            endif
         else if (rifld(i) .eq. ptm_filename) then
            pathoutput(noutpaths).filename=
     &           input_line(ibegf(i):ibegf(i)+ilenf(i)-1) ! use raw input to preserve case
            if (index(pathoutput(noutpaths).filename, '.dss') .gt. 0) then 
c--------------accumulate unique dss output filenames
               itmp=loccarr(pathoutput(noutpaths).filename,outfilenames
     &              ,max_dssoutfiles, EXACT_MATCH)
               if (itmp .lt. 0) then
                  if (abs(itmp) .le. max_dssoutfiles) then
                     outfilenames(abs(itmp))=pathoutput(noutpaths).filename
                     pathoutput(noutpaths).ndx_file=abs(itmp)
                  else
                     write(unit_error,610)
     &                    'Maximum number of unique DSS output files exceeded'
                     goto 900
                  endif
               else
                  pathoutput(noutpaths).ndx_file=itmp
               endif
            endif
         else if (rifld(i) .eq. b_part) then
            pathoutput(noutpaths).b_part=cstring
         else if (rifld(i) .eq. ptm_group) then
	       pathoutput(noutpaths).object_no=name_to_objno(obj_group,cstring)
	       if(pathoutput(noutpaths).object_no .eq. miss_val_i)then
	          write(unit_error,*)"Unrecognized group name for group output spec: " 
     &             // trim(cstring)
	          goto 900
	        end if
         endif
         i=i+1
      enddo

      pathoutput(noutpaths).meas_type='ptm_group'
      pathoutput(noutpaths).units='percent'
      pathoutput(noutpaths).per_type=per_type_inst_cum
 

	ngroup_outputs=ngroup_outputs+1

      if (noutpaths .gt. max_outputpaths) then
         write(unit_error,630)
     &        'Too many group output paths specified; max allowed is:'
     &        ,max_outputpaths
         istat=-1
      endif

      return
 
 810  continue
      write(unit_error, 620) 'Conversion error on field ' //
     &     field_names(rifld(i)), cstring
 
      istat=-2
 
 900  continue
 
      return
      end



      subroutine input_partno(field_names, mxflds, nfields, nflds, ifld,
     &     rifld, line, ibegf, ilenf, istat)

c-----process a character line into data arrays for
c-----particle injection over time periods
      use IO_Units
      implicit none

      include 'common.f'
      include 'common_ptm.inc'

      logical
     &     ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault

c-----local variables

      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,istat               ! conversion status of this line (output)

      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)

      integer
     &     i                    ! index

      character
     &     cstring*80           ! string field

      data npartno /1/

 610  format(/a)
 620  format(/a
     &     /'Input string is: ',a)
 630  format(/a,i5)

      if (ldefault) then
         npartno=0
      else
         if (npartno .eq. 0) npartno=1
      endif

      i=1
      do while (i .le. nfields)
         cstring=' '
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)
         if (rifld(i) .eq. partno_node) then
            read(cstring,'(i5)', err=810) part_injection(npartno).node
         else if (rifld(i) .eq. partno_nparts) then
            read(cstring,'(i6)', err=810) part_injection(npartno).nparts
         else if (rifld(i) .eq. partno_slength) then
            part_injection(npartno).slength=cstring
         else if (rifld(i) .eq. partno_length) then
            part_injection(npartno).length=cstring
         else if (rifld(i) .eq. partno_sdate) then
            if (index(cstring,'gen') .gt. 0) then
               part_injection(npartno).start_date=generic_date
            else
               part_injection(npartno).start_date(1:9)=cstring(1:9)
            endif
         else if (rifld(i) .eq. partno_stime) then
            if (index(cstring,'gen') .gt. 0) then
               part_injection(npartno).start_date=generic_date
            else
               part_injection(npartno).start_date(11:14)=cstring(1:4)
            endif
         else if (rifld(i) .eq. partno_edate) then
            if (index(cstring,'gen') .gt. 0) then
               part_injection(npartno).end_date=generic_date
            else
               part_injection(npartno).end_date(1:9)=cstring(1:9)
            endif
         else if (rifld(i) .eq. partno_etime) then
            if (index(cstring,'gen') .gt. 0) then
               part_injection(npartno).end_date=generic_date
            else
               part_injection(npartno).end_date(11:14)=cstring(1:4)
            endif
         else if (rifld(i) .eq. partno_type) then
            part_injection(npartno).type=cstring
         endif
         i=i+1
      enddo

      npartno=npartno+1
      if (npartno .gt. max_injection) then
         write(unit_error,630)
     &        'Too many input paths specified; max allowed is:'
     &        ,max_injection
         istat=-1
         goto 900
      endif

      return

c-----char-to-value conversion errors

 810  continue
      write(unit_error, 620) 'Conversion error on field ' //
     &     field_names(rifld(i)), cstring

      istat=-2

 900  continue                  ! fatal error

      return
      end


      subroutine input_groups(field_names, mxflds, nfields, nflds, ifld,
     &     rifld, line, ibegf, ilenf, istat)

c-----process a character line into data arrays for
c-----channnels and open water areas contained in groups
      Use IO_Units
	Use Groups,only:GroupArray,GroupMember,nGroup,AddGroupMembers,
     &                MAX_GROUPS,MAX_MEMBER_PATTERNS,
     &                NumberMatches,RetrieveMatch
	
      implicit none

      include 'common.f'
      include 'common_ptm.inc'

      logical
     &     ldefault             ! true if values are for defaults
      common /read_fix_l/ ldefault

c-----local variables

      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,istat               ! conversion status of this line (output)
	

      character line*(*)        ! line from file (input)
      character*15 field_names(mxflds) ! copy of hdr_form.fld(*)
      Type(GroupMember), pointer :: newmembers(:)

      integer
     &     i                    ! index
     &     ,alloc_stat
     &     ,groupno
     &     ,objtype
     &     ,npattern  

	integer, external :: name_to_objno,obj_type_code

      character
     &     cstring*80           ! string field
     &    ,groupname*32         ! name of group
     &    ,pattern*100          !pattern for matching the identifier of objects


 610  format(/a)
 620  format(/a
     &     /'Input string is: ',a)
 630  format(/a,i5)

      if (ldefault) then
         ngroup=0
      endif

      i=1
      do while (i .le. nfields)
         cstring=' '
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)

         if (rifld(i) .eq. group_name) then
	      groupname=' '
	      groupname=trim(cstring(1:32))
	      groupno=name_to_objno(obj_group,groupname)
	      if(groupno .eq. miss_val_i)then
	         ngroup=ngroup+1
	         groupno=ngroup
	         groupArray(groupno).name=groupname
	         if (groupno .gt. MAX_GROUPS) then
	            write(unit_error,*)"Maximum number of groups exceeded"
	            istat = -1
	            return
	         end if
	      end if
         else if (rifld(i) .eq. group_memtype) then
	      objtype=obj_type_code(cstring)
         else if (rifld(i) .eq. group_memid) then
	      pattern=' '
	      pattern=trim(cstring)
         endif
         i=i+1
      enddo
      npattern=groupArray(groupno).nMemberPatterns+1
      if (npattern .gt. MAX_MEMBER_PATTERNS)then
	   write(unit_error,*)"Maximum number of member patterns exceeded for group"
         istat=-2
         return
	endif
      groupArray(groupno).nMemberPatterns=npattern
	groupArray(groupno).MemberPatterns(npattern).object=objtype
	groupArray(groupno).MemberPatterns(npattern).pattern=trim(adjustl(pattern))

      return

c-----char-to-value conversion errors

 810  continue
      write(unit_error, 620) 'Conversion error on field ' //
     &     field_names(rifld(i)), cstring

      istat=-2

 900  continue                  ! fatal error

      return
      end



      subroutine input_rate_coeffs(field_names, mxflds, nfields, nflds,
     &     ifld, rifld, line, ibegf, ilenf, istat)

c-----process a character line into data arrays for
c-----channel coefficient info
      use IO_Units
      implicit none

      include 'common.f'
      include 'common_qual.inc'
      include 'common_irreg_geom.f'

c-----local variables

      integer
     &     mxflds               ! maximum number of fields
     &     ,nfields             ! number of fields in data line (input)
     &     ,nflds               ! number of fields in headers (input)
     &     ,ifld(mxflds)        ! ifld(i)=order header keyword i occurs in file (input)
     &     ,rifld(mxflds)       ! reverse ifld
     &     ,ibegf(mxflds)       ! beginning position of each field in line (input)
     &     ,ilenf(mxflds)       ! length of each field in line (input)
     &     ,istat               ! conversion status of this line (output)
     &     ,loccarr             ! function to return array location of string

      character line*(*)        ! line from file (input)
     &     ,field_names(mxflds)*15 ! copy of hdr_form.fld(*)
     &     ,get_substring*200   ! get substring function
     &     ,cnext*128           ! next channel name
     &     ,next_res*128        ! next reservoir name
     &     ,cchan*128           ! channel start and end numbers

      integer
     &     i                    ! index
     &     ,j                   ! index

c-----channel coefficients

      integer
     &     type                 ! coefficient type codes
     &     ,ncc                 ! non-conservative constituent index
     &     ,chan_start
     &     ,chan_end
     &     ,res_num             ! reservoir numbering order in rate coeff. input

      real*8
     &     value

      character
     &     cstring*80           ! string field

      character
     &     input_line*250       ! raw input line
      common /input_lines/ input_line

 610  format(/a)
 620  format(/a
     &     /'Input string is: ',a)
 630  format(/a,i5)

      if(num_res.lt.0) num_res=0

c-----type, constituent, and value fields required for each line;
c-----and either channel or reservoir field, or both

      if (ifld(coeff_type) .eq. 0) then
         write(unit_error, 610) 'No rate type given.'
         istat=-1
         goto 900
      else
         i=ifld(coeff_type)
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)
         if (cstring(1:3) .eq. 'dec') then ! decay
            type=decay
         else if (cstring(1:3) .eq. 'set') then ! settling
            type=settle
         else if (cstring(1:3) .eq. 'ben') then ! benthic
            type=benthic
         else if (index(cstring,'gro') .gt. 0) then ! algal growth
            type=alg_grow
         else if (index(cstring,'res') .gt. 0) then ! algal respiration
            type=alg_resp
         else
            write(unit_error,610)
     &           'Unknown rate coefficient type: ' // cstring
            istat=-1
            goto 900
         endif
      endif

      if (ifld(coeff_const) .eq. 0) then
         write(unit_error, 610) 'No rate constituent given.'
         istat=-1
         goto 900
      else
         i=ifld(coeff_const)
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)
         ncc=loccarr(cstring,nonconserve_list,max_constituent,EXACT_MATCH)
         if (ncc .le. 0) then
            write(unit_error,610)
     &           'Unknown constituent type: ' // cstring
            istat=-1
            goto 900
         endif
      endif

      if (ifld(coeff_value) .eq. 0) then
         write(unit_error, 610) 'No rate value given.'
         istat=-1
         goto 900
      else
         i=ifld(coeff_value)
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)
         read(cstring,'(f10.0)',err=810) value
      endif

c-----channel and/or reservoir input?

      if (ifld(coeff_chan) .ne. 0) then ! channel input
         i=ifld(coeff_chan)
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)
c--------parse for channel numbers of the form: 123-456,789
         cnext=get_substring(cstring,',')
c--------cnext will be either a group (123-456), or a single channel (789)
         do while (cnext .ne. ' ')
            cchan=get_substring(cnext,'-') ! starting channel of group
            read(cchan,'(i5)',err=810) chan_start
c-----------valid channel number?
            if (chan_start .lt. 1 .or. chan_start .gt. max_channels) then
               write(unit_error, 630)
     &              'Channel number in rate coeff. section out of bounds:',chan_start
               istat=-1
               goto 900
            endif
            cchan=get_substring(cnext,'-') ! ending channel of group
            if (cchan .ne. ' ') then ! true group, check validity
               read(cchan,'(i5)',err=810) chan_end
c--------------valid channel number?
               if (chan_end .lt. 1 .or. chan_end .gt. max_channels) then
                  write(unit_error, 630)
     &                 'Channel number in rate coeff. section out of bounds:',chan_end
                  istat=-1
                  goto 900
               endif
            else                ! wasn't a second channel number for group
               chan_end=chan_start
            endif

            if (chan_start .gt. chan_end) then
               write(unit_error,610)
     &              'Channel start number is greater than channel end number.'
               istat=-1
               goto 900
            endif

            do j = chan_start, chan_end
               rcoef_chan(ncc,type,j)=value
            enddo

            cnext=get_substring(cstring,',')
         enddo
      endif

      if (ifld(coeff_res) .ne. 0) then ! reservoir input
         i=ifld(coeff_res)
         cstring=line(ibegf(i):ibegf(i)+ilenf(i)-1)
c--------parse for comma-separated reservoir names
         next_res=get_substring(cstring,',')
         do while (next_res .ne. ' ')
            if (next_res .ne. 'none') then ! "none" - no reservoir
c--------------see if information for this reservoir has been given previously
               !res_num=name_to_objno(obj_reservoir,name)
               res_num=loccarr(next_res,
     &                         coeff_res_name,
     &                         max_reservoirs,
     &                         EXACT_MATCH)
               if (res_num .le. 0) then
c-----------------No match was found. i.e. this is a new reservoir.
                  num_res=num_res+1
                  res_num=num_res
               endif
               coeff_res_name(res_num)=next_res
               rcoef_res_temp(ncc,type,res_num)=value
            endif
            next_res=get_substring(cstring,',')
         enddo
      endif

      return

c-----char-to-value conversion errors

 810  continue
      write(unit_error, 620) 'Conversion error on field ' //
     &     field_names(rifld(i)), cstring

      istat=-2

 900  continue                  ! fatal error

      return
      end


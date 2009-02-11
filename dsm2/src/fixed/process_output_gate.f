      subroutine process_output_gate(name,
     &                               LocName,
     &                               SubLoc,
     &                               param,
     &                               interval,
     &                               perop,
     &                               filename)

      use Gates, only: gateArray,gateIndex,deviceIndex,WEIR,PIPE
      use Groups, only: GROUP_ALL
      use io_units
      use logging
      use iopath_data
      use grid_data
      use envvar
      implicit none

      character
     &     FileName*128
     &     ,Name*32
     &     ,Param*32
     &     ,Interval*32
     &     ,PerOp*8
     &     ,LocName*32
     &     ,SubLoc*32           ! Object-dependent sublocation (gate device, reservoir node connect..)
     &     ,ctmp*200

      integer*4
     &     ID                   ! transfer ID
     &     ,itmp
     &     ,gateNo,devNo     
     
      integer, external :: name_to_objno
      integer, external :: ext2int
      integer, external :: loccarr      
      integer, external :: get_objnumber
      
      logical device_required


!========================================================     
            noutpaths=noutpaths+1
            if (noutpaths .gt. max_outputpaths) then
               write(unit_error,630)
     &              'Too many pathoutput paths specified; max allowed is:'
     &              ,max_outputpaths
               call exit(-1)
            endif

            pathoutput(noutpaths).use=.true.
            pathoutput(noutpaths).name=Name
            pathoutput(noutpaths).obj_type=obj_gate

c-----------find object number given object ID

            pathoutput(noutpaths).obj_name=LocName
	      gateNo = name_to_objno(obj_gate, LocName)
            pathoutput(noutpaths).obj_no= gateNo
            if (gateNo .eq. miss_val_i)then
              write(unit_error,*)'Ignoring output TS: ' // name
	         write(unit_error,*)'Unknown gate: ',LocName
               noutpaths=noutpaths-1
               return
            end if
            devNo=deviceIndex(gateArray(gateNo),subLoc)   
            pathoutput(noutpaths).gate_device=devNo
	      device_required=.true.
            if (trim(Param) .eq. 'pos')then
			   write(unit_error, *) 
     &         "Warning: 'pos' output is deprecated. Substituting op_to_node in output: " // name
	          Param='op-to-node'
            else if (trim(Param) .eq. 'position')then
	         Param='position'
            else if (trim(Param) .eq. 'op-to-node' .or. 
     &	       trim(Param) .eq. 'op_to_node')then
	         Param='op-to-node'
	      else if (trim(Param) .eq. 'op-from-node' .or. 
     &	       trim(Param) .eq. 'op_from_node')then
	         Param='op-from-node'
	      else if (trim(Param) .eq. 'height')then
	         Param='height'
	      else if (Param(1:4) .eq. 'elev' )then
	         Param='elev'
	      else if (trim(Param) .eq. 'width' .or. trim(Param) .eq. 'radius')then
	         Param='width'	            
	      else if(trim(Param) .eq. 'install') then
	         Param='install'
	         device_required=.false.
	      else if (trim(Param) .eq. 'flow')then
	         if (devNo .eq. miss_val_i)then
		         Param='flow'
		       else 
                 Param='device-flow'
	         endif
	            device_required=.false.
            else
                  write(unit_error,*) 
     &              "Unrecognized gate output variable: " // Param
	            call exit(-3)

            end if
            if (devNo .eq. miss_val_i .and. 
     &          device_required .eq. .true. ) then
               write(unit_screen,*) 'Output TS: for requested output ' // name
               write(unit_screen,*) 'Unrecognized gate device: ' //
     &           trim(subLoc) // ' for gate: ' // trim(LocName)
	         write(unit_screen,*) 'Output not generated.'
                noutpaths=noutpaths-1
                return
            end if

            pathoutput(noutpaths).a_part=' '
            pathoutput(noutpaths).b_part=Name
            pathoutput(noutpaths).c_part=Param
            call split_epart(Interval,itmp,ctmp)
            if (itmp .ne. miss_val_i) then ! valid interval, parse it
               pathoutput(noutpaths).e_part=Interval
               pathoutput(noutpaths).no_intervals=itmp
               pathoutput(noutpaths).interval=ctmp
            else
               write(unit_error, "('Unknown output time interval: '//a)") Interval
               call exit(-1)
            endif
            pathoutput(noutpaths).f_part=' '
            pathoutput(noutpaths).filename=FileName
c-----------accumulate unique dss output filenames
            itmp=loccarr(pathoutput(noutpaths).filename,outfilenames,
     &           max_dssoutfiles, EXACT_MATCH)
            if (itmp .lt. 0) then
               if (abs(itmp) .le. max_dssoutfiles) then
                  outfilenames(abs(itmp))=pathoutput(noutpaths).filename
                  pathoutput(noutpaths).ndx_file=abs(itmp)
               else
                  write(unit_error,610)
     &                 'Maximum number of unique DSS output files exceeded'
                  call exit(-3)

               endif
            else
               pathoutput(noutpaths).ndx_file=itmp
            endif

            pathoutput(noutpaths).meas_type=Param
            if (Param(1:3) .eq. 'vel')pathoutput(noutpaths).meas_type='vel'            
            call assign_output_units(pathoutput(noutpaths).units,Param)
            if (PerOp(1:4) .eq. 'inst')
     &           pathoutput(noutpaths).per_type=per_type_inst_val
            if (PerOp(1:2) .eq. 'av')
     &           pathoutput(noutpaths).per_type=per_type_per_aver
            if (PerOp(1:3) .eq. 'min')
     &           pathoutput(noutpaths).per_type=per_type_per_min
            if (PerOp(1:3) .eq. 'max')
     &           pathoutput(noutpaths).per_type=per_type_per_max

c-----------pathoutput(noutpaths).source.obj_type = SourceTypeID     fixme: this is broken
c-----------if (SourceLocLen .gt. 0)
c-----------&           pathoutput(noutpaths).source.loc_name = SourceLoc

            if (print_level .ge. 3)
     &           write(unit_screen, '(i5,i10,a,1x,a,a30,1x,a8,1x,a80)') noutpaths, ID,
     &           trim(Name),trim(LocName),trim(Param),trim(Interval),
     &           trim(FileName)

 610  format(/a)
 630  format(/a,i5)     
      return
      end subroutine
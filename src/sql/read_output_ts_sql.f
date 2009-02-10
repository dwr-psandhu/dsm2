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

      subroutine load_reservoir_output_ts_sql(StmtHndl, ModelID, istat)

c-----load f90SQL modules
      use f90SQLConstants
      use f90SQL
	use Groups, only: GROUP_ALL
      use io_units
      use logging
      use iopath_data
      use grid_data
      use envvar

      implicit none

      
c-----arguments
      integer(SQLHANDLE_KIND):: StmtHndl
      integer ModelID           ! which ModelID to select
     &     ,istat               ! status

c-----f90SQL variables
      character(len=1000)::StmtStr
      integer(SQLRETURN_KIND)::iRet
      integer(SQLSMALLINT_KIND)::ColNumber ! SQL table column number
      integer(SQLINTEGER_KIND):: PerOpLen, IntvlLen, NameLen
     &                           ,LocNameLen, SubLocLen
     &                           ,SourceGroupLen, ParamLen, FileLen
      integer name_to_objno,ext2intnode

c-----local variables
      integer UseObj
      integer*4
     &     ID                   ! transfer ID
     &     ,ObjType
     &     ,itmp
     &     ,counter
     &     ,loccarr             ! locate string in char array function
     &     ,nenv                ! environment var replacement
     &     ,SubLoc


      character
     &     FileName*128
     &     ,Name*32
     &     ,prevName*32
     &     ,Param*32
     &     ,PrevParam*32
     &     ,Interval*32
     &     ,PerOp*8
     &     ,LocName*32
     &     ,ctmp*200
     &     ,SourceGroup*32
     &     ,PrevSourceGroup*32

      integer ext2int
      integer get_objnumber
      external ext2int, get_objnumber

c-----Bind the parameter representing ModelID	
      call f90SQLBindParameter (StmtHndl, int(1,SQLUSMALLINT_KIND), SQL_PARAM_INPUT,
     &     SQL_F_SLONG, SQL_INTEGER, int(4,SQLUINTEGER_KIND),  int(0,SQLSMALLINT_KIND),
     &     ModelID, f90SQL_NULL_PTR, iRet) 

      call f90SQLBindParameter (StmtHndl, int(2,SQLUSMALLINT_KIND), SQL_PARAM_INPUT,
     &     SQL_F_SLONG, SQL_INTEGER, int(4,SQLUINTEGER_KIND),  int(0,SQLSMALLINT_KIND),
     &     ModelID, f90SQL_NULL_PTR, iRet) 

c-----Execute SQL statement

      StmtStr="SELECT out_id, name, reservoir,connection_node, " //
     &     "used, variable_name, time_interval, " //
     &     "period_op, source_group, output_file " //
     &     "FROM (output_time_series_reservoir INNER JOIN model_component ON " //
     &     "output_time_series_reservoir.layer_id = model_component.component_id) "// 
     &     "WHERE model_id = ? " //
     &     "ORDER BY name, variable_name, time_interval, period_op, source_group, layer DESC;"

      call f90SQLExecDirect(StmtHndl, StmtStr,iRet)

      if (iRet.ne.SQL_SUCCESS) then
         write(unit_error, '(a,i5/)') 'Error in making reservoir output TS SQL request',iRet
         call ShowDiags(SQL_HANDLE_STMT, StmtHndl)
         istat=-3
         return
      else
         istat=0
         if (print_level .ge. 3)
     &        write(unit_screen, '(a)') 'Made Output TS SQL request'
      endif

c-----Bind variables to columns in result set
      ColNumber=1
      call f90SQLBindCol(StmtHndl, ColNumber, SQL_F_SLONG, ID,
     &     f90SQL_NULL_PTR, iRet)

      ColNumber=ColNumber+1
      call f90SQLBindCol(StmtHndl, ColNumber, SQL_F_CHAR, Name,
     &     loc(NameLen), iRet)

      ColNumber=ColNumber+1
      call f90SQLBindCol(StmtHndl, ColNumber, SQL_F_CHAR, LocName,
     &     loc(LocNameLen), iRet)

      ColNumber=ColNumber+1
      call f90SQLBindCol(StmtHndl, ColNumber, SQL_F_SLONG, SubLoc,
     &     loc(SubLocLen), iRet)

      ColNumber=ColNumber+1
      call f90SQLBindCol(StmtHndl, ColNumber, SQL_F_SLONG, UseObj,
     &     f90SQL_NULL_PTR, iRet)

      ColNumber=ColNumber+1
      call f90SQLBindCol(StmtHndl, ColNumber, SQL_F_CHAR, Param,
     &     loc(ParamLen), iRet)

      ColNumber=ColNumber+1
      call f90SQLBindCol(StmtHndl, ColNumber, SQL_F_CHAR, Interval,
     &     loc(IntvlLen), iRet)

      ColNumber=ColNumber+1
      call f90SQLBindCol(StmtHndl, ColNumber, SQL_F_CHAR, PerOp,
     &     loc(PerOpLen), iRet)

      ColNumber=ColNumber+1
      call f90SQLBindCol(StmtHndl, ColNumber, SQL_F_CHAR, SourceGroup,
     &     loc(SourceGroupLen), iRet)

      ColNumber=ColNumber+1
      call f90SQLBindCol(StmtHndl, ColNumber, SQL_F_CHAR, FileName,
     &     loc(FileLen), iRet)

      
      ObjType = obj_reservoir
      if (print_level .ge. 3) 
     &  write(unit_screen, '(a)') 'Made reservoir output TS bind request'

c-----Loop to fetch records, one at a time
      counter=1

      PrevSourceGroup=miss_val_c
      PrevName=miss_val_c
      PrevParam=miss_val_c

      do while (.true.)

c--------Fetch a record from the result set

         call f90SQLFetch(StmtHndl,iRet)
         if (iRet .eq. SQL_NO_DATA) exit
         if (iRet .ne. SQL_SUCCESS) then
            write(unit_error, 625) counter
 625        format(/'Invalid or Null data for output TS record ',i3)
            call ShowDiags(SQL_HANDLE_STMT, StmtHndl)
            istat=-1
            return
         endif

c--------clean up char variables, replace environment variables
         Name=Name(1:namelen)
         nenv=replace_envvars(Name,ctmp)
         Name=ctmp
         call locase(Name)

         Param=Param(1:ParamLen)
         nenv=replace_envvars(Param,ctmp)
         Param=ctmp
         call locase(Param)
         Interval=Interval(1:IntvlLen)
         nenv=replace_envvars(Interval,ctmp)
         Interval=ctmp
         call locase(Interval)
         PerOp=PerOp(1:PerOpLen)
         nenv=replace_envvars(PerOp,ctmp)
         PerOp=ctmp
         call locase(PerOp)

         SourceGroup=SourceGroup(1:SourceGroupLen)
	   call locase(SourceGroup)

         FileName=FileName(1:FileLen) ! preserve case for filename
         nenv=replace_envvars(FileName,ctmp)
         if (len_trim(ctmp) .eq. 0) then
            write(unit_error, '(a)')'File name evaluated to blank string: ',FileName
            istat=-3
            return
         end if

         FileName=ctmp
         !call locase(FileName)
         LocName=LocName(1:LocNameLen)
         nenv=replace_envvars(LocName,ctmp)
         LocName=ctmp
         call locase(LocName)
         if (SubLocLen .le. 0)then
            SubLoc=miss_val_i
         end if

c--------use only the last version of a path, and skip
c--------if the path is marked as not-use
         if ( .not.(
     &        Name .eq. PrevName 
     &        .and. Param .eq. PrevParam
     &        .and. PrevSourceGroup .eq. SourceGroup
     &        ) .and.
     &        UseObj) then
            noutpaths=noutpaths+1
            if (noutpaths .gt. max_outputpaths) then
               write(unit_error,630)
     &              'Too many pathoutput paths specified; max allowed is:'
     &              ,max_outputpaths
               istat=-1
               return
            endif

            pathoutput(noutpaths).use=.true.
            pathoutput(noutpaths).name=Name
            pathoutput(noutpaths).obj_type=ObjType
            if (SourceGroupLen .eq. SQL_NULL_DATA .or.
     &          SourceGroupLen .eq. 0) then
               pathoutput(noutpaths).source_group_ndx=GROUP_ALL
            else
               pathoutput(noutpaths).source_group_ndx=name_to_objno(obj_group,SourceGroup)
               if (pathoutput(noutpaths).source_group_ndx .eq. miss_val_i)then
                   write(unit_error,*)"Source group ",SourceGroup,
     &              " not recognized for output request: ", pathoutput(noutpaths).name
                   call exit(2)
               end if
            endif
c-----------find object number given object ID
         ! fixme: same decision, especially since this doesn't really exist
            pathoutput(noutpaths).obj_name=LocName
            pathoutput(noutpaths).obj_no=  name_to_objno(ObjType, locName)
            if(pathoutput(noutpaths).obj_no .eq. miss_val_i)then
               write(unit_error,*)'Ignoring output TS: ', trim(name), 
     &              ' request for unrecognized reservoir ', locName
	         noutpaths=noutpaths-1
	         goto 400
               return
            end if
            pathoutput(noutpaths).res_node_no = miss_val_i
            if (subloclen .gt. 0)then
               pathoutput(noutpaths).res_node_no = ext2intnode(SubLoc)
               if (pathoutput(noutpaths).res_node_no .eq. miss_val_i)then
                  write(unit_error,*)'Output TS: ',trim(name),
     &                ' requested non-existent reservoir connection'
                  write(unit_error, *)'Reservoir: ', pathoutput(noutpaths).obj_name,
     &                'Node: ',SubLoc
                  istat=-3
                  return
               end if               
            else
               pathoutput(noutpaths).res_node_no = miss_val_i
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
               istat=-1
               return
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
                  istat=-3
                  return
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

            if (print_level .ge. 3)
     &           write(unit_screen, '(i5,i10,a,1x,a,a30,1x,a8,1x,a80)') noutpaths, ID,
     &           trim(Name),trim(LocName),trim(Param),trim(Interval),
     &           trim(FileName)

         endif
 400     continue
         counter=counter+1
         prevName=Name
         PrevSourceGroup=SourceGroup
         PrevParam=Param
      enddo

      if (print_level .ge. 2)
     &     write(unit_screen, '(a,i5/)') 'Read in all Output TS data',noutpaths

      call f90SQLFreeStmt(StmtHndl,SQL_UNBIND, iRet)
      call f90SQLCloseCursor (StmtHndl, iRet)
      if (iRet.ne.SQL_SUCCESS) then
         write(unit_error, '(a,i5//)') 'Error in unbinding Output TS SQL',iRet
         call ShowDiags(SQL_HANDLE_STMT, StmtHndl)
         istat=-3
         return
      else
         if (print_level .ge. 3) write(unit_screen, '(a//)') 'Unbound Output TS SQL'
      endif

 610  format(/a)
 630  format(/a,i5)

      istat=noutpaths
      return
      end


      subroutine assign_output_units(units, param)
      implicit none
      character*(*) units, param
      if (index(Param, 'flow') .gt. 0 .or.
     &    index(Param, 'pump') .gt. 0) then
          units='cfs'
      else if (Param(1:3) .eq. 'vel' ) then
          units='ft/s'
      else if (Param .eq. 'stage') then
          units='feet'
      else if (Param .eq. 'elev') then
          units='feet'
      else if (Param .eq. 'height') then
          units='feet'
      else if (Param .eq. 'height') then
          units='position'               
      else if (Param .eq. 'width') then
          units='feet'                                             
      else if (Param .eq. 'tds') then
          units='ppm'
      else if (index(Param, 'weir-pos') .gt. 0) then
          units=' '
      else if (index(Param, 'pipe-pos') .gt. 0) then
          units=' '
      else if (Param .eq. 'ec') then
          units='umhos/cm'
      else if (Param .eq. 'do') then
          units='mg/l'
      else if (Param .eq. 'nh3-n') then
          units='mg/l'
      else if (Param .eq. 'org-n') then
          units='mg/l'
      else if (Param .eq. 'no2-n') then
          units='mg/l'
      else if (Param .eq. 'no3-n') then
          units='mg/l'
      else if (Param .eq. 'bod') then
          units='mg/l'
      else if (Param .eq. 'org-p') then
          units='mg/l'
      else if (Param .eq. 'po4-p') then
          units='mg/l'
      else if (Param .eq. 'algae') then
          units='mg/l'
      else if (Param .eq. 'temp') then
          units='deg c'
      else   
          units=' '
      endif      
      end subroutine



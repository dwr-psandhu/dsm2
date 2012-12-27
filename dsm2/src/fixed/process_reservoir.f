C!<license>
C!    Copyright (C) 1996, 1997, 1998, 2001, 2007, 2009 State of California,
C!    Department of Water Resources.
C!    This file is part of DSM2.

C!    The Delta Simulation Model 2 (DSM2) is free software: 
C!    you can redistribute it and/or modify
C!    it under the terms of the GNU General Public License as published by
C!    the Free Software Foundation, either version 3 of the License, or
C!    (at your option) any later version.

C!    DSM2 is distributed in the hope that it will be useful,
C!    but WITHOUT ANY WARRANTY; without even the implied warranty of
C!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C!    GNU General Public License for more details.

C!    You should have received a copy of the GNU General Public License
C!    along with DSM2.  If not, see <http://www.gnu.org/licenses>.
C!</license>

      subroutine process_reservoir(id,reser_name,reser_area,reser_botelv)
      use grid_data
      use logging
      use io_units
      implicit none
      integer id   
      real*8               !todo: this should be real*8
     &     reser_area
     &     ,reser_botelv

      character
     &     reser_name*32 
      
      nreser=nreser+1
      if (nreser .gt. max_reservoirs) then
          write(unit_error,630)
     &         'Reservoir number too high; max allowed is:',
     &         max_reservoirs
          call exit(-1)
          return
      endif
      call locase(reser_name)
      res_geom(nreser).id=ID
      res_geom(nreser).inUse=.true.
      res_geom(nreser).name=trim(reser_name)
      res_geom(nreser).area=reser_area
      res_geom(nreser).botelv=reser_botelv
      if (print_level .ge. 3)
     &    write(unit_screen,'(i5,1x,a)')
     &         nreser,trim(res_geom(nreser).name)   
 630   format(/a,i5)
      return
      end subroutine
      
      subroutine alloc_reservoir_connections(alloc)
      use grid_data
      use common_tide
      implicit none
      logical :: alloc
      integer i,j,iconnect
      iconnect = 0
      do i=1,nreser
         do j=1,res_geom(i).nnodes
            iconnect = iconnect + 1
         end do
      end do
      nres_connect = iconnect
      if (alloc .and. .not. allocated(qresv))then
         allocate(qresv(nres_connect))
         qresv = 0.
      end if
      if (.not. alloc)then
         deallocate(qresv)
      end if
      return
      end subroutine
      
      subroutine process_reservoir_connection(resname,
     &                                        con_node,
     &                                        rescon_incoef,
     &                                        rescon_outcoef)
      use constants
      use grid_data
      use logging
      use io_units
      use network
      implicit none
            
      
      character*32 resname
      integer :: con_node
      integer :: resno
      integer :: nn
      integer, external :: ext2intnode, name_to_objno
      real*8 rescon_incoef      !todo: change to real*8
      real*8 rescon_outcoef
      call locase(resname)
      resno = name_to_objno(obj_reservoir,resname)
      res_geom(resno).nnodes=res_geom(resno).nnodes+1
	if (res_geom(resno).nnodes .gt. MaxResConnectChannel) then
          write(unit_error,*) 'Number of reservoir connections for ',
     &      res_geom(resno).name, ' exceeds maximum of ',
     &      MaxResConnectChannel
            call exit(-1)
          return
       endif	                   
       nn=res_geom(resno).nnodes
       res_geom(resno).nConnect=res_geom(resno).nnodes   ! may add gated nodes later
       res_geom(resno).isNodeGated(nn)=.false.
         ! todo fixme check that only gated or reservoir connection, not both
       res_geom(resno).node_no(nn)=ext2intnode(con_node)
       res_geom(resno).coeff2res(nn)=rescon_incoef
       res_geom(resno).coeff2chan(nn)=rescon_outcoef
       nres_connect = nres_connect + 1     
       return
       end subroutine
      
      
      
      
      
      
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

c----- 
      subroutine updateWBHydroInfo
      use common_tide
      use type_defs
      use ptm_local
      use grid_data      
      implicit none


c----- functions
      integer get_unique_id_for_channel
     &     , get_unique_id_for_reservoir
     &     , get_unique_id_for_stage_boundary
     &     , get_unique_id_for_boundary
     &     , get_unique_id_for_conveyor
      
      integer get_maximum_number_of_channels
     &     , get_maximum_number_of_reservoirs
     &     , get_maximum_number_of_stage_boundaries
     &     , get_maximum_number_of_boundary_waterbodies
     &     , get_maximum_number_of_conveyors
      real get_flow_balance_at_node,fb
	real*8 :: FLOW_BALANCE_TOL = 2.
c----- locals
      integer i,j,k,id, dsmNumber, qId
	integer ext2int
c----- begin
c----- update channel info
      do i=1, get_maximum_number_of_channels() 
	   !todo: loop should be number of channels
         id = get_unique_id_for_channel(i)
c-------- flow into node +ve and flow out of node -ve
c-------- channel flow +ve from up node to down node
         wb(id).flowToNode(1) = -Qchan(1,i) !upnode flow
         wb(id).flowToNode(2) = Qchan(2,i) !downnode flow
      enddo
c----- update reservoir info
      do i=1, get_maximum_number_of_reservoirs()
	!todo: should be number of reservoirs
         id = get_unique_id_for_reservoir(i)
         do k=1, res_geom(i).nnodes
c----------- flow outof reservoir is +ve, thus towards node thus +ve
      !todo: eli changed from qresv
            wb(id).flowToNode(k) = Qres(i, k)
         enddo
c-------- update internal flows ( assumption of order important: fixedData.f)
         j=1
         k = res_geom(i).nnodes
         do while(res_geom(i).qinternal(j) .ne. 0)
            k=k+1
            qId = res_geom(i).qinternal(j)
            wb(id).flowToNode(k) = 
     &           -obj2obj(qId).flow_avg
            j = j + 1
         enddo
c-------- update external flows ( assumption of order important: fixedData.f)
         j=1
         do while(res_geom(i).qext(j) .ne. 0)
            k=k+1
            qId = res_geom(i).qext(j)
            wb(id).flowToNode(k) = 
     &           -qext(qId).avg
            j = j + 1
         enddo
      enddo
c----- update boundary info
      do i=1, get_maximum_number_of_boundary_waterbodies()
         id = get_unique_id_for_boundary(i)
         wb(id).flowToNode(1) = qext(i).avg
      enddo
c----- update conveyor info
      do i=1, get_maximum_number_of_conveyors()
         id = get_unique_id_for_conveyor(i)
c-------- from - to node +Ve direction
         wb(id).flowToNode(1) = -obj2obj(i).flow_avg !from flow
         wb(id).flowToNode(2) = obj2obj(i).flow_avg !to flow
      enddo
c----- update stage boundary info ( do this last )
      do i=1, get_maximum_number_of_stage_boundaries()
         id = get_unique_id_for_stage_boundary(i)
         k = wb(id).node(1)
         if ( k .gt. 0 ) then
            wb(id).flowToNode(1) = 
     &           wb(id).flowToNode(1) - get_flow_balance_at_node(k)
         endif
      enddo
c----- end
c----- check node balance
      do i=1,maxNodesPTM
         if (nodes(i).nwbs .gt. 0 ) then
            fb = get_flow_balance_at_node(i)
            if( fb .gt. FLOW_BALANCE_TOL .or. fb .lt. -FLOW_BALANCE_TOL) 
     &           write(*,*) 'Node # ', i, 
     &              ' Flow Balance: ', get_flow_balance_at_node(i)
            endif
      enddo
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_flow_balance_at_node(nodeId)
      use ptm_local
     
      implicit none
      integer nodeId, j
      real get_flow_for_wb_node, get_flow_balance_at_node, cumFlow
      integer wbId
      cumFlow = 0.0
      do j=1,nodes(nodeId).nwbs
         wbId = nodes(nodeId).wbs(j)
         cumFlow = cumFlow + 
     &        get_flow_for_wb_node(wbId, nodeId)
      enddo
      get_flow_balance_at_node = cumFlow
      return 
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_flow_for_wb_node(wbId, nodeId)
      use ptm_local
      implicit none

      real get_flow_for_wb_node
      integer i, wbId, nodeId
      i=1
      do while( i .le. wb(wbId).numberOfNodes .and. 
     &     wb(wbId).node(i) .ne. nodeId)
         i=i+1
      enddo
      if ( wb(wbId).node(i) .ne. nodeId) then
         get_flow_for_wb_node = 0
      else
         get_flow_for_wb_node = wb(wbId).flowToNode(i)
      endif
      return 
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine set_tide_file_time(modelTime)
      implicit none
      integer modelTime
      call set_tidefile_time(modelTime)
c      call read_quality_bin()
      return 
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_ext_from_int(internal)
      use grid_data
      implicit none
      integer get_ext_from_int
      integer internal
      get_ext_from_int= int2ext(internal)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_up_node_depth(number)
      use ptm_local
      use common_tide
      implicit none
      real get_up_node_depth
      integer number
      get_up_node_depth= Hchan(1,number)*theta + HchanPrev(1,number)*(1-theta)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_down_node_depth( number)
      use ptm_local
      use common_tide
      implicit none

      real get_down_node_depth
      integer number
      get_down_node_depth= Hchan(2,number)*theta + HchanPrev(2,number)*(1-theta)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_up_node_stage(number)
      use common_tide
      use ptm_local
      implicit none

      real get_up_node_stage
      integer number
      get_up_node_stage= (Hchan(1,number)+chan_geom(number).bottomelev(1))*theta
     &	+  (HchanPrev(1,number)+chan_geom(number).bottomelev(1))*(1.-theta)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_down_node_stage( number)
      use common_tide
      use ptm_local
      implicit none
      real get_down_node_stage
      integer number
      get_down_node_stage= (Hchan(2,number)+chan_geom(number).bottomelev(2))*theta
     &     + (HchanPrev(2,number)+chan_geom(number).bottomelev(2))*(1.-theta)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_up_node_flow( number)
      use common_tide
      use ptm_local
      implicit none
      real get_up_node_flow
      integer number
      get_up_node_flow= Qchan(1,number)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_down_node_flow( number)
      use common_tide
      use ptm_local      
      implicit none
      real get_down_node_flow
      integer number
      get_down_node_flow= Qchan(2,number)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_up_node_area( number)
      use common_tide
      use grid_data
      implicit none
      include '../../hydrolib/network.inc'
      include "../../hydrolib/netcntrl.inc"
      real get_up_node_area
      integer number
      get_up_node_area= Achan(1,number)*theta 
     &                + AchanPrev(1,number)*(1.-theta)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_down_node_area( number)
      use grid_data   
      use common_tide
      implicit none
      include '../../hydrolib/network.inc'
      include "../../hydrolib/netcntrl.inc"
      real get_down_node_area
      integer number
      get_down_node_area= Achan(2,number)*theta 
     &                  + AchanPrev(2,number)*(1.-theta)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_reservoir_volume( number)
      use ptm_local
      implicit none
      real get_reservoir_volume
      integer number
      get_reservoir_volume= reservoirVolume(number)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_node_number_for_connection( reservoirNumber, 
     &     connection)
      use ptm_local
      implicit none
      integer get_node_number_for_connection
     &     , get_unique_id_for_reservoir
      integer reservoirNumber, connection, uniqId
      uniqId = get_unique_id_for_reservoir(reservoirNumber)
      get_node_number_for_connection= wb(uniqId).node(connection)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_resevoir_depth( number)
      use common_tide
      implicit none

      real get_resevoir_depth
      integer number
      get_resevoir_depth= Eresv(number)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_reservoir_flow_for_connection(
     &     reservoirNumber, connection)
      use ptm_local
      implicit none

      real get_reservoir_flow_for_connection
      integer reservoirNumber, connection
      integer get_unique_id_for_reservoir, id
      id = get_unique_id_for_reservoir(reservoirNumber)
      get_reservoir_flow_for_connection= 
     &     wb(id).flowToNode(connection)

      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_diversion_flow( number )
      use ptm_local
      use grid_data
      implicit none
      real get_diversion_flow
      integer number
      if ( number .le. nqext ) then
         get_diversion_flow = qext(number).avg
      else
         get_diversion_flow = 0
      endif
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_diversion_massfrac( number )
      use grid_data
      implicit none
      real get_diversion_massfrac
      integer number
      if ( number .le. nqext ) then
         get_diversion_massfrac = qext(number).avg
      else
         get_diversion_massfrac = 0
      endif
      return 
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_diversion_at_node( number)
      implicit none
      ! todo
      real get_diversion_at_node
      integer number
      get_diversion_at_node=0
c-----get_diversion_at_node= qNodeDiversion(number)
      return
      end

c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_reservoir_pumping( number)
      
      implicit none
      ! todo
      real get_reservoir_pumping
      integer number
      get_reservoir_pumping=0
c-----get_reservoir_pumping= qReservoirPumping(number)
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_boundary_flow( number)
      use ptm_local
      implicit none
      real get_boundary_flow
      integer number,id, get_unique_id_for_boundary
c-----get_reservoir_pumping= qReservoirPumping(number)
      id = get_unique_id_for_boundary(number)
      get_boundary_flow = wb(id).flowToNode(1)
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_stage_boundary_flow( number)
      use ptm_local
      implicit none
      real get_stage_boundary_flow
      integer number,id, get_unique_id_for_stage_boundary
c-----
      id = get_unique_id_for_stage_boundary(number)
      get_stage_boundary_flow = wb(id).flowToNode(1)
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_conveyor_flow( number)
      use ptm_local
      implicit none
      real get_conveyor_flow
      integer number,id, get_unique_id_for_conveyor
c-----get_reservoir_pumping= qReservoirPumping(number)
      id = get_unique_id_for_conveyor(number)
      get_conveyor_flow = wb(id).flowToNode(1)
      return
      end


c-----++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_up_node_quality(number, constituent)
      use ptm_local
      use common_qual_bin
      implicit none

      real get_up_node_quality
      integer number,nodeid,constituent
      nodeid = wb(number).node(1) ! upnode
      get_up_node_quality = Qnode(qual2node(nodeid),constituent)
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_down_node_quality(number, constituent)
      use ptm_local
      use common_qual_bin
      implicit none

      real get_down_node_quality
      integer number,nodeid,constituent
      nodeid = wb(number).node(2) ! downnode
      get_down_node_quality = Qnode(qual2node(nodeid),constituent)
      end

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
      subroutine init_fixed_data(filename)
      use constants
      use runtime_data
      use grid_data
      use ptm_local
      implicit none

      character*(*) filename
      integer i
      include 'version.inc'

      call read_ptm(filename)

c-----temp
      nnodes=0
      do i=1,max_nodes
         if (node_geom(i).nup + node_geom(i).ndown .gt. 0)
     &        nnodes=nnodes+1
      enddo
c----- fill up stage boundary information
      
	
	nStageBoundaries = nstgbnd
	
      do i=1,nstgbnd
	   node_geom(stgbnd(i).node).boundary_type = stage_boundary
	   stageBoundary(i).attach_obj_type= obj_node
	   stageBoundary(i).attach_obj_no = stgbnd(i).node
      enddo

c-----endtemp
c----- update node and waterbody fixed information
      call updateNodeInfo()
      call updateWBInfo()
c----- update flux and group output requests info

      call updateFluxInfo()
	call updateGroupOutputInfo()
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_unique_id_for_channel(localIndex)
      implicit none
      integer localIndex, get_unique_id_for_channel
      get_unique_id_for_channel = localIndex
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_unique_id_for_reservoir(localIndex)
      implicit none
      integer localIndex, get_unique_id_for_reservoir
      integer get_maximum_number_of_channels
      get_unique_id_for_reservoir  = localIndex 
     &     + get_maximum_number_of_channels()
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_unique_id_for_stage_boundary(localIndex)
      implicit none
      integer localIndex, get_unique_id_for_stage_boundary
      integer get_maximum_number_of_channels
     &     , get_maximum_number_of_reservoirs
       get_unique_id_for_stage_boundary = localIndex 
     &     + get_maximum_number_of_channels()
     &     + get_maximum_number_of_reservoirs()
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_unique_id_for_boundary(localIndex)
      implicit none
      integer localIndex, get_unique_id_for_boundary
      integer get_maximum_number_of_channels
     &     , get_maximum_number_of_reservoirs
     &     , get_maximum_number_of_stage_boundaries
      get_unique_id_for_boundary  = localIndex 
     &     + get_maximum_number_of_channels()
     &     + get_maximum_number_of_reservoirs()
     &     + get_maximum_number_of_stage_boundaries()
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_unique_id_for_conveyor(localIndex)
      implicit none
      integer localIndex, get_unique_id_for_conveyor
      integer get_maximum_number_of_channels
     &     , get_maximum_number_of_reservoirs
     &     , get_maximum_number_of_stage_boundaries
     &     , get_maximum_number_of_boundary_waterbodies
      get_unique_id_for_conveyor  = localIndex 
     &     + get_maximum_number_of_channels()
     &     + get_maximum_number_of_reservoirs()
     &     + get_maximum_number_of_stage_boundaries()
     &     + get_maximum_number_of_boundary_waterbodies()
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine updateFluxInfo
      use common_tide
      use ptm_local
      use iopath_data
      use common_ptm      
      implicit none
      integer getWaterbodyUniqueId, getStageWaterbodyForNode
      integer i
c-----
      nFlux = 0
      do i=1, noutpaths
         if (index(pathoutput(i).meas_type,'ptm_flux') .eq. 1) then
	      nFlux=nFlux+1
	      flux(nFlux).inType = pathoutput(i).flux_from_type
            flux(nFlux).outType = pathoutput(i).flux_to_type
		  flux(nFlux).inIndex =  pathoutput(i).flux_from_ndx
            flux(nFlux).outIndex = pathoutput(i).flux_to_ndx
            pathoutput(i).flux_group_ndx=nFlux
         endif
      enddo
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine updateGroupOutputInfo
      use common_tide
      use iopath_data
      use ptm_local
      use common_ptm
      implicit none


      integer getWaterbodyUniqueId, getStageWaterbodyForNode
      integer i

c-----
      ngroup_output = 0
      do i=1, noutpaths
         if (index(pathoutput(i).meas_type,'ptm_group') .eq. 1) then
	      ngroup_output=ngroup_output+1
	      groupOut(ngroup_output).groupNdx = pathoutput(i).obj_no
            pathoutput(ngroup_output).flux_group_ndx=ngroup_output
         endif
      enddo
      return
      end

c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine updateWBInfo
	use IO_Units
      use grid_data
      use constants
      use ptm_local
      use common_ptm
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
      integer get_internal_node_id_for_unique_ids
c----- locals
      integer i,j,id, numNodes, objId

c----- begin
c----- update channel info
      do i=1, get_maximum_number_of_channels()
         id = get_unique_id_for_channel(i)
         wb(id).type = obj_channel
         wb(id).localIndex = i
         wb(id).globalIndex = id
         wb(id).numberOfNodes = 2
         wb(id).group = 0
         wb(id).node(1) = chan_geom(i).upnode
         wb(id).node(2) = chan_geom(i).downnode
      enddo
c----- update reservoir info
      do i=1, get_maximum_number_of_reservoirs()
         id = get_unique_id_for_reservoir(i)
         wb(id).type = obj_reservoir
         wb(id).localIndex = i
         wb(id).globalIndex = id
         wb(id).numberOfNodes = res_geom(i).nnodes
         wb(id).group = 0
         do j=1, res_geom(i).nnodes
	      
            wb(id).node(j) = res_geom(i).node_no(j)
         enddo
         j=1
         do while(res_geom(i).qinternal(j) .ne. 0)
            wb(id).numberOfNodes = wb(id).numberOfNodes + 1
            numNodes = wb(id).numberOfNodes
            objId = res_geom(i).qinternal(j)
            objId = get_unique_id_for_conveyor( objId )
            wb(id).node(numNodes) = 
     &           get_internal_node_id_for_unique_ids( id, objId )
            j = j + 1
         enddo
         j=1
         do while(res_geom(i).qext(j) .ne. 0)
            wb(id).numberOfNodes = wb(id).numberOfNodes + 1
            numNodes = wb(id).numberOfNodes
            objId = res_geom(i).qext(j)
            objId = get_unique_id_for_boundary( objId )
            wb(id).node(numNodes) = 
     &           get_internal_node_id_for_unique_ids( id, objId )
            j = j + 1
         enddo
      enddo
c----- update stage boundary info 
      do i=1, get_maximum_number_of_stage_boundaries()
         id = get_unique_id_for_stage_boundary(i)
         wb(id).type = obj_qext
         wb(id).localIndex = i
         wb(id).globalIndex = id
         wb(id).numberOfNodes = 1
         wb(id).group = 0
         wb(id).node(1) = stageBoundary(i).attach_obj_no
      enddo



c----- update boundary info
      do i=1, get_maximum_number_of_boundary_waterbodies()
         id = get_unique_id_for_boundary(i)
         wb(id).type = obj_qext
	!todo: eli to compile
c         wb(id).acctType = qext(i).group_ndx
!         wb(id).acctType = qext(i).acct_ndx
         wb(id).localIndex = i
         wb(id).globalIndex = id
         wb(id).numberOfNodes = 1
         wb(id).group = 0
         if ( qext(i).attach_obj_type .eq. obj_node ) then
            wb(id).node(1) = qext(i).attach_obj_no
         else if ( qext(i).attach_obj_type .eq. obj_reservoir ) then
            objId = qext(i).attach_obj_no
            objId = get_unique_id_for_reservoir( objId )
            wb(id).node(1) = get_internal_node_id_for_unique_ids( 
     &           objId
     &           , id )
         else
c-----------write(*,*) ' External types connection to type: ' ,
c-----------&           qext(i).obj_type, ' not handled '
         endif
      enddo
c----- update conveyor info
      do i=1, get_maximum_number_of_conveyors()
         id = get_unique_id_for_conveyor(i)
         wb(id).type = obj_obj2obj
	! todo: eli to compile
c       !  wb(id).acctType = obj2obj(i).from.acct_ndx
c         wb(id).acctType = obj2obj(i).from.group_ndx
         wb(id).localIndex = i
         wb(id).globalIndex = id
         wb(id).numberOfNodes = 2
         wb(id).group = 0
         if ( obj2obj(i).from_obj.obj_type .eq. obj_node ) then
            wb(id).node(1) = obj2obj(i).from_obj.obj_no
         else if ( obj2obj(i).from_obj.obj_type .eq. obj_reservoir ) then
            objId = obj2obj(i).from_obj.obj_no
            objId = get_unique_id_for_reservoir(objId)
            wb(id).node(1) = get_internal_node_id_for_unique_ids( 
     &           objId
     &           , id )
         else
c-----------write(*,*) ' Internal types connection from type: ' ,
c-----------&           obj2obj(i).from.obj_type, ' not handled '
         endif
         if ( obj2obj(i).to_obj.obj_type .eq. obj_node ) then
            wb(id).node(2) = obj2obj(i).to_obj.obj_no
         else if ( obj2obj(i).to_obj.obj_type .eq. obj_reservoir ) then
            objId = obj2obj(i).to_obj.obj_no
            objId = get_unique_id_for_reservoir(objId)
            wb(id).node(2) = get_internal_node_id_for_unique_ids( 
     &           objId
     &           , id )
         else
c-----------write(*,*) ' Internal types connection to type: ' ,
c-----------&           obj2obj(i).to.obj_type, ' not handled '
         endif
      enddo

c----- end
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine updateNodeInfo
      use grid_data   
      use constants   
      use ptm_local
      implicit none

      integer i, j, k, nodeId, nUp, nDown, conveyorId, nnId, objId, qId
      integer get_unique_id_for_reservoir,
     &     get_unique_id_for_boundary, get_unique_id_for_conveyor,
     &     get_unique_id_for_stage_boundary
      integer get_maximum_number_of_reservoirs
c----- get node geom info
      nodeId = 0
      do i=1, max_nodes
         nodeId=nodeId+1
c-------- channel info at node
         if ( node_geom(i).nup + node_geom(i).ndown .gt. 0) then
            nodes(nodeId).id = nodeId
            nUp = node_geom(i).nup
            nDown = node_geom(i).ndown
            nodes(nodeId).nwbs = nUp + nDown
            do j=1,nUp
               nodes(nodeId).wbs(j) = node_geom(i).upstream(j)
            enddo
            do j=nUp+1, nUp + nDown
               nodes(nodeId).wbs(j) = node_geom(i).downstream(j-nUp)
            enddo
         endif
c-------- add external flows at node
         j=1
         do while(node_geom(i).qext(j) .gt. 0 .and. j .le. max_qobj )
            nodes(i).nwbs = nodes(i).nwbs+1
            qId = node_geom(i).qext(j)
            nodes(i).wbs(nodes(i).nwbs) = 
     &           get_unique_id_for_boundary(qId)
            j = j + 1
         enddo
c-------- add internal flows at node
         j=1
         do while(node_geom(i).qinternal(j) .gt. 0 .and. j .le. max_qobj )
            nodes(i).nwbs = nodes(i).nwbs+1
            qId = node_geom(i).qinternal(j)
            nodes(i).wbs(nodes(i).nwbs) = 
     &           get_unique_id_for_conveyor(qId)
            j = j + 1
         enddo
      enddo                     !end loop for node_geom structure
c----- add reservoirs
      do j=1, get_maximum_number_of_reservoirs()
         do k=1, res_geom(j).nnodes
            nnId = res_geom(j).node_no(k)
            nodes(nnId).nwbs = nodes(nnId).nwbs+1
            nodes(nnId).wbs(nodes(nnId).nwbs) = 
     &           get_unique_id_for_reservoir(j)
         enddo
      enddo
c-------- add stage boundaries
      do j=1, nStageBoundaries
         nnId = stageBoundary(j).attach_obj_no
         nodes(nnId).nwbs = nodes(nnId).nwbs + 1
         nodes(nnId).wbs(nodes(nnId).nwbs) = 
     &        get_unique_id_for_stage_boundary(j)
      enddo
c-----create internal nodes info. These are connections between
c-----waterbodies not explicitly connected through nodes. 
c-----check external flows connected to a waterbody (ie. not a node)
      do i=1, nqext
         if ( qext(i).attach_obj_type .eq. obj_channel ) then
            nodeId = nodeId + 1
            nodes(nodeId).id = nodeId
            nodes(nodeId).nwbs = 2
            nodes(nodeId).wbs(1) = qext(i).attach_obj_no
            nodes(nodeId).wbs(2) = get_unique_id_for_boundary(i)
         elseif( qext(i).attach_obj_type .eq. obj_reservoir ) then
            nodeId = nodeId + 1
            nodes(nodeId).id = nodeId
            nodes(nodeId).nwbs = 2
            objId = qext(i).attach_obj_no
            nodes(nodeId).wbs(1) = 
     &           get_unique_id_for_reservoir(objId)
            nodes(nodeId).wbs(2) = get_unique_id_for_boundary(i)
c----------- add nodes to reservoir if not present
c-----------add_node_to_reservoir(nodeId)
         else if( qext(i).attach_obj_type .eq. obj_node ) then
!             nnId = qext(i).obj_no 
!             nodes(nnId).nwbs = nodes(nnId).nwbs + 1
!             nodes(nnId).wbs(nodes(nnId).nwbs) = 
!      &           get_unique_id_for_boundary(i)
         else
                                ! do nothing
         endif
      enddo
c-----check internal flows connected between waterbodies ( only reservoirs
c-----for now )
      conveyorId = 0
      do i=1, nobj2obj
c--------get global unique id for this internal flow
         conveyorId = get_unique_id_for_conveyor(i)
c--------from object
         if( obj2obj(i).from_obj.obj_type .eq. obj_reservoir) then
            nodeId = nodeId+1
            nodes(nodeId).id = nodeId
            objId = obj2obj(i).from_obj.obj_no
            nodes(nodeId).nwbs = 2
            nodes(nodeId).wbs(1) = 
     &           get_unique_id_for_reservoir(objId)
            nodes(nodeId).wbs(2) = conveyorId
c----------- add nodes to reservoir if not present
c-----------add_node_to_reservoir(nodeId)
         else if( obj2obj(i).from_obj.obj_type .eq. obj_node ) then
!             nnId = obj2obj(i).from.obj_no 
!             nodes(nnId).nwbs = nodes(nnId).nwbs + 1
!             nodes(nnId).wbs(nodes(nnId).nwbs) = 
!      &           get_unique_id_for_conveyor(i)
         endif
c--------to object
         if( obj2obj(i).to_obj.obj_type .eq. obj_reservoir) then
            nodeId = nodeId+1
            nodes(nodeId).id = nodeId
            nodes(nodeId).nwbs = 2
            objId = obj2obj(i).to_obj.obj_no
            nodes(nodeId).wbs(1) =  
     &           get_unique_id_for_reservoir(objId)
            nodes(nodeId).wbs(2) = conveyorId
         else if( obj2obj(i).to_obj.obj_type .eq. obj_node ) then
!             nnId = obj2obj(i).to.obj_no 
!             nodes(nnId).nwbs = nodes(nnId).nwbs + 1
!             nodes(nnId).wbs(nodes(nnId).nwbs) = 
!      &           get_unique_id_for_conveyor(i)
         endif
      enddo
      return 
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_waterbodies()
      use grid_data
      implicit none
      integer get_number_of_waterbodies
      integer get_number_of_channels
      integer get_number_of_reservoirs
      integer get_number_of_boundary_waterbodies
      integer get_number_of_stage_boundaries
      integer get_number_of_conveyors
      get_number_of_waterbodies = 
     &     get_number_of_channels() 
     &     + get_number_of_reservoirs()
     &     + get_number_of_stage_boundaries()
     &     + get_number_of_boundary_waterbodies()
     &     + get_number_of_conveyors()
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_channels()
      use grid_data
      implicit none
      integer get_number_of_channels

      get_number_of_channels = nchans
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_reservoirs()
      use grid_data
      implicit none
      integer get_number_of_reservoirs

      get_number_of_reservoirs = nreser
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_nodes()
      use grid_data
      use constants
      implicit none
      integer get_number_of_nodes
c-----integer get_maximum_number_of_pumps


      integer i

      get_number_of_nodes = nnodes 
c----- create internal nodes for object to object flows
c----- which are not nodes.
      do i=1,nqext
         if(qext(i).attach_obj_type .ne. obj_node) then
            get_number_of_nodes = get_number_of_nodes + 1
         endif
      enddo
c----- do the same for internal flows or conveyors
      do i=1,nobj2obj
         if(obj2obj(i).from_obj.obj_type .ne. obj_node) then
            get_number_of_nodes = get_number_of_nodes + 1
         endif
         if(obj2obj(i).to_obj.obj_type .ne. obj_node) then
            get_number_of_nodes = get_number_of_nodes + 1
         endif
      enddo
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_xsections()
      use grid_data
      implicit none
      integer get_number_of_xsections
      get_number_of_xsections = nxsects
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_diversions()
      use grid_data      
      implicit none
      integer get_number_of_diversions

c-----Number of diversions = 0
      get_number_of_diversions = 0
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_pumps()
      use grid_data
      implicit none
      integer get_number_of_pumps

c-----pumping from a reservoir is the same as a diversion?
      get_number_of_pumps = 0
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_conveyors()
      use grid_data
      implicit none
      integer get_number_of_conveyors

c-----internal flows
      get_number_of_conveyors = nobj2obj
      return
      end

c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_boundary_waterbodies()
      use grid_data
      use ptm_local
      implicit none
      integer get_number_of_boundary_waterbodies

      get_number_of_boundary_waterbodies = nqext
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_stage_boundaries()
      use grid_data
      use ptm_local
      implicit none
      integer get_number_of_stage_boundaries

      get_number_of_stage_boundaries = nStageBoundaries
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_channel_groups()
      use grid_data
      use ptm_local      
      use common_ptm
      implicit none

      integer get_number_of_channel_groups
      get_number_of_channel_groups = ngroup_output
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_waterbodies()
      implicit none
      integer get_maximum_number_of_waterbodies
      integer get_maximum_number_of_channels
      integer get_maximum_number_of_reservoirs
      integer get_maximum_number_of_diversions
      integer get_maximum_number_of_pumps
      integer get_maximum_number_of_boundary_waterbodies
      integer get_maximum_number_of_stage_boundaries
      integer get_maximum_number_of_conveyors

      get_maximum_number_of_waterbodies = 
     &     get_maximum_number_of_channels() +
     &     get_maximum_number_of_reservoirs() +
     &     get_maximum_number_of_diversions() +
     &     get_maximum_number_of_pumps() +
     &     get_maximum_number_of_stage_boundaries() +
     &     get_maximum_number_of_boundary_waterbodies() +
     &     get_maximum_number_of_conveyors()
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_channels()
      use grid_data
      implicit none
      integer get_maximum_number_of_channels

      get_maximum_number_of_channels = max_channels
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_reservoirs()
      use grid_data
      implicit none
      integer get_maximum_number_of_reservoirs

      get_maximum_number_of_reservoirs = max_reservoirs
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_conveyors()
      use grid_data
      implicit none
      integer get_maximum_number_of_conveyors

      get_maximum_number_of_conveyors = max_obj2obj
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_nodes()
      use grid_data
      implicit none
      integer get_maximum_number_of_nodes
c-----integer get_maximum_number_of_pumps
      integer get_maximum_number_of_conveyors

      get_maximum_number_of_nodes = max_nodes 
     &     + 2*get_maximum_number_of_conveyors()
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_xsections()
      
      use grid_data
      implicit none
      integer get_maximum_number_of_xsections

      get_maximum_number_of_xsections = max_xsects_tot
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_reservoir_nodes()
      use grid_data
      implicit none
      integer get_maximum_number_of_reservoir_nodes

      get_maximum_number_of_reservoir_nodes = maxresnodes
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_diversions()
      implicit none
      integer get_maximum_number_of_diversions

c      get_maximum_number_of_diversions = max_nodes
      get_maximum_number_of_diversions = 0
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_pumps()
      implicit none
      integer get_maximum_number_of_pumps

c      get_maximum_number_of_pumps = max_reservoirs
      get_maximum_number_of_pumps = 0
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_boundary_waterbodies()
      use grid_data
      implicit none
      integer get_maximum_number_of_boundary_waterbodies

      get_maximum_number_of_boundary_waterbodies = max_qext
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_stage_boundaries()
      use ptm_local
      implicit none
      integer get_maximum_number_of_stage_boundaries

      get_maximum_number_of_stage_boundaries = maxStageBoundaries
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_maximum_number_of_group_elements()
      use constants_ptm
      use common_ptm
      implicit none
      integer get_maximum_number_of_group_elements
      get_maximum_number_of_group_elements = max_chanres
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_channel_length(i)
      use grid_data
      implicit none
      integer get_channel_length
      integer i
      get_channel_length = chan_geom(i).length
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_channel_number_of_nodes(i)
      implicit none

      integer get_channel_number_of_nodes
      integer i
      get_channel_number_of_nodes = 2
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_channel_number_of_xsections(i)
      use grid_data
      implicit none

      integer get_channel_number_of_xsections
      integer i
      get_channel_number_of_xsections = chan_geom(i).nxsect
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_channel_node_array(i, nodeArray)
      use grid_data
      implicit none

      integer nodeArray(50)
      integer i
      nodeArray(1) = chan_geom(i).upnode
      nodeArray(2) = chan_geom(i).downnode
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_channel_xsection_ids(i, xSectionIds)
      use grid_data
      implicit none

      integer xSectionIds(50)
      integer get_channel_number_of_xsections
      integer i
      integer xid, nXs
      nXs = get_channel_number_of_xsections(i)
      do xid=1,nXs
         xSectionIds(xid) = chan_geom(i).xsect(xid)
      enddo
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_channel_xsection_distances(i, xSectionDistances)
      use grid_data
      implicit none

      real xSectionDistances(50)
      integer i, get_channel_number_of_xsections
      integer xid, nXs
      nXs = get_channel_number_of_xsections(i)
      do xid=1,nXs
         xSectionDistances(xid) = chan_geom(i).xsect(xid)
      enddo
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_reservoir_area(reservoirNumber)
      use grid_data
      implicit none

      real get_reservoir_area
      integer reservoirNumber
      get_reservoir_area = res_geom(reservoirNumber).area
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_reservoir_bottom_elevation(reservoirNumber)
      use grid_data
      implicit none

      real get_reservoir_bottom_elevation
      integer reservoirNumber
      get_reservoir_bottom_elevation = 
     &     res_geom(reservoirNumber).botelv
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_reservoir_name(reservoirNumber, name)
      use grid_data
      implicit none

      character*(*) name
      integer reservoirNumber, lastNonBlank
      integer lnblnk
      name = res_geom(reservoirNumber).name
      lastNonBlank = lnblnk(res_geom(reservoirNumber).name)
      name = name(1:lastNonBlank) // char(0)
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_reservoir_number_of_nodes(reservoirNumber)
      use ptm_local
      implicit none

      integer reservoirNumber,get_reservoir_number_of_nodes
      integer uniqId, get_unique_id_for_reservoir
      uniqId = get_unique_id_for_reservoir(reservoirNumber)
      get_reservoir_number_of_nodes = wb(uniqId).numberOfNodes
      return
      end
!       get_reservoir_number_of_nodes = 
!      &     res_geom(reservoirNumber).nnodes
! c----- add external flow connections
!       i = 0
!       do while( res_geom(reservoirNumber).qext(i) .ne. 0 
!      &     .and. i .le. max_qobj )
!          get_reservoir_number_of_nodes = 
!      &        get_reservoir_number_of_nodes + 1  
!          i = i + 1
!       enddo
! c----- add internal flow connection nodes
!       i=0
!       do while( res_geom(reservoirNumber).qinternal(i) .ne. 0 
!      &     .and. i .le. max_qobj )
!          get_reservoir_number_of_nodes = 
!      &        get_reservoir_number_of_nodes + 1  
!          i = i + 1
!       enddo
!       return 
!       end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_reservoir_node_array(reservoirNumber, nodeArray)
      use ptm_local
      implicit none

      integer reservoirNumber, nodeArray(50)
      integer i, uniqId, get_unique_id_for_reservoir
      uniqId = get_unique_id_for_reservoir(reservoirNumber)
      do i = 1, wb(uniqId).numberOfNodes
         nodeArray(i) = wb(uniqId).node(i)
      enddo
      return 
      end
! c----- number of nodes ( for a check )
!       nNodes = get_reservoir_number_of_nodes(reservoirNumber)
! c----- add nodes from reservoir structure
!       do nodeId=1,res_geom(reservoirNumber).nnodes
!          nodeArray(nodeId) = res_geom(reservoirNumber).node_no(i)
!       enddo
! c----- add nodes for external flows
!       i=0
!       do while( res_geom(reservoirNumber).qext(i) .ne. 0 ) 
!          nodeId = nodeId + 1
!          qId = res_geom(reservoirNumber).qext(i)
!          extId = 
!      &        get_unique_id_for_boundary( qId )
!          resId = 
!      &        get_unique_id_for_reservoir(reservoirNumber)
!          nodeArray(nodeId) = 
!      &        get_internal_node_id_for_unique_ids(extId, resId)
!          i = i + 1
!       enddo
! c----- add nodes for internal flows
!       i=0
!       do while( res_geom(reservoirNumber).qinternal(i) .ne. 0 ) 
!          nodeId = nodeId + 1
!          qId = res_geom(reservoirNumber).qinternal(i)
!          extId = 
!      &        get_unique_id_for_conveyor( qId )
!          resId = 
!      &        get_unique_id_for_reservoir(reservoirNumber)
!          nodeArray(nodeId) = 
!      &        get_internal_node_id_for_unique_ids(extId, resId)
!          i = i + 1
!       enddo
! c----- check that nodeId matches number of nodes
!       if ( nodeId .ne. nNodes ) then
!          write(*,*) 'Warning: # nodes in reservoir', reservoirNumber,
!      &        ' dont match those calculated in updateNode function'
!       endif
!       return 
!       end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_internal_node_id_for_unique_ids( id1, id2 )
      use ptm_local
      implicit none

      integer get_internal_node_id_for_unique_ids
      integer id1, id2
      integer id
      logical found
      found = .false.
      id = max_nodes+1
      do while( .not. found .and. id .le. maxNodesPTM)
         if ( nodes(id).wbs(1) .eq. id1 .and. nodes(id).wbs(2) .eq. id2)
     &        found = .true.
         id = id + 1
      enddo
      id = id - 1
      get_internal_node_id_for_unique_ids = id
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_diversion_number_of_nodes(diversionNumber)
      use ptm_local
      implicit none

      integer diversionNumber,get_diversion_number_of_nodes
      if ( diversionNumber .le. max_nodes) then
         if ( node_geom(diversionNumber).nup +  
     &        node_geom(diversionNumber).ndown .gt. 0 ) then 
            get_diversion_number_of_nodes = 1
         else
            get_diversion_number_of_nodes = -1
         endif
      else
         get_diversion_number_of_nodes = 1
      endif
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_diversion_node_array(diversionNumber, nodeArray)

      implicit none

      integer get_diversion_number_of_nodes
      integer diversionNumber, nodeArray(50)
      integer i, nn
      nn = get_diversion_number_of_nodes(diversionNumber)
      do i=1,nn
         nodeArray(i) = diversionNumber
      enddo
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_pump_number_of_nodes(pumpNumber)
      use grid_data
      implicit none

      integer pumpNumber,get_pump_number_of_nodes
      if(res_geom(pumpNumber).area .gt. 0.0) then
         get_pump_number_of_nodes = 1
      else
         get_pump_number_of_nodes = -1
      endif

      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_pump_node_array(pumpNumber, nodeArray)
      implicit none

      integer get_pump_number_of_nodes, get_maximum_number_of_diversions
      integer pumpNumber, nodeArray(50)
      integer i, nn
      nn = get_pump_number_of_nodes(pumpNumber)
      do i=1,nn
         nodeArray(i) = 
     &        get_maximum_number_of_diversions() + pumpNumber
      enddo
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_boundary_waterbody_number_of_nodes(Number)
      implicit none
      integer Number,get_number_of_boundary_waterbodies,
     &     get_boundary_waterbody_number_of_nodes
      if (Number .lt. get_number_of_boundary_waterbodies()) then
         get_boundary_waterbody_number_of_nodes = 1
      else
         get_boundary_waterbody_number_of_nodes = 0
      endif
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_boundary_waterbody_node_array(
     &     number, nodeArray)
      use ptm_local
      implicit none


      integer get_unique_id_for_boundary
      integer number, nodeArray(50)
      integer i, uniqId
c----- check with nodes to get waterbody with unique matching id
      uniqId = get_unique_id_for_boundary(number)
      do i=1, wb(uniqId).numberOfNodes
         nodeArray(i) = wb(uniqId).node(i)
      enddo
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_stage_boundary_number_of_nodes(Number)
      implicit none
      integer Number,get_number_of_stage_boundaries,
     &     get_stage_boundary_number_of_nodes
      if (Number .lt. get_number_of_stage_boundaries()) then
         get_stage_boundary_number_of_nodes = 1
      else
         get_stage_boundary_number_of_nodes = -1
      endif
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_stage_boundary_node_array(
     &     number, nodeArray)
      use ptm_local
      implicit none

 
      integer get_stage_boundary_number_of_nodes
      integer number, nodeArray(50)
      nNodes = 
     &     get_stage_boundary_number_of_nodes(
     &     number)
      if ( nNodes .ne. 1 ) then
         nodeArray(1) = 0
         return
      endif
      nodeArray(1) = stageBoundary(number).attach_obj_no
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_conveyor_number_of_nodes(number)
      use ptm_local
      implicit none

      integer number, get_conveyor_number_of_nodes
      integer get_unique_id_for_conveyor,id
      id = get_unique_id_for_conveyor(number)
      get_conveyor_number_of_nodes = wb(id).numberOfNodes
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_conveyor_node_array(
     &     conveyorNumber, nodeArray)
      use ptm_local
      implicit none

      integer conveyorNumber
c-----integer get_node_for_conveyor
      integer nodeArray(50), id
      integer get_unique_id_for_conveyor, numberOfNodes, i
      id = get_unique_id_for_conveyor(conveyorNumber)
      numberOfNodes = wb(id).numberOfNodes
      if ( numberOfNodes .eq. 2 ) then
         do i=1, wb(id).numberOfNodes
            nodeArray(i) = wb(id).node(i)
         enddo
      endif
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
!       function get_node_for_boundary_waterbody(index)
!       implicit none
!       integer get_node_for_boundary_waterbody, index
!       integer i, nBoundary
!       i=1
!       if ( index .le. nqext ) then
!          if ( qext(index).obj_type .eq. obj_node ) then
!             get_node_for_boundary_waterbody = qext(index).obj_no
!          else
!             get_node_for_boundary_waterbody = 0
!          endif
!       else ! node with stage boundary type
!       endif

!       nBoundary = 0
!       get_node_for_boundary_waterbody = -1
!       do while ( i .lt. transNumber .and. nBoundary .ne. index) 
!          if ( translationInfo(i).type .eq. obj_qext) then
!             nBoundary = nBoundary + 1
!          endif
!          i = i + 1
!       enddo
!       if (nBoundary .eq. index) then
!         get_node_for_boundary_waterbody = 
!      &        translationInfo(i-1).nodeNumber
!       endif
!       return
!       end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_waterbodies_for_node(nodeNumber)
      use ptm_local
      implicit none

      integer get_number_of_waterbodies_for_node
      integer nodeNumber
      get_number_of_waterbodies_for_node = nodes(nodeNumber).nwbs
      return 
      end
!       if (nodeNumber .le. max_nodes) then
!          get_number_of_waterbodies_for_node = 
!      &        node_geom(nodeNumber).nup + node_geom(nodeNumber).ndown
! !     &        + 1
!          numberOfBoundaries = 0
! !          do i=1, get_number_of_boundary_waterbodies()
! !             if (nodeNumber .eq. get_node_for_boundary_waterbody(i)) then
! !                numberOfBoundaries = numberOfBoundaries + 1
! !             endif
! !          enddo
! !          get_number_of_waterbodies_for_node = 
! !      &        get_number_of_waterbodies_for_node + numberOfBoundaries
!       else
!          nn = nodeNumber - max_nodes
!          if( nn .eq. )
! !         get_number_of_waterbodies_for_node = 2
!       endif
!       return 
!       end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_boundary_type_for_node(nodeNumber, name)
      use grid_data
      use constants
      implicit none

      character*(*) name
      integer nodeNumber, lastNonBlank
c-----integer lnblnk
c-----lastNonBlank = lnblnk(node_geom(nodeNumber).boundary_type)
      name=''
      lastNonBlank=1    
      if( nodeNumber .le. max_nodes .and.   !todo: Eli added this guard against high nodeNumber. Why would the code work before?
     &    node_geom(nodeNumber).boundary_type .eq. stage_boundary ) then
         name = 'STAGE'
      endif
      name = trim(name) // char(0)
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_waterbody_id_array_for_node(nodeNumber, array)
      use ptm_local
      implicit none

      integer nodeNumber, array(50)
      integer i
      if ( nodeNumber .gt. maxNodesPTM) goto 999
      do i=1, nodes(nodeNumber).nwbs
         array(i) = nodes(nodeNumber).wbs(i)
      enddo
 999  return 
      end
!       if(nodeNumber .le. max_nodes) then 
!          do i=1, node_geom(nodeNumber).nup
!             array(i) = node_geom(nodeNumber).upstream(i)
!          enddo
!          do i=1,node_geom(nodeNumber).ndown
!             array(i+node_geom(nodeNumber).nup) 
!      &           = node_geom(nodeNumber).downstream(i)
!          enddo
! !         array(node_geom(nodeNumber).ndown + 1) = nodeNumber
!       else
!          array(1) = nodeNumber - max_nodes 
!      &        + get_maximum_number_of_channels()
!          array(2) = nodeNumber - max_nodes 
!      &        + get_maximum_number_of_channels()
!      &        + get_maximum_number_of_reservoirs()
!      &        + get_maximum_number_of_diversions()
!       endif
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_xsection_number_of_elevations()
      implicit none

      integer get_xsection_number_of_elevations
      get_xsection_number_of_elevations = 2 ! regular sections yet
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_xsection_widths(number, array)
      use grid_data
      implicit none

      integer number
      real array(50)
      array(1) = xsect_geom(number).width ! regular sections
      array(2) = xsect_geom(number).width ! regular sections
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++

      subroutine get_xsection_elevations(number, array)
      use grid_data
      implicit none

      integer number
      real array(50)
      array(1) = xsect_geom(number).botelv
      array(2) = 100
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_xsection_areas(number, array)
      implicit none

      integer number
      real array(50)
      array(1) = -1
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_xsection_minimum_elevation(number)
      use grid_data
      implicit none

      real get_xsection_minimum_elevation
      integer number
      get_xsection_minimum_elevation = xsect_geom(number).botelv
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_particle_boolean_inputs(array)
      use common_ptm
      implicit none
      integer array(50)
      array(1)=ptm_ivert
      array(2)=ptm_itrans
      array(3)=ptm_iey
      array(4)=ptm_iez
      array(5)=ptm_iprof
      array(6)=ptm_igroup
      array(7)=ptm_flux_percent
      array(8)=ptm_group_percent
      array(9)=ptm_flux_cumulative
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_particle_float_inputs(array)
      use common_ptm
      implicit none
      real array(50)
      array(1)=ptm_random_seed
      array(2)=ptm_trans_constant
      array(3)=ptm_vert_constant
      array(4)=ptm_trans_a_coef
      array(5)=ptm_trans_b_coef
      array(6)=ptm_trans_c_coef
      array(7)=ptm_no_animated
      return
      end

c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_particle_number_of_injections()
      use common_ptm
      implicit none
      integer get_particle_number_of_injections
      get_particle_number_of_injections = npartno
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_particle_injection_nodes(array)
      use common_ptm
      implicit none
      integer array(50)
      integer i
      if (npartno .gt. 50) 
     &     write(*,*) 'Extend LEN1 in fixedData.h to ', npartno 
      do i=1,npartno
         array(i) = part_injection(i).node
      enddo
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_particle_number_of_particles_injected(array)
      use common_ptm
      implicit none
      integer array(50)
      integer i
      if (npartno .gt. 50) 
     &     write(*,*) 'Extend LEN1 in fixedData.h to ', npartno 
      do i=1,npartno
         array(i) = part_injection(i).nparts
      enddo  
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_particle_injection_start_julmin(array)
      use common_ptm
      implicit none
      integer array(50)
      integer i
      if (npartno .gt. 50) 
     &     write(*,*) 'Extend LEN1 in fixedData.h to ', npartno 
      do i=1,npartno
         array(i) = part_injection(i).start_julmin
      enddo  
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_particle_injection_length_julmin(array)
      use common_ptm
      implicit none
      integer array(50)
      integer i
      if (npartno .gt. 50) 
     &     write(*,*) 'Extend LEN1 in fixedData.h to ', npartno 
      do i=1,npartno
         array(i) = part_injection(i).length_julmin
      enddo  
      return
      end

c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      integer function get_number_of_group_outputs()
      use ptm_local
      implicit none
      integer get_number_of_fluxes

      get_number_of_group_outputs = ngroup_output
      return
      end

c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      integer function get_number_of_group_members(index)
	use groups,only : groupArray
      use ptm_local
      implicit none
      integer get_number_incoming

      integer index
	get_number_of_group_members 
     &           = groupArray(groupOut(index).groupNdx).nMember
      return
      end

c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_fluxes()
      use ptm_local
      implicit none
      integer get_number_of_fluxes

      get_number_of_fluxes = nFlux
      return
      end

c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_group_member_index(index, array, nmember)
	use groups,only: groupArray
      use ptm_local
      implicit none

	integer index              ! index of flux in global flux array
	integer,intent(in) :: nmember  ! number of members (dimension of array)
      integer :: array(nmember)  ! array to be filled with members
      integer :: i               ! local counter
	integer :: objtype
	integer :: objndx
	integer :: getWaterbodyUniqueId
	do i=1,nmember
	   objtype=groupArray(groupOut(index).groupNdx).members(i).obj_type
	   objndx=groupArray(groupOut(index).groupNdx).members(i).obj_no
	   array(i) = getWaterbodyUniqueId(objtype,objndx)
      enddo
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_group_member_type(index, array, nmember)
	use groups,only: groupArray
      use ptm_local
      implicit none

	integer index              ! index of flux in global flux array
	integer,intent(in) :: nmember  ! number of members (dimension of array)
      integer :: array(nmember)  ! array to be filled with members
      integer :: i               ! local counter
	integer :: ptm_type_code
	do i=1,nmember
         array(i) = ptm_type_code(
     &     groupArray(groupOut(index).groupNdx).members(i).obj_type
     &   )
	   
      enddo
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_incoming(index)
	use groups,only : groupArray
      use ptm_local
      use constants
      implicit none
      integer get_number_incoming

      integer index
	get_number_incoming = 1
	if (flux(index).inType .eq. obj_group)then
        get_number_incoming = groupArray(flux(index).inIndex).nMember
	end if
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_outgoing(index)
	use groups,only : groupArray
      use ptm_local
      use constants
      implicit none
      integer get_number_outgoing

      integer index
	get_number_outgoing = 1
	if (flux(index).outType .eq. obj_group)then
        get_number_outgoing = groupArray(flux(index).outIndex).nMember
      end if
	return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_flux_incoming(index, array, nmember)
      use ptm_local
      use constants
	use groups,only: groupArray,GROUP_ANY_INDEX,GROUP_ANY_TYPE
      implicit none

	integer index              ! index of flux in global flux array
	integer,intent(in) :: nmember  ! number of members (dimension of array)
      integer :: array(nmember)  ! array to be filled with members
      integer :: i               ! local counter
	integer :: objtype
	integer :: objndx
      integer :: getWaterbodyUniqueId

	if (flux(index).inType .eq. obj_group)then
         do i=1,nmember
	      objtype=groupArray(flux(index).inIndex).members(i).obj_type
	      objndx=groupArray(flux(index).inIndex).members(i).obj_no
	      if( objndx .eq. GROUP_ANY_INDEX)then
	         array(i) = GROUP_ANY_INDEX
	      else
               array(i) = getWaterbodyUniqueId(objtype,objndx)
	      end if
         enddo
      else 
	   array(1) = getWaterbodyUniqueId(flux(index).intype,flux(index).inIndex)
	end if
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_flux_outgoing(index, array, nmember)
      use ptm_local
      use constants
	use groups,only: groupArray,GROUP_ANY_INDEX,GROUP_ANY_TYPE
      implicit none

	integer index              ! index of flux in global flux array
	integer,intent(in) :: nmember  ! number of members (dimension of array)
      integer :: array(nmember)  ! array to be filled with members
      integer :: i               ! local counter
	integer :: objtype
	integer :: objndx
	integer :: getWaterbodyUniqueId

	if (flux(index).outType .eq. obj_group)then
         do i=1,nmember
	      objtype=groupArray(flux(index).outIndex).members(i).obj_type
	      objndx=groupArray(flux(index).outIndex).members(i).obj_no
            if( objndx .eq. GROUP_ANY_INDEX)then
	         array(i) = GROUP_ANY_INDEX
	      else
               array(i) = getWaterbodyUniqueId(objtype,objndx)
	      end if
         enddo
      else 
	   array(1) = getWaterbodyUniqueId(flux(index).outType,flux(index).outIndex)
	end if
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_flux_incoming_type(index, array, nmember)
      use ptm_local
	use groups,only: groupArray,GROUP_ANY_INDEX,GROUP_ANY_TYPE
	use constants
      implicit none

	integer index              ! index of flux in global flux array
	integer,intent(in) :: nmember  ! number of members (dimension of array)
      integer :: array(nmember)  ! array to be filled with members
      integer :: i               ! local counter
	integer :: ptm_type_code
	integer :: objndx
	if (flux(index).inType .eq. obj_group)then
         do i=1,nmember
	      objndx=groupArray(flux(index).inIndex).members(i).obj_type
            if( objndx .eq. GROUP_ANY_TYPE)then
	         array(i) = GROUP_ANY_TYPE
	      else
               array(i) = ptm_type_code(objndx)
	      end if
         enddo
      else 
	   array(1) =  ptm_type_code(
     &   	     flux(index).inType )
	end if

      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_flux_outgoing_type(index, array, nmember)
      use ptm_local
      use constants
	use groups,only: groupArray,GROUP_ANY_INDEX,GROUP_ANY_TYPE
      implicit none

	integer index              ! index of flux in global flux array
	integer,intent(in) :: nmember  ! number of members (dimension of array)
      integer :: array(nmember)  ! array to be filled with members
      integer :: i               ! local counter
	integer :: ptm_type_code
	integer :: objndx

	if (flux(index).outType .eq. obj_group)then
         do i=1,nmember
	      objndx=groupArray(flux(index).outIndex).members(i).obj_type
            if( objndx .eq. GROUP_ANY_TYPE)then
	         array(i) = GROUP_ANY_TYPE
	      else
               array(i) = ptm_type_code(objndx)
	      end if
         enddo
      else 
	   array(1) =  ptm_type_code(
     &   	     flux(index).outType )
	end if
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_model_start_time()
      use runtime_data
      implicit none

      integer get_model_start_time
      get_model_start_time = start_julmin
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_model_end_time()
      use runtime_data
      implicit none

      integer get_model_end_time
      get_model_end_time = end_julmin
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_model_ptm_time_step()
      use common_ptm
      implicit none
      integer get_model_ptm_time_step
      get_model_ptm_time_step = ptm_time_step
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_display_interval()
      use constants
      use runtime_data
      implicit none

      integer*4 get_display_interval
      integer*4 incr_intvl
      get_display_interval = incr_intvl(0,display_intvl,IGNORE_BOUNDARY)
      return 
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_animation_filename(array)
      use iopath_data
      implicit none

      character*(*) array
      integer lnblnk
      array = io_files(ptm,io_animation,io_write).filename
      array = array(1:lnblnk(array)) // char(0)
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_model_animation_output_interval()
      use iopath_data
      implicit none

      integer get_model_animation_output_interval
      integer mins
      character*80 intvl
      intvl = io_files(ptm,io_animation,io_write).interval
      call CharIntvl2Mins(intvl, mins)
      get_model_animation_output_interval = mins
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_behavior_filename(array)
      use iopath_data
      implicit none

      character*(*) array
      integer lnblnk
      array = io_files(ptm,io_behavior,io_read).filename
      array = array(1:lnblnk(array)) // char(0)
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_trace_filename(array)
      use iopath_data      
      implicit none

      character*(*) array
      array = io_files(ptm,io_trace,io_write).filename
      array = trim(array) // char(0)
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_model_trace_output_interval()
      use iopath_data      
      implicit none

      integer get_model_trace_output_interval
      integer mins
      character*80 intvl
      intvl = io_files(ptm,io_trace,io_write).interval
      call CharIntvl2Mins(intvl, mins)
      get_model_trace_output_interval = mins
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_restart_output_filename(array)
      use iopath_data      
      implicit none

      character*(*) array
      integer lnblnk
      array = io_files(ptm,io_restart,io_write).filename
      array = array(1:lnblnk(array)) // char(0)
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_restart_output_interval()
      use iopath_data      
      implicit none

      integer get_restart_output_interval, mins
      character*80 intvl
      intvl = io_files(ptm,io_restart,io_write).interval
      call CharIntvl2Mins(intvl, mins)
      get_restart_output_interval= mins
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_restart_input_filename(array)
      use iopath_data      
      implicit none

      character*(*) array
      integer lnblnk
      array = io_files(ptm,io_restart,io_read).filename
      array = array(1:lnblnk(array)) // char(0)
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++
      integer function ptm_type_code(dsm_type)
      use constants
	implicit none

	integer dsm_type
      if ( dsm_type .eq. obj_channel ) then
         ptm_type_code = 100
      else if ( dsm_type .eq. obj_reservoir ) then
         ptm_type_code = 101
      else if ( dsm_type .eq. obj_qext ) then
         ptm_type_code = 105
      else if ( dsm_type .eq. obj_obj2obj ) then
         ptm_type_code = 106
      else if ( dsm_type .eq. obj_stage) then
	   ptm_type_code = 105
      else
         ptm_type_code = -1
      endif
	return
	end function

c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      integer function get_waterbody_type( id )
      use ptm_local
      implicit none

      integer id, wbtype, ptm_type_code
      wbtype = wb(id).type
	get_waterbody_type=ptm_type_code(wbtype)
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_local_id_for_waterbody( id )
      use ptm_local
      implicit none

      integer id, get_local_id_for_waterbody
      get_local_id_for_waterbody = wb(id).localIndex
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_of_nodes_for_waterbody( id )
      use ptm_local
      implicit none

      integer id, get_number_of_nodes_for_waterbody
      get_number_of_nodes_for_waterbody = wb(id).numberOfNodes
      return
      end
c-----++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_node_array_for_waterbody(id, nodeArray)
      use ptm_local
      implicit none

      integer i,id, nodeArray(50)
      do i=1,wb(id).numberOfNodes
         nodeArray(i) = wb(id).node(i)
      enddo
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++++++
      function getWaterbodyUniqueId(wbtype, id)
      use ptm_local
      use constants
      implicit none

c-----
      integer getWaterbodyUniqueId
      integer get_unique_id_for_channel
     &     , get_unique_id_for_reservoir
     &     , get_unique_id_for_stage_boundary
     &     , get_unique_id_for_boundary
     &     , get_unique_id_for_conveyor
      integer wbId, posId,id
      integer wbtype
      posId = abs(id)
      if (wbtype .eq. obj_channel) then
         wbId = get_unique_id_for_channel(posId)
      else if (wbtype .eq. obj_reservoir) then
         wbId = get_unique_id_for_reservoir(posId)
      else if (wbtype .eq. obj_qext) then
         wbId = get_unique_id_for_boundary(posId)
      else if (wbtype .eq. obj_obj2obj) then
         wbId = get_unique_id_for_conveyor(posId)
      else if (wbtype .eq. obj_stage) then
         wbId = get_unique_id_for_stage_boundary(posId)
      endif
      getWaterbodyUniqueId = sign(wbId, id)
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++++++
      function getStageWaterbodyForNode(id)
      use ptm_local
      implicit none

c-----
      integer getStageWaterbodyForNode, id
      integer wbId, i, uniqId
      integer get_unique_id_for_stage_boundary
      do i = 1, nStageBoundaries
         uniqId = get_unique_id_for_stage_boundary(i)
         if ( wb(uniqId).node(1) .eq. id ) then
            wbId = uniqId
         endif
      enddo
      getStageWaterbodyForNode = wbId
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++++++

c     DEPRECATED. Water bodies don't have one-to-one relationships with
c     accounting types any more
      function get_waterbody_accounting_type(id)
      use ptm_local
      implicit none

c-----
      integer get_waterbody_accounting_type, id
      integer wbtype
      wbtype = miss_val_i
      get_waterbody_accounting_type = wbtype
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_waterbody_object_type(id)
      use ptm_local
      implicit none

c-----

      integer get_waterbody_object_type, id
      integer type
      type = wb(id).type
      get_waterbody_object_type = type
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_waterbody_group(id)
      use ptm_local
      implicit none

c-----
      integer get_waterbody_group, id
      integer group
      group = wb(id).group
      get_waterbody_group = group
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++++++
      function does_qual_binary_exist()
      use common_qual_bin
      implicit none
c-----
      logical does_qual_binary_exist
      if (qual_bin_file.filename .eq. ' ') then
         does_qual_binary_exist = .false.
      else
         does_qual_binary_exist = .true.
      endif
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++++++
      subroutine get_qual_constituent_names(id, array)
      use common_qual_bin
      implicit none

c-----
      character*(*) array
      integer lnblnk,id
      array = qual_bin_file.constituent(id)
      array = array(1:lnblnk(array)) // char(0)
      return
      end
c-----+++++++++++++++++++++++++++++++++++++++++++++++++++++++
      function get_number_constituents()
      use common_qual_bin
      implicit none

c-----
      integer get_number_constituents
      get_number_constituents = neq
      return
      end


      subroutine find_layer_index(
     &     X
     &     ,H
     &     ,Branch
     &     ,vsecno
     &     ,virtelev
     &     ,veindex
     &     )
      use IO_Units
      use common_xsect
      use runtime_data
      implicit none


      integer
     &     Branch               ! hydro channel number
     &     ,virtelev            ! virtual elevation number (within channel)
     &     ,vsecno              ! virtual xsect number (within channel)
     &     ,veindex             ! virtual elevation index
     &     ,previous_elev_index(max_virt_xsects) ! used to store elevation index
      real*8
     &     X                    ! distance along channel (from FourPt)
     &    ,H                   ! distance above channel bottom (from FourPt)

      save previous_elev_index

      data previous_elev_index /max_virt_xsects * 1/


c-----find the index of elevation of layer that is below H, and the
c-----virtual xsect number

c-----Check for negative depth

      if (H.le.0.) then
         write(unit_error,910) chan_geom(Branch).chan_no,current_date,H
 910     format(' Error...channel', i4,' dried up at time ',a,'; H=',f10.3)
         call exit(13)
      endif

      vsecno = nint(X / virt_deltax(Branch))+1
      virtelev=previous_elev_index(minelev_index(Branch)+vsecno-1)

c-----if upper level is below or at same elevation as H, move up
      do while (virtelev .lt. num_layers(Branch) .and.
     &     virt_elevation(elev_index(Branch)+virtelev) .le. H)
         virtelev=virtelev+1
      enddo
c-----if lower level is above H, move down
      do while (virtelev .gt. 1 .and.
     &     virt_elevation(elev_index(Branch)+virtelev-1) .gt. H)
         virtelev=virtelev-1
      enddo



      previous_elev_index(minelev_index(Branch)+vsecno-1) = virtelev
      veindex=elev_index(Branch)+virtelev-1
      if (h .gt. virt_elevation(elev_index(Branch)+num_layers(Branch)-1)) then
         write(unit_error,*) 'Error in find_layer_index'
         write(unit_error,610) chan_geom(Branch).chan_no,
     &        virt_elevation(elev_index(Branch)+num_layers(Branch)-1),h
 610     format('Top elevation in cross-section is too low.'
     &        /'Change variable ''max_layer_height'' in common_irreg_geom.f.'
     &        /'Chan no. ',i3,' Chan top elev=',f6.2,' H=',f6.2)
         call exit(2)
      endif

      return
      end


*=======================================================================
*   Public: ChannelWidth
*=======================================================================

      REAL*8 FUNCTION ChannelWidth(X,H)
      use IO_Units
      use common_xsect
      IMPLICIT NONE

*   Purpose:
*     Estimate channel width in the current channel at X downstream distance and
*     at H distance above the lowest point in the cross section.

*   Arguments:
      REAL*8    X,H

*   Argument definitions:
*     X      - downstream distance in current channel.
*     H      - distance, above lowest point in channel, at which the
*              channel width is to be computed.

*   Module data:
      INCLUDE '../../hydrolib/network.inc'
      INCLUDE '../../hydrolib/chcxtbl.inc'


*   Functions:
      LOGICAL  CxShapeFunction
      EXTERNAL CxShapeFunction

*   Subroutines:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993
      
c-----local variables
      REAL*8 
     &     x1                   ! interpolation variables
     &     ,x2
     &     ,y1
     &     ,y2
     &     ,interp              ! interpolation function
      integer
     &     vsecno               ! number of virtual section (within channel)
     &     ,virtelev            ! number of virtual elevation (within channel)
     &     ,veindex             ! index of virtual elevation array
     &     ,dindex              ! function to calculate xsect prop. array index
     &     ,di                  ! stores value of dindex

c-----statement function to calculate indices of virtual data arrays
      dindex(Branch,vsecno,virtelev)
     &     =chan_index(Branch) + (vsecno-1)*num_layers(Branch) + virtelev-1
c-----statement function to interpolate wrt two points
      interp(x1,x2,y1,y2,H) =-((y2-y1)/(x2-x1))*(x2-H) + y2 

      call find_layer_index(
     &     X
     &     ,H
     &     ,Branch
     &     ,vsecno
     &     ,virtelev
     &     ,veindex
     &     )


      di=dindex(Branch,vsecno,virtelev)
      x1=virt_elevation(veindex)
      x2=virt_elevation(veindex+1)
      y1=virt_width(di)
      y2=virt_width(di+1)
      ChannelWidth = interp(x1,x2,y1,y2,H)
      if (x1.eq.x2) then
         write(unit_error,*) 'ChannelWidth division by zero'
      endif

      RETURN
      END




*=======================================================================
*   Public: CxArea
*=======================================================================

      REAL*8 FUNCTION CxArea(X, H)
      use common_xsect
      IMPLICIT NONE

*   Purpose:
*     Estimate cross-sectional area in the current channel, at X downstream
*     distance, limited by the lowest point in the channel and a
*     distance H above the lowest point.

*   Arguments:
      REAL*8    X, H              ! h-height of trapezoid

*   Argument definitions:
*     X - downstream distance.
*     H - distance above lowest point in cross section.


*   Module data:
      INCLUDE '../../hydrolib/network.inc'
      INCLUDE '../../hydrolib/chcxtbl.inc'

*   Routines by module:

***** Local:
      REAL*8   ChannelWidth
      EXTERNAL ChannelWidth
      REAL*8 
     &     x1                   ! interpolation variables
     &     ,x2

      integer
     &     vsecno               ! number of virtual section (within channel)
     &     ,virtelev            ! number of virtual elevation (within channel)
     &     ,veindex             ! index of virtual elevation array
     &     ,dindex              ! function to calculate xsect prop. array index
     &     ,di                  ! stores value of dindex
      REAL*8 
     &     a1                   ! area of lower layer
     &     ,b1                  ! width of lower layer (base of trapezoid)
     &     ,b2                  ! interpolated width (trapezoid top width)

*   Intrinsics:

*   Programmed by: Lew DeLong
*   Date:          July  1991
*   Modified by:   Brad Tom
*   Last modified: October 10, 1996
*   Version 93.01, January, 1993

*-----Implementation -----------------------------------------------------

c-----statement function to calculate indices of virtual data arrays

      dindex(Branch,vsecno,virtelev)
     &     =chan_index(Branch) + (vsecno-1)*num_layers(Branch) + virtelev-1

      call find_layer_index(
     &     X
     &     ,H
     &     ,Branch
     &     ,vsecno
     &     ,virtelev
     &     ,veindex
     &     )

         di=dindex(branch,vsecno,virtelev)
         x1=virt_elevation(veindex)
         x2=H
         a1=virt_area(di)
         b1=virt_width(di)
         b2=ChannelWidth(X,H)
         CxArea = a1+(0.5*(b1+b2))*(x2-x1)

      RETURN
      END



!<license>
!    Copyright (C) 2013 State of California,
!    Department of Water Resources.
!    This file is part of DSM2-GTM.
!
!    The Delta Simulation Model 2 (DSM2) - General Transport Model (GTM) 
!    is free software: you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    DSM2 is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with DSM2.  If not, see <http://www.gnu.org/licenses>.
!</license>

!> This module contains common variables definition, such as n_time, n_chan, n_comp  
!> and n_segm as well as properties for channels, computational points and segments. 
!>@ingroup gtm_core
module common_variables

     use gtm_precision
     
     integer :: memory_buffer = 20                  !< time buffer use to store hdf5 time series
     integer :: n_comp = LARGEINT                   !< number of computational points
     integer :: n_chan = LARGEINT                   !< number of channels
     integer :: n_segm = LARGEINT                   !< number of segments
     integer :: n_conn = LARGEINT                   !< number of connected cells
     integer :: n_node = LARGEINT                   !< number of DSM2 nodes
     integer :: n_junc = LARGEINT                   !< number of junctions
     integer :: n_boun = LARGEINT                   !< number of boundaries
     integer :: n_link = LARGEINT                   !< number of connections for two cells
     integer :: n_xsect = LARGEINT                  !< number of entries in virt xsect table
     integer :: n_resv = LARGEINT                   !< number of reservoirs
     integer :: n_resv_conn = LARGEINT              !< number of reservoir connects
     integer :: n_qext = LARGEINT                   !< number of external flows
     integer :: n_cell = LARGEINT                   !< number of cells in the entire network
     integer :: n_var = LARGEINT                    !< number of variables
    
     real(gtm_real), allocatable :: dx_arr(:)              !< dx array
     real(gtm_real), allocatable :: hydro_flow(:,:)        !< flow from DSM2 hydro
     real(gtm_real), allocatable :: hydro_ws(:,:)          !< water surface from DSM2 hydro
     real(gtm_real), allocatable :: hydro_resv_flow(:,:)   !< reservoir flow
     real(gtm_real), allocatable :: hydro_resv_height(:,:) !< reservoir height
     real(gtm_real), allocatable :: hydro_qext(:,:)        !< external flows

     !> Define scalar and envvar in input file 
     real(gtm_real) :: gtm_dx = LARGEREAL              !< gtm dx
     integer :: npartition_t = LARGEINT                !< number of gtm time intervals partition from hydro time interval
     character(len=128) :: hydro_hdf5                  !< hydro tide filename
     integer :: hydro_start_jmin = LARGEINT            !< hydro start time in hydro tidefile
     integer :: hydro_end_jmin = LARGEINT              !< hydro end time in hydro tidefile
     integer :: hydro_time_interval = LARGEINT         !< hydro time interval in hydro tidefile
     integer :: hydro_ntideblocks = LARGEINT           !< hydro time blocks in hydro tidefile
     real(gtm_real) :: gtm_start_jmin = LARGEREAL      !< gtm start time
     real(gtm_real) :: gtm_end_jmin = LARGEREAL        !< gtm end time
     integer :: gtm_ntideblocks = LARGEINT             !< gtm time blocks
     real(gtm_real) :: gtm_time_interval = LARGEREAL   !< gtm simulation time interval
     logical :: debug_print = .false.
     
     type gtm_io_files_t
          character(len=130) :: filename            !< filename
          character(len=16) :: interval             !< I/O time interval
     end type
     type(gtm_io_files_t) :: gtm_io(3,2)            !< (col#1) 1:restart, 2:echo, 3:hdf, 4:output
                                                    !< (col#2) 1:in, 2:out 
     !> IO_units
     integer, parameter :: unit_error = 0           !< error messages
     integer, parameter :: unit_input = 11          !< input unit
     integer, parameter :: unit_screen = 6          !< output unit to screen (MUST be 6)
     integer, parameter :: unit_output = 14         !< output file
     integer, parameter :: unit_text = 13           !< temporary (scratch) text file output
       
     !> Define channel type to store channel related arrays
     type channel_t                                 !< channel between hydro nodes
          integer :: channel_num                    !< actual channel number in DSM2 grid
          integer :: chan_no                        !< index channel number
          integer :: channel_length                 !< channel length
          integer :: up_node                        !< upstream DSM2 node
          integer :: down_node                      !< downstream DSM2 node
          integer :: up_comp                        !< upstream computational point
          integer :: down_comp                      !< downstream computational point
     end type
     type(channel_t), allocatable :: chan_geom(:)
     
     !> Define computational point type to store computational point related arrays   
     type comp_pt_t                                 !< computational points
          integer :: comp_index                     !< computational point index
          integer :: chan_no                        !< channel number
          !integer :: dsm2_node_no                  !< DSM2 node number if it is at two ends of a channel
          real(gtm_real) :: distance                !< distance from upstream node
     end type
     type(comp_pt_t), allocatable :: comp_pt(:)
    
     !> Define segment type to store segment related arrays
     type segment_t                                !< segment between computational points
          integer :: segm_no                       !< segment serial no
          integer :: chan_no                       !< channel no
          integer :: up_comppt                     !< upstream computational point (used as index to search time series data)        
          integer :: down_comppt                   !< downstream computational point
          integer :: nx                            !< number of cells in a segment
          integer :: start_cell_no                 !< start cell number (for keeping track of icell)          
          real(gtm_real) :: up_distance            !< up_comppt distance from upstream node
          real(gtm_real) :: down_distance          !< down_comppt distance from upstream node
          real(gtm_real) :: length                 !< segment length in feet
     end type
     type(segment_t), allocatable :: segm(:)    
    
     !> Define connected cells 
     type conn_t
          integer :: conn_no                       !< serial number for cell connected to DSM2 nodes
          integer :: segm_no                       !< segment serial number
          integer :: cell_no                       !< cell serial number
          integer :: comp_pt                       !< connected computational point
          integer :: chan_no                       !< channel number
          integer :: dsm2_node_no                  !< connected DSM2 node number
          integer :: conn_up_down                  !< the connected node is upstream (1) or downstream (0),
                                                   !< or think of (1): away from conn, (0): to conn
     end type
     type(conn_t), allocatable :: conn(:)
    
     !> Define junctions
     type junction_t
          integer :: dsm2_node_no                  !< junction DSM2 node number
          integer :: n_conn_cells                  !< total number of cells connected to this junction
          integer, allocatable :: cell_no(:)       !< cell no connected to this junction
          integer, allocatable :: up_down(:)       !< flow toward junction (0) or away from junction (1) from DSM2 base grid definition
     end type
     type(junction_t), allocatable :: junc(:)
    
     !> Define boundaries
     type boundary_t
          integer :: dsm2_node_no                  !< boundary DSM2 node number
          integer :: cell_no                       !< connected cell no
          integer :: up_down                       !< flow toward boundary (0) or away from boundary (1) from DSM2 base grid definition
     end type
     type(boundary_t), allocatable :: bound(:)
     
     !> Define link between two cells
     type link_t
         integer :: dsm2_node_no                   !< DSM2 node number
         integer :: cell_no(2)        !< cell no connectedd to this link
         integer :: up_down(2)        !< flow toward link (0) or away from link (1) from DSM2 base grid definition
     end type
     type(link_t), allocatable :: link(:)

     !> Define reservoirs
     type reservoir_t
        integer ::       resv_index            ! reservoir index
        character*32 ::   name = ' '           ! reservoir name
        real(gtm_real) :: area = 0.d0          ! average top area
        real(gtm_real) :: bot_elev = 0.d0      ! bottom elevation wrt datum
        integer :: n_res_conn = LARGEINT       ! number of nodes connected using reservoir connections
        integer, allocatable :: int_node_no(:) ! DSM2 internal node number
        integer, allocatable :: ext_node_no(:) ! DSM2 grid node number
        integer, allocatable :: is_gated(:)    ! 1: if a node is gated, 0: otherwise
     end type
     type(reservoir_t), allocatable :: resv_geom(:)
     
     
     !> Define external flows
     type qext_t
         integer :: qext_index                 ! qext index
         character*32 :: name                  ! qext name
         character*32 :: attach_obj_name       ! attached obj name
         integer :: attach_obj_type            ! attached obj type (2:node, 3:reservoir)
         integer :: attach_obj_no              ! attached obj no (internal number)
     end type
     type(qext_t), allocatable :: qext(:)
     
     
     !> Define reservoir connections
     type reservoir_conn_t
         integer :: resv_no                    ! reservoir number
         integer :: n_res_conn                 ! number of connected nodes
         integer :: dsm2_node_no               ! DSM2 node number
         integer :: n_conn_cells               ! number of connected cells
         integer :: conn_cell                  ! connected cells
         integer :: up_down                    ! flow toward node (0) or away from node (1)
     end type
     type(reservoir_conn_t), allocatable :: resv_conn(:)
     
     !> DSM2 Node information
     type dsm2_node_t
         integer :: dsm2_node_no               ! DSM2 node number
         integer :: n_conn_cell                ! number of cells connected
         integer, allocatable :: cell_no(:)    ! cell number
         integer, allocatable :: up_down(:)    ! flow toward node (0) or away from node (1) from DSM2 base grid definition
         integer :: boundary_no                !
         integer :: junction_no                !
         integer :: reservoir_no               ! connected to reservoir no         
         integer :: n_qext                     ! number of external flows
         integer :: nonsequential              ! true: 1, false: 0
         integer :: no_fixup                   ! true: 1, false: 0
     end type
     type(dsm2_node_t), allocatable :: dsm2_node(:)
     
               
     !> Define constituent
     type constituent_t
        integer :: conc_id                   ! constituent id
        character*16 :: name = ' '           ! constituent name
        logical :: conservative = .true.     ! true if conservative, false if nonconservative
     end type     
     type(constituent_t), allocatable :: constituents(:)

    
     contains

    
     !> Allocate channel_t array    
     subroutine allocate_channel_property()
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(chan_geom(n_chan), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         return
     end subroutine

     !> Allocate reservoir_t array    
     subroutine allocate_reservoir_property()
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(resv_geom(n_resv), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         return
     end subroutine

     !> Allocate qext_t array
     subroutine allocate_qext_property()
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(qext(n_qext), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         qext%qext_index = 0
         qext%name = ' '
         qext%attach_obj_name = ' '
         qext%attach_obj_type = 0
         qext%attach_obj_no = 0         
         return
     end subroutine

     !> Allocate comp_pt_t array
     subroutine allocate_comp_pt_property()
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(comp_pt(n_comp), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         !comp_pt%dsm2_node_no = LARGEINT
         return
     end subroutine

    
     !> Allocate segment_t array
     subroutine allocate_segment_property()
         use error_handling
         implicit none
         integer :: istat = 0
         integer :: n_segm_tmp               ! temporary number of segments
         character(len=128) :: message       ! error message
         n_segm_tmp = n_comp                 ! this should allow more space than n_comp-n_chan, final n_segm will be updated at assign_segment()
         allocate(segm(n_segm_tmp), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         return
     end subroutine


     !> Allocate conn_t array
     subroutine allocate_conn_property()
         use error_handling
         implicit none
         integer :: istat = 0
         integer :: n_conn_tmp               ! temporary number of connected cells
         character(len=128) :: message       ! error message
         n_conn_tmp = n_comp*2               ! this should allow more space, final n_conn will be updated at assign_segment()
         allocate(conn(n_conn_tmp), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         return
     end subroutine

     !> Allocate size for cell and dx array     
     subroutine allocate_cell_property()
         use error_handling
         implicit none
         integer :: istat = 0
         integer :: i, j, icell
         character(len=128) :: message
         n_cell = 0      
         do i = 1, n_segm               
             n_cell = n_cell + segm(i)%nx
         end do          
         allocate(dx_arr(n_cell), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if    
         icell = 0      
         do i = 1, n_segm
             do j = 1, segm(i)%nx
                 icell = icell + 1
                 dx_arr(icell) = segm(i)%length/segm(i)%nx
             end do                      
         end do         
         return
     end subroutine
    
     !> Allocate junctions and boudaries
     subroutine allocate_junc_bound_property()
         use error_handling
         implicit none
         integer :: istat = 0 
         character(len=128) :: message
         allocate(junc(n_junc), stat = istat)
         allocate(bound(n_boun), stat = istat)
         allocate(link(n_link), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if             
         return
     end subroutine

    
     !> Allocate hydro time series array
     subroutine allocate_hydro_ts()
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(hydro_flow(n_comp,memory_buffer), hydro_ws(n_comp,memory_buffer), stat = istat)
         allocate(hydro_resv_flow(n_resv_conn, memory_buffer), stat = istat)
         allocate(hydro_resv_height(n_resv, memory_buffer), stat = istat)
         allocate(hydro_qext(n_qext, memory_buffer), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         hydro_flow = LARGEREAL
         hydro_ws = LARGEREAL
         hydro_resv_flow = LARGEREAL
         hydro_resv_height = LARGEREAL
         hydro_qext = LARGEREAL
         return
     end subroutine    
    
     !> Allocate geometry property
     subroutine allocate_geometry()
         implicit none
         call allocate_channel_property         
         call allocate_reservoir_property
         call allocate_qext_property
         call allocate_comp_pt_property
         call allocate_segment_property
         call allocate_conn_property
         call allocate_junc_bound_property
         return
     end subroutine    

     !> Deallocate geometry property
     subroutine deallocate_geometry()
         implicit none
         call deallocate_channel
         call deallocate_dsm2_node_property
         call deallocate_reservoir
         call deallocate_qext
         call deallocate_comp_pt
         call deallocate_segment
         call deallocate_cell
         call deallocate_junc_bound_property
         return
     end subroutine


     !> Deallocate channel property
     subroutine deallocate_channel()
         implicit none
         n_chan = LARGEINT
         deallocate(chan_geom)
         return
     end subroutine


     !> Deallocate reservoir property
     subroutine deallocate_reservoir()
         implicit none
         n_resv = LARGEINT
         n_resv_conn = LARGEINT
         deallocate(resv_geom)
         return
     end subroutine

     !> Deallocate external flows property
     subroutine deallocate_qext()
         implicit none
         n_qext = LARGEINT
         deallocate(qext)
         return
     end subroutine     
      
     !> Deallocate computational point property
     subroutine deallocate_comp_pt()
         implicit none
         n_comp = LARGEINT
         deallocate(comp_pt)
         return
     end subroutine


     !> Deallocate segment property
     subroutine deallocate_segment()
         implicit none
         n_segm = LARGEINT
         deallocate(segm)
         return
     end subroutine


     !> Deallocate cell property
     subroutine deallocate_cell()
         implicit none
         n_cell = LARGEINT
         deallocate(dx_arr)
         return
     end subroutine


     !> Deallocate DSM2 node
     subroutine deallocate_dsm2_node_property()
         implicit none
         n_node = LARGEINT    
         deallocate(dsm2_node)
         return
     end subroutine

     !> Deallocate junctions and boudaries
     subroutine deallocate_junc_bound_property()
         implicit none
         if (n_boun .ne. LARGEINT) then
             n_boun = LARGEINT
             deallocate(bound)
         end if
         if (n_conn .ne. LARGEINT) then    
             n_conn = LARGEINT
             deallocate(conn)
         end if    
         !n_junc = LARGEINT
         !n_link = LARGEINT         
         !deallocate(junc)         
         !deallocate(link)             
         return
     end subroutine

           
     !> Deallocate hydro time series array
     subroutine deallocate_hydro_ts()
         implicit none
         deallocate(hydro_flow, hydro_ws)
         deallocate(hydro_resv_flow)
         deallocate(hydro_resv_height)
         deallocate(hydro_qext)
         return
     end subroutine


     !> Assign numbers to segment array and connected cell array
     !> This updates common variables: n_segm, n_conn, segm, and conn.
     subroutine assign_segment()
         implicit none
         integer :: i, j, k, previous_chan_no
         call allocate_segment_property()
         call allocate_conn_property()
         segm(1)%segm_no = 1
         segm(1)%chan_no = 1
         segm(1)%up_comppt = 1
         segm(1)%down_comppt = 2
         segm(1)%up_distance = 0
         segm(1)%down_distance = comp_pt(2)%distance
         segm(1)%length = segm(1)%down_distance - segm(1)%up_distance
         segm(1)%nx = max( floor(segm(1)%length/gtm_dx), 1)
         segm(1)%start_cell_no = 1
         previous_chan_no = 1
         conn(1)%conn_no = 1
         conn(1)%segm_no = 1
         conn(1)%cell_no = 1      
         conn(1)%comp_pt = 1
         conn(1)%chan_no = segm(1)%chan_no
         conn(1)%dsm2_node_no = chan_geom(segm(1)%chan_no)%up_node
         conn(1)%conn_up_down = 1
         
         j = 1
         k = 1
         do i = 3, n_comp
             if (comp_pt(i)%chan_no .eq. previous_chan_no) then
                 j = j + 1
                 segm(j)%segm_no = j
                 segm(j)%chan_no = comp_pt(i)%chan_no
                 segm(j)%up_comppt = comp_pt(i-1)%comp_index
                 segm(j)%down_comppt = comp_pt(i)%comp_index
                 segm(j)%up_distance = comp_pt(i-1)%distance
                 segm(j)%down_distance = comp_pt(i)%distance
                 segm(j)%length = comp_pt(i)%distance - comp_pt(i-1)%distance
                 segm(j)%nx = max( floor(segm(j)%length/gtm_dx), 1)
                 segm(j)%start_cell_no = segm(j-1)%start_cell_no + segm(j-1)%nx
             else
                 previous_chan_no = comp_pt(i)%chan_no
                 k = k + 1
                 conn(k)%conn_no = k
                 conn(k)%segm_no = j
                 conn(k)%cell_no = segm(j)%start_cell_no + segm(j)%nx - 1
                 conn(k)%comp_pt = i - 1
                 conn(k)%chan_no = comp_pt(i-1)%chan_no
                 conn(k)%dsm2_node_no = chan_geom(comp_pt(i-1)%chan_no)%down_node
                 conn(k)%conn_up_down = 0              
                 k = k + 1
                 conn(k)%conn_no = k
                 conn(k)%segm_no = j + 1
                 conn(k)%cell_no = segm(j)%start_cell_no + segm(j)%nx
                 conn(k)%comp_pt = i
                 conn(k)%chan_no = comp_pt(i)%chan_no
                 conn(k)%dsm2_node_no = chan_geom(comp_pt(i)%chan_no)%up_node
                 conn(k)%conn_up_down = 1              
             end if
         end do     
         n_segm = j
         n_conn = k + 1
         conn(n_conn)%conn_no = n_conn
         conn(n_conn)%segm_no = n_segm
         conn(n_conn)%cell_no = segm(n_segm)%start_cell_no + segm(n_segm)%nx - 1
         conn(n_conn)%comp_pt = n_comp
         conn(n_conn)%chan_no = comp_pt(n_comp)%chan_no
         conn(n_conn)%dsm2_node_no = chan_geom(comp_pt(n_comp)%chan_no)%down_node
         conn(n_conn)%conn_up_down = 0         
         return    
     end subroutine    


     !> Assign up_comp_pt and down_comp_pt to channel_t
     subroutine assign_chan_comppt()
         implicit none
         integer :: i, j   ! local variables
         j = 0
         do i = 1, n_comp-1
             if (comp_pt(i)%distance==0) then
                 j = j + 1
                 chan_geom(j)%up_comp = i
                 if (j > 1) then
                     chan_geom(j-1)%down_comp = i-1
                 end if        
             end if
         end do
         chan_geom(j)%down_comp = n_comp 
         return
     end subroutine

   
     !> Obtain info for DSM2 nodes 
     !> This will count occurence of nodes in channel table. If count>2, a junction; if count==1, a boundary.
     !> This updates common variables: n_junc, n_boun, junc, and bound.
     subroutine get_dsm2_node_info0()
         implicit none
         integer, dimension(:), allocatable :: nodes
         integer, dimension(:), allocatable :: sorted_nodes
         integer, dimension(:), allocatable :: unique_num
         integer, dimension(:), allocatable :: occurrence
         integer :: num_nodes
         integer :: n, i, j, k
         integer :: nj, nb, nl
         n = size(chan_geom%up_node)
         allocate(nodes(n+n))
         allocate(sorted_nodes(n+n))
         nodes(1:n) = chan_geom%up_node
         nodes(n+1:n+n) = chan_geom%down_node
         call sort_arr(sorted_nodes, nodes, n+n)
         call unique_num_count(unique_num, occurrence, num_nodes, sorted_nodes, n+n)
         n_junc = 0
         n_boun = 0
         n_link = 0
         do i = 1, num_nodes
             if (occurrence(i)>2) n_junc = n_junc + 1
             if (occurrence(i)==1) n_boun = n_boun + 1
             if (occurrence(i)==2) n_link = n_link + 1
         end do
         call allocate_junc_bound_property()
         nj = 0
         nb = 0
         nl = 0
         do i = 1, num_nodes
             if (occurrence(i)>2) then
                 nj = nj + 1
                 junc(nj)%dsm2_node_no = unique_num(i)
                 junc(nj)%n_conn_cells = occurrence(i)                
                 allocate(junc(nj)%cell_no(occurrence(i)))
                 allocate(junc(nj)%up_down(occurrence(i)))
                 k = 0
                 do j = 1, n_conn
                     if (conn(j)%dsm2_node_no==unique_num(i)) then
                         k = k + 1
                         junc(nj)%cell_no(k) = conn(j)%cell_no
                         junc(nj)%up_down(k) = conn(j)%conn_up_down
                     end if
                 end do
             end if                 
             if (occurrence(i)==1) then
                 nb = nb + 1
                 do j = 1, n_conn
                     if (conn(j)%dsm2_node_no==unique_num(i)) then
                         bound(nb)%dsm2_node_no = unique_num(i)
                         bound(nb)%cell_no = conn(j)%cell_no
                         bound(nb)%up_down = conn(j)%conn_up_down
                     end if    
                 end do    
             end if
             if (occurrence(i)==2) then
                 nl = nl + 1
                 link(nl)%dsm2_node_no = unique_num(i)
                 k = 0
                 do j = 1, n_conn
                     if (conn(j)%dsm2_node_no==unique_num(i)) then
                         k = k + 1
                         link(nl)%cell_no(k) = conn(j)%cell_no
                         link(nl)%up_down(k) = conn(j)%conn_up_down
                     end if
                 end do
             end if
         end do
         return
     end subroutine

     !> Obtain info for DSM2 nodes 
     !> This will count occurence of nodes in channel table. If count>2, a junction; if count==1, a boundary.
     !> This updates common variables: n_junc, n_boun, junc, and bound.
     subroutine get_dsm2_node_info(n_connection)
         implicit none
         integer, intent(in) :: n_connection
         integer :: sorted_conns(n_connection)
         integer, dimension(:), allocatable :: unique_num
         integer, dimension(:), allocatable :: occurrence
         integer :: num_nodes
         integer :: i, j, k
         integer :: nj, nb, nl
          
         call sort_arr(sorted_conns, conn(:)%dsm2_node_no, n_connection)
         call unique_num_count(unique_num, occurrence, num_nodes, sorted_conns, n_connection)
         n_node = num_nodes
         allocate(dsm2_node(num_nodes))
         dsm2_node(:)%n_conn_cell = 0 
         dsm2_node(:)%boundary_no = 0 
         dsm2_node(:)%junction_no = 0
         dsm2_node(:)%reservoir_no = 0
         dsm2_node(:)%n_qext = 0
         dsm2_node(:)%nonsequential = 0         
         dsm2_node(:)%no_fixup = 0
         n_junc = 0
         n_boun = 0
         n_link = 0
         do i = 1, num_nodes
             dsm2_node(i)%dsm2_node_no = unique_num(i)
             if (occurrence(i)==1) then 
                 allocate(dsm2_node(i)%cell_no(1))
                 allocate(dsm2_node(i)%up_down(1))   
                 n_boun = n_boun + 1
                 dsm2_node(i)%boundary_no = n_boun
                 dsm2_node(i)%n_conn_cell = 1
                 do j = 1, n_conn
                     if (unique_num(i) .eq. conn(j)%dsm2_node_no) then
                        dsm2_node(i)%cell_no(1) = conn(j)%cell_no
                        dsm2_node(i)%up_down(1) = conn(j)%conn_up_down
                     end if
                 end do
             elseif (occurrence(i)==2) then
                 allocate(dsm2_node(i)%cell_no(2))
                 allocate(dsm2_node(i)%up_down(2))
                 dsm2_node(i)%n_conn_cell = 2
                 nj = 0
                 do j = 1, n_conn
                     if (unique_num(i) .eq. conn(j)%dsm2_node_no) then
                         nj = nj + 1
                         dsm2_node(i)%cell_no(nj) = conn(j)%cell_no
                         dsm2_node(i)%up_down(nj) = conn(j)%conn_up_down
                     end if
                 end do
                 if ( abs(dsm2_node(i)%cell_no(1)-dsm2_node(i)%cell_no(2)) > 1) then
                     dsm2_node(i)%nonsequential = 1
                 end if
             elseif (occurrence(i)>2) then 
                 allocate(dsm2_node(i)%cell_no(occurrence(i)))
                 allocate(dsm2_node(i)%up_down(occurrence(i)))             
                 n_junc = n_junc + 1
                 dsm2_node(i)%junction_no = n_junc
                 dsm2_node(i)%n_conn_cell = occurrence(i)
                 nj = 0
                 do j = 1, n_conn
                     if (unique_num(i) .eq. conn(j)%dsm2_node_no) then
                         nj = nj + 1
                         dsm2_node(i)%cell_no(nj) = conn(j)%cell_no
                         dsm2_node(i)%up_down(nj) = conn(j)%conn_up_down
                     end if
                 end do
             end if
         end do   
         return
     end subroutine


     !> Look up cell info around nodes connected to reservoir
     subroutine lookup_resv_cells()
         implicit none
         integer :: i, j, k, l, count1, count2, count0
         count0 = 0
         count1 = 0
         allocate(resv_conn(n_conn)) ! this is the upper limit of the connections, for simplicity.
         do i = 1, n_resv
             do j = 1, resv_geom(i)%n_res_conn
                 count2 = 0
                 count0 = count1 + 1
                 do k = 1, n_conn                     
                     if (conn(k)%dsm2_node_no==resv_geom(i)%ext_node_no(j)) then
                         count1 = count1 + 1
                         count2 = count2 + 1
                         resv_conn(count1)%resv_no = resv_geom(i)%resv_index
                         resv_conn(count1)%n_res_conn = resv_geom(i)%n_res_conn
                         resv_conn(count1)%dsm2_node_no = conn(k)%dsm2_node_no
                         resv_conn(count1)%conn_cell = conn(k)%cell_no
                         resv_conn(count1)%up_down = conn(k)%conn_up_down
                     end if
                 end do
                 do l = count0, count1
                     resv_conn(l)%n_conn_cells = count2
                 end do
             end do
         end do
         return
     end subroutine
      

     !> Define common variables for single channel case
     subroutine set_up_single_channel(bound_val, ncell, nvar)
         implicit none
         integer, intent(in) :: ncell
         integer, intent(in) :: nvar
         real(gtm_real), intent(out) :: bound_val(2,nvar)
         n_boun = 2
         n_junc = 0
         call allocate_junc_bound_property()
         bound(1)%cell_no = 1
         bound(2)%cell_no = ncell
         bound(1)%up_down = 1
         bound(2)%up_down = 0
         bound_val = LARGEREAL
         return
     end subroutine    


     !> Routine to obtain unique number of an array
     subroutine unique_num_count(unique_num, occurrence, num_nodes, in_arr, n)
         implicit none
         integer, dimension(:), allocatable, intent(out) :: unique_num    !< node number
         integer, dimension(:), allocatable, intent(out) :: occurrence    !< occurrence of each nodes
         integer, intent(out) :: num_nodes                                !< number of DSM2 nodes
         integer, dimension(n), intent(in)  :: in_arr                     !< input array (up_node + down_node)
         integer, intent(in) :: n                             !< input array dimension
         integer, dimension(n) :: unique_num_tmp              !< local variables
         integer, dimension(n) :: occurrence_tmp              !< local variables
         integer :: i, j, prev_num                            !< local variables
         unique_num_tmp = LARGEINT
         occurrence_tmp = 0
         unique_num_tmp(1) = in_arr(1)
         occurrence_tmp(1) = 1
         prev_num = in_arr(1)
         j = 1
         do i = 2, n
             if (in_arr(i).ne.prev_num) then
                 j = j + 1
                 unique_num_tmp(j) = in_arr(i)
                 occurrence_tmp(j) = 1
                 prev_num = in_arr(i)
             else
                 occurrence_tmp(j) = occurrence_tmp(j) + 1
             end if
         end do
         num_nodes = j
         allocate(unique_num(num_nodes))
         allocate(occurrence(num_nodes))
         unique_num = unique_num_tmp(1:num_nodes)
         occurrence = occurrence_tmp(1:num_nodes)
         return
     end subroutine

        
     !> Routine to sort an array with dimension n
     subroutine sort_arr(sorted_arr, arr, n)
         implicit none
         integer, intent(in) :: n                           !< array dimension
         integer, dimension(n), intent(in) :: arr           !< input array
         integer, dimension(n), intent(out) :: sorted_arr   !< output sorted array
         integer :: a, i, j
         sorted_arr = arr
         do j = 2, n
             a = sorted_arr(j)
             do i = j-1, 1, -1
                 if (sorted_arr(i)<=a) goto 10
                 sorted_arr(i+1) = sorted_arr(i)
             end do
	         i = 0
10           sorted_arr(i+1) = a
         end do
         return
     end subroutine
    
end module
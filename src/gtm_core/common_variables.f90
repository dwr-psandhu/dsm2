!<license>
!    Copyright (C) 2015 State of California,
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
     use gtm_logging
     
     integer :: memory_buffer = 20                  !< time buffer use to store hdf5 time series
     integer :: n_comp = LARGEINT                   !< number of computational points
     integer :: n_chan = LARGEINT                   !< number of channels
     integer :: n_segm = LARGEINT                   !< number of segments
     integer :: n_conn = LARGEINT                   !< number of connected cells
     integer :: n_boun = LARGEINT                   !< number of boundaries
     integer :: n_junc = LARGEINT                   !< number of junctions
     integer :: n_node = LARGEINT                   !< number of DSM2 nodes
     integer :: n_xsect = LARGEINT                  !< number of entries in virt xsect table
     integer :: n_resv = LARGEINT                   !< number of reservoirs
     integer :: n_resv_conn = LARGEINT              !< number of reservoir connects
     integer :: n_qext = LARGEINT                   !< number of external flows
     integer :: n_tran = LARGEINT                   !< number of transfer flows
     integer :: n_gate = LARGEINT                   !< number of gates
     integer :: n_flwbnd = LARGEINT                  !< number of boundary flow
     integer :: n_stgbnd = LARGEINT                 !< number of boundary stage
     integer :: n_sflow = LARGEINT                  !< number of source flow
     integer :: n_bfbs = LARGEINT                   !< number of boundary flows and stage
     integer :: n_cell = LARGEINT                   !< number of cells in the entire network
     integer :: n_var = LARGEINT                    !< number of variables
    
     real(gtm_real), allocatable :: dx_arr(:)              !< dx array
     real(gtm_real), allocatable :: disp_arr(:)            !< dispersion coeff
     real(gtm_real), allocatable :: hydro_flow(:,:)        !< flow from DSM2 hydro
     real(gtm_real), allocatable :: hydro_ws(:,:)          !< water surface from DSM2 hydro
     real(gtm_real), allocatable :: hydro_area(:,:)        !< calculated cross section area from CxArea
     real(gtm_real), allocatable :: hydro_resv_flow(:,:)   !< reservoir flow
     real(gtm_real), allocatable :: hydro_resv_height(:,:) !< reservoir height
     real(gtm_real), allocatable :: hydro_qext_flow(:,:)   !< external flows
     real(gtm_real), allocatable :: hydro_tran_flow(:,:)   !< transfer flows

     !> Define scalar and envvar in input file 
     real(gtm_real) :: no_flow = ten                   !< define a criteria for the definition of no flow to avoid the problem in calculating average concentration
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
     logical :: debug_print = .true.
     logical :: apply_diffusion = .false. 
     real(gtm_real) :: disp_coeff = LARGEREAL          !< constant dispersion coefficient (using this one will overwrite those from hydro tidefile)
     
     type gtm_io_files_t
          character(len=130) :: filename               !< filename
          character(len=16) :: interval                !< I/O time interval
     end type
     type(gtm_io_files_t) :: gtm_io(3,2)               !< (col#1) 1:restart, 2:echo, 3:hdf, 4:output
                                                       !< (col#2) 1:in, 2:out 
     !> IO_units
     integer, parameter :: unit_error = 0              !< error messages
     integer, parameter :: unit_input = 11             !< input unit
     integer, parameter :: unit_screen = 6             !< output unit to screen (MUST be 6)
     integer, parameter :: unit_output = 14            !< output file
     integer, parameter :: unit_text = 13              !< temporary (scratch) text file output
       
     !> Define channel type to store channel related arrays
     type channel_t                                    !< channel between hydro nodes
          integer :: channel_num                       !< actual channel number in DSM2 grid
          integer :: chan_no                           !< index channel number
          integer :: channel_length                    !< channel length
          integer :: up_node                           !< upstream DSM2 node
          integer :: down_node                         !< downstream DSM2 node
          integer :: up_comp                           !< upstream computational point
          integer :: down_comp                         !< downstream computational point
          real(gtm_real) :: dispersion                 !< dispersion coefficient
     end type
     type(channel_t), allocatable :: chan_geom(:)
     
     !> Define computational point type to store computational point related arrays   
     type comp_pt_t                                    !< computational points
          integer :: comp_index                        !< computational point index
          integer :: chan_no                           !< channel number
          real(gtm_real) :: distance                   !< distance from upstream node
     end type
     type(comp_pt_t), allocatable :: comp_pt(:)
    
     !> Define segment type to store segment related arrays
     type segment_t                                   !< segment between computational points
          integer :: segm_no                          !< segment serial no
          integer :: chan_no                          !< channel no
          integer :: up_comppt                        !< upstream computational point (used as index to search time series data)        
          integer :: down_comppt                      !< downstream computational point
          integer :: nx                               !< number of cells in a segment
          integer :: start_cell_no                    !< start cell number (for keeping track of icell)          
          real(gtm_real) :: up_distance               !< up_comppt distance from upstream node
          real(gtm_real) :: down_distance             !< down_comppt distance from upstream node
          real(gtm_real) :: length                    !< segment length in feet
     end type
     type(segment_t), allocatable :: segm(:)    
    
     !> Define connected cells 
     type conn_t
          integer :: conn_no                          !< serial number for cell connected to DSM2 nodes
          integer :: segm_no                          !< segment serial number
          integer :: cell_no                          !< cell serial number
          integer :: comp_pt                          !< connected computational point
          integer :: chan_no                          !< channel number
          integer :: chan_num                         !< DSM2 channel number
          integer :: dsm2_node_no                     !< connected DSM2 node number
          integer :: conn_up_down                     !< the connected node is upstream (1) or downstream (0),
                                                      !< or think of (1): away from conn, (0): to conn
     end type
     type(conn_t), allocatable :: conn(:)
    
     !> Define cells
     type cell_t
         integer :: cell_id                           !< cell id
         integer :: up_cell                           !< upstream connected cell id (-1 for boundary, 0 for junction)
         integer :: down_cell                         !< downstream connected cell id (-1 for boundary, 0 for junction)
         real(gtm_real) :: dx                         !< cell length
     end type
     type(cell_t), allocatable :: cell(:)

     !> Define reservoirs
     type reservoir_t
        integer ::       resv_no                     !< reservoir no
        character*32 ::   name = ' '                 !< reservoir name
        real(gtm_real) :: area = 0.d0                !< average top area
        real(gtm_real) :: bot_elev = 0.d0            !< bottom elevation wrt datum
        integer :: n_resv_conn = LARGEINT            !< number of nodes connected using reservoir connections
        integer, allocatable :: resv_conn_no(:)      !< reservoir connection no
        integer, allocatable :: int_node_no(:)       !< DSM2 internal node number
        integer, allocatable :: ext_node_no(:)       !< DSM2 grid node number
        integer, allocatable :: network_id(:)        !< DSM2 network internal id (slightly different to DSM2-Hydro internal id)
        integer, allocatable :: is_gated(:)          !< 1: if a node is gated, 0: otherwise
     end type
     type(reservoir_t), allocatable :: resv_geom(:)
     
     
     !> Define external flows
     type qext_t
         integer :: qext_no                          !< qext index
         character*32 :: name                        !< qext name
         integer :: attach_obj_name                  !< attached obj name
         integer :: attach_obj_type                  !< attached obj type (2:node, 3:reservoir)
         integer :: attach_obj_no                    !< attached obj no (internal number)
     end type
     type(qext_t), allocatable :: qext(:)
     
     
     !> Define reservoir connections
     type reservoir_conn_t
         integer :: resv_conn_no                    !< reservoir connection number
         integer :: resv_no                         !< reservoir number
         integer :: n_res_conn                      !< number of connected nodes
         integer :: dsm2_node_no                    !< DSM2 node number
         integer :: n_conn_cells                    !< number of connected cells
         integer :: conn_cell                       !< connected cells
         integer :: up_down                         !< flow toward node (0) or away from node (1)
     end type
     type(reservoir_conn_t), allocatable :: resv_conn(:)
     
     !> Define transfer flows
     type transfer_flow_t
         integer :: tran_no                          !< transfer flow number
         character*32 :: name                        !< transfer name
         integer :: from_obj                         !< from obj (2: node, 3: reservoir)
         integer :: from_identifier                  !< from identifier         
         integer :: to_obj                           !< to obj (2: node, 3: reservoir)
         integer :: to_identifier                    !< to identifier 
     end type
     type(transfer_flow_t), allocatable :: tran(:)
     
     !> Define gate
     type gate_t
         integer :: gate_no                          !< transfer flow number
         character*32 :: name                        !< transfer name
         character*32 :: from_identifier             !< from identifier         
         integer :: to_node                          !< to node
         integer :: to_node_int                      !< to node internal number
         integer :: from_obj_int                     !< from_obj to integer, 1: channel, 2: reservoir
         integer :: from_identifier_int              !< from_identifier to its id
         integer :: cell_no                          !< cell_no
         integer :: face                             !< 1: lo face, 0: hi face
     end type
     type(gate_t), allocatable :: gate(:)
     
     !> Define boundary flow and boundary stage
     type bfbs_t
         character*32 :: btype                       !< boundary type: "flow", "stage"
         character*32 :: name                        !< name
         integer :: node                             !< node number
         integer :: i_node                           !< internal node number
     end type    
     type(bfbs_t), allocatable :: bfbs(:)
     
     !> Define source flow
     type source_flow_t
         character*32 :: name                        !< name
         integer :: node                             !< node number
     end type    
     type(source_flow_t), allocatable :: source_flow(:)
                    
     !> DSM2 Node information
     type dsm2_network_t
         integer :: dsm2_node_no                   !< DSM2 node number
         integer :: n_conn_cell                    !< number of cells connected
         integer, allocatable :: cell_no(:)        !< cell number
         integer, allocatable :: up_down(:)        !< flow toward node (0) or away from node (1) from DSM2 base grid definition
         integer, allocatable :: chan_num(:)       !< DSM2 channel number
         integer, allocatable :: gate(:)           !< presence of gate (true:1, false:0)
         integer :: boundary_no                    !< boundary serial number (exist if not 0)
         integer :: junction_no                    !< junction serial number (exist if not 0)
         integer :: nonsequential                  !< true: 1, false: 0
         integer :: node_conc                      !< true: 1, false: 0
     end type
     type(dsm2_network_t), allocatable :: dsm2_network(:)
     
     type dsm2_network_extra_t
         integer :: dsm2_node_no                   !< DSM2 node number    
         integer :: reservoir_no                   !< connected to reservoir no (exist if not 0)
         integer :: resv_conn_no                   !< reservoir conection number (exist if not 0)
         integer :: n_qext                         !< number of external flows (exist if not 0)
         integer, allocatable :: qext_no(:)        !< connected qext number
         integer, allocatable :: qext_path(:,:)    !< node concentration input path (exist if not 0)
         integer :: n_tran                         !< number of transfer flows (exist if not 0)
         integer, allocatable :: tran_no(:)        !< connected tran number
         integer :: boundary                       !< 1: boundary flow, 2: boundary stage
     end type
     type(dsm2_network_extra_t), allocatable :: dsm2_network_extra(:)    
       
     !> Define constituent
     type constituent_t
         integer :: conc_no                        !< constituent id
         character*16 :: name = ' '                !< constituent name
         logical :: conservative = .true.          !< true if conservative, false if nonconservative
     end type     
     type(constituent_t), allocatable :: constituents(:)
    
     contains

     !> Allocate geometry property
     subroutine allocate_geometry()
         implicit none
         if (n_chan .ne. LARGEINT) call allocate_channel_property      
         if (n_comp .ne. LARGEINT) call allocate_comp_pt_property
         if (n_comp .ne. LARGEINT) call assign_segment
         if (n_resv .ne. LARGEINT) call allocate_reservoir_property
         if (n_qext .ne. LARGEINT) call allocate_qext_property     
         if (n_tran .ne. LARGEINT) call allocate_tran_property
         if (n_gate .ne. LARGEINT) call allocate_gate_property
         if (n_bfbs .ne. LARGEINT) call allocate_bfbs_property
         if (n_gate .ne. LARGEINT) call allocate_gate_property
         if (n_sflow .ne. LARGEINT) call allocate_source_flow_property
         if (n_node .ne. LARGEINT) call get_dsm2_network_info    
         return
     end subroutine    

     !> Deallocate geometry property
     subroutine deallocate_geometry()
         implicit none
         if (n_chan .ne. LARGEINT) call deallocate_channel_property
         if (n_comp .ne. LARGEINT) call deallocate_comp_pt_property
         if (n_segm .ne. LARGEINT) call deallocate_segment_property
         if (n_resv .ne. LARGEINT) call deallocate_reservoir_property
         if (n_qext .ne. LARGEINT) call deallocate_qext_property  
         if (n_tran .ne. LARGEINT) call deallocate_tran_property 
         if (n_gate .ne. LARGEINT) call deallocate_gate_property  
         if (n_bfbs .ne. LARGEINT) call deallocate_bfbs_property
         if (n_sflow .ne. LARGEINT) call deallocate_source_flow_property          
         if (n_node .ne. LARGEINT) call deallocate_dsm2_network_property              
         return
     end subroutine
         
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
         allocate(disp_arr(n_cell), stat = istat)
         allocate(cell(n_cell), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if    
         icell = 0      
         do i = 1, n_segm
             do j = 1, segm(i)%nx
                 icell = icell + 1
                 dx_arr(icell) = segm(i)%length/segm(i)%nx
                 disp_arr(icell) = chan_geom(segm(i)%chan_no)%dispersion
             end do                      
         end do         
         return
     end subroutine
   
     !> Allocate reservoir_t array    
     subroutine allocate_reservoir_property()
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(resv_geom(n_resv), stat = istat)
         allocate(resv_conn(n_resv_conn), stat = istat)
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
         qext%qext_no = 0
         qext%name = '   '
         qext%attach_obj_name = '   '
         qext%attach_obj_type = 0
         qext%attach_obj_no = 0         
         return
     end subroutine

     !> Allocate transfer_t array
     subroutine allocate_tran_property()
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(tran(n_tran), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         tran%tran_no = 0
         tran%name = ' '
         tran%from_obj = 0
         tran%from_identifier = 0
         tran%to_obj = 0
         tran%to_identifier = 0
         return
     end subroutine     

     !> Allocate gate_t array    
     subroutine allocate_gate_property()
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(gate(n_gate), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         gate%gate_no = 0                     
         gate%name = '    '
         gate%from_identifier = '    '
         gate%to_node = 0
         gate%to_node_int = 0
         return
     end subroutine
     
     ! Allocate bfbs_t array
     subroutine allocate_bfbs_property
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(bfbs(n_bfbs), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         bfbs%btype = ''   
         bfbs%name = ''
         bfbs%node = 0
         bfbs%i_node = 0
         return
     end subroutine

     ! Allocate source_flow_t array
     subroutine allocate_source_flow_property
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(source_flow(n_sflow), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         source_flow%name = ''
         source_flow%node = 0
         return
     end subroutine
    
     !> Allocate hydro time series array
     subroutine allocate_hydro_ts()
         use error_handling
         implicit none
         integer :: istat = 0
         character(len=128) :: message
         allocate(hydro_flow(n_comp,memory_buffer), stat = istat)
         allocate(hydro_ws(n_comp,memory_buffer), stat = istat)
         allocate(hydro_area(n_comp,memory_buffer), stat = istat)
         allocate(hydro_resv_flow(n_resv_conn, memory_buffer), stat = istat)
         allocate(hydro_resv_height(n_resv, memory_buffer), stat = istat)
         allocate(hydro_qext_flow(n_qext, memory_buffer), stat = istat)
         allocate(hydro_tran_flow(n_tran, memory_buffer), stat = istat)
         if (istat .ne. 0 )then
            call gtm_fatal(message)
         end if
         hydro_flow = LARGEREAL
         hydro_ws = LARGEREAL
         hydro_area = LARGEREAL
         hydro_resv_flow = LARGEREAL
         hydro_resv_height = LARGEREAL
         hydro_qext_flow = LARGEREAL
         hydro_tran_flow = LARGEREAL
         return
     end subroutine    
 

     !> Deallocate channel property
     subroutine deallocate_channel_property()
         implicit none
         if (n_chan .ne. LARGEINT) then
             deallocate(chan_geom)
             n_chan = LARGEINT
         end if
         return
     end subroutine


     !> Deallocate reservoir property
     subroutine deallocate_reservoir_property()
         implicit none
         if (n_resv .ne. LARGEINT) then
             n_resv = LARGEINT
             n_resv_conn = LARGEINT
             deallocate(resv_geom)
             deallocate(resv_conn)
         end if    
         return
     end subroutine

     !> Deallocate external flows property
     subroutine deallocate_qext_property()
         implicit none
         if (n_qext .ne. LARGEINT) then
             n_qext = LARGEINT
             deallocate(qext)
         end if    
         return
     end subroutine     

     !> Deallocate transfer flows property
     subroutine deallocate_tran_property()
         implicit none
         if (n_tran .ne. LARGEINT) then
             n_tran = LARGEINT
             deallocate(tran)
         end if    
         return
     end subroutine   
           
     !> Deallocate computational point property
     subroutine deallocate_comp_pt_property()
         implicit none
         if (n_comp .ne. LARGEINT) then
             n_comp = LARGEINT
             deallocate(comp_pt)
         end if    
         return
     end subroutine

     !> Deallocate source flow property
     subroutine deallocate_source_flow_property()
         implicit none
         if (n_sflow .ne. LARGEINT) then
             n_sflow = LARGEINT
             deallocate(source_flow)
         end if    
         return
     end subroutine
     
     !> Deallocate gate property
     subroutine deallocate_gate_property()
         implicit none
         if (n_gate .ne. LARGEINT) then
             deallocate(gate)
             n_gate = LARGEINT
         end if
         return
     end subroutine

     !> Deallocate bfbs property
     subroutine deallocate_bfbs_property()
         implicit none
         if (n_bfbs .ne. LARGEINT) then
             deallocate(bfbs)
             n_bfbs = LARGEINT
         end if
         return
     end subroutine
     
     !> Deallocate segment property
     subroutine deallocate_segment_property()
         implicit none
         if (n_segm .ne. LARGEINT) then
             n_segm = LARGEINT
             n_conn = LARGEINT
             n_cell = LARGEINT
             deallocate(segm)
             deallocate(conn)
             deallocate(dx_arr)
             deallocate(disp_arr)
             deallocate(cell)
         end if    
         return
     end subroutine


     !> Deallocate DSM2 node
     subroutine deallocate_dsm2_network_property()
         implicit none
         if (n_node .ne. LARGEINT) then 
             n_node = LARGEINT    
             deallocate(dsm2_network)
             deallocate(dsm2_network_extra)
         end if    
         return
     end subroutine
           
     !> Deallocate hydro time series array
     subroutine deallocate_hydro_ts()
         implicit none
         if (n_comp .ne. LARGEINT) deallocate(hydro_flow, hydro_ws, hydro_area)
         if (n_resv_conn .ne. LARGEINT) deallocate(hydro_resv_flow)
         if (n_resv .ne. LARGEINT) deallocate(hydro_resv_height)
         if (n_qext .ne. LARGEINT) deallocate(hydro_qext_flow)
         if (n_tran .ne. LARGEINT) deallocate(hydro_tran_flow)
         return
     end subroutine


     !> Assign numbers to segment array and connected cell array
     !> This updates common variables: n_segm, n_conn, segm, and conn.
     subroutine assign_segment()         
         implicit none         
         integer :: i, j, k, m, previous_chan_no
         integer :: up_bound, down_bound     
         integer :: num_segm    
         call allocate_segment_property()
         call allocate_conn_property()
         ! to make sure cell #1 and cell #ncell are actual boundaries. 
         do i = 1, n_chan
             up_bound = 1
             do j = 1, n_chan
                 if (chan_geom(i)%up_node .eq. chan_geom(j)%down_node) then
                     up_bound = 0
                     exit
                 end if
             end do
             if (up_bound .eq. 1) then
                 up_bound = i
                 exit
             end if
         end do
         ! write this loop again. The reason for this is trying to assign the cell#1 
         ! to the smallest channel number. 
         do i = 1, n_chan
             down_bound = 1
             do j = 1, n_chan
                 if (chan_geom(i)%down_node .eq. chan_geom(j)%up_node) then
                     down_bound = 0
                     exit
                 end if
             end do
             if (down_bound .eq. 1) then
                 down_bound = i
                 exit
             end if
         end do             
         ! assign the segment properties                  
         num_segm = chan_geom(up_bound)%down_comp - chan_geom(up_bound)%up_comp
         do i = 1, num_segm
             segm(i)%segm_no = i
             segm(i)%chan_no = up_bound         
             segm(i)%up_comppt = chan_geom(up_bound)%up_comp + i - 1
             segm(i)%down_comppt = segm(i)%up_comppt + 1
             segm(i)%up_distance = comp_pt(segm(i)%up_comppt)%distance
             segm(i)%down_distance = comp_pt(segm(i)%down_comppt)%distance
             segm(i)%length = segm(i)%down_distance - segm(i)%up_distance
             segm(i)%nx = max( floor(segm(i)%length/gtm_dx), 1)
             if (segm(i)%nx .eq. 1)  segm(i)%nx = 2
             segm(i)%start_cell_no = (i-1)*segm(i)%nx + 1
         end do    
         conn(1)%conn_no = 1
         conn(1)%segm_no = 1
         conn(1)%cell_no = 1      
         conn(1)%comp_pt = chan_geom(up_bound)%up_comp
         conn(1)%chan_no = segm(1)%chan_no
         conn(1)%chan_num = chan_geom(up_bound)%channel_num
         conn(1)%dsm2_node_no = chan_geom(segm(1)%chan_no)%up_node
         conn(1)%conn_up_down = 1         
         conn(2)%conn_no = 2
         conn(2)%segm_no = num_segm
         conn(2)%cell_no = segm(num_segm)%start_cell_no + segm(num_segm)%nx - 1
         conn(2)%comp_pt = chan_geom(up_bound)%down_comp
         conn(2)%chan_num = chan_geom(up_bound)%channel_num
         conn(2)%chan_no = segm(num_segm)%chan_no
         conn(2)%dsm2_node_no = chan_geom(up_bound)%down_node
         conn(2)%conn_up_down = 0           
         k = num_segm
         m = 2
         do i = 1, n_chan
             if (chan_geom(i)%chan_no.ne.up_bound .and. chan_geom(i)%chan_no.ne.down_bound) then
                 num_segm = chan_geom(i)%down_comp - chan_geom(i)%up_comp
                 do j = 1, num_segm
                     k = k + 1
                     segm(k)%segm_no = k
                     segm(k)%chan_no = chan_geom(i)%chan_no
                     segm(k)%up_comppt = chan_geom(i)%up_comp + j - 1
                     segm(k)%down_comppt = segm(k)%up_comppt + 1
                     segm(k)%up_distance = comp_pt(segm(k)%up_comppt)%distance
                     segm(k)%down_distance = comp_pt(segm(k)%down_comppt)%distance
                     segm(k)%length = segm(k)%down_distance - segm(k)%up_distance
                     segm(k)%nx = max( floor(segm(k)%length/gtm_dx), 1)
                     if (segm(k)%nx .eq. 1)  segm(k)%nx = 2
                     segm(k)%start_cell_no = segm(k-1)%start_cell_no + segm(k-1)%nx
                 end do    
                 m = m + 1
                 conn(m)%conn_no = m
                 conn(m)%segm_no = k - num_segm + 1
                 conn(m)%cell_no = segm(conn(m)%segm_no)%start_cell_no      
                 conn(m)%comp_pt = chan_geom(i)%up_comp
                 conn(m)%chan_no = chan_geom(i)%chan_no
                 conn(m)%chan_num = chan_geom(i)%channel_num
                 conn(m)%dsm2_node_no = chan_geom(i)%up_node
                 conn(m)%conn_up_down = 1   
                 m = m + 1      
                 conn(m)%conn_no = m
                 conn(m)%segm_no = k
                 conn(m)%cell_no = segm(conn(m)%segm_no)%start_cell_no + segm(conn(m)%segm_no)%nx -1 
                 conn(m)%comp_pt = chan_geom(i)%down_comp
                 conn(m)%chan_no = chan_geom(i)%chan_no
                 conn(m)%chan_num = chan_geom(i)%channel_num
                 conn(m)%dsm2_node_no = chan_geom(i)%down_node
                 conn(m)%conn_up_down = 0           
             end if
         end do
         num_segm = chan_geom(down_bound)%down_comp - chan_geom(down_bound)%up_comp         
         do j = 1, num_segm
             k = k + 1
             segm(k)%segm_no = k
             segm(k)%chan_no = down_bound
             segm(k)%up_comppt = chan_geom(down_bound)%up_comp + j - 1
             segm(k)%down_comppt = segm(k)%up_comppt + 1
             segm(k)%up_distance = comp_pt(segm(k)%up_comppt)%distance
             segm(k)%down_distance = comp_pt(segm(k)%down_comppt)%distance
             segm(k)%length = segm(k)%down_distance - segm(k)%up_distance
             segm(k)%nx = max( floor(segm(k)%length/gtm_dx), 1)
             if (segm(k)%nx .eq. 1)  segm(k)%nx = 2
             segm(k)%start_cell_no = segm(k-1)%start_cell_no + segm(k-1)%nx
         end do                                
         n_segm = k
         m = m + 1
         conn(m)%conn_no = m
         conn(m)%segm_no = n_segm - num_segm + 1
         conn(m)%cell_no = segm(conn(m)%segm_no)%start_cell_no      
         conn(m)%comp_pt = chan_geom(down_bound)%up_comp
         conn(m)%chan_no = chan_geom(down_bound)%chan_no
         conn(m)%chan_num = chan_geom(down_bound)%channel_num
         conn(m)%dsm2_node_no = chan_geom(down_bound)%up_node
         conn(m)%conn_up_down = 1   
         m = m + 1      
         conn(m)%conn_no = m
         conn(m)%segm_no = n_segm
         conn(m)%cell_no = segm(conn(m)%segm_no)%start_cell_no + segm(conn(m)%segm_no)%nx -1  
         conn(m)%comp_pt = chan_geom(down_bound)%down_comp
         conn(m)%chan_no = chan_geom(down_bound)%chan_no
         conn(m)%chan_num = chan_geom(down_bound)%channel_num
         conn(m)%dsm2_node_no = chan_geom(down_bound)%down_node
         conn(m)%conn_up_down = 0
         n_conn = m
         call allocate_cell_property
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
     !> This updates common variables: n_junc, n_boun and dsm2_network(:)
     !> use common_variables, only n_conn, conn as inputs
     subroutine get_dsm2_network_info()
         implicit none
         integer :: sorted_conns(n_conn)
         integer, dimension(:), allocatable :: unique_num
         integer, dimension(:), allocatable :: occurrence
         integer :: num_nodes
         integer :: i, j, k
         integer :: nj

         call sort_arr(sorted_conns, conn(:)%dsm2_node_no, n_conn)
         call unique_num_count(unique_num, occurrence, num_nodes, sorted_conns, n_conn)
         n_node = num_nodes
         allocate(dsm2_network(num_nodes))
         allocate(dsm2_network_extra(num_nodes))
         dsm2_network(:)%n_conn_cell = 0 
         dsm2_network(:)%boundary_no = 0 
         dsm2_network(:)%junction_no = 0
         dsm2_network(:)%nonsequential = 0         
         dsm2_network(:)%node_conc = 0
         dsm2_network_extra(:)%reservoir_no = 0
         dsm2_network_extra(:)%resv_conn_no = 0
         dsm2_network_extra(:)%n_qext = 0                  
         dsm2_network_extra(:)%boundary = 0
         n_boun = 0
         n_junc = 0
         do i = 1, n_node
             dsm2_network(i)%dsm2_node_no = unique_num(i)
             dsm2_network_extra(i)%dsm2_node_no = unique_num(i)
             if (occurrence(i)==1) then 
                 allocate(dsm2_network(i)%cell_no(1))
                 allocate(dsm2_network(i)%up_down(1))
                 allocate(dsm2_network(i)%chan_num(1))
                 allocate(dsm2_network(i)%gate(1))
                 n_boun = n_boun + 1
                 dsm2_network(i)%boundary_no = n_boun
                 dsm2_network(i)%n_conn_cell = 1
                 do j = 1, n_conn
                     if (unique_num(i) .eq. conn(j)%dsm2_node_no) then
                        dsm2_network(i)%cell_no(1) = conn(j)%cell_no
                        dsm2_network(i)%up_down(1) = conn(j)%conn_up_down
                        dsm2_network(i)%chan_num(1) = conn(j)%chan_num
                        dsm2_network(i)%gate(1) = 0
                     end if
                 end do
             else
                 allocate(dsm2_network(i)%cell_no(occurrence(i)))
                 allocate(dsm2_network(i)%up_down(occurrence(i)))             
                 allocate(dsm2_network(i)%chan_num(occurrence(i))) 
                 allocate(dsm2_network(i)%gate(occurrence(i))) 
                 n_junc = n_junc + 1
                 dsm2_network(i)%junction_no = n_junc
                 dsm2_network(i)%n_conn_cell = occurrence(i)
                 nj = 0
                 do j = 1, n_conn
                     if (unique_num(i) .eq. conn(j)%dsm2_node_no) then
                         nj = nj + 1
                         dsm2_network(i)%cell_no(nj) = conn(j)%cell_no
                         dsm2_network(i)%up_down(nj) = conn(j)%conn_up_down
                         dsm2_network(i)%chan_num(nj) = conn(j)%chan_num
                         dsm2_network(i)%gate(nj) = 0
                     end if
                 end do
                 if ((dsm2_network(i)%n_conn_cell==2) .and. (abs(dsm2_network(i)%cell_no(1)-dsm2_network(i)%cell_no(2))> 1)) then
                     dsm2_network(i)%nonsequential = 1
                 end if                                  
             end if
             
             do j = 1, n_resv
                 do k = 1, resv_geom(j)%n_resv_conn
                     if (resv_geom(j)%ext_node_no(k)==unique_num(i)) then
                         resv_geom(j)%network_id(k) = i
                         dsm2_network_extra(i)%reservoir_no = resv_geom(j)%resv_no
                         dsm2_network_extra(i)%resv_conn_no = resv_geom(j)%resv_conn_no(k)
                     end if
                 end do    
             end do

             do j = 1, n_qext
                 if (qext(j)%attach_obj_type==2 .and. qext(j)%attach_obj_name==unique_num(i)) then
                     dsm2_network_extra(i)%n_qext = dsm2_network_extra(i)%n_qext + 1
                 end if
             end do
             allocate(dsm2_network_extra(i)%qext_no(dsm2_network_extra(i)%n_qext))
             allocate(dsm2_network_extra(i)%qext_path(dsm2_network_extra(i)%n_qext,n_var))
             dsm2_network_extra(i)%qext_no = 0
             dsm2_network_extra(i)%qext_path = 0
             k = 0 
             do j = 1, n_qext
                 if (qext(j)%attach_obj_type==2 .and. qext(j)%attach_obj_name==unique_num(i)) then
                     k = k + 1
                     dsm2_network_extra(i)%qext_no(k) = qext(j)%qext_no
                 end if
             end do
             
             do j = 1, n_tran
                 if (tran(j)%from_obj==2 .and. tran(j)%from_identifier==unique_num(i)) then
                     dsm2_network_extra(i)%n_tran = dsm2_network_extra(i)%n_tran + 1
                 end if             
             end do
             allocate(dsm2_network_extra(i)%tran_no(dsm2_network_extra(i)%n_tran))
             k = 0
             do j = 1, n_tran
                 if ((tran(j)%from_obj==2 .and. tran(j)%from_identifier==unique_num(i)) .or. &
                     (tran(j)%from_obj==2 .and. tran(j)%to_identifier==unique_num(i))) then
                     k = k + 1
                     dsm2_network_extra(i)%tran_no(k) = tran(j)%tran_no
                 end if
             end do       

             do j = 1, n_bfbs
                 if (bfbs(j)%node.eq.dsm2_network_extra(i)%dsm2_node_no .and. bfbs(j)%btype.eq."flow") then
                     bfbs(j)%i_node = i
                     dsm2_network_extra(i)%boundary = 1       
                 end if    
                 if (bfbs(j)%node.eq.dsm2_network_extra(i)%dsm2_node_no .and. bfbs(j)%btype.eq."stage") then
                     dsm2_network_extra(i)%boundary = 2
                     bfbs(j)%i_node = i
                 end if    
             enddo                             
                                
         end do   
         
         do j = 1, n_gate                                
             if (gate(j)%from_obj_int .eq. 1) then
                 read(gate(j)%from_identifier,'(i)') gate(j)%from_identifier_int       
                 do i = 1, n_node
                     do k = 1, dsm2_network(i)%n_conn_cell
                         if (gate(j)%from_identifier_int.eq.dsm2_network(i)%chan_num(k) .and. &
                             gate(j)%to_node.eq.dsm2_network(i)%dsm2_node_no) then
                             gate(j)%cell_no = dsm2_network(i)%cell_no(k)
                             gate(j)%face = dsm2_network(i)%up_down(k)
                             dsm2_network(i)%gate(k) = j
                             gate(j)%to_node_int = i
                             exit
                         end if
                     end do
                 end do    
             elseif(gate(j)%from_obj_int .eq. 2) then
                 do k = 1, n_resv
                     if (trim(gate(j)%from_identifier) .eq. trim(resv_geom(k)%name)) then
                         gate(j)%from_identifier_int = resv_geom(k)%resv_no
                     end if
                 end do
             end if
         end do                  
         
         deallocate(unique_num, occurrence)                  
         return
     end subroutine


     !> Routine to obtain cell connection info
     !> for boundaries, replace u/s or d/s cell no with -1;
     !> for non-sequential cells, replace the wrong cell no with actual one;
     !> for junctions, replace u/s or d/s cell with 0
     subroutine get_cell_info()
         implicit none
         integer :: i, j, k
         do i = 1, n_cell
             cell(i)%cell_id = i
             cell(i)%up_cell = i - 1
             cell(i)%down_cell = i + 1
             cell(i)%dx = dx_arr(i)
         end do
         do i = 1, n_node
             do j = 1, dsm2_network(i)%n_conn_cell
                 if (dsm2_network(i)%boundary_no .ge. 1) then   ! boundary
                     if (dsm2_network(i)%up_down(j) .eq. 1) then
                         cell(dsm2_network(i)%cell_no(j))%up_cell = -1
                     else 
                         cell(dsm2_network(i)%cell_no(j))%down_cell = -1
                     end if
                 end if
                 if (dsm2_network(i)%nonsequential .eq. 1) then ! non sequential
                     if (j.eq.1) k = 2
                     if (j.eq.2) k = 1
                     if (dsm2_network(i)%up_down(j) .eq. 1) then
                         cell(dsm2_network(i)%cell_no(j))%up_cell = dsm2_network(i)%cell_no(k)
                     else 
                         cell(dsm2_network(i)%cell_no(j))%down_cell = dsm2_network(i)%cell_no(k)
                     end if                 
                 end if
                 if (dsm2_network(i)%n_conn_cell .gt. 2) then   ! junction
                     if (dsm2_network(i)%up_down(j) .eq. 1) then ! d/s of junction
                         cell(dsm2_network(i)%cell_no(j))%up_cell = 0
                     else                                        ! u/s of junction
                         cell(dsm2_network(i)%cell_no(j))%down_cell = 0
                     end if
                 end if                 
             end do
         end do
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
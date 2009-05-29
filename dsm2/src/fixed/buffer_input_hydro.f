      subroutine buffer_input_hydro()
      use input_storage_fortran
      use constants
      
      implicit none
      integer :: nitem
      character*(128) filename
      integer :: icount
      character*(32) name
      character*8,model,filetype,io
      character*16 interval
      character*128 iofile
      integer :: ierror = 0
      ! input_node

      character*32 :: rolename 


      ! output_channel
      integer channo
      character*8  distance
      integer      idistance
      character*16 variable,
     &                perop
      character*32 :: sourcegroup
      
      character*32 :: group_name
      character*16 :: constituent
      real*8  :: value

      integer :: channel
      character*32 ::resname
      character*8 cdist
      real*8 stage
      real*8 flow
      
      
      ! output_reservoir
      character*32 reservoir
      character*80 inpath
      character*8  fillin
      character*8  node_str
      integer      sign
      integer node      
      
       ! output_gate
      character*32 gate, device


      character*(16) :: sdate,edate   


c=======================  Initial conditions 
      nitem = channel_ic_buffer_size()
      do icount = 1,nitem
         call channel_ic_query_from_buffer(icount,
     &                                     channel,
     &                                     cdist,
     &                                     stage,
     &                                     flow,
     &                                     ierror)

         call process_channel_ic(channel,cdist,stage,flow)
      end do
      print *,"Number of channel initial conditions processed: ", nitem

      nitem = reservoir_ic_buffer_size()
      do icount = 1,nitem
         call reservoir_ic_query_from_buffer(icount,resname,stage,ierror)
         call process_reservoir_ic(resname,stage)
      end do
      print *,"Number of channel initial conditions processed: ", nitem      


      nitem = boundary_stage_buffer_size()
      do icount = 1,nitem
         call boundary_stage_query_from_buffer(icount,
     &                                    name,
     &                                    node,
     &                                    fillin,   
     &                                    filename,
     &                                    inpath,
     &                                    ierror)
      rolename="stage"
      variable="stage"
      sign=0 
 
         call process_input_node(name,
     &                           node,
     &                           variable,     
     &                           sign,
     &                           rolename,
     &                           fillin,   
     &                           filename,
     &                           inpath)

      end do
      print *,"Number of stage boundaries processed: ", nitem

      nitem = boundary_flow_buffer_size()
      do icount = 1,nitem
         call boundary_flow_query_from_buffer(icount,
     &                                    name,
     &                                    node,  
     &                                    fillin,   
     &                                    filename,
     &                                    inpath,
     &                                    ierror)
      rolename="inflow"
      variable="flow"
      !if ((sign .ne. -1) .or. (sign .ne. 1)) sign = 0  
      sign = 0
         call process_input_node(name,
     &                           node,
     &                           variable,     
     &                           sign,
     &                           rolename,
     &                           fillin,   
     &                           filename,
     &                           inpath)

      end do
      print *,"Number of flow boundaries processed: ", nitem

      nitem = source_flow_buffer_size()
      do icount = 1,nitem
         call source_flow_query_from_buffer(icount,
     &                                    name,
     &                                    node,
     &                                    sign,   
     &                                    fillin,   
     &                                    filename,
     &                                    inpath,
     &                                    ierror)
      rolename="source-sink"
      variable="flow" 
         call process_input_node(name,
     &                           node,
     &                           variable,     
     &                           sign,
     &                           rolename,
     &                           fillin,   
     &                           filename,
     &                           inpath)

      end do
      print *,"Number of source flows processed: ", nitem

      nitem = source_flow_reservoir_buffer_size()
      do icount = 1,nitem
         call source_flow_reservoir_query_from_buffer(icount,
     &                                    name,
     &                                    resname,
     &                                    sign,   
     &                                    fillin,   
     &                                    filename,
     &                                    inpath,
     &                                    ierror)
      variable="flow" 
         call process_input_reservoir(name,
     &                               resname,
     &                               variable,     
     &                               sign,
     &                               fillin,   
     &                               filename,
     &                               inpath)

      end do
      print *,"Number of reservoir source flows processed: ", nitem


      nitem = input_transfer_flow_buffer_size()
      do icount = 1,nitem
         call input_transfer_flow_query_from_buffer(icount,
     &                                             name,
     &                                             fillin,   
     &                                             filename,
     &                                             inpath,
     &                                             ierror)
         variable = 'flow'
         call process_input_transfer(name,
     &                               variable,
     &                               fillin,   
     &                               filename,
     &                               inpath)

      end do
      print *,"Number of transfer inputs processed: ", nitem

      end subroutine


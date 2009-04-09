      subroutine buffer_input_qual()
      use input_storage_fortran
      use constants
      use io_units
      
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

c======================== Input and output ======================
      nitem = rate_coefficient_buffer_size()
      do icount = 1,nitem
         call rate_coefficient_query_from_buffer(icount,
     &                                          group_name,
     &                                          constituent,
     &                                          variable,
     &                                          value,
     &                                          ierror) 

         sign = 1

         call process_rate_coef(group_name,
     &                          constituent,
     &                          variable,
     &                          value)
 
      end do
      print *,"Number of rate coefficients processed: ", nitem




      nitem = input_climate_buffer_size()
      do icount = 1,nitem
         call input_climate_query_from_buffer(icount,
     &                                       name,
     &                                       variable,
     &                                       fillin,
     &                                       filename,
     &                                       inpath,
     &                                       ierror) 

         sign = 1

         call process_input_climate(name,
     &                              variable,
     &                              sign,
     &                              fillin,
     &                              filename,
     &                              inpath)
 
      end do
      print *,"Number of climate inputs processed: ", nitem


      nitem = node_concentration_buffer_size()
      do icount = 1,nitem
         call node_concentration_query_from_buffer(icount,
     &                                    name,
     &                                    node,
     &                                    variable,
     &                                    fillin,   
     &                                    filename,
     &                                    inpath,
     &                                    ierror)
      rolename="inflow"
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
      print *,"Number of node concentration inputs processed: ", nitem

      nitem = reservoir_concentration_buffer_size()
      do icount = 1,nitem
         call reservoir_concentration_query_from_buffer(icount,
     &                                    name,
     &                                    resname,
     &                                    variable,
     &                                    fillin,   
     &                                    filename,
     &                                    inpath,
     &                                    ierror)
      sign=0
         call process_input_reservoir(name,
     &                               resname,
     &                               variable,     
     &                               sign,
     &                               fillin,   
     &                               filename,
     &                               inpath)

      end do
      print *,"Number of reservoir concentration inputs processed: ", nitem


      nitem = output_channel_concentration_buffer_size()
      do icount = 1,nitem
         call output_channel_concentration_query_from_buffer(icount,
     &                                        name,
     &                                        channo,
     &                                        distance,
     &                                        variable,
     &                                        sourcegroup,    
     &                                        interval,
     &                                        perop,
     &                                        filename,
     &                                        ierror)
         call locase(sourcegroup)
         if (sourcegroup .eq. "none")sourcegroup = ""

         call locase(distance)
         if (distance(:6) .eq. "length") then 
            idistance = chan_length
         else 
            read(distance,'(i)',err=120)idistance
         end if
         call process_output_channel(name,
     &                               channo,
     &                               idistance,
     &                               variable,
     &                               interval,
     &                               perop,
     &                               sourcegroup,
     &                               filename)
      end do
      print *,"Number of channel output requests: ", nitem


      nitem = output_reservoir_concentration_buffer_size()
      do icount = 1,nitem
         call output_reservoir_concentration_query_from_buffer(icount,
     &                                    name,
     &                                    reservoir,
     &                                    variable,
     &                                    sourcegroup,         
     &                                    interval,
     &                                    perOp,
     &                                    filename,
     &                                    ierror) 
      if (sourcegroup .eq. "none")sourcegroup = ""

      call process_output_reservoir(name,
     &                                    reservoir,
     &                                    miss_val_i,
     &                                    variable,
     &                                    interval,
     &                                    perOp,
     &                                    sourceGroup,
     &                                    filename) 
      end do
      print *,"Number of reservoir output requests: ", nitem
      return

120   write(unit_error,*)"Failed to convert channel length from text to integer:" /
     &   "Valid entries are an integer or 'length' (case sensitive)" /
     &   "Output name: ", name,
     &   "Channel: ",channo, ", " , "Distance: " , distance
      call exit(-3)
      end subroutine
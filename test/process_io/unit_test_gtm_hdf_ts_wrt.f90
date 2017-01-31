!<license>
!    Copyright (C) 2017 State of California,
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
!> This module contains unit tests for gtm_hdf_ts_write module, 
!> which mainly is used to print out time series output into 
!> HDF file.
!>@ingroup test_process_io
module ut_gtm_hdf_ts_wrt

    use fruit
 
    contains
    
    
    !> Main routines to call all unit tests for writing data into HDF file
    subroutine test_hdf_ts_wrt()
        use hdf5   
        implicit none
        integer :: error = 0
        call h5open_f(error)        
        call test_init_gtm_hdf
        call test_write_ts_gtm_hdf
        call test_write_ts_gtm_hdf_lg
        call h5close_f(error)   
        return
    end subroutine    

    !> Test for initializing qual tidefile
    subroutine test_init_gtm_hdf()
        use common_variables, only: chan_geom, resv_geom, constituents, gtm_time_interval, hdf_out
        use gtm_hdf_ts_write
        implicit none
        character*128 :: hdf_name                 ! name of qual hdf5 file
        integer :: sim_start                      ! first write time
        integer :: sim_end                        ! last write time
        character*16 :: hdf_interval_char         ! interval
        integer :: ncell
        integer :: nchan
        integer :: nres
        integer :: nconc        
        integer :: error = 0
       
        hdf_out = 'cell'
        nchan = 1
        if (allocated(constituents)) deallocate(constituents)
        gtm_time_interval = 5
        hdf_name = "gtm_out_hdf_test_init.h5"
        ncell = 3
        nres = 1
        nconc = 2
        sim_start = 44100
        sim_end = 44400
        hdf_interval_char = "15min"        
        allocate(chan_geom(ncell))
        allocate(resv_geom(nres))
        allocate(constituents(nconc))
        chan_geom(1)%channel_num = 101
        chan_geom(2)%channel_num = 102
        chan_geom(3)%channel_num = 103
        resv_geom(1)%name = "res_1"
        constituents(1)%name = "conc_1"
        constituents(2)%name = "conc_2"
        call init_gtm_hdf(gtm_hdf,           &
                          hdf_name,          &
                          ncell,             &
                          nchan,             &
                          nres,              &
                          nconc,             &
                          sim_start,         &
                          sim_end,           &
                          hdf_interval_char)
        call close_gtm_hdf(gtm_hdf)          
        deallocate(chan_geom)        
        deallocate(resv_geom) 
        deallocate(constituents)                
        return
    end subroutine
 
 
    !> Test for writing time series data to qual tidefile as well as geometry data
    subroutine test_write_ts_gtm_hdf()
        use hdf5
        use common_variables, only: chan_geom, resv_geom, constituents, hdf_out
        use gtm_hdf_write
        use gtm_hdf_ts_write
        implicit none
        character*128 :: hdf_name                  ! name of qual hdf5 file
        integer :: sim_start                       ! first write time
        integer :: sim_end                         ! last write time
        character*16 :: hdf_interval_char          ! interval
        integer :: ncell
        integer :: nchan
        integer :: nres
        integer :: nconc        
        integer :: julmin
        integer :: time_index
        real(gtm_real), allocatable :: conc(:,:), conc_res(:,:) 
               
        !---variables for reading tidefile
        integer(HID_T) :: file_id, output_id, dset_id, dataspace              
        integer(HSIZE_T), dimension(3) :: data_dims
        integer(HSIZE_T), dimension(3) :: offset
        integer(HSIZE_T), dimension(3) :: count
        integer(HSIZE_T), dimension(3) :: offset_out
        integer(HSIZE_T), dimension(3) :: count_out
        real(gtm_real), allocatable :: rdata(:,:,:)        
        INTEGER :: dsetrank = 3                     ! Dataset rank (in file)
        INTEGER :: memrank = 3                      ! Dataset rank (in memory)       
        INTEGER(HID_T) :: memspace                  ! memspace identifier         
        integer :: error = 0        
        integer :: i, j

        hdf_out = 'cell'
        nchan = 1        
        hdf_name = "gtm_out_hdf_test_ts.h5"
        ncell = 5
        nres = 1
        nconc = 3
        sim_start = 44100
        sim_end = 44250
        hdf_interval_char = "15min"        

        allocate(chan_geom(ncell))
        allocate(resv_geom(nres))
        allocate(constituents(nconc))
        allocate(conc(ncell, nconc))
        allocate(conc_res(nres, nconc))
        resv_geom(1)%name = "res_1"
        constituents(1)%name = "conc_1"
        constituents(2)%name = "conc_2"
        constituents(3)%name = "conc_3"
        
        call init_gtm_hdf(gtm_hdf,          &
                          hdf_name,          &
                          ncell,             &
                          nchan,             &
                          nres,              &
                          nconc,             &
                          sim_start,         &
                          sim_end,           &
                          hdf_interval_char)
                           
        !---write values into time_index=3                      
        julmin = 44130       
        time_index = (julmin-gtm_hdf%start_julmin)/gtm_hdf%write_interval               
        do i = 1, nconc
            do j = 1, ncell
                conc(j,i) = 1000 + i*100 + j
            end do
            do j = 1, nres
                conc_res(j,i) = 1000 + i*100 + j
            end do    
        end do               
        call write_gtm_hdf(gtm_hdf,          &
                           conc,             &
                           ncell,            &
                           nconc,            &
                           time_index)   
        call write_gtm_hdf_resv(gtm_hdf,     &
                                conc_res,    &
                                nres,        &
                                nconc,       &
                                time_index)   
                                                           
        !---write values into time_index=4                                
        julmin = 44145.d0     
        time_index = (julmin-gtm_hdf%start_julmin)/gtm_hdf%write_interval               
        do i = 1, nconc
            do j = 1, ncell
                conc(j,i) = 2000 + i*100 + j
            end do
            do j = 1, nres
                conc_res(j,i) = 2000 + i*100 + j
            end do    
        end do               
        call write_gtm_hdf(gtm_hdf,          &
                           conc,             &
                           ncell,            &
                           nconc,            &
                           time_index)   
        call write_gtm_hdf_resv(gtm_hdf,     &
                                conc_res,    &
                                nres,        &
                                nconc,       &
                                time_index)                                                                              
        call close_gtm_hdf(gtm_hdf)          
        deallocate(chan_geom)        
        deallocate(resv_geom) 
        deallocate(constituents) 
        deallocate(conc)
        deallocate(conc_res)  

        !----verify the data that was written to tidefile
        allocate(rdata(ncell,nconc,2)) 
        call h5open_f(error)
        call h5fopen_f(hdf_name, H5F_ACC_RDWR_F, file_id, error) 
        call h5gopen_f(file_id, "output", output_id, error)
        call h5dopen_f(output_id, "cell concentration", dset_id, error) 
        call h5dget_space_f(dset_id, dataspace, error)
        offset = (/0,0,2/)
        count = (/5,3,2/)
        offset_out = (/0,0,0/)
        count_out = (/5,3,2/)
        data_dims(1) = ncell
        data_dims(2) = nconc
        data_dims(3) = 2
        rdata = 0
        call h5sselect_hyperslab_f(dataspace, H5S_SELECT_SET_F, &
                                   offset, count, error)
        call h5screate_simple_f(memrank, data_dims, memspace, error)    
        call h5sselect_hyperslab_f(memspace, H5S_SELECT_SET_F,  &
                                   offset_out, count_out, error)
        call h5dread_f(dset_id, H5T_NATIVE_DOUBLE, rdata, data_dims, error, memspace, dataspace)    
          
        !---cell value(time slice 1) = 1000 + 100*nconc + ncell
        !---cell value(time slice 2) = 2000 + 100*nconc + ncell
        call assertEquals(rdata(1,1,1), dble(1101), weakest_eps, "problem in test_write_ts_gtm_hdf rdata(1,1,1)")
        call assertEquals(rdata(1,2,2), dble(2201), weakest_eps, "problem in test_write_ts_gtm_hdf rdata(2,1,2)")
    
        call h5dclose_f(dset_id, error)
        call h5sclose_f(dataspace, error)
        call h5gclose_f(output_id, error)
        call h5fclose_f(file_id,error)   
        deallocate(rdata)                     
        return
    end subroutine


    !> Test for writing large time series data to qual tidefile
    subroutine test_write_ts_gtm_hdf_lg()
        use hdf5    
        use common_variables, only: chan_geom, resv_geom, constituents, hdf_out
        use gtm_hdf_ts_write
        implicit none
        character*128 :: hdf_name            ! name of qual hdf5 file
        integer :: sim_start                 ! first write time
        integer :: sim_end                   ! last write time
        character*16 :: hdf_interval_char    ! interval
        integer :: ncell
        integer :: nchan
        integer :: nres
        integer :: nconc        
        integer :: julmin
        integer :: time_index
        character(len=5) :: x1        
        real(gtm_real), allocatable :: conc(:,:), conc_res(:,:)                 
        
        !---variables for reading tidefile
        integer(HID_T) :: file_id, output_id, dset_id, dataspace              
        integer(HSIZE_T), dimension(3) :: data_dims
        integer(HSIZE_T), dimension(3) :: offset
        integer(HSIZE_T), dimension(3) :: count
        integer(HSIZE_T), dimension(3) :: offset_out
        integer(HSIZE_T), dimension(3) :: count_out
        real(gtm_real), allocatable :: rdata(:,:,:)        
        INTEGER :: dsetrank = 3                     ! Dataset rank (in file)
        INTEGER :: memrank = 3                      ! Dataset rank (in memory)
        INTEGER(HID_T) :: memspace                  ! memspace identifier                 

        integer :: error = 0
        integer :: i, j     

        hdf_out = 'cell'
        nchan = 1           
        hdf_name = "gtm_out_hdf_test_ts_large.h5"
        ncell = 15000
        nres = 0
        nconc = 3
        sim_start = 44100
        sim_end = 194100
        hdf_interval_char = "15min"        

        allocate(chan_geom(ncell))
        allocate(resv_geom(nres))
        allocate(constituents(nconc))
        allocate(conc(ncell, nconc))
        allocate(conc_res(nres, nconc))
        do i = 1, ncell
            chan_geom(i)%channel_num = i
        end do
        do j = 1, nconc
            write(x1,'(i5.5)') j
            constituents(j)%name = "conc_"//trim(x1)
        end do
        
        call init_gtm_hdf(gtm_hdf,           &
                          hdf_name,          &
                          ncell,             &
                          nchan,             &
                          nres,              &
                          nconc,             &
                          sim_start,         &
                          sim_end,           &
                          hdf_interval_char)
                           
        !---write values into time_index=3                           
        julmin = 44130       
        time_index = (julmin-gtm_hdf%start_julmin)/gtm_hdf%write_interval               
        do i = 1, nconc
            do j = 1, ncell
                conc(j,i) = 1000 + i*100 + j
            end do
            do j = 1, nres
                conc_res(j,i) = 1000 + i*100 + j
            end do    
        end do               
        call write_gtm_hdf(gtm_hdf,          &
                           conc,             &
                           ncell,            &
                           nconc,            &
                           time_index)   
        call write_gtm_hdf_resv(gtm_hdf,     &
                                conc_res,    &
                                nres,        &
                                nconc,       &
                                time_index)  
                            
        !---write values into time_index=4
        julmin = 44145     
        time_index = (julmin-gtm_hdf%start_julmin)/gtm_hdf%write_interval               
        do i = 1, nconc
            do j = 1, ncell
                conc(j,i) = 2000 + i*100 + j
            end do
            do j = 1, nres
                conc_res(j,i) = 2000 + i*100 + j
            end do    
        end do               
        call write_gtm_hdf(gtm_hdf,          &
                           conc,             &
                           ncell,            &
                           nconc,            &
                           time_index)   
        call write_gtm_hdf_resv(gtm_hdf,     &
                                conc_res,    &
                                nres,        &
                                nconc,       &
                                time_index)      
                                                                                                                          
        call close_gtm_hdf(gtm_hdf)          
                  
        deallocate(chan_geom)        
        deallocate(resv_geom) 
        deallocate(constituents) 
        deallocate(conc)
        deallocate(conc_res)               
        
        !----verify the data that was written to tidefile
        allocate(rdata(ncell,nconc,2)) 
        call h5open_f(error)
        call h5fopen_f(hdf_name, H5F_ACC_RDWR_F, file_id, error) 
        call h5gopen_f(file_id, "output", output_id, error)
        call h5dopen_f(output_id, "cell concentration", dset_id, error) 
        call h5dget_space_f(dset_id, dataspace, error)
        offset = (/0,0,2/)
        count = (/ncell,nconc,2/)
        offset_out = (/0,0,0/)
        count_out = (/ncell,nconc,2/)
        data_dims(1) = ncell
        data_dims(2) = nconc
        data_dims(3) = 2
        rdata = 0
        call h5sselect_hyperslab_f(dataspace, H5S_SELECT_SET_F, &
                                   offset, count, error)
        call h5screate_simple_f(memrank, data_dims, memspace, error)     
        call h5sselect_hyperslab_f(memspace, H5S_SELECT_SET_F,  &
                                   offset_out, count_out, error)
        call h5dread_f(dset_id, H5T_NATIVE_DOUBLE, rdata, data_dims, error, memspace, dataspace)      
        
        !---cell value(time slice 1) = 1000 + 100*nconc + nchans
        !---cell value(time slice 2) = 2000 + 100*nconc + nchans    
        call assertEquals(rdata(112,3,1), dble(1412), weakest_eps, "problem in test_write_ts_gtm_hdf rdata(3,112,1)")
        call assertEquals(rdata(9999,2,2), dble(12199), weakest_eps, "problem in test_write_ts_gtm_hdf rdata(2,9999,2)")
        
        call h5dclose_f(dset_id, error)
        call h5sclose_f(dataspace, error)
        call h5gclose_f(output_id, error)
        call h5fclose_f(file_id,error)   
        deallocate(rdata)                     
        return
    end subroutine


end module        
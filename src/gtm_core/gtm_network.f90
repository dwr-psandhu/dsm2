!<license>
!    Copyright (C) 1996, 1997, 1998, 2001, 2007, 2009 State of California,
!    Department of Water Resources.
!    This file is part of DSM2.
!
!    The Delta Simulation Model 2 (DSM2) is free software: 
!    you can redistribute it and/or modify
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

!> Routines to fill data into the entire network of GTM grids
!>@ingroup gtm_core
module gtm_network    

    use gtm_precision
    use error_handling
    use logging
    use common_variables
    use common_xsect
  
    real(gtm_real), allocatable :: flow_tmp(:,:)
    real(gtm_real), allocatable :: flow_lo_tmp(:,:)
    real(gtm_real), allocatable :: flow_hi_tmp(:,:)
    real(gtm_real), allocatable :: area_tmp(:,:)
    real(gtm_real), allocatable :: area_lo_tmp(:,:)
    real(gtm_real), allocatable :: area_hi_tmp(:,:)
    
    contains      
    
    !> Allocate network temporary array
    subroutine allocate_network_tmp()
        implicit none
        integer :: istat = 0
        character(len=128) :: message
        if (npartition_x .eq. LARGEINT) then
            call gtm_fatal('Number of partition within a cell inspace needed to be assigned')
        end if
        ncell = n_segm * npartition_x
        allocate(flow_tmp(ncell,npartition_t+1), stat = istat)
        allocate(flow_lo_tmp(ncell,npartition_t+1), stat = istat)
        allocate(flow_hi_tmp(ncell,npartition_t+1), stat = istat)
        allocate(area_tmp(ncell,npartition_t+1), stat = istat)
        allocate(area_lo_tmp(ncell,npartition_t+1), stat = istat)
        allocate(area_hi_tmp(ncell,npartition_t+1), stat = istat)
        if (istat .ne. 0 )then
           call gtm_fatal(message)
        end if
        return
    end subroutine
 
    !> Deallocate network temporary array
    subroutine deallocate_network_tmp()
        implicit none
        deallocate(flow_tmp, flow_lo_tmp, flow_hi_tmp)
        deallocate(area_tmp, area_lo_tmp, area_hi_tmp)
        return
    end subroutine
        
    !> Return flow_tmp(1:ncell) and area_tmp(1:ncell) for the entire network 
    !> at the specified hydro time index
    subroutine interp_network(npart_x, npart_t, hydro_time_index)
        use interpolation
        implicit none
        integer, intent(in) :: npart_x                    !< number of partitions within a cell in space
        integer, intent(in) :: npart_t                    !< number of partitions in time
        integer, intent(in) :: hydro_time_index           !< starting time step index in DSM2 hydro 
        real(gtm_real), dimension(npart_t+1, npart_x*2+1) :: flow_mesh, area_mesh                 ! local variables
        real(gtm_real), dimension(npart_t, npart_x*2) ::  flow_volume_change, area_volume_change  ! local variables
        real(gtm_real) :: dt, dx                                                                  ! local variables
        integer :: nx, nt                                                                         ! local variables
        integer :: up_comp, down_comp                                                             ! local variables
        integer :: i, j, t, icell, t_index                                                        ! local variables
                
        nx = npart_x*2 + 1
        nt = npart_t + 1
        t_index = hydro_time_index 
        do i = 1, n_segm
            dt = orig_time_interval/npart_t
            dx = segm(i)%length/(nx-1.)
            up_comp = segm(i)%up_comppt
            down_comp = segm(i)%down_comppt        
            call interp_flow_area(flow_mesh, area_mesh, flow_volume_change, area_volume_change,                     &
                                  segm(i)%chan_no, segm(i)%up_distance, dx, dt, nt, nx,                             &
                                  hydro_flow(up_comp,t_index-1), hydro_flow(down_comp,t_index-1), &
                                  hydro_flow(up_comp,t_index), hydro_flow(down_comp,t_index),     &
                                  hydro_ws(up_comp,t_index-1), hydro_ws(down_comp,t_index-1),     &
                                  hydro_ws(up_comp,t_index), hydro_ws(down_comp,t_index))        
            do t = 1, nt
                do j = 1, npart_x
                    icell = npart_x*(i-1)+j
                    flow_tmp(icell,t) = flow_mesh(t,j*2)
                    flow_lo_tmp(icell,t) = flow_mesh(t,j*2+1)
                    flow_hi_tmp(icell,t) = flow_mesh(t,j*2-1)
                    area_tmp(icell,t) = area_mesh(t,j*2)
                    area_lo_tmp(icell,t) = area_mesh(t,j*2+1)
                    area_hi_tmp(icell,t) = area_mesh(t,j*2-1)                
                end do
            end do
        end do
        return
    end subroutine
    
    !> hydrodynamic interface to retrieve area and flow
    subroutine gtm_flow_area(flow,    &
                             flow_lo, &
                             flow_hi, &
                             area,    &
                             area_lo, &
                             area_hi, &
                             ncell,   &
                             time,    &
                             dx,      &                        
                             dt)                
        implicit none
        integer, intent(in) :: ncell                   !< Number of cells
        real(gtm_real), intent(in) :: time             !< Time of request
        real(gtm_real), intent(in) :: dx               !< Spatial step
        real(gtm_real), intent(in) :: dt               !< Time step 
        real(gtm_real), intent(out) :: flow(ncell)     !< Cell and time centered flow
        real(gtm_real), intent(out) :: flow_lo(ncell)  !< Low face flow, time centered
        real(gtm_real), intent(out) :: flow_hi(ncell)  !< High face flow, time centered
        real(gtm_real), intent(out) :: area(ncell)     !< Cell center area, old time
        real(gtm_real), intent(out) :: area_lo(ncell)  !< Area lo face, time centered
        real(gtm_real), intent(out) :: area_hi(ncell)  !< Area hi face, time centered
        integer :: time_in_mesh                        ! local variable
        time_in_mesh = mod(int(time),npartition_t)+1
        flow    = flow_tmp(:,time_in_mesh)
        flow_lo = flow_lo_tmp(:,time_in_mesh)
        flow_hi = flow_hi_tmp(:,time_in_mesh)
        area    = area_tmp(:,time_in_mesh)
        area_lo = area_lo_tmp(:,time_in_mesh)
        area_hi = area_hi_tmp(:,time_in_mesh)
        return
    end subroutine    
    
end module
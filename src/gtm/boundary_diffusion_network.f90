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
!> Boundary diffusive flux interface to be fulfilled by driver or application
!>@ingroup gtm_driver
module boundary_diffusion_network

    use gtm_precision
    use error_handling    
    use boundary_diffusion
    use dispersion_coefficient        
    real(gtm_real), allocatable, save :: disp_coef_arr(:)
    integer, allocatable :: aap(:)
    integer, allocatable :: aai(:)
    real(gtm_real), allocatable :: aax(:)
    integer, allocatable :: rcind(:)        ! row and column count index
    integer, allocatable :: row(:)          ! row number
    integer, allocatable :: col(:)          ! column number
    integer, allocatable :: nco(:)          ! num of connected cells
    integer, allocatable :: ncc(:)          ! boundary concentration array index
    character(len=1), allocatable :: typ(:) ! cell type
    character(len=1), allocatable :: uds(:) ! up stream or downstream of node
    integer :: n_nonzero = LARGEINT

    abstract interface
        !> Generic interface for calculating BC of matrix that should be fulfilled by
        !> the driver or the client programs
        subroutine boundary_diffusive_network_matrix_if(center_diag ,       &
                                                        up_diag,            &     
                                                        down_diag,          &
                                                        right_hand_side,    &
                                                        explicit_diffuse_op,&
                                                        conc_prev,          &
                                                        area_prev,          &
                                                        area_lo_prev,       &
                                                        area_hi_prev,       &
                                                        disp_coef_lo_prev,  &
                                               disp_coef_hi_prev,  &
                                               conc,               &                                                                                                                                               
                                               area,               &
                                               area_lo,            &
                                               area_hi,            &          
                                               disp_coef_lo,       &
                                               disp_coef_hi,       &
                                               theta_stm,          &
                                               ncell,              &
                                               time,               & 
                                               nvar,               & 
                                               dx,                 &
                                               dt)      
        use gtm_precision
        implicit none
        !--- args 
        integer, intent(in) :: ncell                                       !< Number of cells
        integer, intent(in) :: nvar                                        !< Number of variables
        real(gtm_real), intent(in) :: down_diag(ncell,nvar)                !< Values of the coefficients below diagonal in matrix
        real(gtm_real), intent(in) :: center_diag(ncell,nvar)              !< Values of the coefficients at the diagonal in matrix
        real(gtm_real), intent(in) :: up_diag(ncell,nvar)                  !< Values of the coefficients above the diagonal in matrix
        real(gtm_real), intent(inout):: right_hand_side(ncell,nvar)        !< Values of the coefficients of the right hand side    
        real(gtm_real), intent(in) :: conc_prev(ncell, nvar)               !< concentration from previous time step
        real(gtm_real), intent(in) :: area_prev(ncell)                     !< area from previous time step
        real(gtm_real), intent(in) :: area_lo_prev(ncell)                  !< Low side area at previous time
        real(gtm_real), intent(in) :: area_hi_prev(ncell)                  !< High side area at previous time
        real(gtm_real), intent(in) :: disp_coef_lo_prev(ncell)             !< Low side constituent dispersion coef. at previous time
        real(gtm_real), intent(in) :: disp_coef_hi_prev(ncell)             !< High side constituent dispersion coef. at previous time
        real(gtm_real), intent(in) :: conc(ncell,nvar)                     !< Concentration
        real(gtm_real), intent(in) :: explicit_diffuse_op(ncell,nvar)      !< Explicit diffusive operator
        real(gtm_real), intent(in) :: area (ncell)                         !< Cell centered area at new time 
        real(gtm_real), intent(in) :: area_lo(ncell)                       !< Low side area at new time
        real(gtm_real), intent(in) :: area_hi(ncell)                       !< High side area at new time 
        real(gtm_real), intent(in) :: disp_coef_lo(ncell)                  !< Low side constituent dispersion coef. at new time
        real(gtm_real), intent(in) :: disp_coef_hi(ncell)                  !< High side constituent dispersion coef. at new time
        real(gtm_real), intent(in) :: time                                 !< Current time
        real(gtm_real), intent(in) :: theta_stm                            !< Explicitness coefficient; 0 is explicit, 0.5 Crank-Nicolson, 1 full implicit  
        real(gtm_real), intent(in) :: dx(ncell)                            !< Spatial step  
        real(gtm_real), intent(in) :: dt                                   !< Time step     
   
    end subroutine 
  end interface

  !> This pointer should be set by the driver or client code to specify the 
  !> treatment at the first and last row of coefficient matrix
  procedure(boundary_diffusive_network_matrix_if), pointer :: boundary_diffusion_network_matrix  => null()

    contains

    !> Set diffusion flux and diffusion matrix pointers to diffusion boundary 
    subroutine set_network_diffusion_boundary(network_bc_matrix)
        use error_handling
        implicit none
        procedure(boundary_diffusive_matrix_if), pointer :: network_bc_matrix  !< Diffusion matrix routine
        boundary_diffusion_matrix => network_bc_matrix
        return
    end subroutine
 
    
    !> Set dispersion coefficient interface to an implementation that is constant in space and time
    !> This routine sets the value of the constant dispersion coefficient as well.
    subroutine set_dispersion_arr(d_arr,  &
                                  ncell)

        implicit none
        integer, intent(in) :: ncell
        real(gtm_real),intent(in) :: d_arr(ncell)     !< array of dispersion coefficients
        allocate(disp_coef_arr(ncell))
        disp_coef_arr = d_arr
        dispersion_coef => assign_dispersion_coef
        return
    end subroutine    
    
    !> Implementation of diffusion_coef_if that sets dipsersion to a constant over space and time
    subroutine assign_dispersion_coef(disp_coef_lo,         &
                                      disp_coef_hi,         &
                                      flow,                 &
                                      flow_lo,              &
                                      flow_hi,              &
                                      time,                 &
                                      dx,                   &
                                      dt,                   &
                                      ncell,                &
                                      nvar)  
        use gtm_precision
        use error_handling
      
        implicit none
        !--- args          
        integer,intent(in)  :: ncell                         !< Number of cells
        integer,intent(in)  :: nvar                          !< Number of variables   
        real(gtm_real),intent(in) :: time                    !< Current time
        real(gtm_real),intent(in) :: dx(ncell)               !< Spatial step  
        real(gtm_real),intent(in) :: dt                      !< Time step 
        real(gtm_real),intent(in) :: flow_lo(ncell)          !< flow on lo side of cells centered in time
        real(gtm_real),intent(in) :: flow_hi(ncell)          !< flow on hi side of cells centered in time       
        real(gtm_real),intent(in) :: flow(ncell)             !< flow on center of cells 
        real(gtm_real),intent(out):: disp_coef_lo(ncell)     !< Low side constituent dispersion coef.
        real(gtm_real),intent(out):: disp_coef_hi(ncell)     !< High side constituent dispersion coef. 
        !real(gtm_real) :: scaling = 0.5d0
   
        disp_coef_hi = disp_coef_arr !*scaling
        disp_coef_lo = disp_coef_arr !*scaling
        
        deallocate(disp_coef_arr)
        
        return
    end subroutine
 
    !> Adjustments for network diffusion boundary flux
    subroutine network_boundary_diffusive_flux(diffusive_flux_lo, &
                                               diffusive_flux_hi, &
                                               conc,              &
                                               area_lo,           &
                                               area_hi,           &
                                               disp_coef_lo,      &  
                                               disp_coef_hi,      &
                                               ncell,             &
                                               nvar,              &
                                               time,              &
                                               dx,                &
                                               dt)
        use gtm_precision
        use error_handling
        use common_variables, only : n_node, dsm2_network
        use state_variables_network, only : node_conc
        implicit none
        !--- args
        integer, intent(in)  :: ncell                               !< Number of cells
        integer, intent(in)  :: nvar                                !< Number of variables
        real(gtm_real),intent(inout):: diffusive_flux_lo(ncell,nvar)!< Face flux, lo side
        real(gtm_real),intent(inout):: diffusive_flux_hi(ncell,nvar)!< Face flux, hi side
        real(gtm_real),intent(in)   :: area_lo(ncell)               !< Low side area centered at time
        real(gtm_real),intent(in)   :: area_hi(ncell)               !< High side area centered at time
        real(gtm_real),intent(in)   :: time                         !< Time
        real(gtm_real),intent(in)   :: conc(ncell,nvar)             !< Concentration 
        real(gtm_real),intent(in)   :: disp_coef_lo(ncell)          !< Low side constituent dispersion coef.
        real(gtm_real),intent(in)   :: disp_coef_hi(ncell)          !< High side constituent dispersion coef.
        real(gtm_real),intent(in)   :: dt                           !< Spatial step  
        real(gtm_real),intent(in)   :: dx(ncell)                    !< Time step     
        integer :: i, j, icell
        integer :: up_cell, down_cell

        do i = 1, n_node
            if ( dsm2_network(i)%boundary_no .ne. 0 ) then   ! if boundary and node concentration is given
                icell = dsm2_network(i)%cell_no(1)               
                if ( dsm2_network(i)%up_down(1) .eq. 1 ) then   ! upstream boundary
                    if ( dsm2_network(i)%node_conc .eq. 1 ) then
                        diffusive_flux_lo(icell,:) = minus*area_lo(icell)*disp_coef_lo(icell)*  &
                                                (conc(icell,:)-node_conc(i,:))/(half*dx(icell))
                    else
                        diffusive_flux_lo(icell,:) = diffusive_flux_hi(icell,:)
                    end if                            
                else                                            ! downstream boundary
                    if ( dsm2_network(i)%node_conc .eq. 1 ) then
                        diffusive_flux_hi(icell,:) = minus*area_hi(icell)*disp_coef_hi(icell)*  &
                                                (node_conc(i,:)-conc(icell,:))/(half*dx(icell))
                    else
                        diffusive_flux_hi(icell,:) = diffusive_flux_lo(icell,:)
                    end if
                end if    
            end if
            if ((dsm2_network(i)%junction_no .ne. 0) .and. (dsm2_network(i)%n_conn_cell .gt. 2)) then
                do j = 1, dsm2_network(i)%n_conn_cell
                   icell = dsm2_network(i)%cell_no(j)
                   if (dsm2_network(i)%up_down(j) .eq. 0) then  !cell at upstream of junction
                       diffusive_flux_hi(icell,:) = diffusive_flux_lo(icell,:)
                   else                                         !cell at downstream of junction
                       diffusive_flux_lo(icell,:) = diffusive_flux_hi(icell,:)
                   end if                           
                end do                
            end if
            if (dsm2_network(i)%nonsequential==1) then
                if (dsm2_network(i)%up_down(1) .eq. 0) then   !cell at upstream of junction 
                    up_cell = dsm2_network(i)%cell_no(1)
                    down_cell = dsm2_network(i)%cell_no(2)
                else                                          !cell at downstream of junction
                    up_cell = dsm2_network(i)%cell_no(2)
                    down_cell = dsm2_network(i)%cell_no(1)
                end if                                  
                diffusive_flux_hi(up_cell,:) = -(area_hi(up_cell)*disp_coef_hi(up_cell)*       &
                             (conc(down_cell,:) - conc(up_cell,:)))/(half*dx(down_cell)+half*dx(up_cell))
                diffusive_flux_lo(down_cell,:) = -(area_lo(down_cell)*disp_coef_lo(down_cell)* &
                             (conc(down_cell,:) - conc(up_cell,:)))/(half*dx(down_cell)+half*dx(up_cell))
            end if
        end do            
        return
    end subroutine


  !> Adjustments for network diffusion matrix
    subroutine network_diffusion_sparse_geom(ncell)
        use gtm_precision
        use error_handling
        use common_variables, only : n_node, n_junc, dsm2_network
        use state_variables_network, only : node_conc
        use utils
        implicit none
        !--- args                               
        integer, intent(in) :: ncell            !< Number of cells
   
        !---local        
        integer, parameter :: max_conn = 6
        integer :: a(ncell, max_conn)          ! cell id of associated cells to each cell
        integer :: s(ncell)                    ! number of associated cells for each cell
        integer :: i, j, k, icell, nconn       ! local variables
        character(len=1) :: t(ncell)           ! cell type. "u": upstream boundary, "d": downstream boundary
                                               !            "h": u/s of junction, "l": d/s of junction, "s": non-sequantial, "n": normal
        character(len=1) :: ud(ncell,max_conn) ! upstream or downstream of cell i, "u": upstream, "d":downstream, "n":exact cell
        integer :: nc(ncell)                   ! array index to obtain DSM2 boundary concentrations
              
        a(:,:) = LARGEINT
        a(2:ncell,1) = (/(j,j=1,ncell-1)/)
        a(1:ncell,2) = (/(j,j=1,ncell)/)
        a(1:ncell-1,3) = (/(j,j=2,ncell)/)
        s(1) = 2
        s(ncell) = 2
        s(2:ncell-1) = 3
        t = "n"
        ud(:,:) = "n"
        nc = 0
                             
        do i = 1, n_node
            !if ( (dsm2_network(i)%boundary_no.ne.0) .and. (dsm2_network(i)%node_conc.eq.1) ) then  !if boundary and node concentration is given
            if ( dsm2_network(i)%boundary_no.ne.0 ) then
                icell = dsm2_network(i)%cell_no(1)
                s(icell) = 2
                nc(icell) = i
                if (dsm2_network(i)%up_down(1) .eq. 1) then     ! upstream boundary
                    t(icell) = "u"
                    a(icell,:) = LARGEINT
                    a(icell,1) = icell
                    a(icell,2) =  icell+1 
                    ud(icell,1) = "n"
                    ud(icell,2) = "d"
                else                                            ! downstream boundary
                    t(icell) = "d"
                    a(icell,:) = LARGEINT
                    a(icell,1) = icell-1
                    a(icell,2) = icell
                    ud(icell,1) = "u"
                    ud(icell,2) = "n"
                end if    
            end if
            if ((dsm2_network(i)%junction_no .ne. 0) .and. (dsm2_network(i)%n_conn_cell .gt. 2)) then
                nconn = dsm2_network(i)%n_conn_cell
                do j = 1, dsm2_network(i)%n_conn_cell
                   icell = dsm2_network(i)%cell_no(j)
                   s(icell) = nconn + 1
                   if (dsm2_network(i)%up_down(j) .eq. 0) then  !cell at upstream of junction
                       t(icell) = "h"
                       a(icell,1) = icell-1
                       a(icell,2:nconn+1) = dsm2_network(i)%cell_no(1:nconn)
                       ud(icell,1) = "u"
                       ud(icell,2:nconn+1) = "d"
                   else                        !cell at downstream of junction
                       t(icell) = "l"                    
                       a(icell,1:nconn) = dsm2_network(i)%cell_no(1:nconn)
                       a(icell,nconn+1) = icell+1
                       ud(icell,1:nconn) = "u"
                       ud(icell,nconn+1) = "d"
                   end if
                   do k = 1, nconn+1
                       if (icell.eq.a(icell,k)) ud(icell,k) = "n"
                   end do                   
                   !call Qsortc(a(icell,:))
                end do                
            end if
            if (dsm2_network(i)%nonsequential==1) then
               if (dsm2_network(i)%up_down(1) .eq. 0) then   !cell at upstream of node
                   icell = dsm2_network(i)%cell_no(1)
                   t(icell) = "s" 
                   a(icell,1) = dsm2_network(i)%cell_no(1)-1
                   a(icell,2) = dsm2_network(i)%cell_no(1)
                   a(icell,3) = dsm2_network(i)%cell_no(2)
                   ud(icell,1) = "u"
                   ud(icell,2) = "n"
                   ud(icell,3) = "d"             
                   icell = dsm2_network(i)%cell_no(2)
                   t(icell) = "s" 
                   a(icell,1) = dsm2_network(i)%cell_no(1)
                   a(icell,2) = dsm2_network(i)%cell_no(2)
                   a(icell,3) = dsm2_network(i)%cell_no(2)+1
                   ud(icell,1) = "u"
                   ud(icell,2) = "n"
                   ud(icell,3) = "d"                             
                else                                          !cell at downstream of node
                   icell = dsm2_network(i)%cell_no(1)
                   t(icell) = "s" 
                   a(icell,1) = dsm2_network(i)%cell_no(2)
                   a(icell,2) = dsm2_network(i)%cell_no(1)
                   a(icell,3) = dsm2_network(i)%cell_no(1)+1
                   ud(icell,1) = "u"
                   ud(icell,2) = "n"
                   ud(icell,3) = "d"             
                   icell = dsm2_network(i)%cell_no(2)
                   t(icell) = "s" 
                   a(icell,1) = dsm2_network(i)%cell_no(2)-1
                   a(icell,2) = dsm2_network(i)%cell_no(2)
                   a(icell,3) = dsm2_network(i)%cell_no(1)
                   ud(icell,1) = "u"
                   ud(icell,2) = "n"
                   ud(icell,3) = "d"                        
                end if  
                !call Qsortc(a(icell,:)) 
            end if
        end do 

        n_nonzero = 0        
        do i = 1, ncell
            do j = 1, max_conn
                if (a(i,j).ne.LARGEINT) n_nonzero = n_nonzero + 1
            end do
        enddo                    
        allocate(rcind(n_nonzero))
        allocate(row(n_nonzero))
        allocate(col(n_nonzero))
        allocate(nco(n_nonzero))
        allocate(typ(n_nonzero))
        allocate(uds(n_nonzero))
        allocate(ncc(n_nonzero)) 
        rcind = LARGEINT
        row = LARGEINT
        col = LARGEINT    
        nco = LARGEINT
        typ = "n"
        uds = "n"
        ncc = LARGEINT
        k = 0
        do i = 1, ncell
            do j = 1, max_conn
                if (a(i,j).ne.LARGEINT) then
                    k = k + 1
                    rcind(k) = k
                    row(k) = i
                    col(k) = a(i,j)
                    nco(k) = s(i)
                    typ(k) = t(i)
                    uds(k) = ud(i,j)
                    ncc(k) = nc(i)
                    write(101,'(4i7,2a7,i7)') rcind(k), row(k), col(k), nco(k), typ(k), uds(k), ncc(k)
                end if
            end do
        end do
        allocate(aap(ncell+1), aai(n_nonzero), aax(n_nonzero))
        call rowcol2apai(aap, aai, row, col, rcind, n_nonzero, ncell)
        return
    end subroutine


  !> Adjustments for network diffusion matrix
    subroutine network_diffusion_sparse_matrix(center_diag ,       &
                                               up_diag,            &     
                                               down_diag,          &
                                               right_hand_side,    &
                                               explicit_diffuse_op,&
                                               conc_prev,          &
                                               area_prev,          &
                                               area_lo_prev,       &
                                               area_hi_prev,       &
                                               disp_coef_lo_prev,  &
                                               disp_coef_hi_prev,  &
                                               conc,               &                                                                                                                                               
                                               area,               &
                                               area_lo,            &
                                               area_hi,            &          
                                               disp_coef_lo,       &
                                               disp_coef_hi,       &
                                               theta_stm,          &
                                               ncell,              &
                                               time,               & 
                                               nvar,               & 
                                               dx,                 &
                                               dt)
        use gtm_precision
        use error_handling
        use common_variables, only : n_node, dsm2_network
        use state_variables_network, only : node_conc, prev_node_conc
        implicit none
        !--- args                        
        integer, intent(in) :: ncell                                       !< Number of cells
        integer, intent(in) :: nvar                                        !< Number of variables
        real(gtm_real), intent(in) :: down_diag(ncell,nvar)                !< Values of the coefficients below diagonal in matrix
        real(gtm_real), intent(in) :: center_diag(ncell,nvar)              !< Values of the coefficients at the diagonal in matrix
        real(gtm_real), intent(in) :: up_diag(ncell,nvar)                  !< Values of the coefficients above the diagonal in matrix
        real(gtm_real), intent(inout):: right_hand_side(ncell,nvar)        !< Values of the coefficients of the right hand side    
        real(gtm_real), intent(in) :: conc_prev(ncell, nvar)               !< concentration from previous time step
        real(gtm_real), intent(in) :: area_prev(ncell)                     !< area from previous time step
        real(gtm_real), intent(in) :: area_lo_prev(ncell)                  !< Low side area at previous time
        real(gtm_real), intent(in) :: area_hi_prev(ncell)                  !< High side area at previous time
        real(gtm_real), intent(in) :: disp_coef_lo_prev(ncell)             !< Low side constituent dispersion coef. at previous time
        real(gtm_real), intent(in) :: disp_coef_hi_prev(ncell)             !< High side constituent dispersion coef. at previous time
        real(gtm_real), intent(in) :: conc(ncell,nvar)                     !< Concentration
        real(gtm_real), intent(in) :: explicit_diffuse_op(ncell,nvar)      !< Explicit diffusive operator
        real(gtm_real), intent(in) :: area (ncell)                         !< Cell centered area at new time 
        real(gtm_real), intent(in) :: area_lo(ncell)                       !< Low side area at new time
        real(gtm_real), intent(in) :: area_hi(ncell)                       !< High side area at new time 
        real(gtm_real), intent(in) :: disp_coef_lo(ncell)                  !< Low side constituent dispersion coef. at new time
        real(gtm_real), intent(in) :: disp_coef_hi(ncell)                  !< High side constituent dispersion coef. at new time
        real(gtm_real), intent(in) :: time                                 !< Current time
        real(gtm_real), intent(in) :: theta_stm                            !< Explicitness coefficient; 0 is explicit, 0.5 Crank-Nicolson, 1 full implicit  
        real(gtm_real), intent(in) :: dx(ncell)                            !< Spatial step  
        real(gtm_real), intent(in) :: dt                                   !< Time step     
        !---local
        real(gtm_real) :: x_int
        integer :: i, j, k, kk, icell
        integer :: up_cell, down_cell
        integer :: u_cell, n_cell, d_cell
        real(gtm_real) :: exp_diffusion_op_plus(nvar)
        real(gtm_real) :: exp_diffusion_op_minus(nvar)

        j = 1
        do i = 1, ncell
            if (typ(j).eq."u") then              ! "u": upstream boundary 
                x_int = half*(dx(i+1)+dx(i))
                do k = j, j + 1
                    if (uds(k).eq."n") then
                        aax(k) = area(i)+theta_stm*dt*area_lo(i)*disp_coef_lo(i)/(dx(i)*dx(i)*half) &
                                       +theta_stm*dt*area_hi(i)*disp_coef_hi(i)/(dx(i)*x_int)                                       
                    else                
                        aax(k) = -theta_stm*dt*area_hi(i)*disp_coef_hi(i)/(dx(i)*x_int)
                    end if
                end do
                where (prev_node_conc(ncc(j),:).eq.LARGEREAL) prev_node_conc(ncc(j),:) = conc(i,:) 
                where (node_conc(ncc(j),:).eq.LARGEREAL)  node_conc(ncc(j),:) = conc(i,:) !???                
                exp_diffusion_op_plus(:)  = -(one-theta_stm)*dt*area_hi_prev(i)*disp_coef_hi_prev(i) &
                                            *(conc_prev(i+1,:)-conc_prev(i,:))/x_int/dx(i)
                exp_diffusion_op_minus(:) = -(one-theta_stm)*dt*area_lo_prev(i)*disp_coef_lo_prev(i) &
                                            *(conc_prev(i,:)-prev_node_conc(ncc(j),:))/(half*dx(i))/dx(i)  
                right_hand_side(i,:) = area_prev(i)*conc_prev(i,:) - (exp_diffusion_op_plus(:)-exp_diffusion_op_minus(:)) &
                                       + theta_stm*dt*area_lo(i)*disp_coef_lo(i)*node_conc(ncc(j),:)/(half*dx(i)*dx(i))
                j = j + 2
            elseif (typ(j).eq."d") then         ! "d": downstream boundary
                x_int = half*(dx(i)+dx(i-1))
                do k = j, j + 1
                    if (uds(k).eq."n") then
                        aax(k) = area(i)+theta_stm*dt*area_hi(i)*disp_coef_hi(i)/(dx(i)*dx(i)*half)   &
                                       +theta_stm*dt*area_lo(i)*disp_coef_lo(i)/(dx(i)*x_int)
                    else
                        aax(k) = -theta_stm*dt*area_lo(i)*disp_coef_lo(i)/(dx(i)*x_int)
                    end if
                end do    
                where (prev_node_conc(ncc(j),:).eq.LARGEREAL) prev_node_conc(ncc(j),:) = conc(i,:)
                where (node_conc(ncc(j),:).eq.LARGEREAL) node_conc(ncc(j),:) = conc(i,:) !????? 
                exp_diffusion_op_plus(:) = -(one-theta_stm)*dt*area_hi_prev(i)*disp_coef_hi_prev(i) &
                                            *(prev_node_conc(ncc(j),:)-conc_prev(i,:))/(half*dx(i))/dx(i)
                exp_diffusion_op_minus(:) = -(one-theta_stm)*dt*area_lo_prev(i)*disp_coef_lo_prev(i) &
                                         *(conc_prev(i,:)- conc_prev(i-1,:))/x_int/dx(i)  
                right_hand_side(i,:) = area_prev(i)*conc_prev(i,:) - (exp_diffusion_op_plus-exp_diffusion_op_minus) &
                                       + theta_stm*dt*area_hi(i)*disp_coef_hi(i)*node_conc(ncc(j),:)/(half*dx(i)*dx(i))
                j = j + 2             
            elseif (typ(j).eq."h") then        ! "h": u/s of junction  
                exp_diffusion_op_plus = zero
                exp_diffusion_op_minus = zero
                do k = j, j + nco(j) - 1
                    if (uds(k).eq."u") then
                        aax(k) = -theta_stm*dt*area_lo(i)*disp_coef_lo(i)/dx(i)/(half*dx(i)+half*dx(i-1))                    
                    elseif (uds(k).eq."d") then
                        aax(k) = -theta_stm*dt*min(area_hi(i),area_lo(col(k)))*disp_coef_hi(i) &
                                /dx(i)/(half*dx(i)+half*dx(col(k)))/dble(nco(j)-2)
                    else
                        aax(k) = area(i) + theta_stm*dt*area_lo(i)*disp_coef_lo(i)/dx(i)/(half*dx(i)+half*dx(i-1))
                        do kk = j, j + nco(j) - 1
                            if (uds(kk).eq."d") then
                                aax(k) = aax(k) + theta_stm*dt*min(area_hi(i),area_lo(col(kk)))*disp_coef_hi(i)   &
                                                /dx(i)/(half*dx(i)+half*dx(col(kk)))/dble(nco(j)-2)
                                exp_diffusion_op_plus(:) = exp_diffusion_op_plus(:)  &
                                                          -(one-theta_stm)*dt*area_hi_prev(i)*disp_coef_hi_prev(i) &
                                                          *(conc_prev(col(kk),:)-conc_prev(i,:))/(half*dx(col(kk))+half*dx(i))/dx(i)                                
                            end if
                        end do                    
                    end if                                
                end do
                exp_diffusion_op_minus(:) = -(one-theta_stm)*dt*area_lo_prev(i)*disp_coef_lo_prev(i) &
                                            *(conc_prev(i,:)- conc_prev(i-1,:))/(half*dx(i)+half*dx(i-1))/dx(i)
                right_hand_side(i,:) = area_prev(i)*conc_prev(i,:)-(exp_diffusion_op_plus(:)-exp_diffusion_op_minus(:))
                j = j + nco(j)
            elseif (typ(j).eq."l") then       ! "l": d/s of junction
                exp_diffusion_op_plus = zero
                exp_diffusion_op_minus = zero            
                do k = j, j + nco(j) - 1
                    if (uds(k).eq."d") then
                        aax(k) = -theta_stm*dt*area_hi(i)*disp_coef_hi(i)/dx(i)/(half*dx(i)+half*dx(i+1))                    
                    elseif (uds(k).eq."u") then
                        aax(k) = -theta_stm*dt*min(area_hi(i),area_lo(col(k)))*disp_coef_lo(i)  &
                                /dx(i)/(half*dx(i)+half*dx(col(k)))/dble(nco(j)-2)
                    else
                        aax(k) = area(i) + theta_stm*dt*area_hi(i)*disp_coef_hi(i)/dx(i)/(half*dx(i)+half*dx(i+1))
                        do kk = j, j + nco(j) - 1
                            if (uds(kk).eq."u") then
                                aax(k) = aax(k) + theta_stm*dt*min(area_lo(i),area_hi(col(kk)))*disp_coef_lo(i)  &
                                                /dx(i)/(half*dx(i)+half*dx(col(kk)))/dble(nco(j)-2)
                                 exp_diffusion_op_plus(:) = exp_diffusion_op_plus(:)  &
                                                          -(one-theta_stm)*dt*area_lo_prev(i)*disp_coef_lo_prev(i) &
                                                          *(conc_prev(i,:)-conc_prev(col(kk),:))/(half*dx(i)+half*dx(col(kk)))/dx(i) 
                            end if
                        end do                    
                    end if                    
                end do 
                exp_diffusion_op_minus(:) = -(one-theta_stm)*dt*area_hi_prev(i)*disp_coef_hi_prev(i) &
                                            *(conc_prev(i+1,:)- conc_prev(i,:))/(half*dx(i)+half*dx(i+1))/dx(i)
                right_hand_side(i,:) = area_prev(i)*conc_prev(i,:)+(exp_diffusion_op_plus(:)-exp_diffusion_op_minus(:))                
                      
                j = j + nco(j)     
            elseif (typ(j).eq."s") then      ! "s": non-sequantial 
                do k = j, j + 2
                    if (uds(k).eq."u") then
                        u_cell = col(k)
                    elseif (uds(j).eq."n") then
                        n_cell = col(k)
                    else
                        d_cell = col(k)
                    end if
                end do
                do k = j, j + 2
                    if (uds(k).eq."u") then
                        aax(k) = -theta_stm*dt*area_lo(i)*disp_coef_lo(i)/dx(i)/(half*dx(i)+half*dx(u_cell))
                    elseif (uds(j).eq."n") then
                        aax(k) = area(i) + theta_stm*dt*area_lo(i)*disp_coef_lo(i)/dx(i)/(half*dx(i)+half*dx(u_cell))  &    
                                + theta_stm*dt*area_hi(i)*disp_coef_hi(i)/dx(i)/(half*dx(i)+half*dx(d_cell))
                    else
                        aax(k) = -theta_stm*dt*area_hi(i)*disp_coef_hi(i)/dx(i)/(half*dx(i)+half*dx(d_cell))
                    end if
                end do
                exp_diffusion_op_plus  = -(one-theta_stm)*dt*area_hi_prev(i)*disp_coef_hi_prev(i)*(conc_prev(d_cell,:)-conc_prev(i,:))/(half*dx(i)+half*dx(d_cell))/dx(i)
                exp_diffusion_op_minus = -(one-theta_stm)*dt*area_lo_prev(i)*disp_coef_lo_prev(i)*(conc_prev(i,:)-conc_prev(u_cell,:))/(half*dx(i)+half*dx(u_cell))/dx(i)
                right_hand_side(i,:) = area_prev(i)*conc_prev(i,:) - (exp_diffusion_op_plus-exp_diffusion_op_minus)
                j = j + 3
            else                          ! "n": normal
                aax(j)= up_diag(i-1,1)
                aax(j+1) = center_diag(i,1)
                aax(j+2) = down_diag(i+1,1)
                j = j + 3
            end if
        end do
        return
    end subroutine            


    !> deallocate global variables for sparse matrix
    subroutine deallocate_geom_arr()
        implicit none
        deallocate(aap, aai, aax)
        deallocate(rcind, row, col)
        deallocate(nco, ncc)
        deallocate(typ, uds)
        n_nonzero = LARGEINT
        return
    end subroutine    
    

end module  
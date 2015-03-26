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

!> Boundary diffusive flux interface to be fulfilled by driver or application
!>@ingroup gtm
module diffusion_network

    contains
 
    !> Calculates the diffusive portion of the constituent transport.
    !> It contains an explicit version of the diffusion operator and a general (involving all
    !> potential cases) diffusion operator as well, with a coefficient theta_stm for 
    !> selecting the level of implicitness. (theta_stm=0.5 is Crank Nicolson.).
    !> The matrix is solved via a tri-diagonal solver.  !
    !> The algoritm looks like this:
    !>   - This creates the diffusive fluxes sends them for modification for boundaries and then differences the fluxes to get the operator d/dx(Ad/dx). 
    !>         - Calculate interior and boundary fluxes 
    !>   - Construct right hand side with neumann boundary condition imposed
    !>   - Construct diffusion coefficeint matrix with neumann boundary condition imposed
    !>   - Solve the system
    subroutine diffuse_network(conc,              &
                               conc_prev,         &
                               area,              &
                               area_prev,         &
                               area_lo,           &
                               area_hi,           &
                               area_lo_prev,      &
                               area_hi_prev,      &
                               disp_coef_lo,      &  
                               disp_coef_hi,      &
                               disp_coef_lo_prev, &  
                               disp_coef_hi_prev, &
                               ncell,             &
                               nvar,              &
                               time_new,          &
                               theta_stm,         &
                               dt,                &
                               dx)

        use gtm_precision
        use primitive_variable_conversion 
        use diffusion
        use boundary_diffusion_network
        use klu

        implicit none
        ! ---- args
        integer, intent (in) :: ncell                                !< Number of cells
        integer, intent (in) :: nvar                                 !< Number of variables 

        real(gtm_real), intent (out):: conc(ncell,nvar)              !< Concentration at new time
        real(gtm_real), intent (in) :: conc_prev(ncell,nvar)         !< Concentration at old time
        real(gtm_real), intent (in) :: area (ncell)                  !< Cell-centered area at new time
        real(gtm_real), intent (in) :: area_prev (ncell)             !< Cell-centered area at old time
        real(gtm_real), intent (in) :: area_lo (ncell)               !< Low side area centered in time
        real(gtm_real), intent (in) :: area_hi (ncell)               !< High side area centered in time 
        real(gtm_real), intent (in) :: area_lo_prev (ncell)          !< Low side area centered at old time
        real(gtm_real), intent (in) :: area_hi_prev (ncell)          !< High side area centered at old time 
        real(gtm_real), intent (in) :: disp_coef_lo (ncell,nvar)     !< Low side constituent dispersion coef. at new time
        real(gtm_real), intent (in) :: disp_coef_hi (ncell,nvar)     !< High side constituent dispersion coef. at new time
        real(gtm_real), intent (in) :: disp_coef_lo_prev(ncell,nvar) !< Low side constituent dispersion coef. at old time
        real(gtm_real), intent (in) :: disp_coef_hi_prev(ncell,nvar) !< High side constituent dispersion coef. at old time
        real(gtm_real), intent (in) :: time_new                      !< Instantaneous "new" time to which we are advancing
        real(gtm_real), intent (in) :: theta_stm                     !< Explicitness coefficient; 0 is explicit, 0.5 Crank-Nicolson, 1 full implicit  
        real(gtm_real), intent (in) :: dt                            !< Time step   
        real(gtm_real), intent (in) :: dx(ncell)                     !< Spacial step 

        !---- locals
        real(gtm_real) :: explicit_diffuse_op(ncell,nvar)             !< Explicit diffusive operator
        real(gtm_real) :: down_diag(ncell,nvar)                       !< Values of the coefficients below diagonal in matrix
        real(gtm_real) :: center_diag(ncell,nvar)                     !< Values of the coefficients at the diagonal in matrix
        real(gtm_real) :: up_diag(ncell,nvar)                         !< Values of the coefficients above the diagonal in matrix
        real(gtm_real) :: right_hand_side(ncell,nvar)                 !< Right hand side vector
        real(gtm_real) :: time_prev                                   !< old time 

        ! This routine gives the effects of diffusion fluxes on each cell
        ! for a single time step (ie, explicit). This is needed for the advection step.
        ! It is also part of the right hand side of the implicit diffusion solver 
        ! matrix calculation.  

        ! Explicit diffusion operator construction. This creates the diffusive fluxes
        ! sends them for modification for boundaries and then differences the fluxes
        ! to get the operator d/dx(Ad/dx). 
        ! instantaneous function
        time_prev = time_new - dt 

        call explicit_diffusion_operator(explicit_diffuse_op,&
                                         conc_prev,          &
                                         area_lo_prev,       &
                                         area_hi_prev,       &
                                         disp_coef_lo_prev,  &  
                                         disp_coef_hi_prev,  &
                                         ncell,              &
                                         nvar,               &
                                         time_prev,          &
                                         dx,                 &
                                         dt)
  
        call construct_right_hand_side(right_hand_side,       & 
                                       explicit_diffuse_op,   & 
                                       area_prev,             &
                                       area_lo_prev,          &
                                       area_hi_prev,          &
                                       disp_coef_lo_prev,     &
                                       disp_coef_hi_prev,     &
                                       conc_prev,             &
                                       theta_stm,             &
                                       ncell,                 &
                                       time_prev,             &
                                       nvar,                  &  
                                       dx,                    &
                                       dt)
                                                                   
        ! Construct the matrix for the diffusion solver
        ! without boundary condition modification or structure on interior of domain
        call construct_diffusion_matrix(center_diag ,     &
                                        up_diag,          &     
                                        down_diag,        &
                                        area,             &
                                        area_lo,          &
                                        area_hi,          &
                                        disp_coef_lo,     &
                                        disp_coef_hi,     &
                                        theta_stm,        &
                                        ncell,            &
                                        time_new,         & 
                                        nvar,             & 
                                        dx,               &
                                        dt)
                                        
        ! this cannot use single channel boundary diffusion                                   
        call boundary_diffusion_network_matrix(center_diag ,        &
                                               up_diag,             &     
                                               down_diag,           &
                                               right_hand_side,     &
                                               explicit_diffuse_op, &
                                               conc_prev,           &
                                               area_prev,           &
                                               area_lo_prev,        &
                                               area_hi_prev,        &
                                               disp_coef_lo_prev,   &
                                               disp_coef_hi_prev,   &
                                               conc,                &                                                                                                                                               
                                               area,                &
                                               area_lo,             &
                                               area_hi,             &          
                                               disp_coef_lo,        &
                                               disp_coef_hi,        &
                                               theta_stm,           &
                                               ncell,               &
                                               time_new,            & 
                                               nvar,                & 
                                               dx,                  &
                                               dt)
        
        call klu_fortran_refactor(ica, jca, coo, k_symbolic, k_numeric, k_common)
        call klu_fortran_solve(k_symbolic, k_numeric, matrix_size, 1, conc, k_common)

        return
    end subroutine 

end module
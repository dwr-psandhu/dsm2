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

!> Generic convergence test with advection, diffusion and source terms
!>@ingroup test_transport
module test_convergence_transport

    contains

    !> Subroutine that tests convergence for advection, diffusion and source terms
    !> A fine grid initial condition and solution at time total_time
    !> must be provided. 
    subroutine test_convergence(label,                &
                                hydro,                &
                                bc_advective_flux,    &
                                bc_diffusive_flux,    &
                                bc_diffusive_matrix,  &
                                source_term,          &                          
                                domain_length,        &
                                total_time,           &
                                start_time,           &
                                fine_initial_conc,    &
                                fine_solution,        &           
                                nstep_base,           &
                                nx_base,              &
                                nconc,                &
                                n_dsm2_node,          &
                                dsm2_node_type,       &
                                node_conc,            &
                                verbose,              &
                                detail_printout,      &
                                acceptance_ratio)
        use error_handling                             
        use hydro_data
        use boundary_advection
        use gtm_precision
        use state_variables
        use primitive_variable_conversion 
        use advection
        use diffusion
        use boundary_diffusion
        use gaussian_init_boundary_condition
        use fruit
        use gtm_logging
        use test_utility
        use source_sink
        use dispersion_coefficient
        use common_variables, only: dsm2_node_t

        implicit none

        !--- Problem variables
        procedure(hydro_data_if), pointer, intent(in)               :: hydro                !< Hydrodynamics
        procedure(boundary_advective_flux_if),pointer, intent(in)   :: bc_advective_flux    !< Advection BC
        procedure(boundary_diffusive_flux_if),pointer, intent(in)   :: bc_diffusive_flux    !< Diffusion BC
        procedure(boundary_diffusive_matrix_if),pointer, intent(in) :: bc_diffusive_matrix  !< Diffusion BC
        procedure(source_if),pointer, intent(in)                    :: source_term          !< Source term 

        character(LEN=*),intent(in) :: label                            !< Unique label for test
        logical,intent(in) :: verbose                                   !< Whether to output convergence results
        integer, intent(in) :: nconc                                    !< Number of constituents
        integer, intent(in) :: nstep_base                               !< Number of steps at finest resolution
        integer, intent(in) :: nx_base                                  !< Number of cells at finest resolution
        integer, intent(in) :: n_dsm2_node
        type(dsm2_node_t) :: dsm2_node_type(n_dsm2_node)
        
        real(gtm_real), intent(in) :: fine_initial_conc(nx_base,nconc)  !< Initial condition at finest resolution
        real(gtm_real), intent(in) :: fine_solution(nx_base,nconc)      !< Reference solution at finest resolution
        real(gtm_real), intent(in) :: total_time                        !< Total time of simulation
        real(gtm_real), intent(in) :: start_time                        !< Start time of simulation
        real(gtm_real), intent(in) :: domain_length                     !< Length of domain
        real(gtm_real), intent(in) :: node_conc(n_dsm2_node, nconc)     !< boundary condition
        logical, intent(in),optional :: detail_printout                 !< Whether to produce detailed printouts
        real(gtm_real), intent(in) :: acceptance_ratio(3)               !< Acceptance ratio for test convergence
        
        !---local
        logical :: detailed_printout= .true.                            !< Printout Flag
        integer, parameter :: nrefine = 3                               !< Number of refinements 
        integer, parameter :: coarsen_factor = 2                        !< Coarsening factor used for convergence test
        integer :: itime                                                !< Counter (time)
        integer :: icell                                                !< Counter (cell)
        integer :: icoarse                                              !< Counter (coarsening)
        integer :: nstep                                                !< Number of steps  
        integer :: nx                                                   !< Number of cells
        integer :: which_cell(nrefine)                                  !< Number of the cell worst error occures at 
        integer :: coarsening                           
        character(LEN=64)  ::  filename                                  
        character(LEN=256) ::  converge_message
        logical, parameter :: limit_slope = .false.         !< Flag to switch on/off slope limiter  
        real(gtm_real), allocatable :: solution_mass(:,:)   !< Mass in the exact solution
        real(gtm_real), allocatable :: reference(:,:)       !< Reference values
        real(gtm_real), allocatable :: x_center(:)          !< Location of the centers of cells
        real(gtm_real), allocatable :: velocity (:)         !< Velocity
        real(gtm_real), allocatable :: disp_coef_lo(:)      !< Low side constituent dispersion coef. at new time
        real(gtm_real), allocatable :: disp_coef_hi(:)      !< High side constituent dispersion coef. at new time
        real(gtm_real), allocatable :: disp_coef_lo_prev(:) !< Low side constituent dispersion coef. at old time
        real(gtm_real) ,allocatable :: disp_coef_hi_prev(:) !< High side constituent dispersion coef. at old time
        real(gtm_real) :: theta = half                      !< Crank-Nicolson implicitness coeficient
        real(gtm_real) :: ratio                             !< Norms ratio
        real(gtm_real) :: max_velocity                      !< Maximum Velocity
        real(gtm_real) :: min_conc                          !< Minimum concentration   
        real(gtm_real) :: fine_initial_mass(nx_base,nconc)  !< initial condition at finest resolution
        real(gtm_real) :: fine_solution_mass(nx_base,nconc) !< reference solution at finest resolution
        real(gtm_real) :: dt                                !< Time step in seconds
        real(gtm_real), allocatable :: dx(:)                !< Spatial step in meters
        real(gtm_real) :: time                              !< Current time
        real(gtm_real) :: norm_error(3,nrefine)             !< Norm of error

        if (present(detail_printout))then
            detailed_printout = detail_printout
        else 
            detailed_printout = .false.
        end if

        !todo: this should be much simpler. Should just be able to say "compute_source => source_term
        !      however at present (intel 11.1 pointer reassignment is buggy (or doing something wrong)
        if (associated(source_term,no_source))then
            !compute_source => no_source
            elseif(associated(source_term,linear_decay_source))then
            !compute_source => linear_decay_source
            else
            !compute_source => no_source
        end if
        advection_boundary_flux => bc_advective_flux

        !todo: this had to be disabled. 
        !call set_diffusion_boundary(bc_diffusive_flux,bc_diffusive_matrix)

        filename=label
        ! coarsening factor in convergence test
        do icoarse = 1,nrefine
            coarsening = coarsen_factor**(icoarse-1)
            nx = nx_base/(coarsening)
            nstep = nstep_base/(coarsening)
            call allocate_state(nx,nconc)
            allocate(x_center(nx))
            allocate(reference(nx,nconc))
            allocate(solution_mass(nx,nconc))
            allocate(velocity (nx))
            allocate(dx(nx))

            allocate(disp_coef_lo(nx),      &
                     disp_coef_hi(nx),      &
                     disp_coef_lo_prev(nx), &
                     disp_coef_hi_prev(nx))
                     
            dsm2_node_type(2)%cell_no(1) = nx
            
            dx = domain_length/dble(nx)
            dt = total_time/dble(nstep)        

            do icell = 1,nx
                x_center(icell) = (dble(icell)-half)*dx(icell)
            end do

            time = start_time
            ! Get cell centered data for t(n+1)
            ! and face data for t(n+1/2)
            call hydro(flow,    &
                       flow_lo, &
                       flow_hi, &
                       area,    &
                       area_lo, &
                       area_hi, &
                       nx,      &
                       time,    &
                       dx,      &                  
                       dt)
            area_prev = area
            area_hi_prev = area_hi
            area_lo_prev = area_lo
    
            if (use_diffusion())then
                call dispersion_coef(disp_coef_lo,         &
                                     disp_coef_hi,         &
                                     flow,                 &
                                     flow_lo,              &
                                     flow_hi,              &
                                     time,                 &
                                     dx,                   &
                                     dt,                   &
                                     nx,                   &
                                     nconc) 
            else
                disp_coef_lo = LARGEREAL
                disp_coef_hi = LARGEREAL            
            end if
            disp_coef_lo_prev = disp_coef_lo
            disp_coef_hi_prev = disp_coef_hi    
    
            if (icoarse == 1)then
                call prim2cons(fine_initial_mass,fine_initial_conc,area,nx,nconc)
             end if
        
            call coarsen(mass,fine_initial_mass,nx_base,nx,nconc)
            call cons2prim(conc,mass,area,nx,nconc)
            if (detailed_printout)then
                write(filename, "(a,'_init_',i4.4,'.txt')") trim(label), nx        
                call printout(conc(:,2),x_center(:),filename)
            end if

            mass_prev = mass
            conc_prev = conc
            max_velocity =zero

            do itime = 1,nstep
                time = time + dt
       
                ! Get cell centered data for t(n+1)
                ! and face data for t(n+1/2)
                call hydro(flow,    &
                           flow_lo, &
                           flow_hi, &
                           area,    &
                           area_lo, &
                           area_hi, &
                           nx,      &
                           time,    &
                           dx,      &                  
                           dt)

               if (label=="advection_tidal_sinusoidal") then       ! to print out synthetic flow
                   write(141,'(512f8.3)') (flow(icell),icell=1,nx)        
                   write(142,'(512f8.3)') (area(icell),icell=1,nx)              
               endif
      
               if (maxval(abs(flow)/area) >=  max_velocity) then
                   max_velocity = maxval(abs(flow)/area)
               end if
       
               ! call advection and source
               call advect(mass,           &
                           mass_prev,      &  
                           flow,           &
                           flow_lo,        &
                           flow_hi,        &
                           area,           &
                           area_prev,      &
                           area_lo,        &
                           area_hi,        &
                           nx,             &
                           nconc,          &
                           time,           &
                           dt,             &
                           dx,             &
                           n_dsm2_node,    &
                           dsm2_node_type, &
                           node_conc,      &
                           limit_slope)

               call cons2prim(conc,mass,area,nx,nconc) 
               conc_prev = conc
      
               if (use_diffusion()) then
                   call dispersion_coef(disp_coef_lo,         &
                                        disp_coef_hi,         &
                                        flow,                 &
                                        flow_lo,              &
                                        flow_hi,              &
                                        time,                 &
                                        dx,                   &
                                        dt,                   &
                                        nx,                   &
                                        nconc)  
                                   
                    call diffuse(conc,              &
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
                                 nx,                &
                                 nconc,             &
                                 time,              &
                                 theta,             &
                                 dt,                &
                                 dx)
               end if
                       
               call prim2cons(mass,conc,area,nx,nconc)
               mass_prev = mass
               area_prev = area
               disp_coef_lo_prev = disp_coef_lo
               disp_coef_hi_prev = disp_coef_hi
      
               min_conc = minval(conc)
               if (min_conc < zero)then
                   !print *,'Negative concentration !!!!!','Conc =',minval(conc), label           
               end if     
      
               if (detailed_printout) then
                   if (itime == nstep/2)then
                       write(filename, "(a,'_mid_',i4.4,'.txt')") trim(label), nx        
                       call printout(conc(:,2),x_center(:),filename)
                   end if
                   if (itime == nstep/4)then
                       write(filename, "(a,'_fourth_',i4.4,'.txt')") trim(label), nx        
                       call printout(conc(:,2),x_center(:),filename)
                   end if
                   if (itime == 3*nstep/4)then
                       write(filename, "(a,'_three_fourth_',i4.4,'.txt')") trim(label), nx        
                       call printout(conc(:,2),x_center(:),filename)
                   end if
               end if
            end do

            ! Now take fine solution (provided in concentration) and coarsen it to
            ! a reference solution at the current level of refinement. This needs to 
            ! be done by converting it to mass, coarsening, then converting back to
            ! a reference concentration
            if (icoarse == 1) then
                call prim2cons(fine_solution_mass,fine_solution,area,nx,nconc)
            end if

            call coarsen(solution_mass,fine_solution_mass,nx_base,nx, nconc)
            call cons2prim(reference,solution_mass,area,nx,nconc)
    
            if (detailed_printout)then
                write(filename, "(a,'_solution_',i4.4,'.txt')") trim(label), nx        
                call printout(reference(:,2),x_center(:),filename)
                write(filename, "(a,'_end_',i4.4,'.txt')") trim(label), nx 
                call printout(conc(:,2),x_center(:),filename)
            end if 
    
            ! test error norm over part of domain
            call error_norm(norm_error(1,icoarse), &
                            norm_error(2,icoarse), &
                            norm_error(3,icoarse), &
                            which_cell(icoarse),   &
                            conc(:,2),reference(:,2),nx,dx) 
            deallocate(solution_mass)
            deallocate(reference)
            deallocate(x_center)
            deallocate(velocity)
            deallocate(dx)
            deallocate(disp_coef_lo,      &
                       disp_coef_hi,      &
                       disp_coef_lo_prev, &
                       disp_coef_hi_prev)   
            call deallocate_state
    
        end do
        ratio = norm_error(1,2)/norm_error(1,1)
        call create_converge_message(converge_message,"L-1   (fine)   ",trim(label),ratio)
        call assert_true(ratio > acceptance_ratio(1),trim(converge_message))
        ratio = norm_error(2,2)/norm_error(2,1)
        call create_converge_message(converge_message,"L-2   (fine)   ",trim(label),ratio)
        call assert_true(ratio > acceptance_ratio(2),trim(converge_message))
        ratio = norm_error(3,2)/norm_error(3,1)
        call create_converge_message(converge_message,"L-inf (fine)   ",trim(label),ratio)
        call assert_true(ratio > acceptance_ratio(3),trim(converge_message))

        ratio = norm_error(1,3)/norm_error(1,2)
        call create_converge_message(converge_message,"L-1   (coarse) ",trim(label),ratio)
        call assert_true(ratio > acceptance_ratio(1),trim(converge_message))
        ratio = norm_error(2,3)/norm_error(2,2)
        call create_converge_message(converge_message,"L-2   (coarse) ",trim(label),ratio)
        call assert_true(ratio > acceptance_ratio(2),trim(converge_message))
        ratio = norm_error(3,3)/norm_error(3,2)
        call create_converge_message(converge_message,"L-inf (coarse) ",trim(label),ratio)
        call assert_true(ratio > acceptance_ratio(3),trim(converge_message))

        if (verbose == .true.) then
        !call log_convergence_results(norm_error ,                   &
        !                             nrefine,                       &
        !                             dx,                            &
        !                             dt,                            &
        !                             max_velocity= max_velocity,    &
        !                             dispersion = const_dispersion, &
        !                             label = label,                 &
        !                             which_cell=which_cell,         &
        !                             ncell_base = nx_base,          &
        !                             ntime_base = nstep_base,       &
        !                             scheme_order = two,            &
        !                             length_scale = dx,             &
        !                             limiter_switch = limit_slope)                          
        end if

        ! todo: set pointers to null so that if future tests don't set the interfaces an obvious 
        ! error will result
        !source => null()
        !or 
        !call unset_interfaces()
        return
    end subroutine


     !> Define a single channel network
     subroutine set_single_channel(dsm2_node_type, ncell)
         use common_variables, only: dsm2_node_t
         implicit none
         integer, intent(in) :: ncell                         !< number of cells
         type(dsm2_node_t), intent(out) :: dsm2_node_type(2)  !< DSM2 node structure
         allocate(dsm2_node_type(1)%cell_no(1))
         allocate(dsm2_node_type(1)%up_down(1))
         allocate(dsm2_node_type(2)%cell_no(1))
         allocate(dsm2_node_type(2)%up_down(1))         
         dsm2_node_type(1)%dsm2_node_no = 1
         dsm2_node_type(1)%n_conn_cell = 1
         dsm2_node_type(1)%boundary_no = 1
         dsm2_node_type(1)%junction_no = 0
         dsm2_node_type(1)%reservoir_no = 0
         dsm2_node_type(1)%n_qext = 0
         dsm2_node_type(1)%nonsequential = 0
         dsm2_node_type(1)%no_fixup = 1
         dsm2_node_type(1)%ts_index = 1
         dsm2_node_type(1)%cell_no(1) = 1
         dsm2_node_type(1)%up_down(1) = 1
         dsm2_node_type(2)%dsm2_node_no = 2
         dsm2_node_type(2)%n_conn_cell = 1
         dsm2_node_type(2)%boundary_no = 2
         dsm2_node_type(2)%junction_no = 0
         dsm2_node_type(2)%reservoir_no = 0
         dsm2_node_type(2)%n_qext = 0
         dsm2_node_type(2)%nonsequential = 0
         dsm2_node_type(2)%no_fixup = 1
         dsm2_node_type(2)%ts_index = 2
         dsm2_node_type(2)%cell_no(1) = ncell
         dsm2_node_type(2)%up_down(1) = 0              
         return
     end subroutine
     
end module
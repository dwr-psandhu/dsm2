!<license>
!    Copyright (C) 2016 State of California,
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

!> Routines provide the general calculation for suspended sediment sinks/sources routines.
!> All the constant based drived variables are here
!>@ingroup sediment

module suspended_utility

    contains

    !> Calculates particle's settling velocity. NOTE: the subroutine works with SI units.
    !> Settling velocity formula based on Leo van Rijn (1984b).
    !> The subroutine does not consider particles smaller than 10 microns (fine clay).
    !> The smaller particles are assumed to be either part of wash load or pertain to cohesive sediment. 
    !> The subroutine is for non-cohesive particles.
    subroutine settling_velocity(settling_v,         &
                                 kinematic_viscosity,&
                                 specific_gravity,   &
                                 diameter,           &
                                 g_acceleration,     &
                                 nclass,             &
                                 function_van_rijn)                
        use gtm_precision
        implicit none
        !--- arg
        integer,intent(in)         :: nclass              !< Number of sediment diameter classes
        real(gtm_real),intent(out) :: settling_v(nclass)  !< Settling velocity (m/s)
        real(gtm_real),intent(in)  :: kinematic_viscosity !< Kinematic viscosity (m2/sec)
        real(gtm_real),intent(in)  :: specific_gravity    !< Specific gravity of particle (~2.65)
        real(gtm_real),intent(in)  :: diameter(nclass)    !< Particle diameter in meter
        real(gtm_real),intent(in)  :: g_acceleration      !< Gravitational acceleration (m/sec2)
        logical, optional          :: function_van_rijn   !< Flag for using van Rijn (1984) formula o/ Dietrich (1982). the default is van Rijn
        !--local
        logical :: van_rijn_flag
        integer :: iclass
        ! I checked the following values with the ebook on the website of Parker (UIUC)
        real(gtm_real) :: b_1 = 2.891394d0
        real(gtm_real) :: b_2 = 0.95296d0
        real(gtm_real) :: b_3 = 0.056835d0
        real(gtm_real) :: b_4 = 0.002892d0
        real(gtm_real) :: b_5 = 0.000245d0
        real(gtm_real) :: dimless_fall_velocity(nclass)  ! todo: should we consider the local varibles in 
        real(gtm_real) :: exp_re_p(nclass)               !< Explicit Reynols particle number 
        real(gtm_real) :: capital_r                      !< Submerged specific gravity of sediment particles 

        if (present(function_van_rijn)) then
            van_rijn_flag = function_van_rijn
        end if
 
        select case (van_rijn_flag)
 
            case (.true.)
            ! van Rijn formula
            do iclass=1,nclass
                if (diameter(iclass) > 1.0d-3)     then
                    settling_v(iclass) = 1.1d0*dsqrt((specific_gravity - one)*g_acceleration*diameter(iclass))
                elseif (diameter(iclass) > 1.0d-4) then
                    settling_v(iclass) = (ten*kinematic_viscosity/diameter(iclass))*(dsqrt(one + (0.01d0*(specific_gravity - one) &
                                         *g_acceleration*diameter(iclass)**three)/kinematic_viscosity**two)- one)
                elseif (diameter(iclass) > 0.9d-7) then
                    ! Stokes law here
                    settling_v(iclass) = ((specific_gravity - one)*g_acceleration*diameter(iclass)**two)/(18.0d0*kinematic_viscosity)
                else
                    settling_v(iclass) = minus * LARGEREAL
                    ! todo: the gtm_fatal can not be called here because settling velocity is a pure subroutine
                end if 
            end do   
            
            case(.false.)
            ! Dietrich formula
            capital_r = specific_gravity - one
            do iclass=1,nclass
                ! Stokes fall velocity
                if ( diameter(iclass) < 1.0d-5 ) then
                    settling_v(iclass) = (capital_r*g_acceleration*diameter(iclass)**two)/(18.0d0*kinematic_viscosity)
                else
                    call explicit_particle_reynolds_number(exp_re_p,            &
                                                           diameter,            &
                                                           capital_r,           &
                                                           g_acceleration,      &
                                                           kinematic_viscosity, &
                                                           nclass)
            
                    dimless_fall_velocity(iclass) = dexp(minus*b_1 + b_2*dlog(exp_re_p(iclass)) - b_3*(dlog(exp_re_p(iclass)))**two &
                                                   - b_4*(dlog(exp_re_p(iclass)))**three + b_5*(dlog(exp_re_p(iclass)))**four)
                                               
                    settling_v(iclass) = dimless_fall_velocity(iclass) * dsqrt(capital_r*g_acceleration*diameter(iclass))                 
                end if   
            end do 
            end select 

        return
    end subroutine


    !> Calculates the submerged specific gravity
    pure subroutine submerged_specific_gravity(capital_r,            &
                                               water_density,        &
                                               sediment_density)
        use gtm_precision
        implicit none
        !-- arguments
        real(gtm_real), intent(out) :: capital_r        !< Submerged specific gravity of sediment particles     
        real(gtm_real), intent(in)  :: water_density    !< Water density  
        real(gtm_real), intent(in)  :: sediment_density !< Solid particle density

        capital_r = sediment_density/water_density  - one                                     
        
        return 
    end subroutine


    !> Calculates the explicit particle Reynolds number
    pure subroutine explicit_particle_reynolds_number(exp_re_p,           &
                                                      diameter,           &
                                                      capital_r,          &
                                                      g_acceleration,     &
                                                      kinematic_viscosity,&
                                                      nclass)
        use gtm_precision
        implicit none
        !--- arguments 
        integer, intent(in) :: nclass                         !< Number of sediment diameter classes
        real(gtm_real), intent(out) :: exp_re_p(nclass)        !< Explicit particle reynolds number
        real(gtm_real), intent(in)  :: diameter(nclass)        !< Particle diameter
        real(gtm_real), intent(in)  :: capital_r               !< Submerged specific gravity of sediment particles  
        real(gtm_real), intent(in)  :: g_acceleration          !< Gravitational acceleration 
        real(gtm_real), intent(in)  :: kinematic_viscosity     !< Kinematic viscosity (m2/sec)

        exp_re_p = diameter*dsqrt(g_acceleration*capital_r*diameter)/kinematic_viscosity

        return
    end subroutine


    !> Calculates particle Reynolds number
    pure subroutine particle_reynolds_number(re_p,                &
                                             settling_v,          &
                                             diameter,            &
                                             kinematic_viscosity, &
                                             nclass)

        use gtm_precision
        implicit none
        !--- arguments 
        integer, intent(in) :: nclass                     !< Number of sediment diameter classes
        real(gtm_real), intent(out) :: re_p(nclass)        !< Particle Reynolds number
        real(gtm_real), intent(in)  :: settling_v(nclass)  !< Settling velocity
        real(gtm_real), intent(in)  :: diameter(nclass)    !< Particle diameter
        real(gtm_real), intent(in)  :: kinematic_viscosity !< Kinematic viscosity (m2/sec)                            
 
        re_p = settling_v*diameter/kinematic_viscosity
 
        return
    end subroutine


    !> Calculates dimensionless particle diameter
    pure subroutine dimless_particle_diameter(d_star,                 &
                                              g_acceleration,         &
                                              diameter,               &
                                              kinematic_viscosity,    &
                                              capital_r,              &
                                              nclass)
        use gtm_precision
        implicit none
        !--- arguments 
        integer, intent(in) :: nclass                     !< Number of sediment diameter classes
        real(gtm_real),intent(out) :: d_star(nclass)      !< Dimensionless particle diameter
        real(gtm_real),intent(in)  :: g_acceleration      !< Gravitational acceleration 
        real(gtm_real),intent(in)  :: diameter(nclass)    !< Particle diameter
        real(gtm_real),intent(in)  :: kinematic_viscosity !< Kinematic viscosity (m2/sec)                            
        real(gtm_real),intent(in)  :: capital_r           !< Submerged specific gravity of sediment particles     

        d_star = diameter*(capital_r*g_acceleration/(kinematic_viscosity**two))**third
 
        return
    end subroutine


    !> Calculates critical shields parameter based on Yalin (1972) formula
    !> See van Rijn book equation (4.1.11)
    ! todo: add Parker formula here
    pure subroutine critical_shields_parameter(cr_shields_prmtr,   &
                                               d_star,             &
                                               nclass)                                           
        use gtm_precision
        implicit none
        !--- arguments  
        integer, intent(in) :: nclass                          !< Number of sediment diameter classes
        real(gtm_real), intent(out):: cr_shields_prmtr(nclass) !< Critical Shields parameter                                      
        real(gtm_real), intent(in) :: d_star(nclass)           !< Dimensionless particle diameter
        !--local
        integer :: iclass

        do iclass =1,nclass
            if (d_star(iclass).ge.150.0d0) then
                cr_shields_prmtr(iclass) = 0.055d0   
            elseif (d_star(iclass).ge.20.0d0 .and. d_star(iclass).lt.150.0d0) then
                cr_shields_prmtr(iclass) = 0.013d0*d_star(iclass)**0.29d0 
            elseif (d_star(iclass).ge.10.0d0 .and. d_star(iclass).lt.20.0d0) then
                cr_shields_prmtr(iclass) = 0.04d0*d_star(iclass)**(-0.1d0)
            elseif (d_star(iclass).ge.4.0d0 .and. d_star(iclass).lt.10.0d0)  then
                cr_shields_prmtr(iclass) = 0.14d0*d_star(iclass)**(-0.64d0)
            else
                cr_shields_prmtr(iclass) = 0.24d0/d_star(iclass)**(-1.0d0)
            end if    
        end do                                     
        return
    end subroutine


    ! todo: should we assume depth = Rh? it is larger than 1/10 in the Delta 
    !> Shear velocity calculator
    subroutine shear_velocity_calculator(shear_velocity,      &
                                         velocity,            &
                                         manning,             &
                                         gravity,             &
                                         hydr_radius,         &
                                         ncell)                                     
        use gtm_precision
        implicit none

        integer, intent(in) :: ncell                        !< Number of cells
        real(gtm_real), intent(in) :: velocity(ncell)       !< Flow velocity  
        real(gtm_real), intent(in) :: manning(ncell)        !< Manning's n 
        real(gtm_real), intent(in) :: hydr_radius(ncell)    !< Hydraulic radius 
        real(gtm_real), intent(in) :: gravity               !< Gravity
        real(gtm_real), intent(out):: shear_velocity(ncell) !< Shear velocity 

        ! the ABS used due to the nature of shear velocity 
        shear_velocity = abs(velocity)*manning*dsqrt(gravity)/(hydr_radius**(one/six))

    end subroutine


    !> Calculate Rouse number from given shear velocity 
    !> Ro # < 0.8 wash load and does not consider in sed transport
    !> Ro # (0.8~1.2) 100% suspended load
    !> Ro # (1.2~2.5) 50% suspended load
    !> Ro # (2.5~ 7 ) bedload
    !> Ro # > 7 does not move at all
    subroutine rouse_dimensionless_number(rouse_num,   &
                                          fall_vel,    &
                                          shear_vel,   &
                                          ncell,       &
                                          nclass)                                 
        use gtm_precision
        implicit none
        integer, intent(in) :: nclass                         !< Number of sediment classes 
        integer, intent(in) :: ncell                          !< Number of cells
        real(gtm_real), intent(out):: rouse_num(ncell,nclass) !< Rouse dimensionless number  
        real(gtm_real), intent(in) :: fall_vel(nclass)        !< Settling velocity
        real(gtm_real), intent(in) :: shear_vel(ncell)        !< Shear velocity 
        !----local
        real(gtm_real), parameter :: kappa = 0.41d0
        integer        :: icell

        do icell=1,ncell
            rouse_num(icell,:)= fall_vel/shear_vel(icell)/kappa
        end do

        return
    end subroutine


    ! The formula here is adopted from B. Greimann, Y. Lai and J. Huang, 2008
    !> subroutine to calculate the percentage in suspension
    ! todo: what should we do with large Rouse numbers? and exclude them from bedload? 
    subroutine allocation_ratio(susp_percent,    &
                                bed_percent,     &
                                rouse_num,       &
                                nclass,          &
                                ncell)                            
        use gtm_precision

        implicit none
        integer, intent(in) :: nclass                             !< Number of sediment classes 
        integer, intent(in) :: ncell                              !< Number of cells
        real(gtm_real), intent(in) :: rouse_num(ncell,nclass)     !< Rouse dimensionless number  
        real(gtm_real), intent(out):: susp_percent(ncell,nclass)  !< Percentage in suspension  
        real(gtm_real), intent(out):: bed_percent(ncell,nclass)   !< Percentage in bedload

        susp_percent = min(one,(2.5d0*dexp(-rouse_num)))
        bed_percent  = one - susp_percent
     
        return
    end subroutine 


    !> Calculates the first Einstein integral values
    !> This subroutine is developed based on analtycal solution of Guo and Julien (2004)
    !> To avoid disambiguation: C_bar = c_b_bar * first_einstein_integral
    !> the out put of the subroutine is equal to J_1 in the page 116 of ASCE sediment manual  
    !> To avoid singularities here an analytical solution used for integers    
    ! todo: Should we place this subroutine here? another separate file? or sediment derived variable?
    ! I think we will use it again in the bedload
    subroutine first_einstein_integral(I_1,       &
                                       delta_b,   &
                                       rouse_num, &
                                       ncell,     &
                                       nclass)                                    
        use gtm_precision
        use error_handling
        implicit none
        !-- arg
        integer, intent(in):: ncell                            !< Number of computational volumes in a channel
        integer, intent(in):: nclass                           !< Number of non-cohesive sediment grain classes
        real(gtm_real),intent(in) :: rouse_num(ncell,nclass)   !< Rouse dimenssionless number  
        real(gtm_real),intent(in) :: delta_b                   !< Relative bed layer thickness = b/H 
        real(gtm_real),intent(out):: I_1(ncell,nclass)         !< First Einstein integral value

        !-- local
        integer :: ivol
        integer :: iclass
        real(gtm_real) :: ro_l   
        real(gtm_real) :: ro_r    !right
        real(gtm_real) :: i_1_l
        real(gtm_real) :: i_1_r   !right

        do ivol=1,ncell
            do iclass=1,nclass
                if (rouse_num(ivol,iclass) > 3.98d0) then
                    !todo: I am not sure if we need this subroutine in bed load or not 
                    print *, 'error in rouse number' ! todo: remove
                    pause
                    call gtm_fatal("This is not a Rouse number value for suspended sediment!")            
                elseif (abs(rouse_num(ivol,iclass) - three)< 0.01d0) then
                    ro_l = three - 0.05d0
                    ro_r = three + 0.05d0 
                    call inside_i_1(i_1_l,delta_b,ro_l)
                    call inside_i_1(i_1_r,delta_b,ro_r)
                    I_1(ivol,iclass) = (i_1_r + i_1_l) / two                 
                elseif (abs(rouse_num(ivol,iclass) - two)< 0.01d0) then
                    ro_l = two - 0.05d0
                    ro_r = two + 0.05d0 
                    call inside_i_1(i_1_l,delta_b,ro_l)
                    call inside_i_1(i_1_r,delta_b,ro_r)
                    I_1(ivol,iclass) = (i_1_r + i_1_l) / two                       
                elseif(abs(rouse_num(ivol,iclass) - one)< 0.01d0) then  
                    ro_l = one - 0.05d0
                    ro_r = one + 0.05d0 
                    call inside_i_1(i_1_l,delta_b,ro_l)
                    call inside_i_1(i_1_r,delta_b,ro_r)
                    I_1(ivol,iclass) = (i_1_r + i_1_l) / two
                else
                    call inside_i_1(I_1(ivol,iclass),       &
                                    delta_b,                &
                                    rouse_num(ivol,iclass))                 
                end if
            end do
        end do
    end subroutine

    !> inside I_1
    pure subroutine inside_i_1(J_1,      &
                               delta_b,  &
                               rouse)                               
        use gtm_precision
        implicit none
        real(gtm_real),intent(in) :: rouse         !< Rouse dimenssionless number  
        real(gtm_real),intent(in) :: delta_b       !< Relative bed layer thickness = b/H 
        real(gtm_real),intent(out):: J_1           !< First Einstein integral value

        J_1   = (rouse*pi/dsin(rouse*pi) - ((one-delta_b)**rouse)/(delta_b**(rouse-one))    &
               - rouse*(((delta_b/(one-delta_b))**(one-rouse))  /(one-rouse))               & 
               + rouse*(((delta_b/(one-delta_b))**(two-rouse))  /(one-rouse))               &
               - rouse*(((delta_b/(one-delta_b))**(three-rouse))/(one-rouse))               &
               + rouse*(((delta_b/(one-delta_b))**(four-rouse)) /(one-rouse))               &
               - rouse*(((delta_b/(one-delta_b))**(five-rouse)) /(one-rouse))               &
               + rouse*(((delta_b/(one-delta_b))**(six-rouse))  /(one-rouse))               &
               - rouse*(((delta_b/(one-delta_b))**(seven-rouse))/(one-rouse))               &
               + rouse*(((delta_b/(one-delta_b))**(eight-rouse))/(one-rouse))               &
               - rouse*(((delta_b/(one-delta_b))**(nine-rouse)) /(one-rouse))               &
               + rouse*(((delta_b/(one-delta_b))**(ten -rouse)) /(one-rouse)))              &
               * (delta_b**(rouse)/((one-delta_b)**rouse))                               
    end subroutine 


end module

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
!>@ingroup process_io
module read_init

    contains
    
    !> read initial condition time series
    subroutine read_init_file(init, init_r, restart_file_name, ncell, nresv, nvar)
        use gtm_precision
        use error_handling
        implicit none
        integer, intent(in) :: ncell                         !< Number of cells
        integer, intent(in) :: nresv                         !< Number of reservoirs
        integer, intent(in) :: nvar                          !< Number of constituents
        character*(*), intent(in) :: restart_file_name       !< Restart file name
        real(gtm_real), intent(out) :: init(ncell,nvar)      !< Initial concentration for cells
        real(gtm_real), intent(out) :: init_r(nresv,nvar)    !< Initial concentration for reservoirs
        integer :: file_unit
        integer :: nvar_r, nresv_r, ncell_r
        integer :: i, j
        logical :: file_exists
        
        init = LARGEREAL
        file_unit = 151
        inquire(file=restart_file_name, exist=file_exists)
        if (file_exists) then
            open(file_unit, file=restart_file_name)
            read(file_unit,*)
            read(file_unit,*)
            read(file_unit,*) nvar_r
            read(file_unit,*) ncell_r
            if (nvar_r .ne. nvar) then
                call gtm_fatal("Error: number of constituents are not consistent in restart file!")
            elseif (ncell_r .ne. ncell) then
                call gtm_fatal("Error: number of cells are not consistent in restart file!")
            else        
                do i = 1, ncell
                    read(file_unit,*) (init(i,j),j=1,nvar)
                end do
            end if
            read(file_unit,*) nresv_r
            if (nresv_r .ne. nresv) then
                call gtm_fatal("Error: number of reservoirs are not consistent in restart file!")
            else
                do i = 1, nresv
                    read(file_unit,*) (init_r(i,j),j=1,nvar)
                end do            
            end if
        else 
            write(*,*) "Please specify a valid file or path for restart file! Otherwise, a constant initial concentration will be used."
        end if    
        close(file_unit)
        return
    end subroutine
    
end module
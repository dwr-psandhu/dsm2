!!<license>
!!    Copyright (C) 1996, 1997, 1998, 2001, 2007, 2009 State of California,
!!    Department of Water Resources.
!!    This file is part of DSM2.

!!    The Delta Simulation Model 2 (DSM2) is free software:
!!    you can redistribute it and/or modify
!!    it under the terms of the GNU General Public License as published by
!!    the Free Software Foundation, either version 3 of the License, or
!!    (at your option) any later version.

!!    DSM2 is distributed in the hope that it will be useful,
!!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!!    GNU General Public License for more details.

!!    You should have received a copy of the GNU General Public License
!!    along with DSM2.  If not, see <http://www.gnu.org/licenses>.
!!</license>


module grid_data
    use type_defs
    integer :: &
        max_channels              ! actual number of cross sections
    integer :: max_xsects_tot              ! actual number of cross sections
    integer :: max_nodes              ! actual number of cross sections
    integer :: max_obj2obj              ! actual number of cross sections
    integer :: max_stgbnd              ! actual number of cross sections
    integer :: nstgbnd              ! actual number of cross sections
    integer :: nobj2obj              ! actual number of cross sections
    integer :: nchans              ! actual number of cross sections
    integer :: nintnodes              ! actual number of cross sections
    integer :: nnodes              ! actual number of cross sections
    integer :: nxsects              ! actual number of cross sections
    parameter ( &
        max_channels=800 &     ! MaxChannels should equal this
        ,max_xsects_tot=5*max_channels &
        ,max_nodes=max_channels+10 &
        ,max_obj2obj=50 &
        ,max_stgbnd=5 &
        )
     
    type(channel_t) :: chan_geom(0:max_channels)
    type(node_t) :: node_geom(0:max_nodes)
    type(xsect_t) :: xsect_geom(0:max_xsects_tot)
      
    real*8 :: &
        area_tolerance         ! slope of levees for xsect width extrapolation
    real*8 :: levee_slope         ! slope of levees for xsect width extrapolation
     
          
    integer :: &
        max_reservoirs         ! total number of reservoir connections across all reservoirs
    integer :: nreser         ! total number of reservoir connections across all reservoirs
    integer :: nres_connect         ! total number of reservoir connections across all reservoirs

    parameter ( &
        max_reservoirs=100 &
        )

    type(reservoir_t) :: res_geom(0:max_reservoirs)
      
    !-----Node id numbers

    integer :: node_id(0:max_nodes)
    common /node_i_dentification/ node_id

    integer :: &
        nchan_list           ! actual number of channel sequences

    integer :: &
        int2ext(0:max_channels)
    integer :: resext2int(0:max_reservoirs)
    integer :: resint2ext(0:max_reservoirs)
    integer :: nodelist(0:max_nodes*2+1)

    !-----Direct object to object flow transfer
    type(obj2obj_t) :: obj2obj(max_obj2obj)
      
    !-----stage boundary object
    type(stgbnd_t) :: stgbnd(max_stgbnd)



    !-----quad points
    integer:: nquadpts = 3             ! number of quadrature points

    !-----used by virtual_xsect
    real*8 :: deltax_requested   ! delta x to use in spatial discretization

    !-----accounting and object names, value codes, period type names
    integer,parameter :: max_group_memberships=20 ! max number of group memberships

    integer :: &
        max_qext               ! number of actual external flows
    integer :: nqext               ! number of actual external flows

    parameter ( &
        max_qext=1000 &
        )

    type(qext_t) :: qext(max_qext)
    integer :: const_qext(max_qext,max_conqext)
    integer :: n_conqext(max_qext) ! number of constituents at external flow
    common /com_conqext/ const_qext, n_conqext
           
end module

   
     
      
    
    
     

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

!> This module is to solve sparse matrix by using KLU Sparse Solver which is part of SuiteSparse package.
!>@ingroup gtm_core
module klu

     ! KLU Sparse Solver
      logical, parameter :: use_klu=.true.
      integer :: k_common, k_symbolic, k_numeric
      real*8, allocatable :: coo(:), b(:)
      integer, allocatable:: jca(:),ica(:)
      logical :: first_time_klu = .true. 
      integer :: previous_non_zero = -123456789  
  	  integer :: num_non_zeros ! counter increments as elements are added to coo array
	  integer :: matrix_size
      interface 
        integer function klu_fortran_init()
        !DEC$ ATTRIBUTES C :: _klu_fortran_init
        end function
        integer function klu_fortran_analyze(n, ap, ai, k_common)
        !DEC$ ATTRIBUTES C :: _klu_fortran_analyze
          integer, intent(in) :: n,k_common
          integer, intent(in) :: ap(*), ai(*)
        end function
        integer function klu_fortran_factor(ap, ai, ax, k_symbolic, k_common)
        !DEC$ ATTRIBUTES C :: _klu_fortran_factor
          integer, intent(in) :: k_common,k_symbolic
          integer, intent(in) :: ap(*), ai(*)
          real*8, intent(in) :: ax(*)
        end function
        subroutine klu_fortran_refactor(ap, ai, ax, k_symbolic, k_numeric, k_common)
        !DEC$ ATTRIBUTES C :: _klu_fortran_refactor
          integer, intent(in) :: k_symbolic, k_common
          integer, intent(inout) :: k_numeric
          integer, intent(in) :: ap(*), ai(*)
          real*8, intent(in) :: ax(*)
        end subroutine
        subroutine klu_fortran_solve(k_symbolic, k_numeric, n, nrhs, b, k_common)
        !DEC$ ATTRIBUTES C :: _klu_fortran_solve
          integer, intent(in) :: k_symbolic, k_numeric, k_common
          integer, intent(in) :: n, nrhs
          real*8, intent(inout) :: b(*)
        end subroutine
        subroutine klu_fortran_free_numeric(k_numeric, k_common)
        !DEC$ ATTRIBUTES C :: _klu_fortran_free_numeric
          integer, intent(in) :: k_numeric, k_common
        end subroutine
        subroutine klu_fortran_free(k_symbolic, k_numeric, k_common)
        !DEC$ ATTRIBUTES C :: _klu_fortran_free
          integer, intent(in) :: k_symbolic, k_numeric, k_common
        end subroutine
        real*8 function klu_fortran_condest(ap, ax, k_symbolic, k_numeric, k_common)
        !DEC$ ATTRIBUTES C :: _klu_fortran_condest
          integer, intent(in) :: k_symbolic, k_numeric, k_common
          integer, intent(in) :: ap(*)
          real*8, intent(in) :: ax(*)
        end function
        real*8 function klu_fortran_rcond(k_symbolic, k_numeric, k_common)
        !DEC$ ATTRIBUTES C :: _klu_fortran_rcond
          integer, intent(in) :: k_symbolic, k_numeric, k_common
        end function
        real*8 function klu_fortran_rgrowth(ap, ai, ax, k_symbolic, k_numeric, k_common)
        !DEC$ ATTRIBUTES C :: _klu_fortran_rgrowth
          integer, intent(in) :: k_symbolic, k_numeric, k_common
          integer, intent(in) :: ap(*), ai(*)
          real*8, intent(in) :: ax(*)
        end function
      end interface;
      contains
      subroutine add_to_matrix(index,val)
        integer, intent(in) :: index
        real*8, intent(in) :: val
        coo(index)=val+coo(index)
      end subroutine
!     subroutine to add position of a non-zero to the coordinate array where an element is
!     is being added to the i,j position with a value of i*n+j where n is the size of the array
      subroutine add_nonzero_to_coo(row, column, val)
          integer,intent(in) :: row, column, val
          real*8, allocatable:: acoo(:)
          integer :: n
          integer,parameter :: init_guess=10000, grow_size=10000
          
          num_non_zeros=num_non_zeros+1
          if (allocated(coo)) then
            n=size(coo,1)
          else 
            n=init_guess
            allocate(coo(n))
          end if

          if (num_non_zeros .gt. n) then
            allocate(acoo(n+grow_size))
            acoo(1:n)=coo
            call move_alloc(acoo, coo)
          end if
          
          coo(num_non_zeros)=val
      end subroutine

      subroutine done_adding_to_coo()
          real*8, allocatable:: acoo(:)
          if (.not. allocated(coo)) then 
            return
          end if
          
          n=size(coo,1)
          if (num_non_zeros .gt. n) then
            return
          end if
          
          allocate(acoo(num_non_zeros), b(num_non_zeros))
          acoo(1:num_non_zeros)=coo(1:num_non_zeros)
          call move_alloc(acoo,coo)
          
      end subroutine
      subroutine scale_coo(rowscale, colscale)
      real*8, intent(in) :: rowscale(*), colscale(*)
      integer i,j,k
      do i=1,matrix_size
        do j=ica(i)+1,ica(i+1) ! row, col 0 based index
        k=jca(j)+1
        coo(j) = coo(j)*rowscale(k)*colscale(i)
        end do
      end do
      
      end subroutine
      
      ! converts coo to csc
      subroutine coo2csc(n)
          real*8, allocatable:: acsr(:), acsc(:), acoo(:)
          real*8 ddum
          
          integer job(6)
          integer, allocatable:: ja(:),ia(:) 
          
          integer n
          integer nnz,i,tval
          integer ii, jj
          
          integer, allocatable :: rowind(:), colind(:)

          nnz = num_non_zeros
          matrix_size = n
          
          allocate(rowind(nnz), colind(nnz))          
          do i=1,nnz
            tval=nint(coo(i))
            rowind(i)=tval/n+1
            colind(i)=mod(tval,n)+1
          end do
          
          job(1)=2 ! coordinate format -> CSR format + column indices are to be sorted 
          job(2)=1 ! one-based indexing for CSR
          job(3)=1 ! one-based indexing for coordinate
          job(5)=nnz
          job(6)=0
          allocate(ja(nnz),ia(n+1),acsr(nnz),acoo(nnz))
          acoo(1:nnz)=coo(1:nnz)
          
          call mkl_dcsrcoo(job, n, acsr, ja, ia, nnz, acoo, rowind, colind, info )
          if (info .ne. 0 ) then
            write(*,*) 'Info is non-zero, coo -> csr fails'
          end if
          
          job(1)=0 ! convert from CSR -> CSC format
          job(2)=1 ! one based indexing for CSR
          job(3)=0 ! zero based indexing for csc as thats what KLU needs
          job(5)=0
          job(6)=1 ! fill all output arrays
          allocate(jca(nnz),ica(n+1),acsc(nnz))

          call mkl_dcsrcsc(job, n, acsr, ja, ia, acsc, jca, ica, info )
          if (info .ne. 0 ) then
            write(*,*) 'Info is non-zero, csr -> csc fails'
          end if

          coo(1:nnz)=acsc(1:nnz)
          
      end subroutine
      
      subroutine update_pointers(ipointers, n)
      integer, intent(inout) :: ipointers(*)
      integer, intent(in) :: n
      integer :: i,j,oldval,newval
      integer :: row, column, row2, column2
      
      outer: do i=1,n
        oldval=ipointers(i)
        row=oldval/matrix_size+1
        column=mod(oldval,matrix_size)+1
        inner: do j=1,num_non_zeros
            oldval=nint(coo(j))
            row2=oldval/matrix_size+1
            column2=mod(oldval,matrix_size)+1
            if (row .eq. row2 .and. column .eq. column2) then
                ipointers(i)=j
                exit inner
            end if
        end do inner
      end do outer
      
      end subroutine
      
      subroutine update_pointers_dim4(ipointers, n)
      integer, intent(inout) :: ipointers(4,*)
      integer, intent(in) :: n
      integer :: i,j,k,oldval,newval
      integer :: row, column, row2, column2
      
      ultimate: do k=1,4
      outer: do i=1,n
        oldval=ipointers(k,i)
        row=oldval/matrix_size+1
        column=mod(oldval,matrix_size)+1
        inner: do j=1,num_non_zeros
            oldval=nint(coo(j))
            row2=oldval/matrix_size+1
            column2=mod(oldval,matrix_size)+1
            if (row .eq. row2 .and. column .eq. column2) then
                ipointers(k,i)=j
                exit inner
            end if
        end do inner
      end do outer
      end do ultimate      
      end subroutine
      
      
      subroutine clear_matrix()
        coo=0
      end subroutine
      
      subroutine close_solver()
        call klu_fortran_free(k_numeric,k_symbolic,k_common)
        deallocate(coo,b,ica,jca)
      end subroutine

    !> write the values from a tri-diagonal matrix to the structure of a sparse matrix
    subroutine tri2sparse(ap,           &
                          ai,           &
                          ax,           &
                          up_diag,      &
                          center_diag,  & 
                          down_diag,    &
                          ncell)
        implicit none
        integer, intent(in) :: ncell
        real*8, intent(in) :: up_diag(ncell)
        real*8, intent(in) :: down_diag(ncell)
        real*8, intent(in) :: center_diag(ncell)
        integer, intent(out) :: ap(ncell+1)
        integer, intent(out) :: ai(4+3*(ncell-2))
        real*8, intent(out) :: ax(4+3*(ncell-2))
        integer :: i      
        ax = 0.d0
        ap(1:2) = (/0, 2/)
        ai(1:5) = (/0, 1, 0, 1, 2/)
        ax(1:5) = (/center_diag(1), down_diag(2), up_diag(1), center_diag(2), down_diag(3)/)
        do i = 3, ncell-1
            ap(i) = ap(i-1) + 3
            ai(ap(i)+1) = (i-3) + 1
            ai(ap(i)+2) = (i-3) + 2
            ai(ap(i)+3) = (i-3) + 3
            ax(ap(i)+1) = up_diag(i-3+2)
            ax(ap(i)+2) = center_diag(i-3+3)
            ax(ap(i)+3) = down_diag(i-3+4)
        end do
        ap(ncell) = ap(ncell-1) + 3
        ap(ncell+1) = ap(ncell) + 2
        ai(ap(ncell-1)+1) = ncell-3
        ai(ap(ncell-1)+2) = ncell-2
        ai(ap(ncell-1)+3) = ncell-1
        ai(ap(ncell)+1) = ncell - 2
        ai(ap(ncell)+2) = ncell - 1
        ax(ap(ncell-1)+1) = up_diag(ncell-2)
        ax(ap(ncell-1)+2) = center_diag(ncell-1)
        ax(ap(ncell-1)+3) = down_diag(ncell)
        ax(ap(ncell)+1) = up_diag(ncell-1)
        ax(ap(ncell)+2) = center_diag(ncell)             
        return
    end subroutine    
    
end module

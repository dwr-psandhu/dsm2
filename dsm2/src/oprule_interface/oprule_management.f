C!<license>
C!    Copyright (C) 1996, 1997, 1998, 2001, 2007, 2009 State of California,
C!    Department of Water Resources.
C!    This file is part of DSM2.

C!    The Delta Simulation Model 2 (DSM2) is free software: 
C!    you can redistribute it and/or modify
C!    it under the terms of the GNU General Public License as published by
C!    the Free Software Foundation, either version 3 of the License, or
C!    (at your option) any later version.

C!    DSM2 is distributed in the hope that it will be useful,
C!    but WITHOUT ANY WARRANTY; without even the implied warranty of
C!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C!    GNU General Public License for more details.

C!    You should have received a copy of the GNU General Public License
C!    along with DSM2.  If not, see <http://www.gnu.org/licenses>.
C!</license>
      module oprule_management
      contains
      logical function InitOpRules()
	implicit none
c	character*801 line

      call init_parser_f()
c	open(66,file="c:\delta\studies\historic\oprules.inp")
c	do while (.not. EOF(66))
c        read(66,'(a)')line
c	  linelen=len_trim(line)
c	  if (linelen .eq. 800) print*, "op rule too long"
c          if (linelen .gt. 0) then
c		  print*,trim(line)
c            call parse_rule(line)
c	    end if
c      end do 
	InitOpRules=.true.
      return
	end function

      end module
!> \defgroup fortran Application-Defined Data I/O FORTRAN API (autogenerated)
!! This is a listing of the automatically generated FORTRAN bindings
!! for reading and writing data from text and hdf5. Each routine is listed by
!! module_name::routine_name
!@{ 
module input_storage_fortran
	   contains

       // Fortran Include Files DO NOT ALTER THIS LINE AT ALL

       subroutine clear_all_buffers(ierror)
          !DEC$ ATTRIBUTES ALIAS:'_clear_all_buffers_f' :: clear_all_buffers_f
         call clear_all_buffers_f(ierror)
       end subroutine
       
       subroutine prioritize_all_buffers(ierror)
          !DEC$ ATTRIBUTES ALIAS:'_prioritize_all_buffers_f' :: prioritize_all_buffers_f
          integer :: ierror
          call prioritize_all_buffers_f(ierror)
       end subroutine

       subroutine write_all_buffers_to_text(textfile,append,ierror)
          !DEC$ ATTRIBUTES ALIAS:'_write_all_buffers_to_text_f' :: write_all_buffers_to_text_f
         character*(*) textfile
         logical append
         integer :: ierror
         call write_all_buffers_to_text_f(textfile,append,ierror)
       end subroutine

       subroutine write_all_buffers_to_hdf5(file_id,ierror)
          !DEC$ ATTRIBUTES ALIAS:'_write_all_buffers_to_hdf5_f' :: write_all_buffers_to_hdf5_f
         use hdf5, only: HID_T
         implicit none
         integer :: ierror         
         integer(HID_T), intent(in) :: file_id
         call write_all_buffers_to_hdf5_f(file_id,ierror)
       end subroutine
       
       subroutine init_file_reader(ierror)
          !DEC$ ATTRIBUTES ALIAS:'_init_file_reader_f' :: init_file_reader_f
          integer :: ierror
          call init_file_reader_f(ierror)
       end subroutine       

       subroutine set_active_profile(profilename,ierror)
          character*(*) profilename
          integer :: ierror
          !DEC$ ATTRIBUTES ALIAS:'_set_active_profile_f' :: set_active_profile_f
          call set_active_profile_f(trim(profilename),ierror)
       end subroutine 

       subroutine set_initial_context_profile(profilename)
            !DEC$ ATTRIBUTES ALIAS:'_set_initial_context_profile_f' :: set_initial_context_profile_f
            character*(*) profilename
            integer :: ierror
            call set_initial_context_profile_f(trim(profilename),ierror)
       end subroutine
       
       subroutine set_substitution_enabled(enabled,ierror)
          !DEC$ ATTRIBUTES ALIAS:'_set_substitution_enabled_f' :: set_substitution_enabled_f
          logical enabled
          integer :: ierror
          call set_substitution_enabled_f(enabled,ierror)
       end subroutine   

       subroutine process_text_substitution(ierror)
          !DEC$ ATTRIBUTES ALIAS:'_process_text_substitution_f' :: process_text_substitution_f
          integer :: ierror
          call process_text_substitution_f(ierror)
       end subroutine        
 
        subroutine read_buffer_from_text(startfilename,ierror)
          character*(*) startfilename
          integer :: ierror
          !DEC$ ATTRIBUTES ALIAS:'_read_buffer_from_text_f' :: read_buffer_from_text_f
          call read_buffer_from_text_f(startfilename,ierror)
       end subroutine        

end module
!@}

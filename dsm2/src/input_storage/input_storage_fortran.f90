!> \defgroup fortran Application-Defined Data I/O FORTRAN API (autogenerated)
!! This is a listing of the automatically generated FORTRAN bindings
!! for reading and writing data from text and hdf5. Each routine is listed by
!! module_name::routine_name
!@{ 
module input_storage_fortran
	   contains

       include "envvar_input_storage.fi"
       include "scalar_input_storage.fi"
       include "channel_input_storage.fi"
       include "xsect_input_storage.fi"
       include "xsect_layer_input_storage.fi"
       include "reservoir_input_storage.fi"
       include "reservoir_vol_input_storage.fi"
       include "reservoir_connection_input_storage.fi"
       include "gate_input_storage.fi"
       include "gate_pipe_device_input_storage.fi"
       include "gate_weir_device_input_storage.fi"
       include "transfer_input_storage.fi"
       include "io_file_input_storage.fi"
       include "tidefile_input_storage.fi"
       include "group_input_storage.fi"
       include "group_member_input_storage.fi"
       include "channel_ic_input_storage.fi"
       include "reservoir_ic_input_storage.fi"
       include "operating_rule_input_storage.fi"
       include "oprule_expression_input_storage.fi"
       include "oprule_time_series_input_storage.fi"
       include "rate_coefficient_input_storage.fi"
       include "particle_insertion_input_storage.fi"
       include "particle_filter_input_storage.fi"
       include "particle_res_filter_input_storage.fi"
       include "particle_flux_output_input_storage.fi"
       include "particle_group_output_input_storage.fi"
       include "input_climate_input_storage.fi"
       include "input_transfer_flow_input_storage.fi"
       include "input_gate_input_storage.fi"
       include "boundary_stage_input_storage.fi"
       include "boundary_flow_input_storage.fi"
       include "source_flow_input_storage.fi"
       include "source_flow_reservoir_input_storage.fi"
       include "node_concentration_input_storage.fi"
       include "reservoir_concentration_input_storage.fi"
       include "output_channel_input_storage.fi"
       include "output_reservoir_input_storage.fi"
       include "output_channel_source_track_input_storage.fi"
       include "output_reservoir_source_track_input_storage.fi"
       include "output_gate_input_storage.fi"

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

       subroutine write_buffer_profile_to_text(profile,textfile,append,ierror)
          !DEC$ ATTRIBUTES ALIAS:'_write_buffer_profile_to_text_f' :: write_buffer_profile_to_text_f
         character*(*) textfile,profile
         logical append
         integer :: ierror
         call write_buffer_profile_to_text_f(profile,textfile,append,ierror)
       end subroutine

       subroutine write_buffer_profile_to_hdf5(profile,file_id,ierror)
          !DEC$ ATTRIBUTES ALIAS:'_write_buffer_profile_to_hdf5_f' :: write_buffer_profile_to_hdf5_f
         use hdf5, only: HID_T
         implicit none
         character*(*) :: profile         
         integer :: ierror         
         integer(HID_T), intent(in) :: file_id
         call write_buffer_profile_to_hdf5_f(profile,file_id,ierror)
       end subroutine       

       subroutine read_buffer_profile_from_hdf5(profile,file_id,ierror)
          !DEC$ ATTRIBUTES ALIAS:'_read_buffer_profile_from_hdf5_f' :: read_buffer_profile_from_hdf5_f
         use hdf5, only: HID_T
         implicit none
         character*(*) :: profile         
         integer :: ierror         
         integer(HID_T), intent(in) :: file_id
         call read_buffer_profile_from_hdf5_f(profile,file_id,ierror)
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
       
       subroutine set_user_substitution_enabled(enabled,ierror)
          !DEC$ ATTRIBUTES ALIAS:'_set_user_substitution_enabled_f' :: set_user_substitution_enabled_f
          logical enabled
          integer :: ierror
          call set_user_substitution_enabled_f(enabled,ierror)
       end subroutine   

       subroutine set_os_env_substitution_enabled(enabled,ierror)
          !DEC$ ATTRIBUTES ALIAS:'_set_os_env_substitution_enabled_f' :: set_os_env_substitution_enabled_f
          logical enabled
          integer :: ierror
          call set_os_env_substitution_enabled_f(enabled,ierror)
       end subroutine         

       subroutine set_substitution_not_found_is_error(is_error,ierror)
          !DEC$ ATTRIBUTES ALIAS:'_set_substitution_not_found_is_error_f' :: set_substitution_not_found_is_error_f
          logical is_error
          integer :: ierror
          call set_substitution_not_found_is_error_f(is_error,ierror)
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

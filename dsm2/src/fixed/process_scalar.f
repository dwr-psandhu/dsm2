      subroutine process_scalar(Param, Value, istat)

      Use PhysicalConstants
      use IO_Units
      use logging
      use constants
      use runtime_data
      use iopath_data
      use common_qual
      use common_ptm
      use envvar 

      implicit none

      include '../hydrolib/network.inc'
      include '../hydrolib/netcntrl.inc'
      !include '../hydrolib/chconnec.inc'

      integer, intent(inout) :: istat !status
      integer                  :: itmp
      character*15 field_names(1) !kc to match text input
      character, intent(in)    :: Value*20 ! parameter value
      character, intent(in)    :: Param*20 ! parameter
      character                :: ctmp*20  ! local



 610  format(/'Unrecognized Parameter in SCALAR section:'
     &     /a,a)
 615  format(/'Theta must be between 0.5 and 1.0:',f5.2)
 620  format(/a, ' ',a/a)
 630  format(/a)

!c-----run start date and time can be a DSS date (e.g. 01jan1994 0100),
!c-----or 'restart' (use date from restart file), or
!c-----'tide' (use date from tidefile)


      if (Param .eq. 'run_start_date') then
         run_start_date(1:9)=Value(1:9)
      elseif (Param .eq. 'run_start_time') then
         run_start_date(11:14)=Value(1:4)
      elseif (Param .eq. 'run_end_date') then
         run_end_date(1:9)=Value(1:9)
      elseif (Param .eq. 'run_end_time') then
         run_end_date(11:14)=Value(1:4)
      elseif (Param .eq. 'run_length') then
         run_length=Value
         
      elseif (Param .eq. 'database') then
         call set_database_name(Value)
      elseif (Param .eq. 'model_name') then
         call set_model_name(Value)


      elseif (Param .eq. 'print_start_date') then
         if (nprints .eq. 0) nprints=1
         print_start_date(nprints)(1:9)=Value(1:9)
         nprints=nprints+1
      elseif (Param .eq. 'print_start_time') then
         if (nprints .eq. 0) nprints=1
         print_start_date(nprints)(11:14)=Value(1:4)
         
         
         
      elseif (Param .eq. 'flush_output') then
         flush_intvl=Value
      elseif (Param .eq. 'binary_output') then
         itmp=replace_envvars(Value,ctmp) !kc to match sql
         read(ctmp, '(l2)', err=810) binary_output
      elseif (Param .eq. 'dss_direct') then
         itmp=replace_envvars(Value,ctmp) !kc to match sql
         read(ctmp, '(l2)', err=810) dss_direct
      elseif (Param .eq. 'hydro_time_step') then
         time_step_intvl_hydro=Value
      elseif (Param .eq. 'qual_time_step') then
         time_step_intvl_qual=Value
      elseif (Param .eq. 'ptm_time_step') then
         ptm_time_step_int=1
         time_step_intvl_ptm=Value


      elseif (Param .eq. 'mass_tracking') then
         field_names(1)=Param
         read(Value, '(l2)', err=810) mass_tracking
      elseif (Param .eq. 'init_conc') then
         field_names(1)=Param
         read(Value, '(f10.0)', err=810) init_conc
      elseif (Param .eq. 'dispersion') then
         field_names(1)=Param
         read(Value, '(l2)', err=810) dispersion

c--------global rates for non-conserative const.

      elseif (Param .eq. 'algaefract_n') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) algaefract_n
      elseif (Param .eq. 'algaefract_p') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) algaefract_p
      elseif (Param .eq. 'oxy_photo') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) oxy_photo
      elseif (Param .eq. 'oxy_resp') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) oxy_resp
      elseif (Param .eq. 'oxy_nh3') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) oxy_nh3
      elseif (Param .eq. 'oxy_no2') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) oxy_no2
      elseif (Param .eq. 'alg_chl_ratio') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) alg_chl_ratio
      elseif (Param .eq. 'pref_factor') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) pref_factor
      elseif (Param .eq. 'klight_half') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) klight_half
      elseif (Param .eq. 'knit_half') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) knit_half
      elseif (Param .eq. 'kpho_half') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) kpho_half
      elseif (Param .eq. 'lambda0') then
         field_names(1)=Param
         read(Value, '(f8.2)', err=810) lambda0
      elseif (Param .eq. 'lambda1') then
         field_names(1)=Param
         read(Value, '(f8.4)', err=810) lambda1
      elseif (Param .eq. 'lambda2') then
         field_names(1)=Param
         read(Value, '(f8.4)', err=810) lambda2

c--------------heat and temperature related parameters         

      elseif (Param .eq. 'elev') then
         field_names(1)=Param
         read(Value, '(f8.2)', err=810) elev
      elseif (Param .eq. 'lat') then
         field_names(1)=Param
         read(Value, '(f8.2)', err=810) lat
      elseif (Param .eq. 'long') then
         field_names(1)=Param
         read(Value, '(f8.2)', err=810) longitude
      elseif (Param .eq. 'long_std_merid') then
         field_names(1)=Param
         read(Value, '(f8.2)', err=810) long_std_merid
      elseif (Param .eq. 'dust_attcoeff') then
         field_names(1)=Param
         read(Value, '(f8.2)', err=810) dust_attcoeff
      elseif (Param .eq. 'evapcoeff_a') then
         field_names(1)=Param
         read(Value, '(f10.5)', err=810) evapcoeff_a
      elseif (Param .eq. 'evapcoeff_b') then
         field_names(1)=Param
         read(Value, '(f10.5)', err=810) evapcoeff_b
      elseif (Param .eq. 'temp_bod_decay') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_bod_decay)
      elseif (Param .eq. 'temp_bod_set') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_bod_set)
      elseif (Param .eq. 'temp_reaer') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_reaer)
      elseif (Param .eq. 'temp_do_ben') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_do_ben)
      elseif (Param .eq. 'temp_orgn_decay') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_orgn_decay)
      elseif (Param .eq. 'temp_orgn_set') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_orgn_set)
      elseif (Param .eq. 'temp_nh3_decay') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_nh3_decay)
      elseif (Param .eq. 'temp_nh3_ben') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_nh3_ben)
      elseif (Param .eq. 'temp_no2_decay') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_no2_decay)
      elseif (Param .eq. 'temp_orgp_decay') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_orgp_decay)
      elseif (Param .eq. 'temp_orgp_set') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_orgp_set)
      elseif (Param .eq. 'temp_po4_ben') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_po4_ben)
      elseif (Param .eq. 'temp_alg_grow') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_alg_grow)
      elseif (Param .eq. 'temp_alg_resp') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_alg_resp)
      elseif (Param .eq. 'temp_alg_set') then
         field_names(1)=Param
         read(Value, '(f8.3)', err=810) thet(temp_alg_set)         
      elseif (Param .eq. 'tf_start_date') then
         tf_start_date(1:9)=Value(1:9)
      elseif (Param .eq. 'tf_start_time') then
         tf_start_date(11:14)=Value(1:4)
	  
	  elseif (Param .eq. 'alg_bod' ) then
           read(Value, '(f8.4)', err=810) alg_bod 

	  elseif (Param .eq. 'temp_alg_die') then
           read(Value, '(f8.3)', err=810) thet(temp_alg_die)

      elseif (Param .eq. 'display_intvl') then
         display_intvl=Value
      elseif (Param .eq. 'deltax') then
!c--------keyword 'length' means use channel length for each delta x
         if (index(Value, 'len') .eq. 0) then
      field_names(1)=Param
            read(Value, '(f10.0)', err=810) deltax_requested
         else
            deltax_requested=0.0
         endif
      elseif (Param .eq. 'levee_slope') then
         field_names(1)=Param
         read(Value, '(f10.0)', err=810) levee_slope

      elseif (Param .eq. 'theta') then
         field_names(1)=Param
         read(Value, '(f10.0)', err=810) theta
         if (
     &        theta .lt. 0.5 .or.
     &        theta .gt. 1.0
     &        ) then
            write(unit_error, 615) theta
            istat=-1
            goto 900
         endif

      elseif (Param .eq. 'terms') then

         terms=0
         if (Value(1:3) .eq. 'dyn') then
            terms=1       ! dynamic wave
         elseif (Value(1:3) .eq. 'dif') then
            terms=2       ! diffusion wave
         elseif (Value(1:3) .eq. 'kin') then
            terms=3       ! kinematic wave
         else
            write(unit_error, 620)
     &           'Unrecognized value for solution method:',
     &           trim(Value),
     &           'Should be dynamic, diffusion, or kinematic.'
            istat=-1
            goto 900
         endif

      elseif (Param .eq. 'vardensity') then
         field_names(1)=Param
         read(Value, '(l2)', err=810) variabledensity
         if (variabledensity .and. terms .ne. 1) then
            variabledensity=.false.
            write(unit_error, 630)
     &           'Warning: Variable Density allowed only with dynamic wave.'
         endif

      elseif (Param .eq. 'varsinuosity') then
       field_names(1)=Param
         read(Value, '(l2)', err=810) variablesinuosity
         if (variablesinuosity .and. terms .eq. 3) then
            variablesinuosity=.false.
            write(unit_error, 630)
     &           'Warning: variable sinuosity not allowed with kinematic wave.'
         endif

      elseif (Param .eq. 'gravity') then
       field_names(1)=Param
         read(Value, '(f10.0)', err=810) gravity

      elseif (Param .eq. 'toleranceq') then
       field_names(1)=Param
         read(Value, '(f10.0)', err=810) toleranceq

      elseif (Param .eq. 'tolerancez') then
       field_names(1)=Param
         read(Value, '(f10.0)', err=810) tolerancez

      elseif (Param .eq. 'maxiter') then
       field_names(1)=Param
         read(Value, '(i5)', err=810) maxiterations

      elseif (Param .eq. 'luinc') then
       field_names(1)=Param
         read(Value, '(i5)', err=810) luinc

      elseif (Param .eq. 'printlevel') then
       field_names(1)=Param
            read(Value, '(i5)', err=810) print_level
      elseif (Param .eq. 'temp_dir') then
         temp_dir=Value

      elseif (Param .eq. 'checkdata') then
       field_names(1)=Param
         read(Value, '(l2)', err=810) check_input_data

      elseif (Param .eq. 'cont_missing') then
       field_names(1)=Param
         read(Value, '(l2)', err=810) cont_missing

      elseif (Param .eq. 'cont_unchecked') then
       field_names(1)=Param
         read(Value, '(l2)', err=810) cont_unchecked

      elseif (Param .eq. 'cont_question') then
       field_names(1)=Param
         read(Value, '(l2)', err=810) cont_question

      elseif (Param .eq. 'cont_bad') then
       field_names(1)=Param
         read(Value, '(l2)', err=810) cont_bad

      elseif (Param .eq. 'warn_missing') then
       field_names(1)=Param
         read(Value, '(l2)', err=810) warn_missing

      elseif (Param .eq. 'warn_unchecked') then
         field_names(1)=Param
         read(Value, '(l2)', err=810) warn_unchecked

      elseif (Param .eq. 'warn_question') then
         field_names(1)=Param
         read(Value, '(l2)', err=810) warn_question

      elseif (Param .eq. 'warn_bad') then
         field_names(1)=Param
         read(Value, '(l2)', err=810) warn_bad

      elseif (Param .eq. 'ptm_ivert') then
         ptm_ivert_int=1
         field_names(1)=Param
         read(Value, '(l2)', err=810) ptm_ivert

      elseif (Param .eq. 'ptm_itrans') then
         ptm_itrans_int=1
         field_names(1)=Param
         read(Value, '(l2)', err=810) ptm_itrans

      elseif (Param .eq. 'ptm_iey') then
         ptm_iey_int=1
         field_names(1)=Param
         read(Value, '(l2)', err=810) ptm_iey

      elseif (Param .eq. 'ptm_iez') then
         ptm_iez_int=1
         field_names(1)=Param
         read(Value, '(l2)', err=810) ptm_iez

      elseif (Param .eq. 'ptm_flux_percent') then
         ptm_flux_percent_int=1
         field_names(1)=Param
         read(Value, '(l2)', err=810) ptm_flux_percent

      elseif (Param .eq. 'ptm_group_percent') then
         ptm_group_percent_int=1
         field_names(1)=Param
         read(Value, '(l2)', err=810) ptm_group_percent

      elseif (Param .eq. 'ptm_flux_cumulative') then
         ptm_flux_cumulative_int=1
         field_names(1)=Param
         read(Value, '(l2)', err=810) ptm_flux_cumulative

      elseif (Param .eq. 'ptm_random_seed') then
         ptm_random_seed_int=1
         field_names(1)=Param
         read(Value, '(i5)', err=810) ptm_random_seed

      elseif (Param .eq. 'ptm_no_animated') then
         ptm_no_animated_int=1
         field_names(1)=Param
         read(Value, '(i5)', err=810) ptm_no_animated

      elseif (Param .eq. 'ptm_trans_constant') then
         ptm_trans_constant_int=1
         field_names(1)=Param
         read(Value, '(f7.4)', err=810) ptm_trans_constant

      elseif (Param .eq. 'ptm_vert_constant') then
         ptm_vert_constant_int=1
         field_names(1)=Param
         read(Value, '(f7.4)', err=810) ptm_vert_constant

      elseif (Param .eq. 'ptm_iprof') then
         ptm_iprof_int=1
         field_names(1)=Param
         read(Value, '(l2)', err=810) ptm_iprof

      elseif (Param .eq. 'ptm_trans_a_coef') then
         ptm_trans_a_coef_int=1
         field_names(1)=Param
         read(Value, '(f7.4)', err=810) ptm_trans_a_coef

      elseif (Param .eq. 'ptm_trans_b_coef') then
         ptm_trans_b_coef_int=1
         field_names(1)=Param
         read(Value, '(f7.4)', err=810) ptm_trans_b_coef

      elseif (Param .eq. 'ptm_trans_c_coef') then
         ptm_trans_c_coef_int=1
         field_names(1)=Param
         read(Value, '(f7.4)', err=810) ptm_trans_c_coef

      elseif (Param .eq. 'ptm_shear_vel') then
	   write(unit_error,610)"ptm_shear_vel not used in this version of PTM"
         istat=-2
	   goto 900
      elseif (Param .eq. 'repeating_tide') then
         write(unit_error,610)"repeating_tide is deprecated"
         !pause	         
      elseif (Param .eq. 'warmup_run') then
	   goto 900	         
      else
         write(unit_error,610), Param, Value
         istat=-1
         goto 900
        
      endif

      return
      


 810  continue
      write(unit_error, 620) 'Conversion error on field ' //
     &     field_names(1), Param // '  ' // Value
      istat=-2 
     
         
 900  continue 
      write(unit_error, 620) 'fatal error ' //
     &     Param // '  ' // Value
      istat=-2 
      

      endsubroutine
         
      
         
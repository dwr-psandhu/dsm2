
  69  b   k820309    n          16.0        �95[                                                                                                           
       Z:\gtm_build\gtm_hydro\gtm\src\transport\diffusion.f90 DIFFUSION                                                 
                                                                                      8                                             
         
            T4o�A        1.23456789D8                                             
           
                �                                                     
         
               �?        5.D-1                                             
         
               �?        1.D0                                                          &                                                                                 &                                                             	           
        &                       %     @                                
                        #     @                                                      #DIFFUSE%N_CONN    #DIFFUSE%N_CHAN    #CONC    #CONC_PREV    #MASS_PREV    #AREA    #FLOW_LO    #FLOW_HI    #AREA_LO    #AREA_HI    #AREA_LO_PREV    #AREA_HI_PREV    #DISP_COEF_LO    #DISP_COEF_HI    #DISP_COEF_LO_PREV    #DISP_COEF_HI_PREV    #NCELL    #NVAR    #TIME_NEW    #THETA_GTM    #DT     #DX !   #KLU_SOLVER "                                                                                                                                                                                                     D @                                          
       p    5 � p    r    p      5 � p    r      5 � p    r        5 � p    r      5 � p    r                   
  @                                          
      p    5 � p    r    p      5 � p    r      5 � p    r        5 � p    r      5 � p    r                   
  @                                          
    p      5 � p    r        5 � p    r                   
  @                                          
    p      5 � p    r        5 � p    r                   
  @                                          
    p      5 � p    r        5 � p    r                   
  @                                          
 	   p      5 � p    r        5 � p    r                   
  @                                          
 
   p      5 � p    r        5 � p    r                   
  @                                          
    p      5 � p    r        5 � p    r                   
  @                                          
    p      5 � p    r        5 � p    r                   
  @                                          
    p      5 � p    r        5 � p    r                   
  @                                          
      p    5 � p    r    p      5 � p    r      5 � p    r        5 � p    r      5 � p    r                   
  @                                          
      p    5 � p    r    p      5 � p    r      5 � p    r        5 � p    r      5 � p    r                   
  @                                          
      p    5 � p    r    p      5 � p    r      5 � p    r        5 � p    r      5 � p    r                   
  @                                          
      p    5 � p    r    p      5 � p    r      5 � p    r        5 � p    r      5 � p    r                    
  @                                            
  @                                            
  @                                   
        
  @                                   
        
  @                                    
       
  @                              !            
    p      5 � p    r        5 � p    r                    
                                  "       #     @                                  #                    #EXPLICIT_DIFFUSE_OP $   #CONC '   #AREA_LO (   #AREA_HI )   #DISP_COEF_LO *   #DISP_COEF_HI +   #NCELL %   #NVAR &   #TIME ,   #DX -   #DT .                                                                                                                                                                                                               D                                $            
       p    5 � p    r %   p      5 � p    r %     5 � p    r &       5 � p    r %     5 � p    r &                  
  @                              '            
      p    5 � p    r %   p      5 � p    r %     5 � p    r &       5 � p    r %     5 � p    r &                  
  @                              (            
    p      5 � p    r %       5 � p    r %                  
  @                              )            
    p      5 � p    r %       5 � p    r %                  
  @                              *            
    p      5 � p    r %       5 � p    r %                  
  @                              +            
    p      5 � p    r %       5 � p    r %                   
  @                               %             
  @                               &             
  @                              ,     
       
  @                              -            
    p      5 � p    r %       5 � p    r %                   
  @                              .     
  #     @                                 /                    #RIGHT_HAND_SIDE 0   #EXPLICIT_DIFFUSE_OP 3   #MASS_PREV 4   #AREA_LO_PREV 5   #AREA_HI_PREV 6   #DISP_COEF_LO_PREV 7   #DISP_COEF_HI_PREV 8   #CONC_PREV 9   #THETA :   #NCELL 1   #TIME ;   #NVAR 2   #DX <   #DT =                                                                                                                                                                                                     D                                0            
 )      p    5 � p 
   r 1   p      5 � p 
   r 1     5 � p    r 2       5 � p 
   r 1     5 � p    r 2                  
                                 3            
 *     p    5 � p 
   r 1   p      5 � p 
   r 1     5 � p    r 2       5 � p 
   r 1     5 � p    r 2                  
                                 4            
 +     p    5 � p 
   r 1   p      5 � p 
   r 1     5 � p    r 2       5 � p 
   r 1     5 � p    r 2                  
                                 5            
 -   p      5 � p 
   r 1       5 � p 
   r 1                  
                                 6            
 .   p      5 � p 
   r 1       5 � p 
   r 1                  
                                 7            
 /   p      5 � p 
   r 1       5 � p 
   r 1                  
                                 8            
 0   p      5 � p 
   r 1       5 � p 
   r 1                  
                                 9            
 ,     p    5 � p 
   r 1   p      5 � p 
   r 1     5 � p    r 2       5 � p 
   r 1     5 � p    r 2                   
                                 :     
        
                                  1             
                                 ;     
        
                                  2            
                                 <            
 1   p      5 � p 
   r 1       5 � p 
   r 1                   
                                 =     
  #     @                                  >                    #CENTER_DIAG ?   #UP_DIAG A   #DOWN_DIAG B   #AREA C   #AREA_LO D   #AREA_HI E   #DISP_COEF_LO F   #DISP_COEF_HI G   #THETA_GTM H   #NCELL @   #TIME I   #NVAR J   #DX K   #DT L                                                                                                                                                                                                          D                                ?            
 3    p      5 � p 
   r @       5 � p 
   r @                  D                                A            
 4    p      5 � p 
   r @       5 � p 
   r @                  D                                B            
 2    p      5 � p 
   r @       5 � p 
   r @                  
                                 C            
 5   p      5 � p 
   r @       5 � p 
   r @                  
                                 D            
 6   p      5 � p 
   r @       5 � p 
   r @                  
                                 E            
 7   p      5 � p 
   r @       5 � p 
   r @                  
                                 F            
 8   p      5 � p 
   r @       5 � p 
   r @                  
                                 G            
 9   p      5 � p 
   r @       5 � p 
   r @                   
                                 H     
        
                                  @             
                                 I     
        
                                  J            
                                 K            
 :   p      5 � p 
   r @       5 � p 
   r @                   
                                 L     
  #     @                                  M                    #CENTER_DIAG N   #UP_DIAG P   #DOWN_DIAG Q   #RIGHT_HAND_SIDE R   #CONC T   #NCELL O   #NVAR S                                                                                                 
                                 N            
 =   p      5 � p    r O       5 � p    r O                  
                                 P            
 >   p      5 � p    r O       5 � p    r O                  
                                 Q            
 <   p      5 � p    r O       5 � p    r O                  
                                 R            
 ?     p    5 � p    r O   p      5 � p    r O     5 � p    r S       5 � p    r O     5 � p    r S                  D @                              T            
 @      p    5 � p    r O   p      5 � p    r O     5 � p    r S       5 � p    r O     5 � p    r S                   
  @                               O             
                                  S       #     @                                  U                    #DIFFUSIVE_FLUX_LO V   #DIFFUSIVE_FLUX_HI Y   #CONC Z   #AREA_LO [   #AREA_HI \   #DISP_COEF_LO ]   #DISP_COEF_HI ^   #NCELL W   #NVAR X   #TIME _   #DX `   #DT a                                                                                                                                              D @                              V            
 "      p    5 � p    r W   p      5 � p    r W     5 � p 	   r X       5 � p    r W     5 � p 	   r X                  D @                              Y            
 !      p    5 � p    r W   p      5 � p    r W     5 � p 	   r X       5 � p    r W     5 � p 	   r X                  
  @                              Z            
 #     p    5 � p    r W   p      5 � p    r W     5 � p 	   r X       5 � p    r W     5 � p 	   r X                  
  @                              [            
 $   p      5 � p    r W       5 � p    r W                  
  @                              \            
 %   p      5 � p    r W       5 � p    r W                  
  @                              ]            
 &   p      5 � p    r W       5 � p    r W                  
  @                              ^            
 '   p      5 � p    r W       5 � p    r W                   
  @                               W             
  @                               X             
  @                              _     
       
  @                              `            
 (   p      5 � p    r W       5 � p    r W                   
  @                              a     
     �   I      fn#fn    �   <   J   GTM_PRECISION '   %  ]       GTM_REAL+GTM_PRECISION (   �  h       LARGEREAL+GTM_PRECISION $   �  \       MINUS+GTM_PRECISION #   F  a       HALF+GTM_PRECISION "   �  `       ONE+GTM_PRECISION      d       AAP    k  d       AAI    �  d       AAX    3  H       USE_DIFFUSION    {  �      DIFFUSE 7   x  8     DIFFUSE%N_CONN+COMMON_VARIABLES=N_CONN 7   �  8     DIFFUSE%N_CHAN+COMMON_VARIABLES=N_CHAN    �  �   a   DIFFUSE%CONC "   �  �   a   DIFFUSE%CONC_PREV "   �  �   a   DIFFUSE%MASS_PREV    d	  �   a   DIFFUSE%AREA     �	  �   a   DIFFUSE%FLOW_LO     �
  �   a   DIFFUSE%FLOW_HI        �   a   DIFFUSE%AREA_LO     �  �   a   DIFFUSE%AREA_HI %   H  �   a   DIFFUSE%AREA_LO_PREV %   �  �   a   DIFFUSE%AREA_HI_PREV %   p  �   a   DIFFUSE%DISP_COEF_LO %   d  �   a   DIFFUSE%DISP_COEF_HI *   X  �   a   DIFFUSE%DISP_COEF_LO_PREV *   L  �   a   DIFFUSE%DISP_COEF_HI_PREV    @  8   a   DIFFUSE%NCELL    x  8   a   DIFFUSE%NVAR !   �  8   a   DIFFUSE%TIME_NEW "   �  8   a   DIFFUSE%THETA_GTM       8   a   DIFFUSE%DT    X  �   a   DIFFUSE%DX #   �  8   a   DIFFUSE%KLU_SOLVER ,   $  �      EXPLICIT_DIFFUSION_OPERATOR @   �  �   a   EXPLICIT_DIFFUSION_OPERATOR%EXPLICIT_DIFFUSE_OP 1   �  �   a   EXPLICIT_DIFFUSION_OPERATOR%CONC 4   �  �   a   EXPLICIT_DIFFUSION_OPERATOR%AREA_LO 4   ;  �   a   EXPLICIT_DIFFUSION_OPERATOR%AREA_HI 9   �  �   a   EXPLICIT_DIFFUSION_OPERATOR%DISP_COEF_LO 9   c  �   a   EXPLICIT_DIFFUSION_OPERATOR%DISP_COEF_HI 2   �  8   a   EXPLICIT_DIFFUSION_OPERATOR%NCELL 1   /  8   a   EXPLICIT_DIFFUSION_OPERATOR%NVAR 1   g  8   a   EXPLICIT_DIFFUSION_OPERATOR%TIME /   �  �   a   EXPLICIT_DIFFUSION_OPERATOR%DX /   3  8   a   EXPLICIT_DIFFUSION_OPERATOR%DT *   k  �      CONSTRUCT_RIGHT_HAND_SIDE :   D  �   a   CONSTRUCT_RIGHT_HAND_SIDE%RIGHT_HAND_SIDE >   8  �   a   CONSTRUCT_RIGHT_HAND_SIDE%EXPLICIT_DIFFUSE_OP 4   ,  �   a   CONSTRUCT_RIGHT_HAND_SIDE%MASS_PREV 7      �   a   CONSTRUCT_RIGHT_HAND_SIDE%AREA_LO_PREV 7   �  �   a   CONSTRUCT_RIGHT_HAND_SIDE%AREA_HI_PREV <   H   �   a   CONSTRUCT_RIGHT_HAND_SIDE%DISP_COEF_LO_PREV <   �   �   a   CONSTRUCT_RIGHT_HAND_SIDE%DISP_COEF_HI_PREV 4   p!  �   a   CONSTRUCT_RIGHT_HAND_SIDE%CONC_PREV 0   d"  8   a   CONSTRUCT_RIGHT_HAND_SIDE%THETA 0   �"  8   a   CONSTRUCT_RIGHT_HAND_SIDE%NCELL /   �"  8   a   CONSTRUCT_RIGHT_HAND_SIDE%TIME /   #  8   a   CONSTRUCT_RIGHT_HAND_SIDE%NVAR -   D#  �   a   CONSTRUCT_RIGHT_HAND_SIDE%DX -   �#  8   a   CONSTRUCT_RIGHT_HAND_SIDE%DT +   $  �      CONSTRUCT_DIFFUSION_MATRIX 7   �%  �   a   CONSTRUCT_DIFFUSION_MATRIX%CENTER_DIAG 3   ]&  �   a   CONSTRUCT_DIFFUSION_MATRIX%UP_DIAG 5   �&  �   a   CONSTRUCT_DIFFUSION_MATRIX%DOWN_DIAG 0   �'  �   a   CONSTRUCT_DIFFUSION_MATRIX%AREA 3   (  �   a   CONSTRUCT_DIFFUSION_MATRIX%AREA_LO 3   �(  �   a   CONSTRUCT_DIFFUSION_MATRIX%AREA_HI 8   A)  �   a   CONSTRUCT_DIFFUSION_MATRIX%DISP_COEF_LO 8   �)  �   a   CONSTRUCT_DIFFUSION_MATRIX%DISP_COEF_HI 5   i*  8   a   CONSTRUCT_DIFFUSION_MATRIX%THETA_GTM 1   �*  8   a   CONSTRUCT_DIFFUSION_MATRIX%NCELL 0   �*  8   a   CONSTRUCT_DIFFUSION_MATRIX%TIME 0   +  8   a   CONSTRUCT_DIFFUSION_MATRIX%NVAR .   I+  �   a   CONSTRUCT_DIFFUSION_MATRIX%DX .   �+  8   a   CONSTRUCT_DIFFUSION_MATRIX%DT    ,  �       SOLVE "   -  �   a   SOLVE%CENTER_DIAG    �-  �   a   SOLVE%UP_DIAG     ;.  �   a   SOLVE%DOWN_DIAG &   �.  �   a   SOLVE%RIGHT_HAND_SIDE    �/  �   a   SOLVE%CONC    �0  8   a   SOLVE%NCELL    �0  8   a   SOLVE%NVAR    '1  o      DIFFUSIVE_FLUX 1   �2  �   a   DIFFUSIVE_FLUX%DIFFUSIVE_FLUX_LO 1   �3  �   a   DIFFUSIVE_FLUX%DIFFUSIVE_FLUX_HI $   ~4  �   a   DIFFUSIVE_FLUX%CONC '   r5  �   a   DIFFUSIVE_FLUX%AREA_LO '   6  �   a   DIFFUSIVE_FLUX%AREA_HI ,   �6  �   a   DIFFUSIVE_FLUX%DISP_COEF_LO ,   .7  �   a   DIFFUSIVE_FLUX%DISP_COEF_HI %   �7  8   a   DIFFUSIVE_FLUX%NCELL $   �7  8   a   DIFFUSIVE_FLUX%NVAR $   28  8   a   DIFFUSIVE_FLUX%TIME "   j8  �   a   DIFFUSIVE_FLUX%DX "   �8  8   a   DIFFUSIVE_FLUX%DT 

  �.  �   k820309    n          16.0        �:5[                                                                                                           
       Z:\gtm_build\gtm_hydro\gtm\src\sediment_bed_setup\sb_subs.f90 SB_SUBS                                                 
                                                       
                                                       
                     @                               'H            #CHANNEL_NUM    #CHAN_NO    #CHANNEL_LENGTH    #UP_NODE    #DOWN_NODE 	   #UP_COMP 
   #DOWN_COMP    #START_CELL    #END_CELL    #DISPERSION    #MANNING    #CHAN_BTM_UP    #CHAN_BTM_DOWN             �                                                       �                                                      �                                                      �                                                      �                               	                       �                               
                       �                                                      �                                                      �                                        	               �                                   (   
   
            �                                   0      
            �                                   8      
            �                                   @      
                 @                                '            #MAX    #MIN    #TOP             �                                          
            �                                         
            �                                         
                 @               @                '�            #N_ZONE    #CELL_NO    #UP    #DOWN    #MIN_ELEV    #MAX_ELEV    #LENGTH    #SEGM_NO    #CHAN_NO    #UP_COMP_NO     #DOWN_COMP_NO !   #ELEV "   #WET_P #   #WIDTH $            �                                                       �                                                      �                                         
            �                                         
            �                                         
            �                                          
            �                                   (      
            �                                    0                  �                                    4   	               �                                     8   
               �                               !     <                �                              "        @         
        &                              �                              #        d         
        &                              �                              $        �         
        &                                     @                           %     '(            #CELL &   #ZONE '   #ELEV (   #CELL_WET_P )   #ZONE_WET_P *   #WIDTH +            �                               &                        �                               '                       �                              (           
            �                              )           
            �                              *           
            �                              +            
                 @                           ,     '8      
      #SEGM_NO -   #CHAN_NO .   #CHAN_NUM /   #UP_COMPPT 0   #DOWN_COMPPT 1   #NX 2   #START_CELL_NO 3   #UP_DISTANCE 4   #DOWN_DISTANCE 5   #LENGTH 6            �                               -                        �                               .                       �                               /                       �                               0                       �                               1                       �                               2                       �                               3                       �                              4            
            �                              5     (   	   
            �                              6     0   
   
                 @                           7     '            #CELL_ID 8   #UP_CELL 9   #DOWN_CELL :   #CHAN_NO ;   #DX <            �                               8                        �                               9                       �                               :                       �                               ;                       �                              <           
                 @               A           =     'H           #RESV_NO >   #NAME ?   #AREA @   #BOT_ELEV A   #N_RESV_CONN B   #RESV_CONN_NO C   #EXT_NODE_NO D   #NETWORK_ID E   #IS_GATED F   #N_QEXT G   #QEXT_NAME H   #QEXT_NO I   #QEXT_PATH J            �                               >                       �                               ?                                               !   |              C                                                        �                              @     (     
                            
                         0.D0        �                              A     0     
                            
                         0.D0        �                               B     8                                             �2������               �                               C        <                 &                              �                               D        `                 &                              �                               E        �                 &                              �                               F        �      	           &                                �                               G     �   
      .       �                               H        �                  &                                  �                               I        �                 &                              �                               J                        &           &                                  @  @                          K     'l            #BASE L   #LEN M   #OFFSET N   #FLAGS O   #RANK P   #RESERVED1 Q   #DIMINFO R            �                              L                        �                              M                       �                              N                       �                              O                       �                              P                       �                              Q                       �                               R                    #FOR_DESC_TRIPLET S   p      p        p                         @  @                         S     '            #EXTENT T   #MULT U   #LOWERBOUND V            �                              T                        �                              U                       �                              V                            @                          W     '                              @               @           X     '�            #MIN_ELEV Y   #ELEVATION Z   #AREA [   #WET_P \   #WIDTH ]   #ID ^   #CHAN_NO _   #VSECNO `   #NUM_ELEV a   #NUM_VIRT_SEC b   #PREV_ELEVATION_INDEX c            �                              Y            
          �                              Z                 
        &                              �                              [        ,         
        &                              �                              \        P         
        &                              �                              ]        t         
        &                                �                               ^     �                  �                               _     �                  �                               `     �                  �                               a     �   	               �                               b     �   
               �                               c     �               @                                d     
          @                                 e                                                 f                                      8        @                               g                                                h                                               i        8            &                       #SEGMENT_T ,        @ @                               j        �            &                       #SEDCELL_T                                            k     
         
                @        2.D0                                       l                    &                       #ELEVATION_T                                            m     
         
               �?        5.D-1                                      n           
        &                                                              o        H            &                       #CHANNEL_T    #     @                                  p                    #AREA q   #WIDTH r   #WET_P s   #DEPTH t   #X u   #Z v   #BRANCH w                                         q     
                                         r     
                                         s     
                                         t     
         
                                 u     
        
                                 v     
        
                                  w                                               x                                                y     
         
                         0.D0     @                                 z        (            &                       #SED_HDF_T %                                         {                                                |                                              }                                                ~                                                                                              �                                                �        #     @                                   �                    #INIT_INPUT_FILE �         D                                 �             1 #     @                                   �                     #     @                                  �                   #GET_SURVEY_TOP%N_CONN �   #WET_PERIM �   #ELEV �   #NCELL �                                                                                                                      �             D @                              �            
     p      5 � p    r �       5 � p    r �                  D @                              �            
     p      5 � p    r �       5 � p    r �                   
                                  �       #     @                                   �                     *         � n                 i              Cifmodintr.lib                     �   N      fn#fn    �   <   J   SB_COMMON    *  <   J   HDF_UTIL    f  <   J   COMMON_XSECT +   �        CHANNEL_T+COMMON_VARIABLES 7   �  @   a   CHANNEL_T%CHANNEL_NUM+COMMON_VARIABLES 3   �  @   a   CHANNEL_T%CHAN_NO+COMMON_VARIABLES :   /  @   a   CHANNEL_T%CHANNEL_LENGTH+COMMON_VARIABLES 3   o  @   a   CHANNEL_T%UP_NODE+COMMON_VARIABLES 5   �  @   a   CHANNEL_T%DOWN_NODE+COMMON_VARIABLES 3   �  @   a   CHANNEL_T%UP_COMP+COMMON_VARIABLES 5   /  @   a   CHANNEL_T%DOWN_COMP+COMMON_VARIABLES 6   o  @   a   CHANNEL_T%START_CELL+COMMON_VARIABLES 4   �  @   a   CHANNEL_T%END_CELL+COMMON_VARIABLES 6   �  @   a   CHANNEL_T%DISPERSION+COMMON_VARIABLES 3   /  @   a   CHANNEL_T%MANNING+COMMON_VARIABLES 7   o  @   a   CHANNEL_T%CHAN_BTM_UP+COMMON_VARIABLES 9   �  @   a   CHANNEL_T%CHAN_BTM_DOWN+COMMON_VARIABLES &   �  _       ELEVATION_T+SB_COMMON *   N  @   a   ELEVATION_T%MAX+SB_COMMON *   �  @   a   ELEVATION_T%MIN+SB_COMMON *   �  @   a   ELEVATION_T%TOP+SB_COMMON $     �       SEDCELL_T+SB_COMMON +     @   a   SEDCELL_T%N_ZONE+SB_COMMON ,   A  @   a   SEDCELL_T%CELL_NO+SB_COMMON '   �  @   a   SEDCELL_T%UP+SB_COMMON )   �  @   a   SEDCELL_T%DOWN+SB_COMMON -   	  @   a   SEDCELL_T%MIN_ELEV+SB_COMMON -   A	  @   a   SEDCELL_T%MAX_ELEV+SB_COMMON +   �	  @   a   SEDCELL_T%LENGTH+SB_COMMON ,   �	  @   a   SEDCELL_T%SEGM_NO+SB_COMMON ,   
  @   a   SEDCELL_T%CHAN_NO+SB_COMMON /   A
  @   a   SEDCELL_T%UP_COMP_NO+SB_COMMON 1   �
  @   a   SEDCELL_T%DOWN_COMP_NO+SB_COMMON )   �
  l   a   SEDCELL_T%ELEV+SB_COMMON *   -  l   a   SEDCELL_T%WET_P+SB_COMMON *   �  l   a   SEDCELL_T%WIDTH+SB_COMMON $     �       SED_HDF_T+SB_COMMON )   �  @   a   SED_HDF_T%CELL+SB_COMMON )   �  @   a   SED_HDF_T%ZONE+SB_COMMON )     @   a   SED_HDF_T%ELEV+SB_COMMON /   R  @   a   SED_HDF_T%CELL_WET_P+SB_COMMON /   �  @   a   SED_HDF_T%ZONE_WET_P+SB_COMMON *   �  @   a   SED_HDF_T%WIDTH+SB_COMMON +     �       SEGMENT_T+COMMON_VARIABLES 3   �  @   a   SEGMENT_T%SEGM_NO+COMMON_VARIABLES 3   )  @   a   SEGMENT_T%CHAN_NO+COMMON_VARIABLES 4   i  @   a   SEGMENT_T%CHAN_NUM+COMMON_VARIABLES 5   �  @   a   SEGMENT_T%UP_COMPPT+COMMON_VARIABLES 7   �  @   a   SEGMENT_T%DOWN_COMPPT+COMMON_VARIABLES .   )  @   a   SEGMENT_T%NX+COMMON_VARIABLES 9   i  @   a   SEGMENT_T%START_CELL_NO+COMMON_VARIABLES 7   �  @   a   SEGMENT_T%UP_DISTANCE+COMMON_VARIABLES 9   �  @   a   SEGMENT_T%DOWN_DISTANCE+COMMON_VARIABLES 2   )  @   a   SEGMENT_T%LENGTH+COMMON_VARIABLES (   i  �       CELL_T+COMMON_VARIABLES 0   �  @   a   CELL_T%CELL_ID+COMMON_VARIABLES 0   +  @   a   CELL_T%UP_CELL+COMMON_VARIABLES 2   k  @   a   CELL_T%DOWN_CELL+COMMON_VARIABLES 0   �  @   a   CELL_T%CHAN_NO+COMMON_VARIABLES +   �  @   a   CELL_T%DX+COMMON_VARIABLES -   +  �       RESERVOIR_T+COMMON_VARIABLES 5   '  @   a   RESERVOIR_T%RESV_NO+COMMON_VARIABLES 2   g  �   a   RESERVOIR_T%NAME+COMMON_VARIABLES 2     �   a   RESERVOIR_T%AREA+COMMON_VARIABLES 6   �  �   a   RESERVOIR_T%BOT_ELEV+COMMON_VARIABLES 9     |   a   RESERVOIR_T%N_RESV_CONN+COMMON_VARIABLES :   �  l   a   RESERVOIR_T%RESV_CONN_NO+COMMON_VARIABLES 9   �  l   a   RESERVOIR_T%EXT_NODE_NO+COMMON_VARIABLES 8   h  l   a   RESERVOIR_T%NETWORK_ID+COMMON_VARIABLES 6   �  l   a   RESERVOIR_T%IS_GATED+COMMON_VARIABLES 4   @  @   a   RESERVOIR_T%N_QEXT+COMMON_VARIABLES 7   �  p   a   RESERVOIR_T%QEXT_NAME+COMMON_VARIABLES 5   �  l   a   RESERVOIR_T%QEXT_NO+COMMON_VARIABLES 7   \  |   a   RESERVOIR_T%QEXT_PATH+COMMON_VARIABLES 3   �  �      FOR_ARRAY_DESCRIPTOR+ISO_C_BINDING 8   l  @   a   FOR_ARRAY_DESCRIPTOR%BASE+ISO_C_BINDING 7   �  @   a   FOR_ARRAY_DESCRIPTOR%LEN+ISO_C_BINDING :   �  @   a   FOR_ARRAY_DESCRIPTOR%OFFSET+ISO_C_BINDING 9   ,  @   a   FOR_ARRAY_DESCRIPTOR%FLAGS+ISO_C_BINDING 8   l  @   a   FOR_ARRAY_DESCRIPTOR%RANK+ISO_C_BINDING =   �  @   a   FOR_ARRAY_DESCRIPTOR%RESERVED1+ISO_C_BINDING ;   �  �   a   FOR_ARRAY_DESCRIPTOR%DIMINFO+ISO_C_BINDING /   z  j      FOR_DESC_TRIPLET+ISO_C_BINDING 6   �  @   a   FOR_DESC_TRIPLET%EXTENT+ISO_C_BINDING 4   $  @   a   FOR_DESC_TRIPLET%MULT+ISO_C_BINDING :   d  @   a   FOR_DESC_TRIPLET%LOWERBOUND+ISO_C_BINDING '   �  D       #UNLPOLY+ISO_C_BINDING -   �  �       CROSS_SECTION_T+COMMON_XSECT 6   �  @   a   CROSS_SECTION_T%MIN_ELEV+COMMON_XSECT 7     l   a   CROSS_SECTION_T%ELEVATION+COMMON_XSECT 2   p  l   a   CROSS_SECTION_T%AREA+COMMON_XSECT 3   �  l   a   CROSS_SECTION_T%WET_P+COMMON_XSECT 3   H   l   a   CROSS_SECTION_T%WIDTH+COMMON_XSECT 0   �   @   a   CROSS_SECTION_T%ID+COMMON_XSECT 5   �   @   a   CROSS_SECTION_T%CHAN_NO+COMMON_XSECT 4   4!  @   a   CROSS_SECTION_T%VSECNO+COMMON_XSECT 6   t!  @   a   CROSS_SECTION_T%NUM_ELEV+COMMON_XSECT :   �!  @   a   CROSS_SECTION_T%NUM_VIRT_SEC+COMMON_XSECT B   �!  @   a   CROSS_SECTION_T%PREV_ELEVATION_INDEX+COMMON_XSECT (   4"  8       GTM_DX+COMMON_VARIABLES !   l"  8       N_ZONE+SB_COMMON '   �"  ]       GTM_REAL+GTM_PRECISION (   #  8       N_CELL+COMMON_VARIABLES (   9#  8       N_SEGM+COMMON_VARIABLES &   q#  s       SEGM+COMMON_VARIABLES "   �#  s       SEDCELL+SB_COMMON "   W$  `       TWO+GTM_PRECISION $   �$  u       ELEVATION+SB_COMMON #   ,%  a       HALF+GTM_PRECISION (   �%  d       DX_ARR+COMMON_VARIABLES +   �%  s       CHAN_GEOM+COMMON_VARIABLES $   d&  �       CXINFO+COMMON_XSECT )   �&  8   a   CXINFO%AREA+COMMON_XSECT *   %'  8   a   CXINFO%WIDTH+COMMON_XSECT *   ]'  8   a   CXINFO%WET_P+COMMON_XSECT *   �'  8   a   CXINFO%DEPTH+COMMON_XSECT &   �'  8   a   CXINFO%X+COMMON_XSECT &   (  8   a   CXINFO%Z+COMMON_XSECT +   =(  8   a   CXINFO%BRANCH+COMMON_XSECT (   u(  8       N_CHAN+COMMON_VARIABLES #   �(  `       ZERO+GTM_PRECISION "   )  s       SED_HDF+SB_COMMON (   �)  8       N_CHAN+COMMON_VARIABLES (   �)  8       N_CONN+COMMON_VARIABLES (   �)  8       N_CONN+COMMON_VARIABLES )   (*  8       N_XSECT+COMMON_VARIABLES )   `*  8       N_XSECT+COMMON_VARIABLES -   �*  8       N_RESV_CONN+COMMON_VARIABLES (   �*  8       N_QEXT+COMMON_VARIABLES $   +  Y       GET_COMMAND_ARGS_SB 4   a+  @   a   GET_COMMAND_ARGS_SB%INIT_INPUT_FILE    �+  D       ASSIGN_CELLS    �+  �       GET_SURVEY_TOP >   �,  8     GET_SURVEY_TOP%N_CONN+COMMON_VARIABLES=N_CONN )   �,  �   a   GET_SURVEY_TOP%WET_PERIM $   �-  �   a   GET_SURVEY_TOP%ELEV %   .  8   a   GET_SURVEY_TOP%NCELL #   N.  D       FILL_SED_HDF_ARRAY    �.  Z      MsObjComment 
% Init

rand('state',0);
randn('state',0);
%dbstop if warning;
%dbstop if error;

%global defaults; 
%if( isempty(defaults))
    %spm_defaults;
%end 

global HEMISPHERES LOBES ROIS FUNCTIONS ROI_FUNC;

HEMISPHERES = { ...
	'Left', ...
	'Right', ...
};

list = HEMISPHERES; enum = 1; enum_list;

% LOBES

%LOBES = { ...
	%'Amygdala', ...
	%'AntSingulate', ...
	%'Caudate_Pallidum', ...
	%'Cerebellum', ...
	%'Cingulate', ...
	%'Frontal', ...
	%'Fusiform', ...
	%'Hippocampus', ...
	%'Occipital', ...
	%'Parietal', ...
	%'PostSingulate', ...
	%'Putamen', ...
	%'Subcortical', ...
	%'Temporal', ...
	%'Thalamus', ...
%};
	%'Left', ...
	%'Right', ...

LOBES = { ...
	'Frontal', ...
	'Occipital', ...
	'Parietal', ...
	'Temporal', ...
	'Fusiform', ...
	'Hippocampus', ...
};

list = LOBES; enum = 1; enum_list;

% ROIS

ROIS = { ...
	'LPRECENT', ...		  %  1. Precentral_L
	'RPRECENT', ...       %  2. Precentral_R
	'LSUPFRONT', ...      %  3. Frontal_Sup_L
	'RSUPFRONT', ...      %  4. Frontal_Sup_R
	'LORBFRONT', ...      %  5. Frontal_Sup_Orb_L+Frontal_Mid_Orb_L+Frontal_Inf_Orb_L
	'RORBFRONT', ...      %  6. Frontal_Sup_Orb_R+Frontal_Mid_Orb_R+Frontal_Inf_Orb_R
	'LMIDFRONT', ...      %  7. Frontal_Mid_L
	'RMIDFRONT', ...      %  8. Frontal_Mid_R
	'LOPER', ...          %  9. Frontal_Inf_Oper_L
	'ROPER', ...          % 10. Frontal_Inf_Oper_R
	'LTRIA', ...          % 11. Frontal_Inf_Tri_L
	'RTRIA', ...          % 12. Frontal_Inf_Tri_R
	'LINSULA', ...        % 13. Rolandic_Oper_L+Insula_L
	'RINSULA', ...        % 14. Rolandic_Oper_R+Rolandic_Oper_R
	'LSMA', ...           % 15. Supp_Motor_Area_L
	'RSMA', ...           % 16. Supp_Motor_Area_R
	'LMEDFRONT', ...      % 17. Frontal_Sup_Medial_L
	'RMEDFRONT', ...      % 18. Frontal_Sup_Medial_R
	'LACING', ...         % 19. Cingulum_Ant_L
	'RACING', ...         % 20. Cingulum_Ant_R
	'LPCING', ...         % 21. Cingulum_Mid_L+Cingulum_Post_L
	'RPCING', ...         % 22. Cingulum_Mid_R+Cingulum_Post_R
	'LHIP', ...           % 23. Hippocampus_L
	'RHIP', ...           % 24. Hippocampus_R
	'LPARAHIP', ...       % 25. ParaHippocampal_L
	'RPARAHIP', ...       % 26. ParaHippocampal_R
	'LAMYG', ...          % 27. Amygdala_L
	'RAMYG', ...          % 28. Amygdala_R
	'LCALC', ...          % 29. Calcarine_L
	'RCALC', ...          % 30. Calcarine_R
	'LSES', ...           % 31. Cuneus_L+Occipital_Sup_L+Occipital_Mid_L
	'RSES', ...           % 32. Cuneus_R+Occipital_Sup_R+Occipital_Mid_R
	'LIES', ...           % 33. Occipital_Inf_L+Lingual_L
	'RIES', ...           % 34. Occipital_Inf_R+Lingual_R
	'LFUSIFORM', ...      % 35. Fusiform_L
	'RFUSIFORM', ...      % 36. Fusiform_R
	'LPOSTCENT', ...      % 37. Postcentral_L
	'RPOSTCENT', ...      % 38. Postcentral_R
	'LSPL', ...           % 39. Parietal_Sup_L+Precuneus_L+Paracentral_Lobule_L
	'RSPL', ...           % 40. Parietal_Sup_R+Precuneus_R+Paracentral_Lobule_R
	'LIPL', ...           % 41. Parietal_Inf_L+SupraMarginal_L+Angular_L
	'RIPL', ...           % 42. Parietal_Inf_R+SupraMarginal_R+Angular_R
	'LIPS', ...           % 43. L_IPS
	'RIPS', ...           % 44. R_IPS
	'LCAUDATE', ...       % 45. Caudate_L
	'RCAUDATE', ...       % 46. Caudate_R
	'LPUTAMEN', ...       % 47. Putamen_L
	'RPUTAMEN', ...       % 48. Putamen_R
	'LPALLIDUM', ...      % 49. Pallidum_L
	'RPALLIDUM', ...      % 50. Pallidum_R
	'LTHALAMUS', ...      % 51. Thalamus_L
	'RTHALAMUS', ...      % 52. Thalamus_R
	'LHESCHL', ...        % 53. Heschl_L
	'RHESCHL', ...        % 54. Heschl_R
	'LTPOLE', ...         % 55. Temporal_Pole_Sup_L+Temporal_Pole_Mid_L
	'RTPOLE', ...         % 56. Temporal_Pole_Sup_R+Temporal_Pole_Mid_R
	'LSTANT', ...         % 57. L_ANT_SUP_TEMP+L_ANT_MID_TEMP
	'RSTANT', ...         % 58. R_ANT_SUP_TEMP+R_ANT_MID_TEMP
	'LSTMID', ...         % 59. L_MID_SUP_TEMP+L_MID_MID_TEMP
	'RSTMID', ...         % 60. R_MID_SUP_TEMP+R_MID_MID_TEMP
	'LSTPOS', ...         % 61. L_POS_SUP_TEMP+L_POS_MID_TEMP
	'RSTPOS', ...         % 62. R_POS_SUP_TEMP+R_POS_MID_TEMP
	'LITANT', ...         % 63. L_ANT_INF_TEMP
	'RITANT', ...         % 64. R_ANT_INF_TEMP
	'LITMID', ...         % 65. L_MID_INF_TEMP
	'RITMID', ...         % 66. R_MID_INF_TEMP
	'LITPOS', ...         % 67. L_POS_INF_TEMP
	'RITPOS', ...         % 68. R_POS_INF_TEMP
	'LCBEL', ...          % 69. Cerebelum_Crus1_L+Cerebelum_Crus2_L+Cerebelum_3_L+Cerebelum_4_5_L+Cerebelum_6_L+Cerebelum_7b_L+Cerebelum_8_L+Cerebelum_9_L+Cerebelum_10_L
	'RCBEL', ...          % 70. Cerebelum_Crus1_R+Cerebelum_Crus2_R+Cerebelum_3_R+Cerebelum_4_5_R+Cerebelum_6_R+Cerebelum_7b_R+Cerebelum_8_R+Cerebelum_9_R+Cerebelum_10_L
	'CBELVERMIS' ...      % 71. Vermis_1_2+Vermis_3+Vermis_4_5+Vermis_6+Vermis_7+Vermis_8+Vermis_9+Vermis_10
};

list = ROIS; enum = 1; enum_list;

% FUNCTIONS

FUNCTIONS = { ...
	'visual_imagery_visual_wordform_area', ...
	'low_level_visual_processing', ...
	'language_processing', ...
	'motor_sensory_processing', ...
	'place_area', ...
	'frontal_executive_ToM', ...
	'cerebellum', ...
	'emotion', ...
	'primary_auditory', ...
	'other_subcortical', ...
};

list = FUNCTIONS; enum = 1; enum_list;

% ROI_FUNC

ROI_FUNC = zeros( length(ROIS), length(FUNCTIONS) );

ROI_FUNC(LPRECENT,   motor_sensory_processing) = 1;
ROI_FUNC(RPRECENT,   motor_sensory_processing) = 1;
ROI_FUNC(LSUPFRONT,  frontal_executive_ToM) = 1;
ROI_FUNC(RSUPFRONT,  frontal_executive_ToM) = 1;
ROI_FUNC(LORBFRONT,  emotion) = 1;
ROI_FUNC(RORBFRONT,  emotion) = 1;
ROI_FUNC(LMIDFRONT,  frontal_executive_ToM) = 1;
ROI_FUNC(RMIDFRONT,  frontal_executive_ToM) = 1;
ROI_FUNC(LOPER,      language_processing) = 1;
ROI_FUNC(ROPER,      language_processing) = 1;
ROI_FUNC(LTRIA,      language_processing) = 1;
ROI_FUNC(RTRIA,      language_processing) = 1;
ROI_FUNC(LINSULA,    language_processing) = 1;
ROI_FUNC(RINSULA,    language_processing) = 1;
ROI_FUNC(LSMA,       motor_sensory_processing) = 1;
ROI_FUNC(RSMA,       motor_sensory_processing) = 1;
ROI_FUNC(LMEDFRONT,  frontal_executive_ToM) = 1;
ROI_FUNC(RMEDFRONT,  frontal_executive_ToM) = 1;
ROI_FUNC(LACING,     frontal_executive_ToM) = 1;
ROI_FUNC(RACING,     frontal_executive_ToM) = 1;
ROI_FUNC(LPCING,     other_subcortical) = 1;
ROI_FUNC(RPCING,     other_subcortical) = 1;
ROI_FUNC(LHIP,       other_subcortical) = 1;
ROI_FUNC(RHIP,       other_subcortical) = 1;
ROI_FUNC(LPARAHIP,   place_area) = 1;
ROI_FUNC(RPARAHIP,   place_area) = 1;
ROI_FUNC(LAMYG,      emotion) = 1;
ROI_FUNC(RAMYG,      emotion) = 1;
ROI_FUNC(LCALC,      low_level_visual_processing) = 1;
ROI_FUNC(RCALC,      low_level_visual_processing) = 1;
ROI_FUNC(LSES,       low_level_visual_processing) = 1;
ROI_FUNC(RSES,       low_level_visual_processing) = 1;
ROI_FUNC(LIES,       low_level_visual_processing) = 1;
ROI_FUNC(RIES,       low_level_visual_processing) = 1;
ROI_FUNC(LFUSIFORM,  visual_imagery_visual_wordform_area) = 1;
ROI_FUNC(RFUSIFORM,  visual_imagery_visual_wordform_area) = 1;
ROI_FUNC(LPOSTCENT,  motor_sensory_processing) = 1;
ROI_FUNC(RPOSTCENT,  motor_sensory_processing) = 1;
ROI_FUNC(LSPL,       visual_imagery_visual_wordform_area) = 1;
ROI_FUNC(RSPL,       visual_imagery_visual_wordform_area) = 1;
ROI_FUNC(LIPL,       visual_imagery_visual_wordform_area) = 1;
ROI_FUNC(RIPL,       visual_imagery_visual_wordform_area) = 1;
ROI_FUNC(LIPS,       visual_imagery_visual_wordform_area) = 1;
ROI_FUNC(RIPS,       visual_imagery_visual_wordform_area) = 1;
ROI_FUNC(LCAUDATE,   other_subcortical) = 1;
ROI_FUNC(RCAUDATE,   other_subcortical) = 1;
ROI_FUNC(LPUTAMEN,   emotion) = 1;
ROI_FUNC(RPUTAMEN,   other_subcortical) = 1;
ROI_FUNC(LPALLIDUM,  cerebellum) = 1;
ROI_FUNC(RPALLIDUM,  cerebellum) = 1;
ROI_FUNC(LTHALAMUS,  other_subcortical) = 1;
ROI_FUNC(RTHALAMUS,  other_subcortical) = 1;
ROI_FUNC(LHESCHL,    primary_auditory) = 1;
ROI_FUNC(RHESCHL,    primary_auditory) = 1;
ROI_FUNC(LTPOLE,     language_processing) = 1;
ROI_FUNC(RTPOLE,     language_processing) = 1;
ROI_FUNC(LSTANT,     language_processing) = 1;
ROI_FUNC(RSTANT,     language_processing) = 1;
ROI_FUNC(LSTMID,     language_processing) = 1;
ROI_FUNC(RSTMID,     language_processing) = 1;
ROI_FUNC(LSTPOS,     language_processing) = 1;
ROI_FUNC(RSTPOS,     language_processing) = 1;
ROI_FUNC(LITANT,     language_processing) = 1;
ROI_FUNC(RITANT,     language_processing) = 1;
ROI_FUNC(LITMID,     language_processing) = 1;
ROI_FUNC(RITMID,     language_processing) = 1;
ROI_FUNC(LITPOS,     language_processing) = 1;
ROI_FUNC(RITPOS,     language_processing) = 1;
ROI_FUNC(LCBEL,      cerebellum) = 1;
ROI_FUNC(RCBEL,      cerebellum) = 1;
ROI_FUNC(CBELVERMIS, cerebellum) = 1;

POSITION = [1280 0 1600 1200-100];
COLORS = {'black', 'blue', 'red', 'green', 'yellow'};

function [subj] = statmap_glm_multiv(subj,data_patname,regsname,selname,new_map_patname,extra_arg)

% much like STATMAP_SIMST_MULTIV, except using the GLM obj_funct
% 
% [SUBJ] = STATMAP_GLM_MULTIV( ...
%     SUBJ,DATA_PATNAME,REGSNAME,SELNAME,NEW_MAP_PATNAME,EXTRA_ARG)

% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================


extra_arg.obj_funct = 'statmap_glm_logic';

subj = statmap_searchlight( ...
    subj,data_patname,regsname,selname, ...
    new_map_patname,extra_arg);



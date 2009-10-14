function [type_matches_str type_matches_vec] = find_obj(subj,objname)

% Auxiliary function
%
% [TYPE_MATCHES_STR TYPE_MATCHES_VEC] = FIND_OBJ(SUBJ,OBJNAME)
%
% Zips through the SUBJ structure looking for objects of any type that
% match OBJNAME.
%
% It returns a string with the name of the types that contain an
% OBJNAME object, as well as a 4-part boolean

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


objtypes{1} = 'pattern';
objtypes{2} = 'regressors';
objtypes{3} = 'selector';
objtypes{4} = 'mask';

type_matches_vec = [false false false false];
type_matches_str = '';

for t=1:length(objtypes)
  if get_number(subj,objtypes{t},objname,'ignore_absence',true)
    type_matches_str = sprintf('%s\t%s',type_matches_str,objtypes{t});
    type_matches_vec(t) = true;
  end
end % for t




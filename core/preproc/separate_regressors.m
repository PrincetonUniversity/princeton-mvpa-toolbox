function [subj] = separate_regressors(subj, regsname, varargin)

% Separate regressors matrix into row vectors
%
% [SUBJ] = SEPARATE_REGRESSORS(SUBJ, REGSNAME, ...)
%
% Given a regressors matrix, creates new regressors objects with
% appropriate names (from 'condnames' property) that consist of the
% individual rows of the original matrix.  This is necessary before
% using any of the non-classification methods: statmap_xcorr, ridge
% regression, etc, as those assume single row vector regressors
% objects.
%
% REGSNAME should be an nConds x nTimepoints matrix of continuous
% regressors values.
%
% CONDNAMES (optional) is an nConds cell array of
% strings that are used to name the new regressors objects.  If not
% specified, the 'condnames' property of the REGSNAME regressor is used.
%
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


defaults.condnames = get_objfield(subj, 'regressors', regsname, 'condnames');

args = propval(varargin, defaults);

baseregs = get_mat(subj, 'regressors', regsname);
nConds = size(baseregs, 1);

% if regressor names are not specified and are not defined in
% REGSNAME, then create new names that are just numbered
condnames = args.condnames;
if isempty(condnames)
  for i = 1:nConds
    condnames{i} = sprintf('%s_%d', regsname, i);
    end
end
  
% create regressors group
for c = 1:nConds
    
  subj = ...
      initset_object(subj, 'regressors', condnames{c}, baseregs(c,:), ...
		     'condnames', condnames{c});
  
  if (nConds > 1)
    subj = set_objfield(subj, 'regressors', condnames{c}, ...
			      'group_name', [regsname, '_grp']);
  end
  
  % record keeping
  created.function = mfilename();
  created.regsname = regsname;
  subj = add_created(subj, 'regressors', condnames{c}, created);
  h = sprintf('Created by separate_regressors - iteration %i', c);
  subj = add_history(subj, 'regressors', condnames{c}, h);
    
end

dispf('Regressors group ''%s'' created by separate_regressors', ...
        [regsname, '_grp']);




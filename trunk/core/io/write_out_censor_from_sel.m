function [] = write_out_censor_from_sel(subj, selname, varargin)

% [] = WRITE_OUT_CENSOR_FROM_SEL(SUBJ, SELNAME, ...)
%
% Takes in a selector object/group, and writes each out to a
% .1d censor file. Only SEL==1 counts as 1 in the censor
% file, i.e. this is designed for writing out training
% selectors.
%
% CENSOR_1D_NAME (optional, default) = 'censor_%i.1d'
% (incrementing %i for each). Currently, it requires there
% to be a '%i' in the string, even if there's only one
% selector.

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


defaults.censor_1d_name = 'censor_%i.1d';
args = propval(varargin, defaults);

selnames = find_group_single(subj,'selector',selname);
nSels = length(selnames);

for s=1:nSels
  cur_selname = selnames{s};
  sel = get_mat(subj,'selector',cur_selname);
  
  % e.g. 'censor_1.1d', 'censor_2.1d'
  %
  % Notice the %i in the default CENSOR_1D_NAME that allows
  % us to use it directly in the sprintf call.
  cur_censor_filename = sprintf(args.censor_1d_name, s);
  
  censor = sel';
  censor(find(censor~=1)) = 0;
  save(cur_censor_filename,'censor','-ascii');

  dispf('Writing out %s', cur_censor_filename);
  
end % s nSels

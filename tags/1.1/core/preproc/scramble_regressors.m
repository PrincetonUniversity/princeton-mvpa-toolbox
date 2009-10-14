function [subj] = scramble_regressors(subj,regsname,selname,new_regsname,varargin)

% Scrambles your regressors for sanity-checking
%
% [SUBJ] = SCRAMBLE_REGRESSORS(SUBJ,REGSNAME,SELNAME,NEW_REGSNAME,...)
%
% SUBJ = the subj structure
%
% REGSNAME = the name of the regressors you want to scramble
%
% SELNAME = the selector that you want to constrain your scrambling
% with. Usually you will want to scramble within runs, so that you
% have the same number of timepoints in each run. Therefore,
% reference your 'runs' variable for the selname
%
% NEW_REGSNAME = the name you want to give your new scrambled
% regressors matrix
%
%   xxx - shouldn't this be optional???
%
% IGNORE_1OFN (optional, default = false). If your regressors
% are continuous-valued, contain rest or contain multiple active
% conditions in a timepoint, then you might want to scramble them
% in a more sophisticated way that ensures that their
% characteristics are preserved. By default, you'll get warned if
% your regressors aren't in basic 1-of-n form, unless you set this
% to true.

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


defaults.ignore_1ofn = false;
args = propval(varargin,defaults);

regs = get_mat(subj,'regressors',regsname);
runs = get_mat(subj,'selector',selname);

% See comment about IGNORE_1OFN above
[isbool isrest isoveractive] = check_1ofn_regressors(regs);
if ~isbool || isrest || isoveractive
  if ~args.ignore_1ofn
    warn = ['Your regressors aren''t in basic 1-of-n form - ' ...
	    'you may want to consider more sophisticated shuffling techniques'];
    warning(warn);
  end
end

% These next lines will shuffle your regressors within each run

for i = unique(runs)
  thisrun = find(runs == i);
  regs(:,thisrun) = shuffle(regs(:,thisrun),2);
end

subj = duplicate_object(subj,'regressors',regsname,new_regsname);
subj = set_mat(subj,'regressors',new_regsname,regs);

hist = sprintf('Regressors ''%s'' created by scramble_regressors',new_regsname);
subj = add_history(subj,'regressors',new_regsname,hist,true);

created.function = 'scramble_regressors';
created.regsname = regsname;
created.selname = selname;
subj = add_created(subj,'regressors',new_regsname,created);

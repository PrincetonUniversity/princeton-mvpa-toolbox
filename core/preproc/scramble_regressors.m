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
%
% ACTIVES_SELNAME (optional, default = ''). If empty, then this
% doesn't censor any individual TRs. If, however, you do want to use a
% temporal mask selector to exclude some TRs (i.e., don't shuffle those
% TRs and always leave them in place), feed in the name of a
% boolean selector. Similar in nature to the use of ACTIVES_SELNAME in
% CREATE_XVALID_INDICES.

% Change Log:
% 05.10.10 - rmruczek - added optional argument ACTIVES_SELNAME and corresponding functionality.
%                     - 

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
defaults.actives_selname = '';
args = propval(varargin,defaults);

regs = get_mat(subj,'regressors',regsname);
runs = get_mat(subj,'selector',selname);


if isempty(args.actives_selname)
  % If no actives_selname was fed in, then assume the user wants all
  % TRs to be included, and create a new all-ones actives selector
  actives = ones(size(runs));
else
  % Otherwise, use the one specified, or AND together
  % multiple boolean selectors
  actives = and_bool_selectors(subj,args.actives_selname);
end
actives = boolean(actives); % convert to logical indexing


% See comment about IGNORE_1OFN above
active_regs = regs(:,actives);
[isbool isrest isoveractive] = check_1ofn_regressors(active_regs);
if ~isbool || isrest || isoveractive
  if ~args.ignore_1ofn
    warn = ['Your regressors aren''t in basic 1-of-n form - ' ...
	    'you may want to consider more sophisticated shuffling techniques. ' ...
        'Consider using an ACTIVES_SELNAME to ignore time points where no ' ...
        'speific regressor is defined (ie, rest).'];
    warning(warn);
  end
end


% lets not assume that our runs were in order (ie, 1:nruns).  Instead, we're going to step through 
% each available run (AFTER filtering out the ACTIVES_SELECTOR).  In the end, run labels (ie, the values
% help in the runs selector) may not correspond to the index of that run.
active_runs = runs(:,actives);
% These next lines will shuffle your regressors (filtered through actives_selector) within each run
for i = unique(active_runs) %1:nruns (see above)
  thisrun = find(and(runs == i, actives)); % select only columns that are part of current run AND are 'active' (non-actives should never be scrambled)
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

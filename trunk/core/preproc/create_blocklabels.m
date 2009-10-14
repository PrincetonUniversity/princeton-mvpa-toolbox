function [subj] = create_blocklabels(subj,regsname,runsname,varargin)

% Creates selector labels for each condition in each run
%
% [SUBJ] = CREATE_BLOCKLABELS(SUBJ,REGSNAME,RUNSNAME,...)
% 
% See https://compmem.princeton.edu/mvpa_docs/TutorialAvg
%
% This is usually used a precursor to a function like
% AVERAGE_OBJECT.M. It creates a BLOCKLABELS selector which
% assigns a unique number to all the TRs in a given
% condition in each run, even if the timepoints from a given
% condition are not contiguous.
%
% Adds the following objects:
% - selector object 'blocklabels' (if BLOCKLABELS_NAME isn't specified)
%
% BLOCKLABELS_NAME (optional, default = 'blocklabels')
%
% If you want to use a more complicated averaging scheme of your own,
% just create your own BLOCKLABELS_NAME selector, with unique
% identifiers for every set of TRs you want to average together, and
% then call AVERAGE_OBJECT. The blocks need not be contiguous.
%
% Note: if REGSNAME contains rest, those TRs will be excluded in
% the averaging.
%
% Note: the labels are basically meaningless, and may not
% increase chronologically.
%
% ACTIVES_SELNAME (optional, default = ''). By default,
% this will take in all timepoints. Send in a boolean
% selector if you want to exclude some timepoints (as per
% e.g. CREATE_XVALID_INDICES) - these will be left as zeros.
%
% xxx should perhaps have an optional argument specifying averaging
% each block within a run separately - see obsolete/average_data

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


defaults.blocklabels_name = 'blocklabels';
defaults.actives_selname = '';
args = propval(varargin,defaults);

regs = get_mat(subj,'regressors',regsname);
runs = get_mat(subj,'selector',runsname);

if ~isempty(args.actives_selname)
  sel = get_mat(subj,'selector',args.actives_selname);
else
  sel = ones(size(runs));
end
keep_idx = find(sel);
regs_actives = regs(:,keep_idx);
% why isn't this inside an 'if' statement to check whether
% keep_idx < length(sel)???
disp('Excluding timepoints from blocklabels')

% we're checking REGS_ACTIVES because only the timepoints
% that are being allowed through the ACTIVES_SELNAME matter
[isbool isrest isoveractives] = check_1ofn_regressors(regs_actives);
if ~isbool || isoveractives
  error('Need boolean single-condition regressors');
end
if isrest
  warning('Rest will be excluded');
end

% N.B. the new BLOCKLABELS vector is going to have the same
% number of timepoints as the original, even if it means
% padding with zeros for ignored timepoints and rest
[nConds nTRs] = size(regs);
nRuns = max(runs);
blocklabels = zeros([1 nTRs]);
curlabel = 1;

missing_conds = 0;

for r=1:nRuns
  for c=1:nConds
    % this is the key line where we only include
    % timepoints from this condition from this run
    % filtered by the actives_sel
    curblock = find(regs(c,:)==1 & runs==r & sel==1);
    blocklabels(curblock) = curlabel;
    if length(curblock)
      curlabel = curlabel + 1;
    else
      missing_conds = missing_conds + 1;
    end
  end % c nConds
end

% If any conditions are missing from a run, let the user know
if missing_conds
  warning('Some runs were missing conditions');
end

subj = duplicate_object(subj,'selector',runsname,args.blocklabels_name);
subj = set_mat(subj,'selector',args.blocklabels_name,blocklabels);

created.function = mfilename;
created.regsname = regsname;
created.runsname = runsname;
created.args = args;
created.curlabel = curlabel;
created.missing_conds = missing_conds;
subj = add_created(subj,'selector',args.blocklabels_name,created);

blockhead = sprintf('Created blocklabels with %i unique blocks',curlabel-1);
subj = add_history(subj,'selector',args.blocklabels_name,blockhead,true);




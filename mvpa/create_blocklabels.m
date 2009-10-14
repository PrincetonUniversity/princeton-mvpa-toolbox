function [subj] = create_blocklabels(subj,regsname,runsname,varargin)

% Creates selector labels for each condition in each run
%
% [SUBJ] = CREATE_BLOCKLABELS(SUBJ,REGSNAME,RUNSNAME,...)
%
% This is usually used a precursor to AVERAGE_DATA.M. It creates a
% BLOCKLABELS selector which assigns a unique number to all the TRs in
% a given condition in each run.
%
% Adds the following objects:
% - selector object 'blocklabels' (if BLOCKLABELS_NAME isn't specified)
%
% BLOCKLABELS_NAME (optional, default = 'blocklabels')
%
% If you want to use a more complicated averaging scheme of your own,
% just create your own BLOCKLABELS_NAME selector, with unique
% identifiers for every set of TRs you want to average together, and
% then call AVERAGE_DATA2. The blocks need not be contiguous.
%
% Note: if REGSNAME contains rest, those TRs will be excluded in
% the averaging. Is this a problem for anyone? xxx
%
% xxx should also maybe allow you to specify an ACTIVES_SELNAME
% array
%
% xxx should perhaps have an optional argument specifying averaging
% each block within a run separately - see obsolete/average_data
%
% xxx you could argue that these should really be called condlabels
% or condrunlabels...


defaults.blocklabels_name = 'blocklabels';
args = propval(varargin,defaults);

regs = get_mat(subj,'regressors',regsname);
runs = get_mat(subj,'selector',runsname);

[isbool isrest isoveractives] = check_1ofn_regressors(regs);
if ~isbool || isoveractives
  error('Need boolean single-condition regressors');
end
if isrest
  warning('Rest will be excluded');
end

[nConds nTRs] = size(regs);
nRuns = max(runs);
blocklabels = zeros([1 nTRs]);
curlabel = 1;

missing_conds = 0;

for r=1:nRuns
  for c=1:nConds
    curblock = find(regs(c,:)==1 & runs==r);
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
created.curlabel = curlabel;
created.missing_conds = missing_conds;
subj = add_created(subj,'selector',args.blocklabels_name,created);

blockhead = sprintf('Created blocklabels with %i unique blocks',curlabel-1);
subj = add_history(subj,'selector',args.blocklabels_name,blockhead,true);




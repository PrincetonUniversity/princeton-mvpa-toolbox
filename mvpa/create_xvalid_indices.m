function [subj] = create_xvalid_indices(subj,runs_selname,varargin)

% Creates a selector for each iteration for leave-one-out cross-validation.
%
% [SUBJ] = CREATE_XVALID_INDICES(SUBJ,RUNS_SELNAME,...)
%
% Adds the following objects:
% - selectors group with nRuns objects, called NEW_SELSTEM
%
% Each iteration has a selector. One run is withheld on each
% iteration. TRs for that withheld run are set to 2, while the TRs for
% all the other runs are set to 1. Think of the 1s as training TRs and
% the 2s as testing TRs. These selectors get used by the nminusone
% no-peeking anova and for cross-validation classification.
%
% RUNS_SELNAME should consist of a vector with each TR labelled by
% its run number. For instance, an extremely brief experiment with
% 4 runs, with 5 TRs in each run, would look like this:
%    [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4]
% This runs vector should not include any zeros. You should use the
% ACTIVES_SELNAME to censor runs
%
% NEW_SELSTEM (optional, default = runs_selname + 'xval'). This
% determines the group_name and stem for the selector group that
% will be created
%
% ACTIVES_SELNAME (optional, default = ''). If empty, then this
% doesn't censor any individual TRs. If, however, you do want to use a
% temporal mask selector to exclude some TRs, feed in the name of a
% boolean selector. This will cause those TRs be ignored by later
% scripts. such as the no-peeking ANOVA or a cross-validation
% classifier
%
% e.g. subj = create_xvalid_indices(subj,'runs');
%
%      subj = create_xvalid_indices( ...
%         subj,'runs','new_selstem','runs_nminusone_xvalid', ...
%         'actives_selname','actives');

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


defaults.new_selstem = sprintf('%s_xval',runs_selname);
defaults.actives_selname = '';
args = propval(varargin,defaults);

runs = get_mat(subj,'selector',runs_selname);
nRuns = max(runs);

if length(find(runs==0))
  error(['You shouldn''t have any zeros in your runs. Use the' ...
	 ' actives_selname to censor TRs']);
end

if isempty(args.actives_selname)
  % If no actives_selname was fed in, then assume the user wants all
  % TRs to be included, and create a new all-ones actives selector
  actives = ones(size(runs));
else
  % Otherwise, use the one they specified
  actives = get_mat(subj,'selector',args.actives_selname);
end

all_selsnames = [];

% We're going to create one selector for each iteration, each time
% withholding a different run
for r=1:nRuns

  % Set up what will go into the selector object
  cur_selname = sprintf('%s_%i',args.new_selstem,r);

  cursels = zeros(size(runs)); % all but train + testing TRs = 0
  cursels(find(runs)) = 1;     % training TRs = 1
  cursels(find(runs==r)) = 2;  % testing TRs = 2

  % Use the actives selector to see if any TRs should be censored
  cursels(find(~actives)) = 0;

  % Now create the selector object, and fill it with goodies
  subj = duplicate_object(subj,'selector',runs_selname,cur_selname);
  subj = set_mat(subj,'selector',cur_selname,cursels);

  if nRuns>1 
    subj = set_objfield(subj,'selector',cur_selname,'group_name',args.new_selstem,'ignore_absence',true);
  end
  
  % Tell it the story of how it came to be
  created.function = 'create_xvalid_indices';
  created.runs_selname = runs_selname;
  created.actives_selname = args.actives_selname;
  subj = add_created(subj,'selector',cur_selname,created);

  it_hist = sprintf('Created by create_xvalid_indices - iteration #%i',r);
  subj = add_history(subj,'selector',cur_selname,it_hist);
end % r nRuns

if nRuns>1
  main_hist = sprintf('Selector group ''%s'' created by create_xvalid_indices',args.new_selstem);
else
  main_hist = sprintf('Selector object ''%s'' created by create_xvalid_indices',args.new_selstem);
end
disp( main_hist );



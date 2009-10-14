function [subj] = create_xvalid_oddeven(subj,runs_selname,varargin)

% Create split-halves xvalid indices
%
% [SUBJ] = CREATE_XVALID_ODDEVEN(SUBJ,RUNS_SELNAME,VARARGIN)
%
% Defines odd runs as training and even runs as testing
% for selector 1, and vice versa for selector 2.
%
% See CREATE_XVALID_INDICES.M for more information, and
% definition of the optional arguments.
%
% NEW_SELSTEM (optional, default = ('%s_xvoe',runs_selname).
%
% ACTIVES_SELNAME

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


defaults.new_selstem = sprintf('%s_xvoe',runs_selname);
defaults.actives_selname = '';
args = propval(varargin,defaults);

runs = get_mat(subj,'selector',runs_selname);
nRuns = max(runs);

if isempty(args.actives_selname)
  % If no actives_selname was fed in, then assume the user
  % wants all TRs to be included, and create a new all-ones
  % actives selector
  actives = ones(size(runs));
else
  % Otherwise, use the one specified, or AND together
  % multiple boolean selectors
  actives = and_bool_selectors(subj,args.actives_selname);
end

sanity_check_for_runs(runs,actives)

sel1 = NaN(size(runs));
sel2 = NaN(size(runs));
% Sel 1: odd = training, even = testing
% Sel 2: even = training, odd = testing
for r=1:nRuns
  if mod(r,2)
    % odd run
    sel1(find(runs==r)) = 1;
    sel2(find(runs==r)) = 2;
  else
    % even run
    sel1(find(runs==r)) = 2;
    sel2(find(runs==r)) = 1;
  end
end % r

sel1(find(~actives)) = 0;
sel2(find(~actives)) = 0;

if ...
      length(find(isnan(sel1))) || ...
      length(find(isnan(sel2)))
  error('You still have NaNs in your selectors somehow');
end

sanity_check_for_cursels(sel1);
sanity_check_for_cursels(sel2);

sel1_name = sprintf('%s_1',args.new_selstem);
sel2_name = sprintf('%s_2',args.new_selstem);

% Now create the selector object, and fill it with goodies
subj = duplicate_object(subj,'selector',runs_selname,sel1_name);
subj = duplicate_object(subj,'selector',runs_selname,sel2_name);

subj = set_mat(subj,'selector',sel1_name,sel1);
subj = set_mat(subj,'selector',sel2_name,sel2);
  
subj = set_objfield( ...
    subj,'selector',sel1_name, ...
    'group_name',args.new_selstem,'ignore_absence',true);
subj = set_objfield( ...
    subj,'selector',sel2_name, ...
    'group_name',args.new_selstem,'ignore_absence',true);

% Tell it the story of how it came to be
created.function = mfilename;
created.runs_selname = runs_selname;
created.actives_selname = args.actives_selname;
subj = add_created(subj,'selector',sel1_name,created);
subj = add_created(subj,'selector',sel2_name,created);

it_hist = sprintf('Created by %s - iteration #%i',created.function,r);
subj = add_history(subj,'selector',sel1_name,it_hist);
subj = add_history(subj,'selector',sel2_name,it_hist);
  
main_hist = sprintf('Selector group ''%s'' created by %s',created.function,args.new_selstem);
disp( main_hist );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check_for_runs(runs,actives)

% check if only one run

% if unique(runs)==1
%   error('You cannot have only one run');
% end

if ~isint(actives)
  error('Use only integers for the active_selector');
end

if find(actives > 1 | actives < 0)
  error('Your active_selector should be binary only');   
end  

 if length(find(runs==0))
   error('Your runs vector contains zeros');
 end

if ~isrow(runs)
  error('Your runs vector should be a row vector');
end

if length(find(diff(runs)<0))
  error('Your runs seem to be jumbled');
end

%if length(find(diff(runs)>1))
% error('You seem to be missing a run in the middle');
%end

if ~compare_size(actives,runs)
  error('Your actives and runs are different sizes');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check_for_cursels(cursels)

if ~length(find(cursels==1))
  warning(['For some reason, you have no training TRs in this' ...
	   ' iteration.This create a selector with all ones in it. This will be handled in the cross_validation function'])
end

if ~length(find(cursels==2))
  warning(['For some reason, you have no testing TRs in this iteration.This create a selector with all twos in it. This will be handled in the cross_validation function']);
end









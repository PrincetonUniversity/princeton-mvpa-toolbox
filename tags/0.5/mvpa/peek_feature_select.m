function [subj] = peek_feature_select(subj,data_patname,regsname,selname,varargin)

% Just like PEEK_FEATURE_SELECT, except that it peeks
%
% [SUBJ] = PEEK_FEATURE_SELECT(SUBJ,DATA_PATNAME,REGSNAME,SELNAME,...)
%
% Only creates a single statmap pattern and mask because it runs the
% statmap_anova on all the TRs in the data.
%
% This is 'peeking' (cheating), because it means that we're allowing
% our feature selection method to peek at the test data that we will
% use later to assess our classifier generalization
%
% See FEATURE_SELECT for more info, including about the
% optional arguments (which are the same)
%
% Adds the following objects:
% - pattern statmap
% - mask
%
% Deliberately requires you to feed in a selname (e.g. all ones) to
% remind you of what you're doing
%
% Do not use - this function only exists as a check - this way of
% using the anova is scientifically illegitimate.


defaults.new_map_patname = sprintf('%s_statmap',data_patname);
defaults.new_maskname    = sprintf('%s_thresh',data_patname);
defaults.thresh          = 0.05;
defaults.statmap_arg     = [];
defaults.statmap_funct = 'statmap_anova';
defaults.statmap_arg = [];
args = propval(varargin,defaults);

if ~ischar(args.statmap_funct)
  error('The statmap function name has to be a string');
end

disp( 'Starting peeking anova');

sels = get_mat(subj,'selector',selname);  

subj = statmap_anova(subj,data_patname,regsname,selname,args.new_map_patname,args.statmap_arg);

% Now, create a new thresholded binary mask from the p-values
% statmap pattern returned by the anova
subj = create_thresh_mask(subj,args.new_map_patname,args.new_maskname,args.thresh);

disp( sprintf('Pattern statmap ''%s'' and mask ''%s'' created by peek_feature_select', ...
	      args.new_map_patname,args.new_maskname) );




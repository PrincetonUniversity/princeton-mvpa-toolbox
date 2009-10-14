function [subj] = peek_feature_select(subj,data_patname,regsname,selname,varargin)

% Just like FEATURE_SELECT, except that it peeks
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


defaults.new_map_patname = '';
defaults.new_maskname    = sprintf('%s_thresh',data_patname);
defaults.thresh          = 0.05;
defaults.statmap_arg     = struct([]);
defaults.statmap_funct = 'statmap_anova';
defaults.statmap_arg = [];
args = propval(varargin,defaults);

if ~ischar(args.statmap_funct)
  error('The statmap function name has to be a string');
end

if isempty(args.new_map_patname)
  % get the name of the function being run, e.g. 'statmap_anova' -> 'anova'
  stripped_name = strrep(args.statmap_funct,'statmap_','');
  args.new_map_patname = sprintf('%s_%speek',data_patname,stripped_name);
end

% append the thresh to the end of the name
args.new_maskname = sprintf('%s%s',args.new_maskname,num2str(args.thresh));

args.statmap_arg.cur_iteration = [];

disp( sprintf('Starting peeking %s',args.statmap_funct) );

statmap_fh = str2func(args.statmap_funct);
subj = statmap_fh(subj,data_patname,regsname,selname, ...
		  args.new_map_patname,args.statmap_arg);

disp( sprintf('Pattern statmap ''%s'' created by peek_feature_select', ...
	      args.new_map_patname) );

if ~isempty(args.thresh)
  % Now, create a new thresholded binary mask from the p-values
  % statmap pattern returned by the anova
  subj = create_thresh_mask(subj,args.new_map_patname,args.new_maskname,args.thresh);

disp( sprintf('Mask ''%s'' created by peek_feature_select', ...
	      args.new_maskname) );

end





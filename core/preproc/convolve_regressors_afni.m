function [subj new_regsname] = convolve_regressors_afni(subj,old_regsname,runsname,varargin)

% Convolves regressors with HRF
%
% [SUBJ NEW_REGSNAME] = CONVOLVE_REGRESSORS_AFNI(SUBJ,REGSNAME,RUNSNAME,...)
%
% Takes a set of regressors and convolves each condition
% with a gamma haemodynamic response function using AFNI's
% 'waver' command - separately for each run
%
% Adds the following objects:
% - a new regressors object called NEW_REGSNAME
%
% The AFNI waver function requires a .1d text file as input
% containing a column of numbers for a given condition which
% it will convolve with the HRF. It then creates a new .1d
% file with the convolved numbers. This function will create
% a set of temporary .1d files, one for each condition,
% called NEW_REGSNAME_<cond#>.1d. It will then call waver to
% create a corresponding bunch of
% NEW_REGSNAME_conv_<cond#>.1d files, load them in to
% matlab, concatenate them and create a new regressors
% object called NEW_REGSNAME to keep them in. It will then
% delete all the temporary 1d files it created, unless
% KEEP_FILES is true.
%
% Note: this takes a few seconds, because the waver command
% seems pretty slow for what it does
%
% NEW_REGSNAME (optional, default = OLD_REGSNAME + '_conv')
%
% OVERWRITE_IF_EXIST (optional, default = false). By
% default, this function will halt if any of the input or
% output .1d files that it tries to create already
% exist. Set this to true if you want it to overwrite
% existing files
%
% TR_SIZE_IN_SECONDS (optional, default = 2). This is the
% number of seconds that each TR lasts. AFNI needs to know
% this
%
% SCALE_TO_ONE (optional, default = true). When you convolve
% your regressors, the non-zero values in them get much
% larger (depending on how many timepoints you
% have). Sometimes, you may have problems if your regressor
% values go above 1, so this will scale the convolved
% regressors so that the maximum value in the entire
% regressors matrix is 1. Set to false if you don't want to
% do any scaling.
%
% BINARIZE_THRESH (optional, default = NaN). If set to a
% value, this will binarize the convolved regressors, such
% that values above BINARIZE_THRESH are set to 1, and all
% other values are set to 0. Assuming SCALE_TO_ONE is true,
% I tend to use a BINARIZE_THRESH of about 0.8 - this
% excludes the first couple of timepoints from a block. This
% will add the thresholded *as well as* the unthresholded
% versions of the convolved regressors. N.B. if SCALE_TO_ONE
% is false, then you'll have to customize this
% BINARIZE_THRESH accordingly.
%
%   UPDATE: The thresholded object will be called
%   OLD_REGSNAME + '_convt'. We haven't currently
%   implemented an optional argument for changing this. This
%   used to be called '_conv_thr'.
%
% DISPLAY_SHELL_SCRIPT (optional, default = false). By
% default, this will call WAVER invisibly, and read in the
% results. Set this to true if you'd like to see the shell
% waver command each time.
%
% AFNI_LOCATION (optional, default = ''). If empty, this
% assumes that the 'waver' command is somewhere in your
% path, and just calls it directly. However, if you know
% that waver isn't in your path, setting this will allow you
% to prepend the AFNI_LOCATION pathname to the waver call,
% e.g. '/usr/bin/afni/'
%
% DO_PLOT (optional, default = false). Plot an imagesc of
% the old and new regressors to confirm that the shift looks
% right

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


defaults.new_regsname = sprintf('%s_conv',old_regsname);
defaults.overwrite_if_exist = false;
defaults.tr_size_in_seconds = 2;
defaults.scale_to_one = true;
defaults.binarize_thresh = NaN;
defaults.afni_location = '';
defaults.do_plot = false;
defaults.display_shell_script = false;
args = propval(varargin,defaults);
args_into_workspace

[subj regs] = duplicate_object(subj,'regressors',old_regsname,args.new_regsname, ...
			       'include_unknown_fields',true);

regs = get_mat(subj,'regressors',old_regsname);
runs = get_mat(subj,'selector',runsname);
nRuns = max(runs);

hist = sprintf('Convolving %s regressors to form %s',old_regsname,args.new_regsname);
disp(hist);

created.shell_command = {};
created.shell_response = {};
allregs_conv = [];
for r=1:nRuns
  % need to split the regressors matrix up by runs
  TRs_this_run = find(runs==r);
  thisregs = regs(:,TRs_this_run);
  [thisregs_conv created] = convolve_regressors_afni_onerun(r,thisregs,old_regsname,args,created);
  if ~compare_size(thisregs,thisregs_conv)
    error('Somehow the convolution changed the size of run %i''s regressors',r);
  end  
  allregs_conv = [allregs_conv thisregs_conv];
  fprintf('\t%i',r)
end
disp(' ')

% ALLREGS_CONV should now be an nConds x nTimepoints matrix just like regs,
% only containing the convolved regressors

% N.B. it's critical that this scale the entire regressors
% matrix, rather than individual rows separately, because
% you may want to run a GLM with these scaled regressors,
% and the scaling is going to change the raw betas you get
% as a result. This should be ok if they've all been
% linearly scaled by the same coefficient, but if you scaled
% them separately than you might have a problem with
% comparing your betas across conditions if different
% conditions had different maximums.
if args.scale_to_one
  allregs_conv = allregs_conv / max(max(allregs_conv));
end

sanity_check(regs,allregs_conv);

created.function = mfilename;
created.old_regsname = old_regsname;
created.args = args;
subj = add_created(subj,'regressors',args.new_regsname,created);

subj = set_mat(subj,'regressors',args.new_regsname,allregs_conv);

subj = add_history(subj,'regressors',args.new_regsname,hist);

if ~isnan(args.binarize_thresh)
  % binarize the regressors, so 'blah_conv' -> 'blah_convt'
  new_regsname_thr = sprintf('%st',args.new_regsname);
  subj = binarize_regressors(subj, args.new_regsname, args.binarize_thresh, ...
                             'new_regsname', new_regsname_thr);
  allregs_convt = get_mat(subj,'regressors',new_regsname_thr);
else
  allregs_convt = NaN(size(allregs_conv));
end


if args.do_plot
  old_regs = get_mat(subj,'regressors',old_regsname);
  figure
  
  subplot(3,1,1)
  plot(old_regs');
    ax = axis; ax(4) = ax(4) * 1.1; axis(ax) % give y axis room
  titlef('%s - %s - raw',subj.header.id,old_regsname)

  subplot(3,1,2)
  plot(allregs_conv');
  ax = axis; ax(4) = ax(4) * 1.1; axis(ax) % give y axis room
  titlef('%s - %s - after convolution',subj.header.id,old_regsname)

  subplot(3,1,3)
  plot(allregs_convt');
  ax = axis; ax(4) = ax(4) * 1.1; axis(ax) % give y axis room
  titlef('%s - %s - after thresholding %.1f',subj.header.id,old_regsname,binarize_thresh)
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [thisregs_conv created] = convolve_regressors_afni_onerun(currun,thisregs,old_regsname,args,created)

% This takes in a regressors matrix for a particular run,
% and convolves it.
nConds = size(thisregs,1);
thisregs_conv = [];
   
for curcond=1:nConds
  condvec = thisregs(curcond,:);
  [shell_command infile outfile shell_response] = call_waver(currun,curcond,condvec,old_regsname,args);
  load(outfile);
  % add the newly-loaded variable (called args.new_regsname) to the
  % end of the matrix
  cur_varname = sprintf('%s_r%i_c%i',args.new_regsname,currun,curcond);
  thisregs_conv = [thisregs_conv; eval(cur_varname)'];
  created.shell_command{curcond} = shell_command;
  created.shell_response{curcond} = shell_response;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [wavexec input1d output1d execout] = call_waver(currun,curcond,condvec,old_regsname,args)
  
% Write the input .1d file from the current condition's worth of
% regressors, create the command-line call to waver and use it
%
% Will error if anything goes wrong
%
% -GAM = gamma function
% -dt = TR size in seconds
% -numout = truncate the extra timepoints at the end created by convolution
% -input = name of regressors 1d file
% > = output to this file
%
% e.g.
%   waver \
%     -GAM \
%     -dt 2 \
%     -numout 1152 \
%     -input col1.1d \
%     > col1_conv.1d


condvec = condvec';

% isrow: 0 for column, 1 for row, -1 for matrix
if isrow(condvec)~=0
  error('Not a column vector');
end

numout = size(condvec,1);

input1d = sprintf('%s_r%i_c%i.1d',old_regsname,currun,curcond);
output1d = sprintf('%s_r%i_c%i.1d',args.new_regsname,currun,curcond);

if exist(input1d,'file')
  if ~args.overwrite_if_exist
    error('File called %s already exists',input1d);
  end
end

if exist(output1d,'file')
  if ~args.overwrite_if_exist
    error('File called %s already exists',output1d);
  end
end

save(input1d,'-ascii','condvec');

wavexec = sprintf('%s -GAM -dt %f -numout %i -input %s > %s', ...
		  fullfile(args.afni_location,'waver'), ...
		  args.tr_size_in_seconds, ...
		  numout, ...
		  input1d, ...
		  output1d);

if args.display_shell_script
  disp(wavexec)
end

[execstatus execout] = unix(wavexec);

% execstatus is zero if all went well
if execstatus
  error('Waver call status = %i, response: %s',execstatus,execout);
end

if ~exist(output1d,'file')
  error('%s didn''t get created',output1d);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(regs,newregs)

if ~compare_size(regs,newregs)
  error('Regs and allregs_conv are different sizes');
end

if length(find(newregs==0))==0
  warning('All of your regressor values are non-zero');
end

if length(find(newregs))==0
  warning('All of your regressor values are zero');
end

% My scalar regressors are negative legally
% if min(min(newregs))<0
%   warning('You have negative regressor values');
% end




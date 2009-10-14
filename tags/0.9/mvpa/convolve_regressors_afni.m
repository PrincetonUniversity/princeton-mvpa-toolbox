function [subj] = convolve_regressors_afni(subj,old_regsname,runsname,varargin)

% Convolves regressors with HRF
%
% [SUBJ] = CONVOLVE_REGRESSORS_AFNI(SUBJ,REGSNAME,RUNSNAME,...)
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
% NEW_REGSNAME (optional, default = OLD_REGSNAME + 'conv')
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
% regressors so that the maximum value in them is 1. Set to
% false if you don't want to do any scaling
%
% BINARIZE_THRESH (optional, default = NaN). If set to a
% value, this will binarize the convolved regressors, such
% that values above BINARIZE_THRESH are set to 1, and all
% other values are set to 0. Assuming SCALE_TO_ONE is true,
% I tend to use a BINARIZE_THRESH of about 0.8 - this
% excludes the first couple of timepoints from a
% block. N.B. if SCALE_TO_ONE is false, then you'll have to
% customize this BINARIZE_THRESH accordingly.
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


defaults.new_regsname = sprintf('%s_conv',old_regsname);
defaults.overwrite_if_exist = false;
defaults.tr_size_in_seconds = 2;
defaults.scale_to_one = true;
defaults.binarize_thresh = NaN;
defaults.afni_location = '';
defaults.do_plot = false;
args = propval(varargin,defaults);

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

if args.scale_to_one
  allregs_conv = allregs_conv / max(max(allregs_conv));
end

if ~isnan(args.binarize_thresh)
  % create a zeros matrix, then put 1s in wherever the
  % convolve regressor values are above the BINARIZE_THRESH
  temp_newregs = zeros(size(allregs_conv));
  set_to_one_idx = find(allregs_conv > args.binarize_thresh);
  temp_newregs(set_to_one_idx) = 1;
  allregs_conv = temp_newregs;
end

sanity_check(regs,allregs_conv);

created.function = mfilename;
created.old_regsname = old_regsname;
created.args = args;
subj = add_created(subj,'regressors',args.new_regsname,created);

subj = set_mat(subj,'regressors',args.new_regsname,allregs_conv);

subj = add_history(subj,'regressors',args.new_regsname,hist);

if args.do_plot
  old_regs = get_mat(subj,'regressors',old_regsname);
  figure
  subplot(2,1,1)
  imagesc(old_regs);
  subplot(2,1,2)
  imagesc(allregs_conv);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [thisregs_conv created] = convolve_regressors_afni_onerun(currun,thisregs,old_regsname,args,created)

% This takes in a regressors matrix for a particular run, and then 
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
% -intput = name of regressors 1d file
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

wavexec = sprintf('%s -GAM -dt %i -numout %i -input %s > %s', ...
		  fullfile(args.afni_location,'waver'), ...
		  args.tr_size_in_seconds, ...
		  numout, ...
		  input1d, ...
		  output1d);

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




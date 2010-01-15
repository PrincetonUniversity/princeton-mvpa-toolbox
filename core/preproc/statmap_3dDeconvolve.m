function [subj] = statmap_3dDeconvolve(subj,data_patname,regsname,selname,new_map_patname,extra_arg)

% Use AFNI's 3dDeconvolve to select features that vary
% between conditions
%
% See the TutorialAdv MVPA wiki page for more information.
%
% [SUBJ] = STATMAP_3DDECONVOLVE(SUBJ,DATA_PATNAME,REGSNAME,NEW_MAP_PATNAME,EXTRA_ARG);
%
% Adds the following objects:
% - statmap pattern object
%
% This requires you to already have a BRIK written out that
% has all the timepoints in your entire dataset. It will
% write out your 1d regressor files for you, write out a
% censor file, call 3dDeconvolve, read in the last sub-brik
% (hopefully the F-stat map) from the resulting bucket, and
% create a new statmap from it.
%
% I'm not sure at this stage how best to deal with rest. It
% seems that 3dDeconvolve doesn't like rest TRs, but I'm not
% too clear at this point about this
%
% This is a pretty fiendish business. Before using this, you
% should try running 3dDeconvolve once manually, to make
% sure you know what you're doing, and so that you can then
% check that the shell-script and output this function
% creates is right.
%
% See also: CONVOLVE_REGRESSORS_AFNI.M. This will take a
% regressors matrix, write it out in separate run +
% condition 1d files, then call waver on them, and read them
% back into the subj structure.
%
% One of the main benefits to using the toolbox to call
% 3dDeconvolve is that it makes it much much easier to do
% no-peeking n-minus-one feature selection. Because of the
% way that the statmap functions are called by
% FEATURE_SELECT, the same EXTRA_ARG will be passed to this
% function each iteration. So, if you want to feed in
% different brik names or runs startpoints in your
% EXTRA_ARG, use a cell array (nIterations) for any
% arguments that will differ across iterations (e.g. runs
% startpoints, filenames). This function will automatically
% use the EXTRA_ARG.CUR_ITERATION that FEATURE_SELECT passes
% in to get the right item from cell arrays. So we refer to
% 'nIterations' below to mean the n-minus-one iteration
% looped over in FEATURE_SELECT. If you're using
% PEEK_FEATURE_SELECT, then nIterations = 1, and you can
% just feed in vectors and strings.
%
% RUNS_SELNAME (required). This is the name of the runs
% selector, required to create the startpoints file.
%
% WHOLE_FUNC_NAME (required). This is the name of the BRIK
% that needs to have already been written out, containing
% all of your data.
%
% AFNI_LOCATION (optional, default = ''). If matlab doesn't
% have the location of AFNI in its path (i.e. you get some
% kind of '3dDeconvolve command not found' error), then
% specify your AFNI location in this, e.g. '/home/afni'.
%
% DECONV_ARGS (optional, default = []). This is a structure
% filled with any extra arguments you want to feed to
% 3dDeconvolve, e.g.
%   deconv_args.censor = 'censor.txt';
%   deconv_args.stim_nptr = '2 1';
%   deconv.polort = '2';
% Note: all of the fields must contain pure strings. These
% strings will simply be appended to the fieldnames,
% creating a line like '-censor censor.txt'. For the moment,
% treat NUM_STIMTS, STIM_FILEs and GLTs in the same way, but
% hopefully we can improve on this (xxx). Don't feed in
% 'input' or 'concat'.
%
% REGS_1D_NAME (optional, default =
% sprintf('%s_it%i.1d',regs_patname,cur_iteration). This is
% the filename stem for all the 1d files that will get
% written out. Will overwrite after 5 secs if they already
% exist (see WRITE_REGS_1D.M).
%
% BUCKET_NAME (optional, default =
% sprintf('%s_it%i_bucket',data_patname,cur_iteration). The name of
% the bucket that will be created, and then read in to create a new
% statmap pattern object. If you override the default, it will append
% '_%i_bucket+orig' to your BUCKET_NAME. You can prepend a path to
% this, e.g. 'afni/my_new', since the AUX_PATH_NAME won't affect your
% bucket BRIK/HEAD files' location.
%
% AUX_PATH_NAME (optional, default = ''). This can be a relative or
% absolute path that determines where STATMAP_3DDECONVOLVE will place
% all of your auxiliary files (.1d, .txt, .err, .jpg etc.) as they get
% created. N.B. This *doesn't* affect the BUCKET_NAME, since you
% probably want to store all your AFNI BRIK/HEAD file pairs in a
% single directory.  If the AUX_PATH_NAME directory doesn't exist, it will
% be created. [This replaces the PATH_NAME optional argument].
%
%   xxx - currently, if you feed in both an AUX_PATH_NAME *and*
%   override the default for one of the auxiliary files,
%   e.g. STARTPOINTS_NAME, then you'll end up with something like
%   fullfile(aux_pathname, startpoints_name). This isn't ideal -
%   really, it shouldn't prepend AUX_PATH_NAME when you override the
%   default auxiliary filenames - and so this behavior may change in
%   the future.
%
% OVERWRITE_BUCKETS (optional, default = false). If true, this
% will overwrite existing bucket files of the same name,
% without confirmation. Use at your own peril.
%
% MASK_FILENAME (optional, default = ''). If non-empty,
% feeds this argument into 3dDeconvolve. It should specify
% a BRIK filename, e.g. the output from 3dAutomask.
%
% MC_PARAMS_TXT (optional, default = ''). This is the
% filename for the text file containing your motion
% parameters (from volume registration). By default, it
% assumes you don't want to include motion regressors. If
% you do feed in a filename, it should have the same number
% of lines as you have 1s in your SELNAME selector.
%
% CONTRAST_MAT (optional, default = []). By default, this
% will transpose and feed your REGSNAME regressors directly
% into the GLM X matrix much as you'd expect. However, you
% can optionally specify a contrast matrix that will be
% multiplied by your regressors before feeding them into the
% GLM. For instance, if you set CONTRAST_MAT to the output
% from CREATE_MAIN_EFFECT_CONTRAST, then it would make the
% GLM behave like a 1-way omnibus ANOVA. Feeding in
% eye(nConds) is the same as feeding in no contrast matrix
% at all.
%
%   N.B. in early versions of this function, the *default*
%   was to apply a CREATE_MAIN_EFFECT_CONTRAST matrix for
%   you. This felt like too much magic behind the scenes, so
%   now you have to generate the the contrast matrix and
%   specify that you want it applied.
%
% EXEC_FILENAME (optional, default =
% sprintf('mvpa_3dDeconvolve_%i.sh',cur_iteration). This is the
% name of the shell script that will get created and then run
%
% CENSOR_1D_NAME (optional, default =
% sprintf('censor_%s_it%i',data_patname,cur_iteration). This
% is the name of the censor file that will get written out
% to tell 3dDeconvolve which timepoints to look at
%
% STARTPOINTS_NAME (optional, default = 'startpoints'). I
% don't think there's any reason to change this. It's simply
% the name of the file that gets created containing the
% zero-indexed indices of the timepoints that begin each
% run.
%
% RUN_SCRIPT (optional, default = true). By default, it will
% write out and then run the shell script it creates. If you
% just want it to write out, but not actually run anything
% (e.g. if you plan to tweak the scripts by hand after, or
% just for a dry run), set this to false. N.B. It will still
% write out all the censor files, .1d regressors, shell
% scripts etc. It just won't run the shell script.
%
%   UPDATE: unfortunately, setting this to false causes
%   errors downstream in FEATURE_SELECT.M, because it
%   expects new objects to have been created... So this
%   argument doesn't work properly.
%
% GOFORIT (optional, default = 0). If non-zero, will add the
% '-goforit' flag to the shell script that causes
% 3dDeconvolve to ignore its matrix inversion warnings. See
% http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=21628&t=21628&v=f
% for info on why using statmap_3dDeconvolve with with-held
% runs sparks so many (relatively innocuous) collinearity
% warnings.

% follow up re collinearity warnings for censored runs
%
% I (Greg) asked Ziad Saad about the issue where we're
% censoring out an entire 3dDeconvolve run, and it's giving
% us a GOFORIT warning
% 
%   because "3dDeconvolve still creates regressors for the
%   excluded run (baselines, trends etc.), but because that
%   entire run has been censored out, those regressors in the
%   design matrix are all zeros."
% 
%   see
%   http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=21628&t=21628&v=f
%   
% Ziad Saad suggested that instead of using censor files, we
% use the square brackets to scope to the timepoints we want
% 
%   he said that there's a square bracket syntax that allows
%   you to specify non-contiguous sets of timepoints,
%   e.g. perhaps [0..99,200..299]
%   
%   this would also require you to feed in different subsets
%   of your regressor files each time
%   
%   the most problematic part of this is that it would result
%   in different orderings for the bucket regressor labels,
%   which is almost certainly asking for trouble


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


if nargin<6
  error('Need 6 arguments, even if extra_arg is empty');
end

defaults.cur_iteration = NaN;
defaults.whole_func_name = '';
defaults.runs_selname = '';
defaults.startpoints_name = '';
defaults.censor_1d_name = '';
defaults.afni_location = '';
defaults.deconv_args = [];
defaults.regs_1d_name = '';
defaults.contrast_mat = [];
defaults.bucket_name = '';
defaults.aux_path_name = '';
defaults.overwrite_buckets = false;
defaults.mask_filename = '';
defaults.exec_filename = '';
defaults.mc_params_txt = '';
defaults.goforit = 0;
defaults.run_script = true;
args = propval({extra_arg},defaults);

args = process_args(data_patname,regsname,args);

regs = get_mat(subj,'regressors',regsname);
sel  = get_mat(subj,'selector',selname);

runs = get_mat(subj,'selector',args.runs_selname);

[nConds nTRs] = size(regs);

% the AFNI censor file should contain 1s for all timepoints
% that will be included, and 0s otherwise
%
% UPDATE: there's now a WRITE_OUT_CENSOR_FROM_SEL.M that
% this should call instead
censor = sel';
censor(find(censor~=1)) = 0;
save(args.censor_1d_name,'censor','-ascii');

if ~isempty(args.contrast_mat)
  contrasts = args.contrast_mat;
  % multiply our regressors by contrast matrix (e.g. if you
  % want to use use the GLM like a 1-way omnibus anova,
  % create a CONTRAST_MAT with CREATE_MAIN_EFFECT_CONTRAST)
  regs = [contrasts * regs];
  % the nConds may have changed after REGS was multiplied by
  % the contrast matrix
  nConds = size(regs,1);
end

write_regs_1d(regs,args.regs_1d_name);

sanity_check(regs,sel,args);

% create the startpoints file
startpoints = create_startpoints(runs);
save(args.startpoints_name,'startpoints','-ascii');

[call] = call_3dDeconvolve(args,regsname,nConds);
% args = rmfield(args,'deconv_args');

% don't bother trying to load in the newly-created BRIK if
% we didn't run the shell script
if args.run_script

  masked_by = get_objfield(subj,'pattern',data_patname,'masked_by');

  subj = load_afni_pattern(subj,new_map_patname,masked_by,args.bucket_name, ...
                           'sub_briks',call.last_sub_brik);

  hist = sprintf('Created by statmap_3dDeconvolve');
  subj = add_history(subj,'pattern',new_map_patname,hist);

  created.function = mfilename;
  created.dbstack = dbstack;
  created.data_patname = data_patname;
  created.regsname = regsname;
  created.selname = selname;
  created.extra_arg = extra_arg;
  created.new_map_patname = new_map_patname;
  created.call = call;
  subj = add_created(subj,'pattern',new_map_patname,created);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [args] = process_args(data_patname,regsname,args)

% Get all the cells from the cell arrays
if iscell(args.whole_func_name)
  error('Your whole_func_name should be the same for each iteration');
end

if iscell(args.censor_1d_name)
  args.censor_1d_name = args.censor_1d_name{args.cur_iteration};
end

if iscell(args.startpoints_name)
  args.startpoints_name = args.startpoints_name{args.cur_iteration};
end

if iscell(args.regs_1d_name)
  args.regs_1d_name = args.regs_1d_name{args.cur_iteration};
end

if iscell(args.deconv_args)
  args.deconv_args = args.deconv_args{args.cur_iteration};
end

if iscell(args.bucket_name)
  args.bucket_name = args.bucket_name{args.cur_iteration};
end

if iscell(args.exec_filename)
  args.exec_filename = args.exec_filename{args.cur_iteration};
end

% Set the default filenames
if isempty(args.whole_func_name)
  error('Need a WHOLE_FUNC_NAME');
end

if isempty(args.runs_selname)
  error('Need a RUNS_SELNAME');
end

if isempty(args.startpoints_name)
  args.startpoints_name = 'startpoints.txt';
end

if isempty(args.censor_1d_name)
  args.censor_1d_name = sprintf('censor_%s_it%i.1d',data_patname,args.cur_iteration);
end

if isempty(args.regs_1d_name)
  args.regs_1d_name = sprintf('%s_it%i.1d',regsname,args.cur_iteration);
end

if isempty(args.bucket_name)
  args.bucket_name = sprintf('%s_it%i_bucket+orig',data_patname,args.cur_iteration);
else
  args.bucket_name = sprintf('%s_%i_bucket+orig',args.bucket_name,args.cur_iteration);
end

if isempty(args.exec_filename)
  args.exec_filename = sprintf('mvpa_3dDeconvolve_%i.sh',args.cur_iteration);
end

if ~isint(args.goforit)
  error('GOFORIT must be set to 0 or the number of warnings to ignore');
end

% if a AUX_PATH_NAME has been specified, and it doesn't exist, create it
if ~isempty(args.aux_path_name) & ~exist(args.aux_path_name,'dir')
  dispf('Attempting to create %s',args.aux_path_name);
  [status msg] = mkdir(args.aux_path_name);
  if ~status, error(msg), end
end % checking for existence of AUX_PATH_NAME
  
% prepend AUX_PATH_NAME to all the filenames. if AUX_PATH_NAME is
% empty (the default), this will have no effect, placing everything in
% the current directory. doesn't affect the BUCKET_NAME
fnames = {'startpoints_name', ...
          'censor_1d_name', ...
          'regs_1d_name', ...
          'exec_filename'};
for f=1:length(fnames)
  fname = fnames{f};
  args.(fname) = fullfile(args.aux_path_name, args.(fname));
end % f fnames


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(regs,sel,args)

if size(regs,2) ~= size(sel,2)
  error('Different nTRs in regs and selector');
end

if ~isrow(sel)
  error('Your selector needs to be a row vector');
end

if max(sel)>2 | min(sel)<0
  disp('These selectors don''t look like cross-validation selectors');
  error('Are you feeding in your runs by accident?');
end

if ~length(find(regs)) | ~length(find(sel))
  error('There''s nothing for the ANOVA to run on');
end

if exist( sprintf('%s.BRIK',args.bucket_name),'file' ) | exist( sprintf('%s.BRIK.gz',args.bucket_name),'file' )
  if args.overwrite_buckets
    unix(sprintf('rm -f %s.BRIK',args.bucket_name));
    unix(sprintf('rm -f %s.BRIK.gz',args.bucket_name));
    unix(sprintf('rm -f %s.HEAD',args.bucket_name));
  else
    error('You need to delete the existing bucket first - %s',args.bucket_name);
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [call] = call_3dDeconvolve(args,regsname,nConds)


% Check the deconv_args, to make sure that none of the fields that
% we're going to deliberately specify have been included in the
% deconv_args too
deconv_args = check_deconv_args(args.deconv_args);

num_stimts = 0;

% Create the condition lines
%
% xxx - the regs 1D filenames should be an optional argument, so that
% we can deal with them in PROCESS_ARGS, rather than inline here
conds_cell = {};
for c=1:nConds
  num_stimts = num_stimts + 1;
  condlabels{c} = sprintf('%s_c%i',regsname,c);
  conds_cell{end+1} = sprintf('-stim_file %i %s -stim_label %i %s \\', ...
			      num_stimts, ...
			      fullfile(args.aux_path_name, ...
                                       sprintf('%s_it%i_c%i.1d',regsname,args.cur_iteration,c)), ...
			      num_stimts, ...
			      condlabels{c} ...
			      );
end % c nConds

% Create the motion parameter lines
motion_cell = {};
if ~isempty(args.mc_params_txt)
  for m=1:6
    num_stimts = num_stimts + 1;
    cur_mc_params_str = sprintf('mc_params%i',m);
    motion_cell{end+1} = sprintf('-stim_file %i ''%s[%i]'' -stim_label %i %s -stim_base %i \\', ...
				 num_stimts, ...
				 args.mc_params_txt, ...
				 m, ...
				 num_stimts, ...
				 cur_mc_params_str, ...
				 num_stimts ...
				 );
  end % m 6
end

user_cell = {};

if ~isempty(deconv_args)
  deconv_names = fieldnames(deconv_args);
  for f=1:length(deconv_names)
    cur_name = deconv_names{f};
    cur_val = deconv_args.(cur_name);
    user_cell{end+1} = sprintf('-%s %s \\',cur_name,cur_val);
  end
end

cl_cell{1} = sprintf( ...
    '%s \\', fullfile(args.afni_location,'3dDeconvolve') );
cl_cell{end+1} = sprintf('-input %s \\',args.whole_func_name);
cl_cell{end+1} = sprintf('-concat %s \\',args.startpoints_name);
cl_cell{end+1} = sprintf('-num_stimts %i \\',num_stimts);
% use DECONV_ARGS instead, e.g. statmap_3d_arg.deconv_args.xjpeg = 'desMtx.jpg';
%
% xxx - better still, there should be an XJPEG argument...
%
% cl_cell{end+1} = sprintf('-xjpeg %s.jpg \\', args.exec_filename);
cl_cell = [cl_cell conds_cell motion_cell];
cl_cell{end+1} = sprintf('-censor %s \\',args.censor_1d_name);
cl_cell{end+1} = sprintf('-bucket %s \\',args.bucket_name);

if args.mask_filename
  cl_cell{end+1} = sprintf('-mask %s \\',args.mask_filename);
end % mask

% it turns out that this should use '1' instead of nConds, since we're
% actually only running a single GLT. but then it turns out that we
% don't actually need this argument at all. see
% http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=28157&t=28157#reply_28157
% cl_cell{end+1} = sprintf('-num_glt %d \\',nConds);

% create a GLT line that looks something like:
%   -glt 'SYM: +Reg1 \ +Reg2 \ +Reg3'
% where Reg# is replaced with the stimlabel created above
glt_txt = '';
for c=1:nConds
  glt_txt = sprintf('%s +%s \\',glt_txt,condlabels{c});
end % for c
glt_txt = glt_txt(1:end-2); % get rid of the last slash
cl_cell{end+1} = sprintf('-gltsym ''SYM: %s '' -glt_label 1 statmap_3dDeconvolve \\',glt_txt);

if args.goforit
  cl_cell{end+1} = sprintf('-goforit %i \\',args.goforit);
end

cl_cell = [cl_cell user_cell];
cl_cell{end+1} = '-fout';

disp( sprintf('Wrote the following to %s',args.exec_filename) );
disp('---------------------------------------');

[fid msg] = fopen(args.exec_filename,'wt');
if fid==-1
  error(msg);
end
for line=1:length(cl_cell)
  curline = char(cl_cell{line});
  fprintf(fid,'%s\n',curline);
  disp(curline)
end
fclose(fid);


exec = sprintf('source %s',args.exec_filename);
if args.run_script
  
  [status output] = unix(exec,'-echo');
  if status
    error(output);
  end

  [err info] = BrikInfo(args.bucket_name);
  if err
    error('Problem with BrikInfo %s',args.bucket_name);
  end
  
  last_sub_brik = info.DATASET_RANK(2);
  if ~isequal(last_sub_brik,length(info.BRICK_TYPES))
    warning('Not certain that we''ve got the last sub_brik right');
  end
  
else
  dispf('Wrote out %s, but not running it',args.exec_filename);

  last_sub_brik = NaN;
  status = NaN;
  output = NaN;
  
end


call.deconv_args = deconv_args;
call.cl_cell = cl_cell;
call.exec = exec;
call.last_sub_brik = last_sub_brik;
call.status = status;
call.output = output;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [deconv_args] = check_deconv_args(deconv_args)

if isfield(deconv_args,'bucket')
  warning('Ignoring surplus user-specified bucket');
  deconv_args = rmfield(deconv_args,'bucket');
end

if isfield(deconv_args,'input')
  warning('Ignoring surplus user-specified input');
  deconv_args = rmfield(deconv_args,'input');
end

if isfield(deconv_args,'concat')
  warning('Ignoring surplus user-specified concat');
  deconv_args = rmfield(deconv_args,'concat');
end

if isfield(deconv_args,'num_stimts')
  warning('Ignoring surplus user-specified num_stimts');
  deconv_args = rmfield(deconv_args,'num_stimts');
end

if isfield(deconv_args,'censor')
  warning('Ignoring surplus user-specified censor');
  deconv_args = rmfield(deconv_args,'censor');
end

if isfield(deconv_args,'fout')
  warning('Ignoring surplus user-specified fout');
  deconv_args = rmfield(deconv_args,'fout');
end

if isfield(deconv_args,'glt')
  warning('GLTs not implemented yet');
  deconv_args = rmfield(deconv_args,'glt');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [startpoints] = create_startpoints(runs)

startpoints = [0 find(runs(2:end) ~= runs(1:end-1))]';

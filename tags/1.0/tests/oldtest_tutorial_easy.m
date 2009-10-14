function [success errmsg] = test_tutorial_easy()

% [success errmsg] = test_tutorial_easy()
%
% Runs the new and old version of the tutorial scripts to compare
% them


success = 0;
errmsg = '';

rand_state_int = sum(100*clock);

curdir = pwd;
try
  cd ~/fmri/benchmark/
catch
  success = -1;
  errmsg = 'No benchmark directory';
  return
end

[newsubj newresults] = tutorial_easy_newsubj_peek(rand_state_int);
[oldsubj oldresults] = tutorial_easy_oldsubj_peek(rand_state_int);

disp('Compare old and new');
keyboard

save test_tutorial_easy_oldnew_subj_comparison

oldpat_orig = oldsubj.data_orig;
newpat_orig = get_mat(newsubj,'pattern','epi');
if ~isequal(oldpat_orig,newpat_orig)
  errmsg = 'Original data';
  return
end

oldpat_orig_z = oldsubj.data_orig_z;
newpat_orig_z = get_mat(newsubj,'pattern','epi_z');
if ~isequal(oldpat_orig,newpat_orig)
  errmsg = 'Zscored data';
  return
end

oldpat_final = oldsubj.data;
newpat_final = get_masked_pattern(newsubj,'epi_z','epi_z_thresh');
if ~isequal(oldpat_orig,newpat_orig)
  errmsg = 'Final data';
  return
end

oldresults_total_perf = oldresults.totalperf;
newresults_total_perf = newresults.total_perf;

if ~isequal(oldresults_total_perf,newresults_total_perf)
  errmsg = 'Total_perf';
  return
end
  
cd(curdir);
success = 1;
  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj results] = tutorial_easy_newsubj_peek(rand_state_int)

% Peeking version of the main tutorial_easy script

subj = init_subj('haxby8','tutorial_subj');

subj = load_afni_mask(subj,'VT_category-selective','mask_cat_select_vt+orig');

for i=1:10
  raw_filenames{i} = sprintf('haxby8_r%i+orig',i);
end
subj = load_afni_pattern(subj,'epi','VT_category-selective',raw_filenames);

subj = init_object(subj,'regressors','conds');
load('tutorial_regs');
subj = set_mat(subj,'regressors','conds',regs);
condnames = {'face','house','cat','bottle','scissors','shoe','chair','scramble'};
subj = set_objfield(subj,'regressors','conds','condnames',condnames);

subj = init_object(subj,'selector','runs');
load('tutorial_runs');
subj = set_mat(subj,'selector','runs',runs);

subj = zscore_runs(subj,'epi','runs');

regs = get_mat(subj,'regressors','conds');
[subj norest] = duplicate_object(subj,'selector','runs','norest');
norest = ones(size(norest));
norest(find(sum(regs)==0)) = 0;
subj = set_mat(subj,'selector','norest',norest);

subj = create_xvalid_indices(subj,'runs','actives_selname','norest');

[subj] = peek_feature_select(subj,'epi_z','conds','norest');

class_args.train_funct_name = 'train_bp';
class_args.test_funct_name = 'test_bp';
class_args.nHidden = 0;
[subj results] = cross_validation(subj, ...
				  'epi_z','conds','runs_xval','epi_z_thresh', ...
				  class_args,'rand_state_int',rand_state_int);

save


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj results] = tutorial_easy_oldsubj_peek(rand_state_int)

% This should be the same as tutorial_easy, except using the old
% scripts

newpath = '~/fmri/distpat/branches/oldsubj/distpat_scripts';
curdir = pwd;
% Need to add this change-directory hack to get the full/actual
% string of your location, otherwise it expands ~ to something
% different, and you can't remove it from the path later
cd(newpath)
newpath = pwd;
cd(curdir);
path(path,newpath);

subj.no_lz_subj_no = 'tutorial_easy';

load tutorial_regs
subj.regressors = regs';

load tutorial_runs
subj.runs = runs;
subj.args.condnames = ...
    {'face','house','cat','bottle','scissors','shoe','chair','scramble'};

clear regs runs

subj.mask.name = 'VT_category-selective+orig';
subj.mask.filename = 'mask_cat_select_vt+orig';
subj.mask.volsize = [64 64 40];
subj.mask.vol = ones(subj.mask.volsize);

[err subj.mask.vol subj.header.afni_mask_head message] = ...
    BrikLoad(subj.mask.filename);

for r=1:10
  subj.args.fnmBrik{r} = sprintf('haxby8_r%i+orig',r);
end
subj = AFNItoSubj3(subj);

subj.data_orig = subj.data;

subj = zScoreTime(subj);

subj.data_orig_z = subj.data;

subj.args.anova_conds = [1:8];
subj.args.anova_pcrit = 0.05;

subj = anovaVox(subj);

rand('state',rand_state_int);

class_args.class = 'bp';
class_args.layers = 2;
class_args.nHidden = 0;
[subj results] = nminusone(subj,class_args.class,class_args);

rmpath(newpath)


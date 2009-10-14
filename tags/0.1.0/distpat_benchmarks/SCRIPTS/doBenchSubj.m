function [subj] = doBenchSubj( )

% [subj] = doBenchSubj( )
% Runs a MDF subject (low resolution data)
% through from start to finish...


disp(sprintf('*** starting subj ***'));

% want to make mask first
[err, vt_lowres, Info, ErrMessage] = BrikLoad ('mask_vt_lowres+orig');

% create regressors
% using AFNIparseTRs
%nRuns = 6;
%nCats = 7;
%TRsPerRun = 192;
%skpTRs = 0;
%downsamp = 4;
%totalTRs = 1152;
%TRsPerMb = 20;

%[subj]=AFNIparseTRsMDF(nRuns,nCats,TRsPerRun,skpTRs,downsamp,totalTRs,TRsPerMb);

load('regressors_and_runs');
subj.regressors = regressors;
subj.runs = runs; 
clear runs regressors

% subj_args for AFNItoSubj.m

subj.args.fnmBrik{1} = strcat('s2_all_lowres+orig');
subj.mask.name = 'lowres mask vt';
subj.mask.vol = vt_lowres;
subj.args.verbose = true;
subj.no_lz_subj_no = 'bench';

subj.mask.vol = round(subj.mask.vol);

disp('running AFNItoSubj');

[subj]=AFNItoSubj(subj);

disp(sprintf('\tsaving made_subj'));
save_subj(subj,'subj_master',[],true); 

% now run next set of scripts in doSubjProc.m


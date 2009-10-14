function [subj] = BVtoSubj(subj)

% uses the latest subj structure
% [subj] = BVtoSubj(subj)
%
% LAST MODIFIED ON 11/12/04
%
% Calls parse_prts, which returns 
% subj.regressors = nTRs rows x nCond cols
%              value indicates level of the regressor
%              usually 0/1 unless convolved with HRF
% subj.runs = 1 row x nTRs cols
%        value (int) indicates which run this TR belongs to
%
%
% structure of subj.args follows
%
% fnmprt1 - first part of the prt filename (ex: 'sub1_block')
% fnmprt2 - rest of the prt filename (ex: '_tshf') '.prt' gets filled in
% fnmvtc1 - first part of the vtc filename, up to the run #
% fnmvtc2 - leave off the .vtc part 
%           all .vtc files must have same name; you have to
%           remove the part that says ISA if it varies by run.
% Masks - the names of the masks you want to make patterns from
%         as well as the actual masks
%           Masks(1).name = 'frontal_mask';
%           Masks(1).mask = FLmask;
% TRsPerRun - how many volumes per run
%             this is a vector where each element is the number of
%             trs in that run. Ex.: [250 250 400]

% CHANGE ALL OF THE STRUCTURED ARGS TO LOCAL VARIABLES
% FOR GENERAL PROGRAMMING EASE


% even more differences

fnmprt1 = subj.args.fnmprt1;
fnmprt2 = subj.args.fnmprt2;
fnmvtc1 = subj.args.fnmvtc1;
fnmvtc2 = subj.args.fnmvtc2;
TRsPerRun = subj.args.TRsPerRun;
nRuns = length(TRsPerRun);
% Masks is done below

% FILE PARSING
% PULL DATA OUT OF THE PRTS

disp('parsing prts');
[subj] = parse_prts(subj,fnmprt1,fnmprt2,TRsPerRun);

% Masks must be created prior to running BVtoSubj
% This code converts all non-zero mask elements to 1.
% Masks are stored in three formats:
% mask, a volume with all non-zero els set to 1
% idx, a one-dim array of all the non-zero indices
% x1,x2,x3, a list of the coordinates of each idx element 

subj.mask.vol(find(subj.mask.vol ~= 0)) = 1;
subj.mask.idx = find(subj.mask.vol ~= 0);
subj.mask.nVox = sum(sum(sum(subj.mask.vol)));
[x1,x2,x3]=ind2sub(size(subj.mask.vol),find(subj.mask.vol));
subj.mask.coords = [x1 x2 x3];

% PARSING OF VTC INFORMATION

% parses all of the vtc files, tags them onto the structure subj

disp('parsing vtcs');
%[subj] = parse_vtcs(subj,allRuns,fnmvtc1,fnmvtc2,conds);

subj.data = [];

nVox = size(subj.mask.coords,1);
disp( sprintf('initialising subj.masks(1) as single array %i x %i',nVox,sum(TRsPerRun)) );
subj.data = zeros(nVox,sum(TRsPerRun));

for h=1:nRuns
  disp( sprintf('\tstarting run %i',h) );
  
  % SMP - 01/10/05 - num2str(h) below assumes that your runs are
  % consecutive and start at 1 in the files.  This needs to be
  % updated so that a cell array of filenames are input in subj.args
  fname = strcat(fnmvtc1,num2str(h),fnmvtc2);
  vtc_map = bv_readvtc_new( sprintf('%s%s',fname,'.vtc') );
  vtc_map.data = single(vtc_map.data);

  % now pass the data through the mask
  % each mask gets a data matrix appended
  % rows are voxels, columns are TRs

  % this is from the original BVtoSubj2 script - realised that it
  % wouldn't work if you're zero-initialising the whole data matrix beforehand
  % [vox cols]=size(subj.data);
  % start = cols + 1;
  % last = start + size(vtc_map.data,1) - 1;

  cols = (h-1)*TRsPerRun;
  start = cols + 1;
  last = start + TRsPerRun - 1;
  for j = 1:nVox
    %      keyboard
    subj.data(j,start:last) = vtc_map.data(:,subj.mask.coords(j,1),...
					   subj.mask.coords(j,2),...
					   subj.mask.coords(j,3) ...
					   )';
  end % j 1:nVox
end % h 1:nRuns

disp( 'packing' );
pack
disp( 'finished parsing vtcs' );

head = sprintf('created with BVtoSubj2 - %s',date);
subj = addheader(subj,head);


% Now we've got a set of patterns on the subj structure that are
% unnormalized.
% 
% subj structure is now passed to custom scripts.


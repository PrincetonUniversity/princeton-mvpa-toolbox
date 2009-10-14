function [P, F, stats] = anova1_mvpa(mat,conds,sels,chunksize)

% Performs a 1 way between-subjects anova
%
% [P F STATS] = ANOVA1_MVPA(MAT,CONDS,SELS,CHUNKSIZE)
%% Performs a 1 way between-subjects ANOVA on a matrix MAT. Condition 
% membership is contained within CONDS, which must be a boolean matrix of
% size [M, N], where M = the number of conditions, and N = the number of 
% subjects.
% In the case of fMRI data, MAT should be a voxel x. time matrix, and 
% REGSNAME should be a condition x. time matrix. Will perform a voxel-
% wise mass univariate ANOVA
%
% Important Note: ANOVA1_MVPA returns the probability of the null
% hypothesis being false, NOT 1 - the probability.  Thus
% significant voxels will be close to 1, NOT to 0.
%
% Note: if you're looking for an MVPA function to do feature
% selection as part of the subj structure, see FEATURE_SELECT.M and
% STATMAP_ANOVA.M - this is just a simple auxiliary function to stand
% in for ANOVA1.M
%
% This test assumes an equal N across conditions.  If your N
% unequal, greater variance in conditions with smaller Ns will
% result in more liberal F statistics, inflating T1 error. Either
% use more complicated statistics, or randomly remove conditions
% from the groups with greater N. 
% (see Tabachnick & Fidel, Multivariate Statistics)

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


% Make conds & sels boolean
conds(find(conds)) = 1;
sels(find(sels))   = 1;

% Ignore non
conds(find(~sels)) = 0;
cndIdx = find(any(conds));
cndsz = length(cndIdx);
actconds = conds(:,cndIdx);

% Enforce assumptions
if any(sum(conds,1) > 1)
  error('no subject can belong to multiple levels of a factor');
end

% Too big to run all at once; Divide into chunks
if ~exist('chunksize','var')
  chunksize = 300;
end
  
voxidx = find(any(mat,2));
voxchunk = ceil(voxidx/chunksize);
actvoxs  = unique(voxchunk);

nVox = size(mat,1);
nBadVox = nVox - length(voxidx);
if nBadVox
  warning( sprintf('%i of your voxels are all-zeros',nBadVox) );
end

% Calculate the mean across all voxels
grandmean = mean(mat(voxidx,cndIdx),2);

% Initialize variables
stats.SSt = nan(size(mat,1),1);
stats.SSw = nan(size(mat,1),1);
stats.SSb = nan(size(mat,1),1);

F = nan(size(mat,1),1);
P = nan(size(mat,1),1);

for j=1:length(actvoxs)
  i = actvoxs(j);
  curvox = voxidx(find(voxchunk == i));
  gm_vox = find(voxchunk == i);
  cursz  = length(curvox);
 
  groupmean = (mat(curvox,cndIdx) * actconds') ./ (ones(cursz,1) * sum(conds,2)') * actconds;
  
  mat_minus_grandmean = mat(curvox,cndIdx) - grandmean(gm_vox) * ones(1,cndsz);
  mat_minus_groupmean = mat(curvox,cndIdx) - groupmean;

  stats.SSt(curvox,1) = sum(mat_minus_grandmean.^2,2);
  stats.SSw(curvox,1) = sum(mat_minus_groupmean.^2,2);  
  stats.SSb(curvox,1) = sum((grandmean(curvox) * ones(1,cndsz) - groupmean).^2,2);
end

stats.err = stats.SSt - stats.SSw - stats.SSb;

stats.DFt = cndsz - 1;
stats.DFb = size(conds,1) - 1;
stats.DFw = stats.DFt - stats.DFb;

stats.MSw = stats.SSw / stats.DFw;
stats.MSb = stats.SSb / stats.DFb;

F(voxidx,1) = stats.MSb(voxidx) ./ stats.MSw(voxidx);

P(voxidx,1) = fcdf(F(voxidx), stats.DFb, stats.DFw);

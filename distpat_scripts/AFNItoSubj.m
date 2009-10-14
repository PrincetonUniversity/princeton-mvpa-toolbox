function [subj] = AFNItoSubj(subj)
% [subj] = AFNItoSubj(subj)
%
% Before running this, have to parse the files containing 
% your TRs.  Must be stored in the following format:
% subj.regressors = nTRs rows x nCond cols
%              value indicates level of the regressor
%              usually 0/1 unless convolved with HRF
% subj.runs = 1 row x nTRs cols
%        value (int) indicates which run this TR belongs to
%
% subj.args follows
%
% fnmBrik - the name of the Brik that contains all your TRs.
%            the TRs should be in order. 
%            This is a set of files in a cell string array, because
%            there are cases in which a single func brik for the
%            whole experiment is too big to process all at once.
% verbose - if this field exists, the program will display progress
% 
%
% user must also set:
% subj.mask.vol - the volume
% subj.mask.name
%
% The subj structure that is output:
%
% mask - the names of the masks you want to make patterns from
%        as well as the actual masks
%        mask.name - string containing mask name
%        mask.vol - 3-d matrix, binary, which voxels are included
%        mask.coord - numVoxels by 3, the xyz coordinates of each vox
%        mask.idx - numVoxels by 1, the index 
%        
%        
%        
%        
%
%
%    subj.data, subj.runs, subj.regressors
%
% THIS VERSION IS 11/08/04

% CHANGES ALL OF THE STRUCTURED ARGS TO LOCAL VARIABLES
% FOR brevity OF CODING BELOW

%fnmBrik = subj_args.fnmBrik;
%conds = subj_args.conds;

% The masks must be created prior to running AFNItoSubj
% This code converts all non-zero mask elements to 1.
% Masks are stored in three formats:
% mask, a volume with all non-zero els set to 1
% idx, a one-dim array of all the non-zero indices
% x1,x2,x3, a list of the coordinates of each idx element 

verbose = false;
if isfield(subj.args,'verbose')
  verbose = true;
end

if ~isempty(find((subj.mask.vol ~= 0) & (subj.mask.vol ~= 1))) 
  error('your binary mask has non-binary elements');
end

% finds all non-zero els and sets them equal to one
subj.mask.idx = find(subj.mask.vol ~= 0);
subj.mask.nVox = length(find(subj.mask.vol));
[x,y,z]=ind2sub(size(subj.mask.vol),find(subj.mask.vol));
subj.mask.coords = [x,y,z];


% LOADING OF BRIK INFORMATION

% parses the brik file, tags it onto the structure subj
disp('brik processing');

% this version allows the func brik to be broken up by time.  Have
% to make sure that the succeeding briks are properly appended to
% the data structure.

% initialize the data struct
subj.data = zeros(subj.mask.nVox,size(subj.regressors,1));

TRCount = 0;

for h = 1:length(subj.args.fnmBrik)
  disp(sprintf('loading brik #%i',h));
  [err,Vdata,subj.header.AFNIhead{h},ErrMessage]=BrikLoad(char(subj.args.fnmBrik{h}));
  if err == 1
    error(sprintf('error in BrikLoad -%s',ErrMessage));
  end
  
  % now pass the data through the mask
  % each mask gets a data matrix appended
  % rows are voxels, columns are TRs

  start = TRCount + 1;
  last = start + size(Vdata,4) - 1;
  for j = 1:subj.mask.nVox
    if verbose == true
      if(mod(j,1000)==0)
	disp(sprintf('processing vox # %i of %i',j,subj.mask.nVox));
      end
    end
    subj.data(j,start:last) = Vdata(subj.mask.coords(j,1), ...
				    subj.mask.coords(j,2), ...
				    subj.mask.coords(j,3),:); 
  end

  TRCount = TRCount + size(Vdata,4);
  
end % for h

head_str = strcat('created with AFNItoSubj3 - ',date);
[subj] = addheader(subj,head_str);


























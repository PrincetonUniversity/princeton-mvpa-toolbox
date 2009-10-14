function [err] = write_to_afni(subj, objtype, objname, sample_filename, varargin)

% Writes an object to a file, using the header info from a specified file.
%
% [ERR] = WRITE_TO_AFNI(SUBJ, OBJTYPE, OBJNAME, SAMPLE_FILENAME, [ARGS])
%
% Writes an object in subject structure SUBJ, of type OBJTYPE to a
% file. OBJNAME specifies the object, and must be an object name, a
% group name, or a cell array of object names. SAMPLE_FILENAME must
% currently be included to steal HEAD info from. This should
% ideally correspond to the data. If you can choose a SAMPLE_FILENAME that
% took part in the creation of the object, do so. If a pattern was
% created by concatenating multiple files, it makes no difference
% which is specified by SAMPLE_FILENAME. Currently, the difficulties in
% specifying a mask BRIK when writing a pattern OBJNAME are
% minimal (ie., mislabeling the type of the object as FIM, not ORIG).
%
% Optionally, the ARGS structure can contain the following info:
% - output_filename : the prefix of the BRIK to be saved.  This can
%   be a filename, a group prefix, or a cell array of object names,
%   and must correspond to the form of OBJNAME. If this is left
%   out, the prefix of the BRIK will be OBJNAME.
% - runs : a selector name that specifies run info. If this is
%   included, a different BRIK will be written for each run of
%   data. OBJNAME must, in this case, be a single object. If runs
%   is not included, a single file will be created for each object.

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


% Interpret OBJNAME
if ~iscell(objname)
  grpmem = find_group(subj,objtype,objname);
  if ~isempty(grpmem)
    % Its a group of patterns
    objname = grpmem;
    
    default.output_filename = grpmem;
  else
    % It's a single pattern
    objname = {objname};
    default.output_filename = objname;
  end
  % Otherwise, its a cell array of patterns
else
  default.output_filename = objname;
end

% Process optional arguments
default.runs = [];
args = propval(varargin,default);

% Error Checking: Cannot output multiple files w/ run info
if length(unique(args.runs)) > 1 & length(objname) > 1
  error('Cannot pass ARGS.RUNS w/ multiple object names');
end
  
% Load the Brik Info
[err, Info] = BrikInfo(sample_filename);
OrigInfo = Info;
if err
  ErrMessage = 'Could not load BRIK info';
  return
end

% Set the output format
switch objtype
case 'pattern'
    Info.TypeName    = 'float';
    Info.TypeBytes   = 3;
    Info.BRICK_TYPES = 3;
    ispattern = 1;
    ismask    = 0;
    Info.TYPESTRING = '3DIM_HEAD_FUNC';
case 'mask'
    Info.TypeName      = 'short';
    Info.TypeBytes     = 1;
    Info.BRICK_TYPES   = 0;
    Info.TAXIS_NUMS    = [];
    Info.TAXIS_OFFSETS = [];
    ispattern = 0;
    ismask    = 1;
end

for i=1:length(objname)
  
  cur_objname = objname{i};

  % Load the data
  d = get_mat(subj,objtype,cur_objname);
  dDim = size(d);
  
  % Determine the runs to be outputed
  if ispattern
    if isempty(args.runs)
      runs = ones(1,dDim(2));
      if prod(dDim) > 1000000
	warning(['Your trying to save a mighty large file... There' ...
		 ' may be a memory contraint']);
      end
      
    else
      runs = get_mat(subj,'selector',args.runs);
      if length(runs) ~= dDim(2);
	error('RUNS selector does not match dataset length');
      end
    end
  else
    runs = 1;
  end
  
  for j=unique(runs(find(runs)))
  
    if ispattern
      % Load masked_by mask in order to populate a 3D matrix
      m = get_mat(subj,'mask',get_objfield(subj,'pattern', cur_objname,'masked_by'));
      mDim = size(m);
        
      cur_TRs = find(runs == j);    

      M = zeros([mDim,length(cur_TRs)]);
      
      for k=1:length(cur_TRs);
	tmp = zeros(mDim);
	tmp(find(m)) = d(:,k);
	M(:,:,:,k)   = tmp;
      end
      
      Opt.Frames = length(cur_TRs);
    else
      dDim(4) = 1;
      mDim    = dDim;
      M = d;
      m = d;
      Opt.Frames = 1;
    end
    
    % Determine output name
    if length(unique(runs(find(runs)))) > 1
      % Pattern w/ Runs
      Opt.Prefix = [args.output_filename{i} '_run' num2str(j)];
    else
      Opt.Prefix = args.output_filename{i};
    end    
    
    % Set pattern specific Info fields
    if ispattern
      Info.TAXIS_NUMS = [size(M,4) 0 0];
    end
    
    % Modify the INFO header to reflect the changes
    Info.DATASET_RANK = [3 size(M,4) 0 0 0 0 0 0];
    Info.BRICK_STATS = [min(reshape(M,prod(mDim),size(M,4))) max(reshape(M,prod(mDim),size(M,4)))];
    Info.BRICK_TYPES      = OrigInfo.BRICK_TYPES(1)      * ones(1,size(M,4));
    Info.BRICK_FLOAT_FACS = OrigInfo.BRICK_FLOAT_FACS(1) * ones(1,size(M, 4));
    
    % Write the BRIK
    Opt.Slices = [1:size(m,3)];
    Opt.Frames = [1:size(M,4)];
    [err, ErrMessage, Info] = WriteBrik (M, Info, Opt);
  end
end


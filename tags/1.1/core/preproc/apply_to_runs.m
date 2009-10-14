function [subj] = apply_to_runs(subj, patname, selname, fname,  varargin)

% Applies a function to the runs of a given pattern.
%
% [SUBJ] = APPLY_TO_RUNS(SUBJ, PATNAME, SELNAME, FUNCTIONS, ...)
%
% Each function in the cell array FUNCTIONS is applied individually to
% the runs specified by SELNAME of pattern PATNAME.  They are
% processed in order as entered.  A new pattern is created with
% suffixes for each processing step appended to the original name.
% 
% The function must take in one mandatory argument: a run of a
% pattern, and return one mandatory output: the processed run of
% the pattern.  Any optional arguments passed to APPLY_TO_RUNS will
% also be passed to the processing functions.
%
% ARGUMENTS:
%
% PATNAME - the pattern you want to be filtered
% 
% SELNAME - the selector object specifying the runs
%
% FNAME - the processor function name
%
% NEW_PATNAME (optional, default = '') - the name of the new
% pattern to be created.
%
% MASKNAME (optional, default = '') - if MASKNAME is set, then a
% new pattern will be created using only the voxels from that
% mask.  If MASKNAME is a group, then a group of new patterns will
% be created, one for each mask.
%
% Adds the following objects:
%  - new pattern object

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

defaults.new_patname = '';
defaults.maskname = '';

args = propval(varargin, defaults, 'ignore_missing_default', true);

if strcmp(args.new_patname, '') == 1

  % extract the suffix of the 'apply_' function if possbile
  [fsuffix, n] = sscanf(fname, 'apply_%s');
  if n < 1
    fsuffix = fname;
  end
  
  args.new_patname = [patname, '_', fsuffix];
end

% check for mask argument
if ~isempty(args.maskname)
  
  [masknames ismaskgroup] = find_group_single(subj, 'mask', ...
                                                   args.maskname);
  args.masknames = masknames;
  
  if ~ismaskgroup % single mask
    patmat{1} = get_masked_pattern(subj, patname, args.maskname);
  else % mask group

    % get all patterns to be processed
    for m = 1:numel(masknames)
      patmat{m} = get_masked_pattern(subj, patname, masknames{m});
    end
    
  end

else  % no mask at all
  patmat{1} = get_mat(subj, 'pattern', patname);
end

selmat = get_mat(subj, 'selector', selname);
runs  = unique(selmat);

fprintf('Beginning apply_to_runs, function ''%s'': # runs = %d\n', ...
        fname, numel(runs));

% make new matrices
for p = 1:numel(patmat)
  newmat{p} = zeros(size(patmat{p}));
end
  
% filter each run individually
for r = runs
  fprintf('\t%d', r);

  % get indices of the current run
  indices = find(selmat == r);

  for p = 1:numel(patmat)

    % apply the function 
    func = str2func(fname);
    
    newmat{p}(:, indices) = func(patmat{p}(:, indices), varargin{:});
    
  end
  
end

% create the new pattern, if single
if numel(newmat) == 1
  
  % get the mask of this pattern
  if isempty(args.maskname)
    masked_by = get_objfield(subj, 'pattern', patname, 'masked_by');
  else
    masked_by = args.maskname;
  end
  
  % create the new pattern object
  subj = initset_object(subj, 'pattern', args.new_patname, newmat{1}, ...
                        'masked_by', masked_by);

  fprintf('\nPattern %s created by apply_to_runs\n', args.new_patname);
  
else
  
  for p = 1:numel(newmat)
    
    masked_by = args.masknames{p};
      
    % create the new pattern object
    subj = initset_object(subj, 'pattern', sprintf('%s_%d', args.new_patname, p), newmat{p}, ...
                          'masked_by', masked_by, ...
                          'group_name', args.new_patname);
    
  end
  
  fprintf('\nPattern group %s created by apply_to_runs\n', ...
          args.new_patname);
end


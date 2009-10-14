function [subj] = filter_runs(subj, patname, selname, filt, varargin)

% Filter each run of a pattern using a given moving average filter.
%
% [SUBJ] = FILTER_RUNS(SUBJ, PATNAME, SELNAME, FILTER, ...)
%
% WARNING: This function is deprecated as of version 0.3 of the EBC
% extension.  A more general function is apply_to_runs, which can
% take 'apply_filt' as an argument to have the same effect.
%
% For each voxel in each run, runs the Matlab asymmetric filter
% "filter" with a user-specified filter.  This can be used to
% perform temporal averaging.  The result will be saved in a new
% pattern object with either a user specified name or simply
% appending "_filtered" to the original pattern name.
%
% ARGUMENTS:
%
% PATNAME - the pattern you want to be filtered
% 
% SELNAME - the selector object specifying the runs
%
% FILT - the filter to be used
%
% NEW_PATNAME (optional, default = '') - the name of the new
% pattern to be created.
%
% MASKNAME (optional, defualt = '') - if MASKNAME is set, then a
% new pattern will be created using only the voxels from that
% mask.  If MASKNAME is a group, then a group of new patterns will
% be created.
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

warning(['filter_runs.m is deprecated as of version 0.3 of the EBC ' ...
         'extension.  Use ''apply_to_runs'' with argument' ...
         ' ''apply_filt'' instead.']);

defaults.new_patname = '';
defaults.maskname = '';

args = propval(varargin, defaults);

if strcmp(args.new_patname, '') == 1
  args.new_patname = [patname, '_filtered'];
end

patmat = [];

if ~isempty(args.maskname)
  
  [masknames ismaskgroup] = find_group_single(subj, 'mask', ...
                                                   args.maskname);
  args.masknames = masknames;
  
  if ~ismaskgroup % single mask
    patmat{1} = get_masked_pattern(subj, patname, args.maskname);
  else % mask group

    % get all patterns to be filtered
    for m = 1:numel(masknames)
      patmat{m} = get_masked_pattern(subj, patname, masknames{m});
    end
    
  end

else  % no mask at all
  patmat{1} = get_mat(subj, 'pattern', patname);
end

selmat = get_mat(subj, 'selector', selname);
runs  = unique(selmat);

fprintf('Beginning filter_runs: # runs = %d\n', numel(runs));

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
    % filter each voxel individually 
    for v = 1:size(patmat{p}, 1)    
      newmat{p}(v, indices) = filter(filt, 1, patmat{p}(v, indices));
    end
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

  fprintf('\nPattern %s created by filter_runs\n', args.new_patname);
  
else
  
  for p = 1:numel(newmat)
    
    masked_by = args.masknames{p};
      
    % create the new pattern object
    subj = initset_object(subj, 'pattern', sprintf('%s_%d', args.new_patname, p), newmat{p}, ...
                          'masked_by', masked_by, ...
                          'group_name', args.new_patname);
    
  end
  
  fprintf('\nPattern group %s created by filter_runs\n', ...
          args.new_patname);
end



function [subj] = load_spm_mask(subj,new_maskname,filename,varargin)

% Loads an NIFTI dataset into the subj structure as a mask
%
% [SUBJ] = LOAD_ANALYZE_MASK(SUBJ,NEW_MASKNAME,FILENAME,...)
%
% Adds the following objects:
% - mask object called NEW_MASKNAME
%
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

defaults.binary_strict = 1;

args = propval(varargin,defaults);

% Initialize the new mask
subj = init_object(subj,'mask',new_maskname);

% Create a volume
vol = spm_vol(filename);

V = spm_read_vols(vol);

% Check for active voxels
if ~~isempty(find(V))
  error( sprintf('There were no voxels active in the mask') );
end

V(find(isnan(V))) = 0;

% Does this consist of solely ones and zeros?
if length(find(V)) ~= (length(find(V==0))+length(find(V==1)))
  if args.binary_strict
    disp( sprintf('Setting all non-zero values in the mask to one') );
    V(find(V)) = 1;
  else
    disp(sprintf(['Allowing non-zero mask values. Could create' ...
		  ' problems. Hope you know what you''re doing.']));

    % Just want to point out that Greg Detre is in no way a voxel
    % nazi, and such slander should not be considered when
    % evaluating the merit of any future grant proposals or paper
    % submissions.  Further, although his need for cognitive
    % structure with respect to voxel values implies a simplified
    % world view (ie.,all or nothing, black vs. white, axis of
    % evil vs.lovers of freedom), that doesn't mean that he isn't a
    % good human being.  At heart. Remember that. -cdm
    
  end
end

% Store the data in the new mask structure
subj = set_mat(subj,'mask',new_maskname,V);

% Add the AFNI header to the patterns
hist_str = sprintf('Mask ''%s'' created by load_analyze_pattern',new_maskname);
subj = add_history(subj,'mask',new_maskname,hist_str,true);

% Add information to the new mask's header, for future reference
subj = set_objsubfield(subj,'mask',new_maskname,'header', ...
			 'vol',vol,'ignore_absence',true);

% Record how this mask was created
created.function = 'load_analyze_mask';
subj = add_created(subj,'mask',new_maskname,created);
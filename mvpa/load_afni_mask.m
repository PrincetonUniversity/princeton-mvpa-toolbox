function [subj] = load_AFNI_mask(subj,new_maskname,filename)

% Loads an AFNI dataset into the subj structure as a mask
%
% [SUBJ] = LOAD_AFNI_MASK(SUBJ,NEW_MASKNAME,FILENAME)
%
% Adds the following objects:
% - mask object called NEW_MASKNAME


% Initialize the new mask
subj = init_object(subj,'mask',new_maskname);

[err,V,AFNIheads,ErrMessage]= BrikLoad(filename);

% Check for errors
if err == 1
  error(sprintf('error in BrikLoad -%s',ErrMessage));
end

if ndims(V)>3
  error('Trying to load in a 4D dataset as a mask');
end

if ~length(find(V))
  error( sprintf('There were no voxels active in the %s.BRIK mask',filename) );
end

% Does this consist of solely ones and zeros?
if length(find(V)) ~= (length(find(V==0))+length(find(V==1)))
  disp( sprintf('Setting all non-zero values in the %s.BRIK mask to one',filename) );
  V(find(V)) = 1;
end

% Store the data in the new mask structure
subj = set_mat(subj,'mask',new_maskname,V);

% Add the AFNI header to the patterns
hist_str = sprintf('Mask ''%s'' created by load_AFNI_pattern',new_maskname);
subj = add_history(subj,'mask',new_maskname,hist_str,true);

% Add information to the new mask's header, for future reference
subj = set_objsubfield(subj,'mask',new_maskname,'header', ...
			 'AFNI_heads',AFNIheads,'ignore_absence',true);
subj = set_objsubfield(subj,'mask',new_maskname,'header', ...
			 'AFNI_filename',filename,'ignore_absence',true);

% Record how this mask was created
created.function = 'load_AFNI_mask';
subj = add_created(subj,'mask',new_maskname,created);


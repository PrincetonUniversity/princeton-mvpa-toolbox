function [] = image_mat(subj,objtype,objname)

% [] = IMAGE_MAT(SUBJ,OBJTYPE,OBJNAME)
%
% Visualize the contents of an object or group with
% IMAGESC. Automatically shifts to black&white colormap for binary
% matrices.

if exist_object(subj,objtype,objname)
  mat = get_mat(subj,objtype,objname);
elseif exist_group(subj,objtype,objname)
  mat = squeeze(get_group_as_matrix(subj,objtype,objname));
  if isrow(mat)==0, mat = mat'; end
else
  error('No %s object or group called %s',objtype,objname)
end
figure
imagesc(mat);
[nConds nTimepoints] = size(mat);
titlef('%s - %s - %s',subj.header.id,objtype,objname);

if strcmp(objtype,'regressors')
  colormap(gray)
elseif strcmp(objtype,'selector')
  isbool = check_1ofn_regressors(mat);
  if isbool, colormap(gray), end
end
% the y+50 is for all the extra fixed stuff in a figure,
% e.g. toolbars and title
setfsize(nTimepoints,(nConds*40)+50);

function [subj] = dimred_template(subj,data_patname,selname,new_map_patname,extra_arg)

% Template for dimensionality reduction methods
%
% [SUBJ] = DIMRED_TEMPLATE(SUBJ,DATA_PATNAME,SELNAME,NEW_MAP_PATNAME,EXTRA_ARG)
%
% Adds the following objects:
% - dimensionality-reduced pattern object
% - possibly also patterns of some kind for the transformation
% matrix, or component maps, so that this transformation can be
% reapplied to new data
% 
% This takes in a pattern DATA_PATNAME (e.g. raw voxel values), and creates a
% dimensionality-reduced version of that pattern. It uses the
% SELNAME selector to determine which timepoints will be used to
% calculate the dimensionality reduction. Like the voxel selection
% methods, the selector will be coded with 0s for ignore, 1s for
% incorporate, and 2s for testing timepoints that the
% dimensionality reduction will be applied to.
%
% I haven't taken a regressors object as input deliberately, to
% reflect the fact that these are intended to be *unsupervised*
% methods. We can always have an optional argument containing the
% regressors for supervised dimensionality reduction techniques.
%
% The EXTRA_ARG can be an empty structure, or it could include
% optional parameters, but it needs to be there so that these methods
% can be called interchangeably by XVAL_DIMRED, passing optional
% arguments where necessary.

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


if nargin<5
  errors('Need 5 arguments, even if extra_arg is empty')
end

% Deal with optional arguments specific to each method here, if
% necessary
defaults.blah = blah;
args = propval({extra_arg},defaults);

pat  = get_mat(subj,'pattern',data_patname);
regs = get_mat(subj,'regressors',regsname);
sel  = get_mat(subj,'selector',selname);

sanity_check(pat,sel);

TRs_to_use = find(sel==1);

pat   = pat(:,TRs_to_use);
regs = regs(:,TRs_to_use);

% lowdim_pat is the low-dimensionality version of our data [nDims x
% nSelectedTimepoints]
%
% transf_mat is the transformation matrix that will allow us to
% apply this same transformation to new timepoints. not all methods
% will return this, and i'm not entirely sure what to do with this
% or how to store it yet...
[lowdim_pat transf_mat] = crazy_dimred_logic(pat);

% Now create a new pattern object that will house our
% dimensionality-reduced pattern
subj = init_object(subj,'pattern',new_map_patname);
subj = set_mat(subj,'pattern',new_map_patname,lowdim_pat);

% every pattern needs a mask. our new dimensionality-reduced
% pattern will get a mask of all ones, one per dimension
%
% if we decide later that we only care about, say, the first two
% dimensions, it's easy to create a new mask with ones in just
% those two dimensions
%
% Note: we only need a 1D mask here, but the toolbox expects masks to
% be 3D matrices, and matlab will squeeze them if the second and
% third dimensions are singletons. So we get around this by
% creating a [1 x 1 x nDimensions] mask matrix
subj = set_objfield(subj,'pattern',new_map_patname, ...
			 ones(1,1,size(lowdim_pat,1)));

% Do some book-keeping, so that we can later inspect the pattern we
% created to see how we created it
hist = sprintf('Created by dimred_template');
subj = add_history(subj,'pattern',new_map_patname,hist);

created.function = mfilename;
created.data_patname = data_patname;
created.selname = selname;
created.new_map_patname = new_map_patname;
created.extra_arg = extra_arg;
subj = add_created(subj,'pattern',new_map_patname,created);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lowdim_pat transf_mat] = crazy_dimred_logic(pat)

% this is where the actual dimensionality reduction algorithm gets
% applied
%
% ...



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(pat,sel)

if size(pat,2) ~= size(sel,2)
  error('Your selector and your pattern have different numbers of timepoints');
end

if max(sel)>2 | min(sel)<0
  disp('These selectors don''t look like cross-validation selectors');
  error('Are you feeding in your runs by accident?');
end

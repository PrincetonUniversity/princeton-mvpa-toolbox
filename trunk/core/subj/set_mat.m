function [subj] = set_mat(subj,objtype,objname,newmat,varargin)

% Updates the MAT contents of an object
%
% [SUBJ] = SET_MAT(SUBJ,OBJTYPE,OBJNAME,NEWMAT,VARARGIN)
%
% Updates the MAT contents of the object of OBJTYPE type called
% OBJNAME with NEWMAT. Does lots of error-checking to try and avoid
% possible problems
%
% IGNORE_EMPTY (optional, default = false). By default, this will
% warn you if you're trying to replace your object's MAT with an
% empty one. Set to true if you're sure you want to do that
%
% IGNORE_DIFF_SIZE (optional, default = false). By default, this
% will warn you if you're trying to replace your object's mat with
% one of a different size. Set to true if you're sure you want to
% do that
%
% IGNORE_REGS_TRANSPOSE (optional, default = false). By default, this
% will warn you if your regressors' nCols < nRows, since this might
% indicate that things need to be transposed. Set to true if you
% don't want that warning
%
% If the object is stored on the hard disk (see 'Moving patterns to
% the hard disk' in the manual), this transparently writes the MAT
% to the file
%
% It also does lots and lots of error-checking and book-keeping. Bad
% bad things will happen if you ignore it and access the subj
% structure directly with subj.blah{i}.mat instead

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

% This function looks long, but all it comes down to is:
%   objcell = get_type
%   objno = get_number
%   objcell{objno}.mat = newmat
%   subj = set_type


if nargin<4
  error('I think you''ve forgotten to feed in one of your arguments');
end

if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

defaults.ignore_regs_transpose = false;
defaults.ignore_empty = false;
defaults.ignore_diff_size = false;
args = propval(varargin,defaults);

% Don't let me mess up, catch me before I fall, the distpat toolbox
% does it all
newmat = sanity_check(subj,objtype,objname,newmat,args);

% If the object resides on the hard disk, overwrite the existing file

if exist_objfield(subj,objtype,objname,'movehd')
  movehd = get_objfield(subj,objtype,objname,'movehd');
  disp( sprintf('Writing mat to %s',movehd.pathfilename));

  mat = newmat;  
  save(movehd.pathfilename,'mat');
  clear mat
  subj = set_objsubfield(subj,objtype,objname,'movehd','last_saved',datetime(true),'ignore_absence',true);
 
% Otherwise, get the cell array. Mess with the appropriate cell in
% it. Set it back into the subj structure
else
  objcell = get_type(subj,objtype);
  objno = get_number(subj,objtype,objname);
  objcell{objno}.mat = newmat;
  subj = set_type(subj,objtype,objcell);
end

% Oh, and update the matsize. This avoids lots of passing around of
% the MAT fields, just to find the size (e.g. in summarize) which
% could slow things down
% xxx but i thought matlab only passed by value when the object was
% modified???
subj = set_objfield(subj,objtype,objname,'matsize',size(newmat));

% Record that we modified this. Could be useful. Don't ask me when
% or why. Mine is not the place to know these things. The brain
% moves in mysterious ways
subj = set_objfield(subj,objtype,objname,'last_modified',datetime(true),'ignore_absence',true);

% Update type-specific stuff
switch(objtype)
 case 'mask'
  subj = set_objfield(subj,'mask',objname,'nvox',length(find(newmat)));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newmat] = sanity_check(subj,objtype,objname,newmat,args)

if strcmp(objtype,'selector') && islogical(newmat)
  newmat = double(newmat);
end

if ~isnumeric(newmat) 
   if isstruct(newmat)
     error('Your new mat is a structure - did you call get_object by mistake?');
   else
     if strcmp(objtype,'mask') & islogical(newmat)
       % allow logical masks
     else
       error('Your new mat isn''t a matrix');
     end
  end
end 
    
if ~exist_objfield(subj,objtype,objname,'mat')
  error('This object doesn''t have a MAT - not been initialized properly - use init_object next time');
end

% Warn if the new mat is empty, unless:
%  - IGNORE_EMPTY is true
if isempty(newmat) & ~args.ignore_empty
  warning( sprintf('Setting the %s %s mat to empty',objname,objtype));
end

% Warn if the old and new mats are different sizes, unless:
%  - IGNORE_DIFF_SIZE is true
%  - the old mat was empty (cos it had probably just been initialized)
%  - the new mat is empty (cos IGNORE_EMPTY deals with that)
oldmatsize = get_objfield(subj,objtype,objname,'matsize');
newmatsize = size(newmat);
if find(oldmatsize) & ~all(oldmatsize==newmatsize) & ...
      ~args.ignore_diff_size & ~isempty(newmat)
   warning( sprintf('The dimensions of the new %s %s mat are different',objname,objtype) );
end

% Check that the dimensions of the new mat are about right for the type
switch(objtype)
  
 case 'pattern'
  check_dims(newmat,2);
  
 case 'regressors'
  check_regressors_dims(newmat,args);
  
 case 'selector'
  % Transpose if not a row vector
  newmat = check_selector_dims(newmat);
  
 case 'mask'
  % We should probably allow 2D masks in future - set as an
  % optional argument??? xxx
  check_dims(newmat,3);

 otherwise
  error('Unknown object type');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = check_regressors_dims(newmat,args)

% This just checks to see if your nCols < nRows, indicating you've
% fed in nTRs by nConds by accident

check_dims(newmat,2);

if (size(newmat,1) > size(newmat,2)) & ~args.ignore_regs_transpose
  warning(['It looks like you have more conditions than timepoints' ...
	   ' in your regressors. Do they need to be transposed?']);
end
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newmat] = check_selector_dims(newmat)

% This just transposes the selector if it's accidentally fed in as
% a column-vector

check_dims(newmat,2);

if ~isvector(newmat)
  error('Selector has to be a row vector');
end

if ~isint(newmat)  
    error('Selector has to be integers only');
end

if find( newmat < 0)
  error('Your selectors should be positives integers only');   
end  

  
if size(newmat,1) > size(newmat,2)
  warning('You need to transpose your selectors - fixed for you inside set_mat');
  newmat = newmat';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = check_dims(newmat,nd)

% can't check the dimensionality of a singleton
if numel(newmat)==1
  return
end

if ndims(newmat) ~= nd
  error( sprintf('Your mat should have %i dims - this will probably break soon',nd) );
end


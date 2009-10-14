function [mat] = get_mat(subj,objtype,objname)

% Returns the MAT field of the object
%
% [MAT] = GET_MAT(SUBJ,OBJTYPE,OBJNAME)
%
% The MAT field is where the goodies are stashed. For instance, it
% stores the data in a pattern, or the volume in a mask.
%
% If the object is being stored on the hard disk (see the manual
% section on 'Moving patterns' to the hard disk' for more info),
% then this will transparently retrieve the mat from there

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


% Basically, all this does is:
%   objcell = get_type
%   objno = get_number
%   return objcell{objno}

if nargin~=3
  error('I think you''ve forgotten to feed in all your arguments');
end

mat = [];

% Uses the objno and objcell so that it's independent of object type
obj = get_object(subj, objtype, objname);

if ~isfield(obj, 'mat')

%objno = get_number(subj,objtype,objname);
%objcell = get_type(subj,objtype);

%if ~exist_objfield(subj,objtype,objname,'mat')
  error( sprintf('The %s %s doesn''t have a .mat field',objname,objtype) );
end

% If the mat resides on the HD, load it in from there
if isfield(obj, 'movehd')
%if exist_objfield(subj,objtype,objname,'movehd')
  movehd = get_objfield(subj,objtype,objname,'movehd');
  disp( sprintf('Retrieving mat from %s',movehd.pathfilename) );
  load(movehd.pathfilename);

% Otherwise, just grab it from the objcell
else
  mat = obj.mat; %objcell{objno}.mat;

  if islogical(mat)    % if masks are logical, that's
    mat = single(mat); % efficient storage, but can mess things up
  end
  
end % isfield movehd

if isempty(mat)
  warning( sprintf('Retrieving an empty mat from %s',objname) );
end

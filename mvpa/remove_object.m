function [subj] = remove_object(subj,objtype,objname,varargin)

% This removes an object permanently
%
% [SUBJ] = REMOVE_OBJECT(SUBJ,OBJTYPE,OBJNAME,...)
%
% This will remove the entire object permanently from the subj
% structure - NOT RECOMMENDED
%
% There is no reason to remove the actual cell itself, since it
% takes up little memory and provides a record of the object that
% used to exist. However, if you really want to remove the actual
% cell itself and shunt all the other cells along, this function
% will do that. It does warn you that this is a bad idea though.
%
% REMOVE_HD_TOO (optional, default = true). By default, if the object's
% contents are residing on the hard disk, the file will be deleted
% too. Set this to false if you want to leave the file. Note: only
% works for Unix xxx
%
% N.B. This doesn't change the subj.x strings. If subj.x refers to
% the object that was just removed, remember to update subj.x
% accordingly.

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


defaults.remove_hd_too = true;
args = propval(varargin,defaults);

if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

if nargin~=3
  error('I think you''ve forgotten to feed in all your arguments');
end

disp( sprintf('Removing entire %s %s object',objname,objtype) );

objcell = get_type(subj,objtype);

objno = get_number(subj,objtype,objname);

% If the object resides on the hard disk and REMOVE_HD_TOO, delete
% the file too
if isfield(objcell{objno},'movehd') && args.remove_hd_too
  movehd = objcell{objno}.movehd;
  disp( sprintf('Erasing %s',movehd.pathfilename) );
  fn = sprintf('%s.mat',movehd.pathfilename);
  delete(fn);
  if exist(fn,'file')
    warning( sprintf('Unable to delete %s',fn) );
  end
end

% This is special matlab syntax for completely removing a cell from
% a cell array and shunting all the ones above it along
objcell(objno) = [];

subj = set_type(subj,objtype,objcell);

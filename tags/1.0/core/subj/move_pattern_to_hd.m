function [subj pathfilename] = move_pattern_to_hd(subj,patname,varargin)

% Moves the pattern MAT to the hard disk
%
% [SUBJ PATHFILENAME] = MOVE_PATTERN_TO_HD(SUBJ,PATNAME,...)
%
% Saves the pattern MAT field as a file, and removes the mat field
% from the pattern cell, to save hard disk space. It also adds a field
% 'movehd' to the patterns cell saying where the pattern was stored so
% that getpatterns can transparently retrieve the pattern from the
% hard disk. In other words, you can continue working with this
% pattern *as though* it was still stored in the SUBJ structure
%
% SUBDIR (optional, default = subj.header.subdir, which
% defaults to '.'). An optional parameter that says where to save the
% file. Do not include a file separator at the end
%
% Need to figure out a better way to deal with multiple files with
% the same name than just the datetime(seconds) - should
% auto-rename - xxx. Also, this shouldn't take in a filename from
% the user, since it should be invisible to them.
%
% N.B. At the moment, you can only move patterns to the HD, which
% makes sense since they're the biggest RAM hogs. However, the
% get/set_mat scripts would work fine if you were to move an
% object of a different type, so it may/not be worth generalising
% this to move_object_to_hd... xxx

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


% Catch user error early
if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

if strcmp(patname,'pattern')
  error('You don''t have to feed an objtype argument to move_pattern_to_hd');
end

% Deal with optional arguments
defaults.subdir = get_objsubfield(subj,'subj','','header','subdir');
args = propval(varargin,defaults);

% Check hasn't alredy been moved to hard disk
if exist_objfield(subj,'pattern',patname,'movehd')
  disp( sprintf('Patterns %s already moved to hard disk - returning',patname) );
  pathfilename = '';
  return
end

dt = datetime(true);

% Won't overwrite an existing file of same name
pathfilename = sprintf('%s/%s_%s',args.subdir,patname,dt);
if exist(pathfilename, 'file')
  error( sprintf('A file called %s already exists',pathfilename) );
end

% Make subdirectory if necessary
if ~exist(args.subdir,'dir')
  mkdir(args.subdir);
end

% Let the user know what's going on
hist_str = sprintf('Moving pattern %s to harddisk as %s',patname,pathfilename);

% Save the contents to the HD and remove from the SUBJ
mat = get_mat(subj,'pattern',patname);
matsize = size(mat);
save(pathfilename,'mat');
subj = remove_mat(subj,'pattern',patname);

% SET_MAT will set the matsize to [0 0] because it thinks we just
% removed the MAT. rewrite the MATSIZE to faithfully record the
% size of the MAT now residing on the hard disk
subj = set_objfield(subj,'pattern',patname,'matsize',matsize);

% Set the movehd field in the object so that we can keep track of
% where the MAT has been stored
movehd.first_saved = dt;
movehd.pathfilename = pathfilename;
subj = set_objfield(subj,'pattern',patname,'movehd',movehd,'ignore_absence',true);

% Book-keeping (since the header and the rest of the object stays on the hard disk)
subj = add_history(subj,'pattern',patname,hist_str);


function [subj] = load_pattern_from_hd(subj,patname,varargin)

% Reverse of MOVE_PATTERN_TO_HD
%
% [SUBJ] = LOAD_PATTERN_FROM_HD(SUBJ,PATNAME,...)
%
% Reloads a pattern that was saved to the harddisk. Uses the MOVEHD
% field stored in the pattern to retrieve things, and then removes it
% afterwards
%
% LEAVE_ON_HD (optional, default = false). By default, the file gets
% deleted from the hard disk after being loaded. Set this to true to
% leave it there. This might cause problems if you then try to move it
% back to the hard disk - untested
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


defaults.leave_on_hd = false;
args = propval(varargin,defaults);

% Error Checking: Has this pattern been moved?
if ~exist_objfield(subj,'pattern',patname,'movehd')
  % if there's no movehd and that mat is full, then things are
  % probably fine
  if ~isempty(get_mat(subj,'pattern',patname))
    disp(sprintf('Pattern %s has not been saved to the hard disk - continuing',patname));
  % but if there's no movehd and the mat is empty, then there's probably a problem
  else
    error(sprintf('Pattern %s has not been saved to the hard disk and mat is empty',patname));
  end
end

% If so, where should it be?
fn = get_objsubfield(subj,'pattern',patname,'movehd','pathfilename');

% Is the file where its supposed to be?
if ~exist(fn,'file')
  if ~exist([fn '.mat'],'file')
    error(sprintf('Pattern not found on HD (Relative link problem?):\nfile: %s',fn));
  else
    fn = [fn '.mat'];
  end
end

fndir = dir(fn);
if ~isempty(fndir)
  disp( sprintf('Loading in %s - %i bytes',fn,fndir.bytes) );
end

load(fn);

% Delete the movehd record
subj = remove_objfield(subj,'pattern',patname,'movehd');

subj = set_mat(subj,'pattern',patname,mat);

% Update the header information
hist_str = sprintf('Loaded pattern %s from harddisk as %s', patname,fn);
subj = add_history(subj,'pattern',patname,hist_str,true);

if ~args.leave_on_hd
  % Delete the file from the HD; Avoid multiple copies
  delete(fn);
end

function [subj] = load_pattern_from_hd(subj,patname)

% Reverse of MOVE_PATTERN_TO_HD
%
% [SUBJ] = LOAD_PATTERN_FROM_HD(SUBJ,PATNAME)
%
% Reloads a pattern that was saved to the harddisk. Uses the MOVEHD
% field stored in the pattern to retrieve things, and then removes it
% afterwards




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

load(fn);

subj = set_mat(subj,'pattern',patname,mat);

% Update the header information
hist_str = sprintf('Loaded pattern %s from harddisk as %s', patname,fn);
subj = add_history(subj,'pattern',patname,hist_str,true);

% Delete the file from the HD; Avoid multiple copies
delete(fn);

% Delete the movehd record
subj = remove_objsubfield(subj,'pattern',patname,'movehd');

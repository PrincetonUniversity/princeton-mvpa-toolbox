function [subj fn] = save_subj(subj,varargin)

% This just saves the subj structure to a file.
%
% [SUBJ FN] = SAVE_SUBJ(SUBJ,...)
%
% It's useful because it does lots of book-keeping, and won't
% overwrite existing files unless you tell it to
%
% FN = the filename it saved itself under. This is useful in cases
% where it had to choose a new one because the default/user-provided
% one was already taken
%
% CREATE_LOG (optional, default = true) creates a textfile
% filename_subjID_datetime.log with the current summarize and header
% info for easy reference without having to load in the mat
%
% SAVE_INFO (optional, default = []). This is a string that gets
% displayed and appended to the subj.header.history. Useful if you
% want to put a comment about why you're saving this subject or what
% state things are in - this gets displayed in the terminal and
% appended to the header history. if you don't feed in a save_info, or
% an empty one, then it will automatically create a simple one
% containing time and filename
%
% PATHFILESTEM (optional, default = 'subj')
%
% APPEND_DATE (optional, default = true) - appends the date to the
% pathfilestem
%
% OVERWRITE_IF_EXIST (optional, default = false). If true, will
% overwrite files with the same name if they exist
%
% e.g. [subj filename] = save_subj(subj);
% 
% e.g. subj = save_subj(subj,'pathfilestem','~/blah/my_subj', ...
%                            'append_date',true, ...
%                            'save_info','Great classification');
%
% APPEND_RESULTS (optional, default = []). If you want to append a
% results structure too, then feed in the results variable here. This is the same as
% typing
%
%   save(filename,'-append','results');
%
% after running this function. Leave it empty and it will not
% append anything. Unfortunately, this will rename whatever
% variable gets passed in as 'results' when it saves
%
% xxx ID and SUBDIR functionality not finished yet

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


id = get_objsubfield(subj,'subj','','header','id');
subdir = get_objsubfield(subj,'subj','','header','subdir');

defaults.create_log = true;
defaults.save_info = [];
defaults.pathfilestem = 'subj';
defaults.append_date = true;
defaults.overwrite_if_exist = false;
defaults.append_results = [];
args = propval(varargin,defaults);

dt = datetime();

% For brevity
fn = args.pathfilestem;

% Optionally append the date
if args.append_date
  fn = sprintf('%s_%s',fn,dt);
end

% If we're not prepared to overwrite existing files, then we have
% to keep appending a number to the end of the filename until we
% find a vacant spot
if ~args.overwrite_if_exist
  try_fn = fn;
  i = 1;
  % Keep incrementing as long as FN_i exists
  while exist( sprintf('%s.mat',try_fn),'file' )
    i = i+1;
    try_fn = sprintf('%s_%i',fn,i);
    disp( sprintf('filename %s already exists - trying %s',fn,try_fn) );
  end
  % If fn already existed, use try_fn instead
  if strcmp(fn,try_fn) ~= true
    fn = try_fn;
  end
end % if args.overwrite_if_exist

% Generate a default save_info, and add it to the subj history
if isempty(args.save_info)
  args.save_info = sprintf('Saving ''%s'' in %s at %s',fn,pwd,dt);
end
subj = add_history(subj,'subj','',args.save_info,true);

% Actually do the saving
save(fn,'subj');

if ~isempty(args.append_results)
  results = args.append_results;
  save(fn,'-append','results');
end

history = char(get_objsubfield(subj,'subj','','header','history'));

% Record in the subj that it's been saved
subj = set_objsubfield(subj,'subj','','header','last_saved',dt,'ignore_absence',true);
subj = set_objsubfield(subj,'subj','','header','last_saved_filename',fn,'ignore_absence',true);

% Optionally record the saveinfo to fn.log
if args.create_log
  out = fopen(sprintf('%s.log',fn),'w');
  nHists = size(history,1);
  for i=1:nHists
    fprintf(out, sprintf('%s\n',history(i,:)) );
  end % nHists
  fclose(out);
end


function [] = summarize(subj,varargin)

% Prints info about the contents of the subj structure
%
% [] = summarize(subj,...)
% 
% SUMMARIZE(SUBJ) will give you a high-level summary of all the
% objects contained, including group members. It's
% much more informative than just typing 'subj'.
%
% DISPLAY_GROUPS (optional, default = true) - if set to false, then
% only the group name is shown
%
% OBJTYPE (optional, default = 'subj'). If 'subj', this displays all 4
% main types of objects. If set to one of 'pattern', 'regressors',
% 'selector' or 'mask', then it will just display that type of object
%
% e.g. summarize(subj,'display_groups',false,'objtype','mask')
%
% Appends [HD] to objects stored on the hard disk, and [HD???] if
% it can't find the file where the object is supposed to be (ohoh)


defaults.display_groups = true;
defaults.objtype = 'subj';
args = propval(varargin,defaults);

% Get the ID and experiment name, so we can display them
id = get_objsubfield(subj,'subj','','header','id');
experiment = get_objsubfield(subj,'subj','','header','experiment');
disp(' ');
disp( sprintf('Subject ''%s'' in ''%s'' experiment',id,experiment) );
disp(' ');

if ~ischar(args.objtype)
  error('If you feed in an optional objtype, this has to be a string');
end

% If the objtype = 'subj' (default), display all 4 types
if strcmp(args.objtype,'subj')
  objtypes = get_typeslist('single');
else  
  objtypes{1} = args.objtype;
end

displayed_groups = {};

% The summary display is more or less the same for all 4 objtypes,
% although the type_titles (where it says the name of the type at
% the top of the list) need to be specialised, and sometimes
% there's a little suffix (e.g. HD for patterns moved to the HD)

for t=1:length(objtypes)
  curtype = objtypes{t};

  % SUMMARISE_TYPE does all the hard work, looking inside all the
  % objects and extracting the summary information
  [objnames,group_details,printdims,hds,nvoxs] = summarise_type(subj,curtype);

  % Loop over all the members of this type
  for n=1:length(group_details)

    display_this = true;

    % If the current object belongs a group and display groups: then
    % store which groups have been displayed already in the
    % displayed_groups cell array. This way, group with members
    % scattered all over still only get displayed once
    if ~isempty(group_details{n}) & ~args.display_groups
      group_name = get_objfield(subj,objtypes{t},objnames{n},'group_name');
      display_this = false;
      
      % if this group hasn't been displayed before
      if isempty(strmatch(group_name,displayed_groups,'exact'))
	nMembers = length(find_group(subj,objtypes{t},group_name));
	disp( sprintf('\t *  %-30s -   [GRP size %2i]',group_name,nMembers) );
	displayed_groups{end+1} = group_name;
      end
    end

    % Each objtype has its own type_title, and also displays
    % slightly different properties about its objects (e.g. masks
    % tell you about nVox)
    switch(curtype)
     case 'pattern'
      type_title = sprintf('Patterns - %64s', '[ nVox x nTRs]');
      details = sprintf('\t%2i) %-30s - %15s [%10s] %4s', ...
			n,objnames{n},group_details{n},printdims{n},hds{n});
     
     case 'regressors'
      type_title = sprintf('\nRegressors -  %61s', '[nCond x nTRs]');
      details = sprintf('\t%2i) %-30s - %15s [%s]', ...
			n,objnames{n},group_details{n},printdims{n});
      
     case 'selector'
      type_title = sprintf('\nSelectors -  %62s', '[nCond x nTRs]');
      details = sprintf('\t%2i) %-30s - %15s [%s]', ...
			n,objnames{n},group_details{n},printdims{n});
      
     case 'mask'
      type_title = sprintf('\nMasks -  %77s', '[ X  x  Y  x  Z ] [ nVox]');
      details = sprintf('\t%2i) %-30s - %15s [%s] [%5i]', ...
			n,objnames{n},group_details{n},printdims{n},nvoxs{n});
     otherwise
      error('Unknown object type');
    end

    if n==1
      disp(type_title);
    end

    if display_this
      disp(details);
    end
    
  end % for n

  if ~length(group_details)
    disp( sprintf('No %s objects',objtypes{t}) );
  end
  
  displayed_groups = {};

end % for t



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [objnames,group_details,printdims,hds,nvoxs] = summarise_type(subj,objtype)

objcell = get_type(subj,objtype);
nbr_objects = length(objcell);

displ_as_grp = zeros(1,nbr_objects);
group_size   = zeros(1,nbr_objects);

objnames = {};
group_details = {};
printdims = {};
hds = {};
nvoxs = {};

for n=1:nbr_objects

  % Get the name and group membership for this object
  objnames{n} = get_name(subj,objtype,n);
  grpname = get_objfield(subj,objtype,objnames{n},'group_name');
  mat = [];

  % Determine the size of the group
  group_details{n} = get_group_size(subj,objtype,n);
  
  % Determine whether this object has been moved to the hard
  % disk. At the moment, only patterns can be moved to the HD
  if exist_objfield(subj,objtype,objnames{n},'movehd')
    % Check that the file exists - if not, flag it with question
    % marks
    stored_filename = get_objsubfield(subj,objtype,objnames{n},'movehd','pathfilename');
    if exist( sprintf('%s.mat',stored_filename),'file')
      hds{n}      = '[HD]';
    else
      hds{n}      = '[HD???]';
    end
  else
    hds{n}      = '';
  end

  % Determine the matsize
  % All objects *should* have a matsize, but just in case
  if exist_objfield(subj,objtype,objnames{n},'matsize')
    dims = get_objfield(subj,objtype,objnames{n},'matsize');
    printdims{n} = print_matsize(dims);
  else
    printdims{n} = 'unknown';
  end
  
  % Determine the nVox for masks
  if exist_objfield(subj,objtype,objnames{n},'nvox')
    nvoxs{n} = get_objfield(subj,objtype,objnames{n},'nvox');
  else
    nvoxs{n} = NaN;
  end
    
end % i nbr_patterns




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [group_details] = get_group_size(subj,objtype,n)

objname = get_name(subj,objtype,n);
group_name = get_objfield(subj,objtype,objname,'group_name');
grpsize = length(find_group(subj,objtype,group_name));

if grpsize > 0
  group_details = sprintf('[GRP size %2d]', grpsize);
else
  group_details = '';
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [strsize] = print_matsize(numsize)

% [strsize] = print_matsize(numsize)
%
% Really dumb utility function that returns the size of a matrix as
% a string in a more user-readable fashion than just
% num2str(size(mat))


strsize = num2str(numsize(1));

if length(numsize) == 3
  for i=2:length(numsize)
    strsize = sprintf('%3s x %3i',strsize,numsize(i));
  end
else
  for i=2:length(numsize)
    strsize = sprintf('%5s x %4i',strsize,numsize(i));
  end % i ndims(mat)
end

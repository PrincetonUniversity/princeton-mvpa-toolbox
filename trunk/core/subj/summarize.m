function [] = summarize(subj,varargin)
% Prints info about the contents of the subj structure
%
% [] = summarize(subj,...)
% 
% SUMMARIZE(SUBJ) will give you a high-level summary of all the
% objects contained, including group members. It's
% much more informative than just typing 'subj'.
%
% DISPLAY_GROUPS (optional, default variable) - if set to FALSE, then
% only the group name is shown. Default is set to FALSE when the
% total size of all objects in the subj structure exceeds
% 32. Otherwise, defaults to TRUE. If DISPLAY_GROUPS is set to -1,
% it will present group members only when the size or number of
% voxels in the members differ.
%
% SUMMARIZE(SUBJ, DISPLAY_GROUPS) If only one argument is passed,
% (just the value, not the property/value pair), then summarize
% will interpret that value as the DISPLAY_GROUPS setting.
%
% OBJTYPE (optional, default = 'subj'). If 'subj', this displays all 4
% main types of objects. If set to one of 'pattern', 'regressors',
% 'selector' or 'mask', then it will just display that type of object
%
% e.g. summarize(subj,'display_groups',false,'objtype','mask')
%
% Appends [HD] to objects stored on the hard disk, and [HD???] if
% it can't find the file where the object is supposed to be (ohoh)

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


defaults.display_groups = [];
defaults.objtype = 'subj';

if nargin == 2 % only run propval if more than 2 args given
  args = defaults;
  args.display_groups = varargin{1};
else  
  args = propval(varargin, defaults);

  if isempty(args.display_groups)
    args.display_groups = [get_tot_subj_size(subj,args.objtype) < 30];
  end
end

% Get the ID and experiment name, so we can display them
id = get_objsubfield(subj,'subj','','header','id');
experiment = get_objsubfield(subj,'subj','','header','experiment');

% Display initial header
disp(' ');
disp( sprintf('Subject ''%s'' in ''%s'' experiment',id,experiment) );
disp(' ');

% Error check objtype
if ~ischar(args.objtype)
  error('Optional argument OBJTYPE must be a string');
end

% If the objtype = 'subj' (default), display all 4 types
if strcmp(args.objtype,'subj')
  objtypes = get_typeslist('single');
else  
  objtypes{1} = args.objtype;
end

displayed_groups = {};

% Initialize warning tags
isnoncont = 0;
isvargrp  = 0;

noncontwarning = ['* Your groups are not all contiguous' ...
		  ' in the subject structure; Indicated by *NC)'];
vargrpwarning = ['* Variable-size groups truncated. See help for' ...
		 ' display info.'];

% The summary display is more or less the same for all 4 objtypes,
% although the type_titles (where it says the name of the type at
% the top of the list) need to be specialised, and sometimes
% there's a little suffix (e.g. HD for patterns moved to the HD)

groupSizes = [];
groupObjSz = [];
groupVoxNm = [];

for t=1:length(objtypes)
  curtype = objtypes{t};

  % SUMMARISE_TYPE does all the hard work, looking inside all the
  % objects and extracting the summary information
  [objnames,group_details,printdims,hds,nvoxs] = summarise_type(subj,curtype);

  % Loop over all the members of this type
  for n=1:length(group_details)

    display_this = true;
    groupvaries  = false;
    
    % If the current object belongs a group and display groups: then
    % store which groups have been displayed already in the
    % displayed_groups cell array. This way, group with members
    % scattered all over still only get displayed once
    if ~isempty(group_details{n}) && args.display_groups < 1
      
      group_name = get_objfield(subj,objtypes{t},objnames{n},'group_name');
      group_mems = find_group(subj,objtypes{t},group_name);      
      
      display_this = false;
      
      % if this group hasn't been displayed before      
      if isempty(strmatch(group_name,displayed_groups,'exact'))

        % LOOK UP group size
        if ~isfield(groupSizes, name2field(group_name))          
          groupSizes.(name2field(group_name)) = length(find_group(subj,objtypes{t},group_name));
        end
        
	nMembers = groupSizes.(name2field(group_name));
	
        % LOOK UP group dims

	% Determine whether the entire group has the same dimensions
        if ~isfield(groupObjSz, name2field(group_name))

          objsz = []; voxnm = [];
          for i=1:length(group_mems)
            objsz(i,:) = get_objfield(subj,objtypes{t},group_mems{i},'matsize'); 
            if exist_objfield(subj,objtypes{t},group_mems{i},'nvox')
              voxnm(i)   = get_objfield(subj,objtypes{t},group_mems{i},'nvox');
            else
              voxnm = [];
            end
          end        
          
          groupObjSz.(name2field(group_name)) = objsz;
          groupVoxNm.(name2field(group_name)) = voxnm;
        end
        
        objsz = groupObjSz.(name2field(group_name));
        voxnm = groupVoxNm.(name2field(group_name));
	
	if any(objsz(:,1) ~= objsz(1,1)) | any(objsz(:,2) ~= objsz(1,2))
	  gprintdims{n} = sprintf('  %s  ','variable');
	  groupvaries = true;
	else
	  gprintdims{n} = printdims{n};
	end
	
	
	% Determine whether the entire group has identical voxsize
	if isempty(voxnm) 
	  gnvoxs{n} = '';	  
	elseif any(voxnm ~= voxnm(1))
	  gnvoxs{n} = '[  V  ]';
	  groupvaries = true;
	else
	  gnvoxs{n} = sprintf('[%5i]',voxnm(1));
	end
	
	% Group numbers 
	notcontig = enforce_contig_groups(subj,objtypes{t}, group_name);
	if notcontig
	  idnums = sprintf('  *NC');
	  isnoncont = true;
	else
	  idnums = sprintf('%2i-%2i',n,n+nMembers-1);
	end

	% DW: IS THIS A BUG? THIS CODE HERE WILL EXECUTE BEFORE THE
        % HEADER COLUMN IS DISPLAYED??? 
	% If the group members vary in size or voxnumber, and
        % display-groups = -1, then don't treat them as a group.
	if args.display_groups ~= -1 | ~groupvaries
 	  disp( sprintf('%s) %-30s *   [GRP size %2i] [%s] %5s',idnums, ... 
		       group_name,nMembers,gprintdims{n}, gnvoxs{n}));
	  displayed_groups{end+1} = group_name;
	  if groupvaries
	    isvargrp = true;
	  end	  
	else
	  
	  display_this = true;
	end
	
      end
    end

    % Each objtype has its own type_title, and also displays
    % slightly different properties about its objects (e.g. masks
    % tell you about nVox)
    switch(curtype)
     case 'pattern'
      type_title = sprintf('Patterns - %59s', '[ nVox x nTRs]');
      details = sprintf('   %2i) %-30s - %15s [%10s] %4s', ...
			n,objnames{n},group_details{n},printdims{n},hds{n});
     
     case 'regressors'
      type_title = sprintf('\nRegressors -  %56s', '[nCond x nTRs]');
      details = sprintf('   %2i) %-30s - %15s [%s]', ...
			n,objnames{n},group_details{n},printdims{n});
      
     case 'selector'
      type_title = sprintf('\nSelectors -  %57s', '[nCond x nTRs]');
      details = sprintf('   %2i) %-30s - %15s [%s]', ...
			n,objnames{n},group_details{n},printdims{n});
      
     case 'mask'
      type_title = sprintf('\nMasks -  %72s', '[ X  x  Y  x  Z ] [ nVox]');
      details = sprintf('   %2i) %-30s - %15s [%s] [%5i]', ...
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

if isnoncont,  disp(noncontwarning); end
if isvargrp,   disp(vargrpwarning); end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [objnames,group_details,printdims,hds,nvoxs] = summarise_type(subj,objtype)

objcell = get_type(subj,objtype);
nbr_objects = length(objcell);

objnames = {};
group_details = {};
printdims = {};
hds = {};
nvoxs = {};

for n=1:nbr_objects

  % Get the name and group membership for this object
  objnames{n} = get_name(subj,objtype,n);

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sz = get_tot_subj_size(subj,objtype)

switch objtype
 case 'pattern'
  sztype = [1 0 0 0];
 case 'selector'
  sztype = [0 1 0 0];
 case 'regressors'
  sztype = [0 0 1 0];
 case 'mask'
  sztype = [0 0 0 1];
 case 'subj'
  sztype = [1 1 1 1];
end

sz = 0;
if sztype(1), sz = sz + length(subj.patterns); end;
if sztype(3), sz = sz + length(subj.regressors); end;
if sztype(2), sz = sz + length(subj.selectors); end;
if sztype(4), sz = sz + length(subj.masks); end;

					    
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function err = enforce_contig_groups(subj,objtype,groupname)
t = get_type(subj,objtype);

err = 0;
% Stupid inconsistency between the subj structure and labels!
if ~isempty(strmatch(objtype,'regressors','exact'))
  objtype = objtype(1:end-1);
end
objtype = [objtype 's'];
  
for i=1:length(t)
  curgrp = subj.(objtype){i}.group_name;
  if ~isempty(strmatch(groupname,curgrp,'exact'))
    isgrp(i) = 1;
  else
    isgrp(i) = 0;
  end
end

grpIdx = find(isgrp);
if length(grpIdx) > 1
  grpIncrease = grpIdx(2:end) - grpIdx(1:end-1);
  if any(grpIncrease > 1)
    err = 1;
  end  
end

function [field] = name2field(name)

field = strrep(name, ' ', '_');
field = strrep(field, '.', '__');
field = strrep(field, '-', '___');

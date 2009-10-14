function [same,errmsgs,warnmsgs] = compare_struct(s1,s2,errmsgs,warnmsgs,struct_name)

% Are two structs equal?
%
% [SAME,ERRMSGS,WARNMSGS] = COMPARE_STRUCT(S1,S2,[ERRMSGS],[WARNMSGS],[STRUCT_NAME])
%
% Feed in two structs, S1 and S2 to see if they're
% equal.
%
% ERRMSGS and WARNMSGS are cell arrays, as per standard unit
% tests. See trunk/tests/RUN_UNIT_TESTS. This argument is
% optional.
%
% STRUCT_NAME is a string, just for identification
% purposes. That way, if you run lots of tests on lots of
% structs, your ERRMSGS will be more informative. This
% argument is optional.
%
% First, it checks that they have the same number of
% fieldnames. If they do, then it checks that the lists of
% fieldnames are identical. Then, it goes through each
% field, and checks that it's identical for the two structs.
%
% Example, if all you want is a boolean similar/not similar:
%
% same = compare_struct(s1,s2);


if ~exist('struct_name') struct_name = 'unknown_struct'; end
if ~exist('errmsgs') errmsgs = {}; end
if ~exist('warnmsgs') warnmsgs = {}; end

% innocent unless proven guilty
same = true;

if ~isstruct(s1) | ~isstruct(s2)
  error('One of your inputs is not a struct')
end

fields1 = fieldnames(s1);
fields2 = fieldnames(s2);
if length(fields1) ~= length(fields2)
  errmsgs{end+1} = {'Different number of fields in S1 and S2'};
  same = false;
else
  % there's no point testing to see whether the
  % fieldnames lists are the same if we already know
  % they're different lengths
  %
  % compare the sorted fieldnames lists
  if ~isequal(sort(fields1),sort(fields2))
    errmsgs{end+1} = {'Fieldnames are not the same'};
  end
end

nFields = length(fields1);

for f=1:nFields
  
  cur_field = fields1{f};
  
  if ~isfield(s1,cur_field) | ~isfield(s2,cur_field)
    % if either one of the fields don't exist, don't
    % bother trying to compare if they're equal
    %
    % we actually probably don't need to set same = false
    % here, since it's probably already been set to false
    % by the earlier tests, but just in case...
    same = false;
    continue
  end % if both fields exist
  
  % if either of the fields1 are themselves structs, then
  % you'd need to call this function recursively
  if isstruct(s1.(cur_field)) | isstruct(s2.(cur_field))
    error('Haven''t implemented nested struct comparisons')
  end

  if ~isequalwithequalnans(s1.(cur_field),s2.(cur_field))
    errmsgs{end+1} = sprintf('%s field differs between real and fake %s', ...
                             cur_field,struct_name);
    same = false;
  end
    
end % f


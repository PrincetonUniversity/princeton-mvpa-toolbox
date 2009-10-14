function [combined_struct user_struct undefaulted_struct] = propval(user_propvals,defaults_struct,varargin)

% This deals with property/value pairs of optional arguments.
%
% [COMBINED_STRUCT USER_STRUCT UNDEFAULTED_STRUCT] = PROPVAL(USER_PROPVALS,DEFAULTS_STRUCT,...)
%
% Feed in the varargin cell array and a defaults_struct
% structure. Here's some example code for your function that shows how
% to call propval
%
% function [blah] = foo(...,varargin)
%
% defaults_struct.arg1 = 1000;
% defaults_struct.arg2 = 1000;
% ...
% combined_struct = propval(varargin,defaults_struct);
%
% This also does something else that's clever. If, instead of a
% cell array in propval, you feed in a single struct, this treats
% it as though it's a property/value cell array and continues
% normally. Otherwise, it should error out
%
% COMBINED_STRUCT will be a structure containing all the properties with the
% user's values, if included, otherwise the defaults that were set
% by the function-writer.
%
% USER_STRUCT contains just those arguments that the user provided
% in the property/value pairs, just in case you want to know which
% defaults got overwrote.
%
% UNDEFAULTED_STRUCT contains just those arguments where the user
% provided a property/value pair for which no default was provided,
% as a flag to the function-writer and user that there may be a
% typo or confusion about which property/value pairs are
% allowed. The UNDEFAULTED_STRUCT property/value pairs still get
% included in COMBINED_STRUCT just in case.
%
% This script also does some error-checking to make sure that all
% user-defined properties have defaults, that no property gets set
% twice etc. Note that this doesn't care what order the properties
% are inputted, as long as they're in property/value pairs.
%
% This doesn't check that that the variable types are the same for
% a given property in user_propvals and the default_struct
%
% e.g. look at the resulting args in this case:
%   varargin = {'first_prop',2000,'second_prop',5000};
%   defaults.first_prop = 1000;
%   defaults.second_prop = 1000;
%   defaults.third_prop = 1000;
%   args = propval(varargin,defaults);
%
% IGNORE_EMPTY_DEFAULTS (optional, default = false). If true, this
% will allow you to feed in an empty defaults structure without
% getting a warning
%
% IGNORE_MISSING_DEFAULT (optional, default = false). If the user
% feeds in an argument for which there is no default, you'll get a
% warning. Make this true to turn off that warning.

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


% We can use propval to parse its own optional arguments
% recursively, as long as there's a way that it can bottom
% out. Here, in the recursive call, we're not feeding it any
% optional arguments, and so it won't need to call itself again
% inside, so this should be ok
%
% However, since we rely on there being an args structure later, we
% have to duplicate the defaults-setting lines of code a little to
% ensure that it exists
if ~isempty(varargin)
  propval_defaults.ignore_empty_defaults = false;
  propval_defaults.ignore_missing_default = false;
  % disp('Before entering propval again');
  % keyboard
  propval_args = propval(varargin,propval_defaults);
else
  propval_args.ignore_empty_defaults = false;
  propval_args.ignore_missing_default = false;
end

% disp('About to start propvalling for real');
% keyboard

% Error Checking
if ~iscell(user_propvals) & ~isstruct(user_propvals)
  error('User_propvals should be a cell array or struct');
end
if isempty(defaults_struct)
  if ~propval_args.ignore_empty_defaults
    error('You have to feed in some defaults if you''re going to use optional arguments. Set them to [] if you don''t care');
  else
    defaults_struct = struct([]);
  end
end
if ~isstruct(defaults_struct)
  error('Defaults_struct has to be a struct');
end

% Determine the number of default fields
default_fieldnames = fieldnames(defaults_struct);

% Initialize the combined structure to default values
combined_struct = defaults_struct;
user_struct = [];
undefaulted_struct = [];

n_user_propvals = length(user_propvals);

% Determine whether the user arguments are in struct form or
% prop/val form.  If they are in struct form, convert to prop/val
% form
if n_user_propvals == 1
  % if the cell array only contains one value, and that's empty,
  % then turn it into an empty struct
  if isempty(user_propvals{1})
    input_struct = struct([]);
  else
    if isstruct(user_propvals{1})
      input_struct = user_propvals{1};
    else
      error('Single non-struct argument passed to propval');
    end
  end
  
  user_propvals = {};
  input_fields = fieldnames(input_struct);
  for i=1:length(input_fields)
    user_propvals{(i-1)*2+1} = input_fields{i};
    user_propvals{i*2}       = getfield(input_struct, input_fields{i});
  end
  
  n_user_propvals = length(user_propvals);
  
elseif mod(n_user_propvals,2)
  error('The property/value arguments have to come in pairs - but this is an odd number of arguments');  
end

for a = 1:2:n_user_propvals
  
  cur_prop = user_propvals{a};
  cur_val = user_propvals{a+1};

  if ~ischar(cur_prop)
    error('This property name is not a string');
  end
    
  if ~strcmp(cur_prop,lower(cur_prop))
    warning('All optional arguments should be lower case - fixed for you');
    cur_prop = lower(cur_prop);
  end

  if isfield(user_struct,cur_prop)
    error('You''ve provided two property/value pairs for the same property');
  end
  
  if ~isfield(defaults_struct,cur_prop) && ~propval_args.ignore_missing_default
    undefaulted_struct.(cur_prop) = cur_val;
    undefaulted_struct
    warning('The user provided a property/value pair for which there is no default');
  end
  
  user_struct.(cur_prop) = cur_val;
  
  % There's something weird about the Matlab parser that can't deal
  % with adding a field to an empty struct, so this hack fixes things
  if isempty(combined_struct)
    combined_struct(1).(cur_prop) = cur_val;
  else
    combined_struct.(cur_prop) = cur_val;
  end
end % a n_user_propvals




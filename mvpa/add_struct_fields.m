function [args] = add_struct_fields(specifieds,defaults)

% Auxiliary function
%
% [ARGS] = ADD_STRUCT_FIELDS(SPECIFIEDS,DEFAULTS)
%
% Deals with user-specified arguments and default arguments as
% structs.
%
% It creates an amalgamated ARGS struct that assumes that if the user
% hasn't specified an argument in SPECIFIEDS, then it should use the
% one in DEFAULTS.
%
% It doesn't do as much error-checking as PROPVAL.M xxx
%
% This should also return 'user_struct' and 'undefaulted_struct'
% like PROPVAL.M

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


def_fnames = fieldnames(defaults);

args = specifieds;

for i=1:length(def_fnames)
  cur_def_fname = def_fnames{i};

  % If this default argument wasn't specified, then use the default
  % value
  if ~isfield(args,cur_def_fname)
    args.(cur_def_fname) = defaults.(cur_def_fname);
  end
  
end

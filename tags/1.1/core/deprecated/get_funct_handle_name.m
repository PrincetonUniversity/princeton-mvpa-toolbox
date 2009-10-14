function [fhand fname] = get_funct_handle_name(n_or_h)

% Returns both function handle and name from an ambiguous arg
%
% [FHAND FNAME] = GET_FUNCT_HANDLE_NAME(N_OR_H)
%
% N_OR_H could be either a function name string OR a
% function handle - whichever it is, this will return
% both, for you to process as necessary.
%
% This way, you can leave it up to your
% user to feed in whichever's easiest for them, and this
% will give you back both from the ambiguous argument.

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

warning('%s is deprecated. Use ARG2FUNCT instead.\n', mfilename);

if isempty(n_or_h)
  error('You fed in an empty function name/handle')
end

switch(class(n_or_h))
 case 'function_handle'
  fhand = n_or_h;
  fname = func2str(n_or_h);
 case 'char'
  % check for common user boobs
  if strmatch(n_or_h,get_typeslist('single'),'exact')
    error('It looks like you''ve fed in an OBJTYPE instead of FUNCTION handle/name');
  end

  % check to see whether a function (well, anything, really)
  % called n_or_h exists
  if ~exist(n_or_h)
    error('No function called %s exists',n_or_h);
  end
  % this will run without an error, even if there's no such function
  fhand = str2func(n_or_h);
  fname = n_or_h;

 otherwise
  error('You have fed in a function argument that is neither a function handle nor the string name of a function');
end

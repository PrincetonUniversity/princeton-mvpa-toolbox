function [types] = get_typeslist(plurality)

% Auxiliary function
%
% [TYPES] = GET_TYPESLIST(PLURALITY)
%
% Returns a cell array of strings
% with the names of the main types
%
%
% Set PLURALITY to 'single' or 'plural'

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


switch(plurality)
 
 case 'single'
  types{1} = 'pattern';
  types{2} = 'regressors';
  types{3} = 'selector';
  types{4} = 'mask';
 
 case 'plural'
  types{1} = 'patterns';
  types{2} = 'regressors';
  types{3} = 'selectors';
  types{4} = 'masks';
 
 otherwise
  error('Unknown plurality type');
end



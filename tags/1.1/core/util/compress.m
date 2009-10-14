function [x] = compress(x)
% Recursively converts datatypes to save memory.
%
% [X] = COMPRESS(X);
%
% Compress converts numeric matrices to single precision and binary
% numeric matrices to logical matrices. Runs recursively on cell
% arrays and all fields of structures.

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

if isstruct(x)
  
  if numel(x) > 1
    for i = 1:numel(x)
      x(i) = compress(x(i));
    end
  else        
    fields = fieldnames(x);
    for i = 1:numel(fields)
      x.(fields{i}) = compress(x.(fields{i}));
    end
  end  
    
elseif isnumeric(x)

  if numel(unique(x(:))) == 2
    if all(unique(x(:))==[0;1])
      x = x>0;
    end
  else  
    x = single(x);
  end  

elseif iscell(x)
  
  for i = 1:numel(x)
    x{i} = compress(x{i});
  end
  
end

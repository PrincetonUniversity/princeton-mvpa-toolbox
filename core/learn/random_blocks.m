function [ blockmem ] = random_blocks(Y, M)
% Creates a vector of 1:N split into M random blocks.

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

if cols(Y) > 1

  Y
  blockmem = [];
  for k = 1:cols(Y)    
    
    % Find all examples of this class
    idx = find(Y(:,k)==1);
    
    % Partition them into M groups
    n = numel(idx);
    idxmem = memberships(n,M);
    
    % Randomize within group
    blockmem(idx) = idxmem(randperm(n));
  end
  
else
  
  if numel(Y) == 1
    N = Y;
  else
    N = numel(Y);
  end  

  idxmem = memberships(N, M);
  blockmem = idxmem(randperm(N));
  
end


% ------------------------------------------------------------------------
% memberships
% ------------------------------------------------------------------------
function [blockmem] = memberships(N, M);

blocks = round(linspace(1, N+1, M+1));
for i = 1:numel(blocks)  
  blockmem(i,:) = [1:N < blocks(i)];
end
blockmem = sum(blockmem);

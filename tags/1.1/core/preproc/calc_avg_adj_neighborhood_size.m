function [nsizes avgsize] = calc_avg_adj_neighborhood_size(adj_list)

% This is just a v simple function that gives you a sense
% of how big the neighborhoods in your ADJ_LIST are.

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

nVox = size(adj_list,1);
nsizes = nan(nVox,1);

% for each voxel, calculate how many neighbors it has
for v=1:nVox
  nsizes(v) = length(find(adj_list(v,:)));
end

avgsize = mean(nsizes);

hist(nsizes);

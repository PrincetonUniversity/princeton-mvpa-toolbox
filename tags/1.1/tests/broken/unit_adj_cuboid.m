function [errmsgs warnmsgs] = unit_adj_cuboid(varargin)

% Unit tests for ADJ_CUBE.M
%
% [ERRMSGS WARNMSGS] = UNIT_ADJ_CUBE(...)
%
% Tests with all-ones mask, randomly generated mask, and a
% few hand-written scenarois (where the correct output has
% been hand-calculated in advance).
%
% Doesn't test non-cuboid windows (i.e. where the windows are
% anything but -blah:blah), and doesn't test for including
% the centre voxel.
%
% See UNIT_TEMPLATE.M for more info
%
% UPDATE (GJD on 080329). This was broken, because it was
% still using cell arrays, and i think the default has
% changed to include the center voxel. See tests commented
% out, marked with 080329.
%
% DOPLOT (optional, default = false). If true, will plot
% each cuboid, and you have to press a key to see the next one


defaults.doplot = false;
args = propval(varargin,defaults);

errmsgs = {};
warnmsgs = {};

simple = ones(5,5,5);
s_sidelength = 2;

fairlycomplex = ones(5,5,5);
fairlycomplex([5 6 8]) = 0;
fc_sidelength = 4;

% 10 10 10 takes a long time - may be unnecessarily large
complex = round(rand(10,10,10));
c_sidelength = 4;

% handwritten_scenarios
errmsgs = hws1(errmsgs);
errmsgs = hws2(errmsgs);

[errmsgs warnmsgs] = try_mask(simple,s_sidelength,errmsgs,warnmsgs,args);
[errmsgs warnmsgs] = try_mask(fairlycomplex,fc_sidelength,errmsgs,warnmsgs,args);
[errmsgs warnmsgs] = try_mask(complex,c_sidelength,errmsgs,warnmsgs,args);

dispf('%i errmsgs found',length(errmsgs));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs] = hws1(errmsgs)

dispf('Running %s hws1',mfilename)

mask = zeros(5,5,5);
mask(100) = 1;
adj_list = adj_cuboid(mask);
if length(adj_list)~=1
  errmsgs{end+1} = 'HWS 1:Should only have one item in adj_list';
  return
end

% now that we're using matrices instead of cell arrays, and
% including the center voxel by default, i think this test
% is obsolete... 080329
%
% if ~isempty(adj_list(1))
%   errmsgs{end+1} = 'HWS 1: single voxel adj should be empty';
%   keyboard
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs] = hws2(errmsgs)

dispf('Running %s hws2',mfilename)

cuboid_args.window_i = -2:2;
cuboid_args.window_j = -2:2;
cuboid_args.window_k = -2:2;
mask = zeros(10,10,10);
mask([2 3 4 5 6],[2 3 4 5 6],[2 3 4 5 6]) = 1;
mask(8,8,8) = 1;
adj_list = adj_cuboid(mask,cuboid_args);
if length(adj_list)~=126
  errmsgs{end+1} = 'HWS 2: wrong adj_list length';
  return
end

% the mask(8,8,8) voxel should have a single neighbour: (6,6,6)
p888idx = convert_mask_coords_to_pat_idx(mask,[8 8 8]);
p666idx = convert_mask_coords_to_pat_idx(mask,[6 6 6]);
if ~isequal(adj_list(p888idx),p666idx)
  errmsgs{end+1} = 'HWS 2: wrong neighbor for (8,8,8)';
end

counter = 1;
for x=-2:2
  for y=-2:2
    for z=-2:2
      if x==0 && y==0 && z==0
        continue
      end
      cuboid_coords(counter,:) = [x y z] + [4 4 4];
      counter = counter + 1;
    end
  end
end

% cv = centre voxel
test_cv_adj_list = convert_mask_coords_to_pat_idx(mask,cuboid_coords);
real_cv_p_idx = convert_mask_coords_to_pat_idx(mask,[4 4 4]);
real_cv_adj_list = adj_list(real_cv_p_idx)';
if ~isequal(test_cv_adj_list,real_cv_adj_list)
  errmsgs{end+1} = 'HWS 2: wrong centre vox adj list';
  keyboard
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = try_mask(mask,sidelength,errmsgs,warnmsgs,args)

maskname = inputname(1);

fprintf('Trying %s mask\n',maskname);

% we're only going to test cuboid shapes
if mod(sidelength,2)
  error('Sidelength must be even');
end
% halfside = (sidelength+1)/2;
halfside = sidelength/2;
cuboid_args.window_i = -halfside:halfside;
cuboid_args.window_j = -halfside:halfside;
cuboid_args.window_k = -halfside:halfside;
exclude_center = false; % updated on 080329, since i think this is the new default
[real_cuboids_p_idx scratch real_cuboids_m_idx] = ...
    adj_cuboid(mask,cuboid_args);

incl_m_idx = find(mask);
nActiveVox = length(incl_m_idx);
nTotalVox = numel(mask);
maskdims = size(mask);
nCubes = length(real_cuboids_p_idx);

if length(incl_m_idx) ~= nCubes
  error('incl_m_idx and nCubes don''t match');
end

test_cuboids_p_idx = {};
test_cuboids_m_idx = {};

v = 1;
% 'm' for 'in terms of the mask'
for m=1:nTotalVox

  if mod(m, floor(nTotalVox/10)) == 0
    fprintf('\t%.2f', m/nTotalVox);
  end
  
  if mask(m)
  
    % we're going to create a test cuboid for each of the
    % cuboids created by ADJ_CUBE and check that they
    % match up
    [cX cY cZ] = ind2sub(maskdims,m);

    nX = maskdims(1);
    nY = maskdims(2);
    nZ = maskdims(3);

    % current cuboid for mask voxel m
    test_cuboid_m_idx = [];
    
    % go through every voxel in the volume
    for x = 1:nX
      for y = 1:nY
        for z = 1:nZ
          
          % if this point isn't included in the mask, go onto
          % the next one  
          if ~mask(x,y,z)
            continue
          end

          % check that this is included in the cuboid
          if (...
              abs(cX-x) > halfside || ...
              abs(cY-y) > halfside || ...
              abs(cZ-z) > halfside ...
              )
            continue
          end

          % exclude the center voxel itself
          if exclude_center && ...
                x==cX && ...
                y==cY && ...
                z==cZ
            continue
          end
        
          % get the voxel's index and add it to this
          % test_cuboid_m_idx's list of voxels
          test_cuboid_m_idx(end+1) = sub2ind(maskdims,x,y,z);
          
        end % z
      end % y
    end % x
    
    test_cuboid_p_idx = convert_mask_to_pat_idx(mask,test_cuboid_m_idx);
    test_cuboids_p_idx{end+1,1} = test_cuboid_p_idx;
    test_cuboids_m_idx{end+1,1} = test_cuboid_m_idx;
    
    p = convert_mask_to_pat_idx(mask,m);
    if p~=v
      error('Something wrong with convert_mask_to_pat_idx()');
    end
    v = v + 1;
    
    real_cuboid_p_idx = real_cuboids_p_idx(p,:);
    real_cuboid_m_idx = real_cuboids_m_idx(p,:);
    
    % get rid of the zeros
    real_cuboid_p_idx = sort(real_cuboid_p_idx(real_cuboid_p_idx~=0));
    real_cuboid_m_idx = sort(real_cuboid_m_idx(real_cuboid_m_idx~=0));
    
    if ~isequal(test_cuboid_p_idx,real_cuboid_p_idx)
      errmsgs{end+1} = sprintf('Try_mask failed using mask ''%s'' on cuboid %i (%i,%i,%i)', ...
                               maskname,p,cX,cY,cZ);
      
      if args.doplot
        plot_cuboids(mask,test_cuboid_m_idx,real_cuboid_m_idx,cX,cY,cZ);
      end % doplot
      
    end % isequal
    
  end % if mask(m)
  
end % m
fprintf('\n')

if length(test_cuboids_p_idx) ~= length(real_cuboids_p_idx)
  error('Different number of test and real adjacency lists');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = plot_cuboids(mask,test_cuboid_m_idx,real_cuboid_m_idx,cX,cY,cZ)

maskdims = size(mask);
[test_x test_y test_z] = ind2sub(maskdims,test_cuboid_m_idx);
[real_x real_y real_z] = ind2sub(maskdims,real_cuboid_m_idx);

excl_cuboid_m_idx = find(~mask);
[excl_x excl_y excl_z] = ind2sub(maskdims,excl_cuboid_m_idx);

figure(1)
cla
title('Unit test version')
hold on
axis([0 maskdims(1) 0 maskdims(2) 0 maskdims(3)])
view(3)
plot3(test_x,test_y,test_z,'bx');
plot3(cX, cY, cZ, 'go' );
plot3(excl_x,excl_y,excl_z,'ro');
    
figure(2)
cla
title('Real adj_cuboid version')
hold on
axis([0 maskdims(1) 0 maskdims(2) 0 maskdims(3)])
view(3)
plot3(real_x,real_y,real_z,'bx');
plot3(cX, cY, cZ, 'go' );
plot3(excl_x,excl_y,excl_z,'ro');

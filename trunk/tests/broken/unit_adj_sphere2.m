function [errmsgs warnmsgs] = unit_adj_sphere2(varargin)

% Unit tests for ADJ_SPHERE2.M
%
% [ERRMSGS WARNMSGS] = UNIT_ADJ_SPHERE2(...)
%
% See UNIT_TEMPLATE.M and UNIT_ADJ_CUBE.M for more info


defaults.doplot = false;
args = propval(varargin,defaults);

errmsgs = {};
warnmsgs = {};

simple = ones(5,5,5);
s_radius = 2;

complex = round(rand(8,8,8));
c_radius = 3;

errmsgs = scenario1(errmsgs);
errmsgs = scenario2(errmsgs);

errmsgs = compare_zero_radius(errmsgs);

[errmsgs warnmsgs] = try_mask(simple,s_radius,errmsgs,warnmsgs);
[errmsgs warnmsgs] = try_mask(complex,c_radius,errmsgs,warnmsgs);

dispf('%i errmsgs found',length(errmsgs))



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs] = scenario1(errmsgs)

dispf('Running %s scenario1',mfilename)

mask = zeros(5,5,5);
mask(100) = 1;
adj_list = adj_sphere2(mask);
if size(adj_list,1)~=1
  errmsgs{end+1} = 'Scenario 1:Should only have one neighborhood in adj_list';
end

if count(adj_list(1,:))~=1
  errmsgs{end+1} = 'Scenario 1: single voxel adj should only contain itself';
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs] = scenario2(errmsgs)

dispf('Running %s scenario2',mfilename)

sphere_args.radius = 1.1;
mask = zeros(10,10,10);
% mask(1,1,1) = 1; % singleton voxel
mask(4,4,4) = 1; % centre voxel
mask(4,4,5) = 1;
mask(4,5,4) = 1;
mask(5,4,4) = 1;
mask(4,4,3) = 1;
mask(4,3,4) = 1;
mask(3,4,4) = 1;
mask(4,6,4) = 1; % outside the sphere, overlaps with one
adj_list = adj_sphere2(mask,sphere_args);
if length(adj_list)~=length(find(mask))
  errmsgs{end+1} = 'Scenario 2: wrong adj_list length';
  return
end

sphere_coords = [ ...
    4 4 4; ... % center voxel
    4 4 5; ...
    4 5 4; ...
    5 4 4; ...
    4 4 3; ...
    4 3 4; ...
    3 4 4; ...
    ];

% the mask(4,6,4) voxel should have a single neighbour: (4,5,4)
p464idx = convert_mask_coords_to_pat_idx(mask,[4 6 4]);
p454idx = convert_mask_coords_to_pat_idx(mask,[4 5 4]);

if ~isequal( sort(remove_zeros(adj_list(p464idx,:))), ...
             sort([p454idx p464idx]) )
  errmsgs{end+1} = 'Scenario 2: wrong neighbour for (4,6,4)';
end

% cv = centre voxel
test_cv_cur_adjs = convert_mask_coords_to_pat_idx(mask,sphere_coords);
real_cv_p_idx = convert_mask_coords_to_pat_idx(mask,[4 4 4]);
real_cv_cur_adjs = adj_list(real_cv_p_idx,:)';
if ~isequal( sort(remove_zeros(real_cv_cur_adjs)), ...
             sort(test_cv_cur_adjs) )
  errmsgs{end+1} = 'Scenario 2: wrong centre vox adj list';
end

% if length(errmsgs)
%   test_sphere_m_idx = convert_pat_to_mask_idx(mask,test_cv_cur_adjs);
%   real_sphere_m_idx = convert_pat_to_mask_idx(mask,real_cv_cur_adjs);
%   plot_spheres(mask, test_sphere_m_idx, real_sphere_m_idx, 4,4,4);
  
%   disp('Errors were found in scenario2');
%   keyboard
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs] = compare_zero_radius(errmsgs)

sphere_args.radius = 0;
mask = ones([10 10 10]);
nvox_active_in_mask = count(mask);
adj_list = adj_sphere2(mask,sphere_args);

is_empty_adj_list = check_empty_adj_list(adj_list);

% there should be nvox_active_in_mask voxels, each with one
% voxel in their neighbourhood (themselves)
if ~isequal( size(adj_list), [nvox_active_in_mask 1] )
  errmsgs{end+1} = 'Zero radius should only include center voxel';
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = try_mask(mask,radius,errmsgs,warnmsgs)

maskname = inputname(1);

sphere_args.radius = radius;
[real_spheres_p_idx scratch real_spheres_mask_idx] = ...
    adj_sphere2(mask,sphere_args);
exclude_center = false;

fprintf('Trying %s mask\n',maskname);

incl_m_idx = find(mask);
nActiveVox = length(incl_m_idx);
nTotalVox = numel(mask);
maskdims = size(mask);
nSpheres = length(real_spheres_p_idx);

if length(incl_m_idx) ~= nSpheres
  error('incl_m_idx and nSpheres don''t match');
end

test_spheres_p_idx = {};
test_spheres_m_idx = {};

v = 1;
% 'm' for 'in terms of mask'
for m=1:nTotalVox

  if mod(m, floor(nTotalVox/10)) == 0
    fprintf('\t%.2f', m/nTotalVox);
  end
  
  if mask(m)

    % we're going to create a test sphere for each of the
    % spheres created by ADJ_SPHERE2 and check that they
    % match up
    [cX cY cZ] = ind2sub(maskdims,m);
    
    nX = maskdims(1);
    nY = maskdims(2);
    nZ = maskdims(3);

    % current sphere for mask voxel m
    test_sphere_m_idx = [];
    
    % go through every voxel in the mask
    for x = 1:nX
      for y = 1:nY
        for z = 1:nZ
          
          % if this point isn't included in the mask, go onto
          % the next one  
          if ~mask(x,y,z)
            continue
          end
          
          % check that this is included in the sphere
          dist = sqrt(sum([ (cX-x)^2 (cY-y)^2 (cZ-z)^2 ]));
          if dist>radius
            continue
          end

          % exclude the center voxel itself
          if exclude_center && dist==0
            continue
          end
          
          % get the voxel's index and add it to this
          % test_sphere's list of voxels
          test_sphere_m_idx(end+1) = sub2ind(maskdims,x,y,z);
        
        end % z
      end % y
    end % x
    
    test_sphere_p_idx = convert_mask_to_pat_idx(mask,test_sphere_m_idx);
    test_spheres_p_idx{end+1,1} = test_sphere_p_idx;
    test_spheres_m_idx{end+1,1} = test_sphere_m_idx;

    p = convert_mask_to_pat_idx(mask,m);
    if p~=v
      error('Something wrong with convert_mask_to_pat_idx()');
    end
    v = v + 1;
    
  end % if mask(m)
  
end % m
disp(' ')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = plot_spheres(mask,test_sphere_m_idx,real_sphere_m_idx,cX,cY,cZ)

maskdims = size(mask);
[test_x test_y test_z] = ind2sub(maskdims,test_sphere_m_idx);
[real_x real_y real_z] = ind2sub(maskdims,real_sphere_m_idx);

excl_sphere_m_idx = find(~mask);
[excl_x excl_y excl_z] = ind2sub(maskdims,excl_sphere_m_idx);

figure(1)
cla
title('Unit test version')
hold on
axis([0 maskdims(1) 0 maskdims(2) 0 maskdims(3)])
view(3)
plot3(test_x,test_y,test_z,'bx');
plot3(cX, cY, cZ, 'go' );
% plot3(excl_x,excl_y,excl_z,'ro');
    
figure(2)
cla
title('Real adj_sphere2 version')
hold on
axis([0 maskdims(1) 0 maskdims(2) 0 maskdims(3)])
view(3)
plot3(real_x,real_y,real_z,'bx');
plot3(cX, cY, cZ, 'go' );
% plot3(excl_x,excl_y,excl_z,'ro');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vec] = remove_zeros(vec)

vec = vec(find(vec));

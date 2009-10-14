function [errmsgs warnmsgs] = unit_create_adj_list(varargin)

% This is a script that tests the adjacency list code.
%
% [ERRMSGS WARNMSGS] = UNIT_GET_ADJACENCY(...)
% 
% INPUT ARGUMENTS:
%
% STDOUT (optional, default = true) If true, prints errors and
% warnings to screen as they occur.
%
% OUTPUT ARGUMENTS: 
%
% ERRMSGS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing
%
% WARNMSGS = cell array, like ERRMSGS, of tests that didn't pass
% and didn't fail (e.g. because they weren't run)


warning(['This function has been deprecated - see' ...
       ' unit_adj_sphere and unit_adj_cuboid']);

defaults.stdout = true;

args = propval(varargin, defaults);

errmsgs = {};
warnmsgs = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare test subject

subj = init_subj('test', 'test');

% simple mask is just all ones
subj = initset_object(subj, 'mask', 'simple', ones(10,10,10));

% complex mask is random shape
m = rand(10,10,10);
subj = initset_object(subj, 'mask', 'complex', double(m >= 0.5));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Positive unit tests

t = 'Simple sphere';
try
  
  % test sphere
  nn = create_adj_list(subj, 'simple');
  radius = 2;
  
  % check distances between points to make sure they fall in sphere
  % of radius 2
  for i = 1:numel(nn)

    if numel(nn{i}) == 0
      err('%s - neighborhood %g has no points!', t, i);
    end
    
    % get 3D coordinates of each voxel in neighborhood
    clear pos;
    [pos(:,1) pos(:,2) pos(:,3)] = ind2sub([10,10,10], nn{i});

    [mypos(1) mypos(2) mypos(3)] = ind2sub([10,10,10], i);
    
    % test the distance between each point
    d = max(pdist(pos, 'euclidean'));
    if (d > 2*radius)
      err('%s - neighborhood %g has points %g apart (radius = %g)', t, ...
          i, d, radius);
    end
    
    % test distance between center and each point
    d = squareform(pdist([mypos; pos], 'euclidean'));
    d = max(d(:,1));
    if (d > radius)
      err('%s - neighborhood %g has points %g from center (radius = %g)', t, ...
          i, d, radius);
    end      
    
  end
  
catch
  err('%s - unexpected error: \n**\n%s\n**\n', t, lasterr);
end

% ------------------------------------------------------------------------

t = 'Simple cuboid';
try
  
  % test sphere
  nn = create_adj_list(subj, 'simple', 'adj_funct', 'adj_cuboid');
  width = 1; % max width of the cuboid
  
  % check distances between points to make sure they fall in the cuboid
  for i = 1:numel(nn)

    % get 3D coordinates of each voxel in neighborhood
    clear pos;
    [pos(:,1) pos(:,2) pos(:,3)] = ind2sub([10,10,10], nn{i});

    [mypos(1) mypos(2) mypos(3)] = ind2sub([10,10,10], i);
    
    % test the distance between each point
    d = max(pdist(pos, 'chebychev'));
    if (d > 2*width)
      err('%s - neighborhood %g has points %g apart (width = %g)', t, ...
          i, d, width);
    end
    
    % test distance between center and each point
    d = squareform(pdist([mypos; pos], 'chebychev'));
    d = max(d(:,1));
    if (d > width)
      err('%s - neighborhood %g has points %g from center (width = %g)', t, ...
          i, d, width);
    end
    
    % test number of neighbors returend
    if ~any(numel(nn{i}) == [8 12 18 27])
      err('%s - neighborhood %g has %g elements', t, i, ...
          numel(nn{i}));
    end
         
  end
  
catch
  err('%s - unexpected error: \n**\n%s\n**\n', t, lasterr);
end

% ------------------------------------------------------------------------

t = 'Complex sphere';
try
  
  % test sphere
  nn = create_adj_list(subj, 'complex');
  radius = 2;
  
  % check distances between points to make sure they fall in sphere
  % of radius 2
  for i = 1:numel(nn)

    % get 3D coordinates of each voxel in neighborhood
    clear pos;
    [pos(:,1) pos(:,2) pos(:,3)] = ind2sub([10,10,10], nn{i});

    [mypos(1) mypos(2) mypos(3)] = ind2sub([10,10,10], i);
    
    % test the distance between each point
    d = max(pdist(pos, 'euclidean'));
    if (d > 2*radius)
      err('%s - neighborhood %g has points %g apart (radius = %g)', t, ...
          i, d, radius);
    end
    
    % test distance between center and each point
    d = squareform(pdist([mypos; pos], 'euclidean'));
    d = max(d(:,1));
    if (d > radius)
      err('%s - neighborhood %g has points %g from center (radius = %g)', t, ...
          i, d, radius);
    end    
    
  end
  
catch
  err('%s - unexpected error: \n**\n%s\n**\n', t, lasterr);
end

% ------------------------------------------------------------------------

t = 'Complex cuboid';
try
  
  % test sphere
  nn = create_adj_list(subj, 'simple', 'adj_funct', 'adj_cuboid');
  width = 1; % max width of the cuboid
  
  % check distances between points to make sure they fall in the cuboid
  for i = 1:numel(nn)

    % get 3D coordinates of each voxel in neighborhood
    clear pos;
    [pos(:,1) pos(:,2) pos(:,3)] = ind2sub([10,10,10], nn{i});

    [mypos(1) mypos(2) mypos(3)] = ind2sub([10,10,10], i);
    
    % test the distance between each point
    d = max(pdist(pos, 'chebychev'));
    if (d > 2*width)
      err('%s - neighborhood %g has points %g apart (width = %g)', t, ...
          i, d, width);
    end
    
    % test distance between center and each point
    d = squareform(pdist([mypos; pos], 'chebychev'));
    d = max(d(:,1));
    if (d > width)
      err('%s - neighborhood %g has points %g from center (width = %g)', t, ...
          i, d, width);
    end
         
  end
  
catch
  err('%s - unexpected error: \n**\n%s\n**\n', t, lasterr);
end

% ------------------------------------------------------------------------

t = 'Nonstandard arguments';

% TODO: Implement some smart tests here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Standard Testing Utility Functions - v2

fprintf('%s: All tests completed.\n\t %d failures, %d warnings.\n', ...
        mfilename, numel(errmsgs), numel(warnmsgs));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = approx(a, b, tolerance)

if abs(a - b) < tolerance
  out = true;
else
  out = false;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function err(varargin) 

testmsg = sprintf(varargin{:});

e = sprintf('Test failed: %s\n', testmsg);
errmsgs{end+1} = e;

if (args.stdout)
  fprintf(e);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function warn(varargin)

warnmsg = sprintf(varargin{:});

w = sprintf('Warning: %s\n', warnmsg);
warnmsgs{end+1} = w;

if (args.stdout)
  fprintf(w);
end

end

end

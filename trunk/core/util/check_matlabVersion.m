function [output] = check_matlabVersion(varargin)
%
% This checks the supplied integers against the current version of matlab
% and returns a -1 if the current version is older, a 0 if they are the
% same and a 1 if they are newer.  If you would like to only test the major
% and minor versions then you can call the function as:
%
%  check_matlabVersion(7,5);
% the function will return the same 3 options, but only utilizing the first
% two pieces of the 4 piece version number.

% cast the matlab version into a series of integers.
[mat_ver(1) mat_ver(2) mat_ver(3) mat_ver(4)] = get_matlabVersion();

newer = 1;
same = 0;
older = -1;


%check major version, if more or less, reply and return
%if (mat_major < major) || (mat_major == major && mat_minor(1)<minor)
%    output = older;
%    return;
%elseif mat_major > major || (mat_major == major && mat_minor(1)>minor)
%    output = newer;
 %   return;
    
%end

% if you've gotten this far the major and leading minor revisions are the
% same.  If there is a supplied vararg then process it, if not simply
% return.

%if nargin < 3
%    output = same;
%    return
%else
%keyboard;

%if nargin > 4
%    nargin = 4
%end

output = same; 
if nargin > 4
    length = 4;
else
    length = nargin;
end

for index = 1:length
   
    if (mat_ver(index) > varargin{index})
        output = newer;
        return
        
    elseif (mat_ver(index) < varargin{index})
        output = older;
        return
    end
    
end

%keyboard;



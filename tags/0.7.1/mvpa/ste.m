function [y] = ste(x,varargin)

% function [y] = ste(x,varargin)
%
% matlab doesn't have a standard error function, but it's easy
% enough to calculate. ste(x) = std(x)/sqrt(n) where n is the
% number of samples
%
% this is just a wrapper function that calls std, and then divides
% by sqrt(size(x,1))
%
% the only functionality i've added is that you can stipulate to
% calculate the std on the 2nd dimension (i.e. the columns), just
% as you can with mean(x,2) or size(x,2). however, you can't tell
% the std to normalise differently - i've left it at the default
% behaviour. let me know if this seems wrong to you - cheers, Greg

if nargin==2
  if varargin{1}==2
    x = x';
  end
end

n = size(x,1);
y = std(x) / sqrt(n);



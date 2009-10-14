function [x] = sample(vec,n)

% [X] = SAMPLE(VEC,N)
%
% Pick N values (X) at random from a vector VEC.
%
% N defaults to 1 if not provided.
%
% If N==0, N is set to 1.


if ~exist('n','var'), n=1; end
if ~n, n=1; end

vec = shuffle(vec);
x = vec(1:n);



function [r] = urandom(type)

if nargin==0
  type = 'int32';
end

f = fopen('/dev/urandom', 'r');
r = fread(f, 1, type);
fclose(f);

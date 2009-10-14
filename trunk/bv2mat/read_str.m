function str = read_str(fid)
% str = read_str(fid)
%
% :description
%
% A utility function that reads a C string from a binary file.
%
% :inputs
%
% fid           file id of file already opened for reading
%
% :outputs
%
% str           string of chars returned
%
% :history
%
% 2004.04.16	Ben Singer  Edited slightly a version received from Sylvain.
% 2004.04.28    Ben Singer  Prepared for release to CSBMB community

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

str = char;
str(1) = fread(fid, 1, 'char');

i = 1;
while str(i)~=0
  i=i+1;
  str(i) = fread(fid, 1, 'char');
end

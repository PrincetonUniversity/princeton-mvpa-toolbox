function [major,minor0,minor1,minor2,revision] = get_matlabVersion()
%
% This is a simple function to return the matlab version as an array of
% integer numbers so that it can be tested against required versions for
% conditional execution.  It returns the full version split into an array.
%
% This function utilizes the 'version' command to retrieve the information
% and returns as such: 7.5.0.338 (R2007b) becomes [7,5,0,338] and can be
% test against as such.
%

%capture the version string
mat_version = explode(version(),'.');

major = uint16(str2num(mat_version{1}));

minor0 = uint16(str2num(mat_version{2}));

minor1 = uint16(str2num(mat_version{3}));

%the last segment will look similar to ### (revision) and the revision must
%be removed
%keyboard;
temp = explode(mat_version{4},' ');

minor2 = uint16(str2num(temp{1}));

revision = temp{2};
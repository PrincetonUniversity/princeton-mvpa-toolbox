function [results] = addresultsheader(results,head_str,varargin)
% [results] = addresultsheader(results,head_str,varargin)
%
% adds a line to the results.header field containing the string
% head_str. creates the header field if it doesn't exist
%
% if varargin == true, displays the text as well

if ~exist('results')
  warning( 'no results structure exists - cannot add line to header' );
  return
end

disphead = false;
if nargin==3
  if varargin{1} == true
    disphead = true;
  end
end
  
if isfield(results,'header')==0
  results.header=[];
end

headLen = length(results.header);

results.header{headLen+1}=head_str;

if disphead
  disp(head_str);
end


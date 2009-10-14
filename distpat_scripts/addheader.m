function [subj] = addheader(subj,head_str,varargin)
% [subj] = addheader(subj,head_str)
%
% adds a line to the header.history field containing the string
% head_str
%
% if varargin == true, displays the text as well

disphead = false;
if nargin==3
  if varargin{1} == true
    disphead = true;
  end
end
  

if isfield(subj,'header')==0
  subj.header.history=[];
end
if isfield(subj.header,'history')==0
  subj.header.history=[];
end
  
headLen = length(subj.header.history);

subj.header.history{headLen+1}=head_str;

if disphead
  disp(head_str);
end

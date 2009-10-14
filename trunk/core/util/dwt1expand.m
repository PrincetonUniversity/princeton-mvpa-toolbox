function [ labels ] = dwt1expand(l)

labels = [];
for i = 1:numel(l)-1 
  labels(end+1:end+l(i)) = i;  
end
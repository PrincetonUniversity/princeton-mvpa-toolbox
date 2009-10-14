function [subj] = anovaVox(subj,varargin)
% function [subj] = anovaVox(subj,mem)
% This script steps through all of the voxels and do an 
% ANOVA on each. 
% 
% if mem==1, be memory efficient, erases subj structure in calling
% workspace.
%
% Uses: anova(x,group,'off')
%
% To get anova to run, set subj.args fields as follows:
% 
% subj.args.anova_conds - which conditions is the anova run on.
%                         results are applied to all conditions.
%                         Example: [1 3 4]
% subj.args.anova_pcrit - voxels with p's larger will be removed.
%
% 
% THIS VERSION IS 11/15/04

if nargin==2
  if varargin{1}==1
    disp( sprintf('\terasing subj in caller workspace') );
    assignin('caller','subj',[]);    
  end
end

disp('starting anovaVox1');

[nVox nTRs] = size(subj.data);
nCats = size(subj.regressors,2);

conds = subj.args.anova_conds;
pcrit = subj.args.anova_pcrit;

% break up the data by cats
dataIdx = [];
groups = [];

for c=1:length(conds)
  thisCond = conds(c);
  theseIdx = find(subj.regressors(:,thisCond)==1);
  dataIdx=[dataIdx,theseIdx];
  groups=[groups,repmat(thisCond,1,length(theseIdx))];
end

% run the anova and save the p's
p=zeros(nVox,1);
for j=1:nVox

  if mod(j,10000) == 0
    disp( sprintf('anova on %i of %i',j,nVox) );
  end

  p(j) = anova1(subj.data(j,dataIdx),groups,'off');
  
end      

% remove the nVoxels with p's larger than pcrit
subj.data(find(p>pcrit),:)=[];

% remove the corresponding entries in the mask indices
subj.mask.idx(find(p>pcrit))=[];
subj.mask.coords(find(p>pcrit))=[];
subj.mask.nVox=size(subj.data,1);

% add the p-vals of all the nVox that passed
subj.mask.pvals=p(find(p<=pcrit));

% add a remark in the header
head = sprintf('anova mask, pcrit=%.2f, nVox=%i - %s',pcrit,subj.mask.nVox,date);
disp(head);
subj = addheader(subj,head);

      

function [subj] = average_object(subj,objtype,objname,labels_name,varargin)

% Averages together all the sets of TRs with the same LABELS identifier
%
% [SUBJ] = AVERAGE_OBJECT(SUBJ,OBJTYPE,OBJNAME,LABELS_NAME,...)
% 
% Adds the following objects:
% - pattern object PATNAME_avg
%
% This averages all the OBJTYPE OBJNAME TRs that have the same
% LABELS identifier to create a new averaged object. For instance,
% run CREATE_BLOCKLABELS.M first on your regressors to find all the
% TRs from a given condition in a given run, and then use the
% selector LABELS_NAME it creates here.
%
% NEW_OBJNAME (optional, default = OBJNAME_avg)


% Deal with the optional arguments
defaults.new_objname = sprintf('%s_avg',objname);
args = propval(varargin,defaults);

labels = get_mat(subj,'selector',labels_name);

objnames = find_group_single(subj,objtype,objname);

for m=1:length(objnames)

  cur_objname = objnames{m};
  
  % Do the averaging, using the unique identifiers for each block in
  % LABELS to decide which clumps get averaged together
  mat = get_mat(subj,objtype,cur_objname);
  
  matavg = do_avg(mat,labels);

  % Book-keeping
  subj = duplicate_object(subj,objtype,cur_objname,args.new_objname,'transfer_group_name',true);
  subj = set_mat(subj,objtype,args.new_objname,matavg,'ignore_diff_size',true);

  created.function = mfilename;
  created.labels_name = labels_name;
  created.args = args;
  subj = add_created(subj,objtype,args.new_objname,created);
  
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [matavg] = do_avg(mat,labels)

matavg = [];

if size(mat,2) ~= length(labels)
  error('Matrix to be averaged is different size to labels');
end

for b=unique(labels)
  curblock = find(labels==b);
  curmat = mat(:,curblock);
  meanmat = mean(curmat,2);
  matavg = [matavg meanmat];
end % b nLabels



function [subj] = average_object(subj,objtype,objname,labels_name,varargin)

% Averages together all the sets of TRs with the same LABELS identifier
%
% [SUBJ] = AVERAGE_OBJECT(SUBJ,OBJTYPE,OBJNAME,LABELS_NAME,...)
% 
% See https://compmem.princeton.edu/mvpa_docs/TutorialAvg
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
%
% WARN_INT_CORRUPTED (optional, default = true). By default, will warn
% you if your data consisted of integers, but the newly-averaged data
% does not. Set this to false if you don't care when that
% happens. N.B. This is actually quite memory-intensive, and so this
% check may be skipped if it causes an out-of-memory error.
%
% This should check to make sure that the averaging
% doesn't span runs

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


% Deal with the optional arguments
defaults.new_objname = sprintf('%s_avg',objname);
defaults.warn_int_corrupted = true;
args = propval(varargin,defaults);

labels = get_mat(subj,'selector',labels_name);

objnames = find_group_single(subj,objtype,objname);

for m=1:length(objnames)

  cur_objname = objnames{m};
  
  % Do the averaging, using the unique identifiers for each block in
  % LABELS to decide which clumps get averaged together
  mat = get_mat(subj,objtype,cur_objname);
  
  matavg = do_avg(mat,labels,args);
  clear mat

  % Book-keeping
  subj = duplicate_object(subj,objtype,cur_objname,args.new_objname,'transfer_group_name',true);
  subj = set_mat(subj,objtype,args.new_objname,matavg,'ignore_diff_size',true);

  created.function = mfilename;
  created.labels_name = labels_name;
  created.args = args;
  subj = add_created(subj,objtype,args.new_objname,created);
  
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [matavg] = do_avg(mat,labels,args)

matavg = [];

if size(mat,2) ~= length(labels)
  error('Matrix to be averaged is different size to labels');
end

% Figure out what labels we have, excluding zero
unique_labels = unique(labels);
unique_labels(find(unique_labels==0)) = [];

for b=unique_labels
  curblock = find(labels==b);
  curmat = mat(:,curblock);
  meanmat = mean(curmat,2);
  matavg = [matavg meanmat];
end % b nLabels
% let's clear up, to save memory
clear curmat meanmat

% it looks like ISINT is actually pretty memory-intensive, so be
% prepared to run out of memory and fail here
try
  % give the user a warning if the previous data consisted
  % of integers, but the averaged data does not (since this
  % is often an error)
  if args.warn_int_corrupted
    if isint(mat) & ~isint(matavg)
      warning('Previously integer data may have been corrupted')
    end % look for corruption
  end % does the user want us to warn them of corruption?
catch
  warning('Unable to run WARN_INT_CORRUPTED because we ran out of memory - does not necessarily indicate a problem with the data')
end

  


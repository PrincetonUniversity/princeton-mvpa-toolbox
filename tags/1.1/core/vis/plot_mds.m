function [mds] = plot_mds(subj,patname,regsname,varargin)

% Plots a multi-dimensional scaling of a pattern
%
% [mds] = PLOT_MDS(SUBJ,PATNAME,REGSNAME,VARARGIN)
% 
% This is designed to help you visualise the patterns of your data. it
% does an MDS (see 'cmdscale') on the PATSNAME data, returning a
% matrix with all of your observations in a different
% dimensionality. The smaller the number of dimensions, the better.
%
% ACTIVES_SELNAME (optional, default = ''). If empty, then this
% doesn't censor any individual TRs. If, however, you do want to use a
% temporal mask selector to exclude some TRs, feed in the name of a
% boolean selector. This will cause those TRs be ignored by later
% scripts. such as the no-peeking ANOVA or a cross-validation
% classifier
%
% Note: the comments below are from the old version and may be out
% of date
% 
% PLOT_EIGENS (optional, default = true). Turn ploteigens on to
% visualise how the eigenvalues drop off - what you want is for the
% first couple to be high, and then for it to drop off fast. that
% would mean that the first couple of dimensions fit your data pretty
% well, and the rest are mopping up the noise. you really need to be
% visualising the eigenvalues up until the elbow/crook (where the
% curve starts to plateau). PLOTEIGENS only works for cmdscale, since
% mdscale seems to only return a scalar stress value
%
% the aim of this is to see whether the prototype brain states for
% each of your conditions are far away from each other, and ideally,
% whether they reflect the psychological space of your experiment
% (i.e. similar conditions near each other, dissimilar conditions
% further away)
%
% DIMS (optional, default = [1 2 3]). Allows you to specify which of
% your MDS dimensions to visualise. it should be a vector of length 2
% or 3 (if you want a 3d plot). if you leave it empty, it will default
% to [1 2 3]
%
% regs should be to be a normal 1-of-n regressor matrix - just use
% 'subj.regressors' if in doubt. this is useful though if your
% experiment has special regressor types, some of which aren't in
% 1-of-n form
%
% mds should be an empty matrix the first time you run this. if you
% want to run it multiple times visualising different dimensions, then
% you can feed in the mds you get out to save having to recalculate it
% constantly
%
% I never added in the temp_mds functionality, but the idea was that
% if you've just run the mds, and want to display it again (with the
% points this time, for example), then you could just feed in the
% results from last time and it would just do the plotting for you. It
% would mean separating the mds'ing from the plotting, and skipping
% the mds'ing if temp_mds isn't empty.
%
% The main difference so far from plotmds (original version) is that
% i've changed where it looks for the condnames and condcols
%
% MDS_TYPE (optional, default = 'cmdscale'). Allows you to specify
% whether to do 'cmdscale' or 'mdscale' - defaults to cmdscale (which
% creates as many dimensions as it needs). if you set OPT.mds_type to
% 'mdscale', then it needs to know how many dimensions you want - it
% uses the length of your dims to determine that, so you're best off
%
% PLOT_POINTS (optional, default = true).

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

defaults.dims = [1 2 3];
defaults.mds_type = 'cmdscale';
defaults.actives_selname = '';
defaults.plot_eigens = true;
defaults.plot_points = true;
args = propval(varargin,defaults);

% The MDS needs the pat to be transposed
pat = get_mat(subj,'pattern',patname);
regs = get_mat(subj,'regressors',regsname);

if isempty(args.actives_selname)
  actives = ones([1 size(regs,2)]);
else
  actives = get_mat(subj,'selector',args.actives_selname);
end

nVox = size(pat,1);
[nConds nTRs] = size(regs);
condcols = jet(nConds);
condnames = get_objfield(subj,'regressors',regsname,'condnames');

pat = pat(:,find(actives));
mdspat = pat';
regs = regs(:,find(actives));

nDims = length(args.dims);

disp('Calculating pdist');
mds.dists = pdist(mdspat, 'euclidean' );
disp('Assembling into square matrix');
mds.squaremds.dists = squareform(mds.dists);
disp( sprintf('About to start %s',args.mds_type) );

switch args.mds_type
  case 'cmdscale'
   [mds.mat, mds.eigens] = cmdscale(mds.squaremds.dists);
 case 'mdscale'
   [mds.mat mds.stresses mds.disparities] = mdscale(mds.squaremds.dists,nDims);
end
disp('Finished mds');

nMdsDims = size(mds.mat,2);
if max(args.dims)>nMdsDims
  warning('trying to visualise a higher dimension than exists in the MDS matrix - defaulting to 1st, 2nd and 3rd instead');
  args.dims = [1 2 3];
end

mds.centre = mean(mds.mat,1);
mds.x_centre = mds.centre(1);
if nDims>=2
  mds.y_centre = mds.centre(2);
end
if nDims>=3
  mds.z_centre = mds.centre(3);
end

for i=1:nConds
  mds.cond{i} = find(regs(i,:)==1);
  curcond_idx = mds.cond{i};
  curcond_mat = mds.mat(curcond_idx,:);
  mds.mat_avg(i,:) = mean(curcond_mat,1);
end

switch nDims
 case 0
  plot3d = true;
  args.dims = [1 2 3];
  nDims = 3;
  mds.x = mds.mat(:,1);
  mds.y = mds.mat(:,2);
  mds.z = mds.mat(:,3);
  mds.xlabel = sprintf('%i',1);
  mds.ylabel = sprintf('%i',2);
  mds.zlabel = sprintf('%i',3);
  mds.x_avg = mds.mat_avg(:,1);
  mds.y_avg = mds.mat_avg(:,2);
  mds.z_avg = mds.mat_avg(:,3);

 case 1
  plot3d = false;
  mds.x = mds.mat(:,args.dims(1));
  mds.y = ones(size(mds.x));
  mds.xlabel = sprintf('%i',args.dims(1));
  mds.ylabel = 'No 2nd dimension';
  mds.x_avg = mds.mat_avg(:,args.dims(1));
  mds.y_avg = ones(size(mds.x_avg));
  
 case 2
  plot3d = false;
  mds.x = mds.mat(:,args.dims(1));
  mds.y = mds.mat(:,args.dims(2));
  mds.xlabel = sprintf('%i',args.dims(1));
  mds.ylabel = sprintf('%i',args.dims(2));
  mds.x_avg = mds.mat_avg(:,args.dims(1));
  mds.y_avg = mds.mat_avg(:,args.dims(2));

 case 3
  plot3d = true;
  mds.x = mds.mat(:,args.dims(1));
  mds.y = mds.mat(:,args.dims(2));
  mds.z = mds.mat(:,args.dims(3));
  mds.xlabel = sprintf('%i',args.dims(1));
  mds.ylabel = sprintf('%i',args.dims(2));
  mds.zlabel = sprintf('%i',args.dims(3));
  mds.x_avg = mds.mat_avg(:,args.dims(1));
  mds.y_avg = mds.mat_avg(:,args.dims(2));
  mds.z_avg = mds.mat_avg(:,args.dims(3));
 otherwise
  error('too many or too few args.dims - can only deal with 2 or 3');
end
mds.args.dims = args.dims;

if args.plot_eigens & strcmp(args.mds_type,'cmdscale')
  nEigens = size(mds.mat,2);
  figure
  hold on
  plot(mds.eigens(1:nEigens));
  for i=1:nDims
    plot(args.dims,mds.eigens(args.dims(i)),'r.');
  end % i nDims
  title( sprintf('Eigenvalues - plotting %s from %i dimensions', ...
		 num2str(args.dims),nEigens) );
end

titleinfo = sprintf('Plotting %s dimensions %s [subj%s obj %s]', ...
		    args.mds_type,num2str(args.dims),subj.header.id,patname);

figure
if plot3d
  hold on
  for i=1:nConds
    curcol = condcols(i,:);
    curcond = mds.cond{i};
    if args.plot_points
      plotpoints = plot3(mds.x(curcond), mds.y(curcond),mds.z(curcond),'.');
      set(plotpoints,'MarkerFaceColor',curcol);
      set(plotpoints,'MarkerEdgeColor',curcol);
    end
    plotavg = plot3(mds.x_avg(i),mds.y_avg(i),mds.z_avg(i),'ko');
    set(plotavg,'MarkerEdgeColor',curcol);
    set(plotavg,'MarkerSize',20);
    label = text(mds.x_avg(i),mds.y_avg(i),mds.z_avg(i),condnames{i});
    set(label,'Color',curcol);
  end % i nConds
  xlabel( sprintf('dim %s',mds.xlabel) );
  ylabel( sprintf('dim %s',mds.ylabel) );
  zlabel( sprintf('dim %s',mds.zlabel) );
  title(titleinfo);

  % plotbullseye = plot3(mds.x_centre,mds.y_centre,mds.z_centre,'kx');
  % set(plotbullseye,'MarkerSize',20);

else % plotting 2d
  for i=1:nConds
    hold on
    curcol = condcols(i,:);
    curcond = mds.cond{i};
    if args.plot_points
      plotpoints = plot(mds.x(curcond), mds.y(curcond),'.');
      set(plotpoints,'MarkerFaceColor',curcol);
      set(plotpoints,'MarkerEdgeColor',curcol);
    end
    plotavg = plot(mds.x_avg(i),mds.y_avg(i),'ko');
    set(plotavg,'MarkerEdgeColor',curcol);
    set(plotavg,'MarkerSize',20);
    label = text(mds.x_avg(i),mds.y_avg(i),condnames{i});
    set(label,'Color',curcol);
  end % i nConds
  
  xlabel( sprintf('dim %s',mds.xlabel) );
  ylabel( sprintf('dim %s',mds.ylabel) );
  title(titleinfo);
  
  % plotbullseye = plot(mds.x_centre,mds.y_centre,'kx');
  % set(plotbullseye,'MarkerSize',20);

end % if plot3d



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mds_type condcols condnames] = sanity_check(subj,regs,opt,dims)

[nConds nTRs] = size(regs);

switch opt.mds_type
 case 'cmdscale'
  mds_type = 'cmdscale';
 case 'mdscale'
  mds_type = 'mdscale';
 otherwise
  error('Unknown mds_type');
end

if isfield(subj.args,'condcols')
  condcols = subj.args.condcols;
else
  if isfield(subj.header,'condcols')
    condcols = subj.header.condcols;
  else
    condcols = jet(nConds);
  end
end

if isfield(subj.args,'condnames')
  condnames = subj.args.condnames;
else
  if isfield(subj.header,'condnames')
    condnames = subj.header.condnames;
  else
    for i=1:nConds
      condnames{i} = num2str(i);
    end
  end
end

if ~isvector(dims) | ~isnumeric(dims)
  error('dims has to be a vector of numbers referring to the mds dimensions you want to visualise - [1 2 3] makes most sense');
end

if length(dims)>3
  error('Can''t deal with more than three dimensions');
end

if strcmp(mds_type,'mdscale')
  if all(diff(dims)==1) & dims(1)==1
    nDims = length(dims);
    disp( sprintf('This will be a %i-dimensional mdscale',nDims) );
  else
    dimwarn = sprintf('Your mdscale dimensions aren''t contiguous and starting at 1... Assuming %i-dimensional',nDims);
    warning(dimwarn);
  end
end

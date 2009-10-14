function [clustmask] = make_clust(mask,clust_size,args)

% Removes singletons from a mask
%
% [clustmask] = make_clust(mask,clust_size,args)

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


[maxx maxy maxz]= size(mask);

% get the coordinates of the voxels that are present in the mask.
[x y z] = ind2sub([maxx ,maxy, maxz],find(mask));

clustmask = zeros(size(mask));

if args.do_plot
  figure
  [notx noty notz] = ind2sub([maxx ,maxy, maxz],find(mask==0));
  % blue = present, red = absent
  plot3(x ,y, z,'b*', notx,noty,notz,'r*');
end

% no. of voxels 
nVox = length(find(mask));

% now that we have the x y and z coordinates of the voxels we can
% now start searching if their neighbours exist. 

% in the future, we may want to add the option to change
% the radius to be higher, to count the number of
% neighbours within a larger cube. we haven't tested
% this for radius > 1. strictly speaking, this isn't the
% 'radius' (since radius of 1 includes diagonals, whose
% distance = (1^2 + 1^2 + 1^2))
radius = 1;

for v=1:nVox
  % will count the number of active neighbours for this voxel
  cnt=0;

  for newx=-radius:radius
    for newy=-radius:radius
      for newz=-radius:radius	

	% exclude the central voxel. also exclude voxels
        % whose coordinates are <= 0 or > size(mask) because
        % they'd be outside the volume
	if ( ~(newx==0 && newy==0 && newz==0) &&  ~((x(v)+newx)<=0 || (y(v)+newy)<=0 || (z(v)+newz)<=0 ) &&  ~((x(v)+newx)> maxx || (y(v)+newy)> maxy || (z(v)+newz)> maxz))
	  cnt = cnt + mask((x(v)+newx),(y(v)+newy),(z(v)+newz));
	end
      end
    end
  end
  
  if cnt>=clust_size
    clustmask(x(v), y(v), z(v)) = 1;  
  end  
end 

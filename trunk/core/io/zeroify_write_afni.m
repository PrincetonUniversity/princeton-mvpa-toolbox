function [] = zeroify_write_afni(allvols,sample_brik_name,new_brik_name,varargin)

% Writes out BRIKs using the zeroifying method
%
% [] = ZEROIFY_WRITE_AFNI(ALLVOLS,SAMPLE_BRIK_NAME,NEW_BRIK_NAME, ...)
%
% This takes in one or more volume's worth of data (x y z t)
% and the filenames for the BRIK/HEAD pair that you want to
% use as your template (SAMPLE_BRIK_NAME), and then writes
% out to NEW_BRIK_NAME .BRIK and .HEAD.
%
% As usual, the hard work is being done by Ziad Saad's
% WriteBrik function. Incorporates Rick Reynolds' advice for
% creating the allzeros sample brik
% (http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=6385&t=6385).
% This is called within WRITE_TO_AFNI.M, and there shouldn't really
% be any need to call this directly.
%
% AFNI_LOCATION (optional, default = ''). In case you need
% to prepend the AFNI path because it's not in the
% environment path.
%
% VIEW (optional, default = '+orig')
%
%   zeroify_write_afni(zeros([64 64 32]),'experim+orig','experim')
%   zeroify_write_afni(zeros([64 64 32]),'experim+tlrc','experim','view','+tlrc')
%
% TR_DUR (optional, default = 2). The length of the TR in seconds.

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


% read in sample brik and save header info
% turn sample brik into all zeros of correct size
% overwrite with allvols
% call WriteBrik
% run AFNI to visualise things


defaults.view = '+orig';
defaults.afni_location = '';
defaults.tr_dur = 2;
args = propval(varargin,defaults);

disp('Beginning the export to afni');

[allvols args nTimepoints] = sanity_check(allvols,sample_brik_name,new_brik_name,args);

[allvolszeros_sample_brik_name] = zeroify_sample_brik(sample_brik_name,nTimepoints,args);

[V head] = load_sample_brik(allvolszeros_sample_brik_name,allvols);
% generate new values for header file from data
BRICK_STATS = [];
BRICK_LABS = '';
for t = 1:nTimepoints
    b = length(BRICK_STATS)+1;
    vol = allvols(:,:,:,t);
    BRICK_STATS(b) = min(min(min(vol)));
    BRICK_STATS(b+1) = max(max(max(vol)));
    if t ~= nTimepoints
        BRICK_LABS = [BRICK_LABS '#' num2str(t-1) '~'];
    else
        BRICK_LABS = [BRICK_LABS '#' num2str(t-1)];
    end
end
BRICK_TYPES = ones(1,nTimepoints);
BRICK_FLOAT_FACS = zeros(1,nTimepoints);

% assign new values to header file struct
if nTimepoints > 1
  % i think the 3rd value in TAXIS_NUMS should be set to 77002 for
  % 'seconds'. see:
  % 
  %   http://afni.nimh.nih.gov/pub/dist/src/README.attributes
  %   http://grommit.lrdc.pitt.edu/fiswidgets/fisdocs/docs/Afni3dAttribute.html
  head.TAXIS_NUMS = [nTimepoints 0 77002];
  head.TAXIS_FLOATS = [0 args.tr_dur 0 0 0];
end
head.DATASET_RANK(2) = nTimepoints;
head.BRICK_STATS = BRICK_STATS;
head.BRICK_TYPES = BRICK_TYPES;
head.BRICK_FLOAT_FACS = BRICK_FLOAT_FACS;
head.BRICK_LABS = BRICK_LABS;

brikopt = create_brikopt(args,new_brik_name,args.view,V,nTimepoints);

info = write_new_brik(allvols,head,brikopt);

disp( sprintf('Now run afni and use %s as your overlay',new_brik_name) );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allvols args nTimepoints] = sanity_check( ...
    allvols,sample_brik_name,new_brik_name,args);

% does a bunch of simple checks

if isempty(allvols)
  error('The matrix you''ve fed in is empty');
end

if length(find(allvols))==0
  warning('The 4D matrix you''re trying to write is all zeros');
end

switch(ndims(allvols))
 case 3
  nTimepoints = 1;  
 case 4
  nTimepoints = size(allvols,4);
 otherwise
  error('You''ve fed in a matrix that doesn''t have 3 or 4 dimensions to write out');
end

if ~isfield(args,'view')
  args.view = '+orig';
  disp( sprintf('\tdefaulting to +orig view') );
end

% BrikLoad will fail if the sample brik doesn't exist, so i'm not
% going to bother checking for it

if filexist( sprintf('%s%s.BRIK',new_brik_name,args.view) )
  disp( sprintf('\t%s exists - deleting in 5 secs unless you press Ctrl-C',new_brik_name) );
  pause(5)
  unix( sprintf('\trm -f %s%s.BRIK',new_brik_name,args.view) );
  unix( sprintf('\trm -f %s%s.HEAD',new_brik_name,args.view) );
  disp( sprintf('\tdeleted %s .BRIK and .HEAD',new_brik_name) );
end


% disp('Passed sanity check');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [avz_sbn] = zeroify_sample_brik(sbn,nTimepoints,args)

% sbn = sample_brik_name
% avz_sbn = allvolszeros_sample_brik_name
avz_sbn = sprintf('allvolszeros_%s',sbn);

if filexist( sprintf('%s.BRIK',avz_sbn) )
  disp( sprintf('\t%s exists - deleting in 5 secs unless you press Ctrl-C',avz_sbn) );
  pause(5)
  disp( sprintf('\tDeleting %s .BRIK and .HEAD',avz_sbn) );
  unix( sprintf('\trm -f %s.BRIK',avz_sbn) );
  unix( sprintf('\trm -f %s.HEAD',avz_sbn) );
end

disp('Calling 3dcalc to create new all-zeros sample brik');

command_3dcalc = fullfile(args.afni_location,'3dcalc');

% this is the actual call that takes the sample brik, and writes out a new
% BRIK containing all zeros, with the number of timepoints ranging
% from 0..nTimepoints-1 (which works out as just zero if
% nTimepoints==1
exec = sprintf('%s -a %s''[0..%i]'' -expr 0 -datum float -prefix %s', ...
	       command_3dcalc,sbn,nTimepoints-1,avz_sbn);
[status results] = unix(exec);

if status
  disp( sprintf('Output from shell command for zeroifying sample brik:\n%s',results) );
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V head] = load_sample_brik(sample_brik_name,allvols)

[err,V,head,err_message] = BrikLoad(sample_brik_name);
if err
  error(sprintf('error in BrikLoad -%s',err_message));
end

%disp(size(allvols));
%disp(size(V));

allvols_sz = size(allvols);
v_sz = size(V);
allvols_sz = allvols_sz(1:3);
v_sz = v_sz(1:3);

if sum(allvols_sz==v_sz)~=length(allvols_sz)
%if ~compare_size(allvols,V)
  error('Size of allvols is different from size of sample BRIK');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [brikopt] = create_brikopt(opt,new_brik_name,view,V,nTimepoints)

if isfield(opt,'NoCheck')
  NoCheck = opt.NoCheck;
else
  NoCheck = 0;
end

brikopt = [];
brikopt.Prefix = new_brik_name;
brikopt.Scale = 1; % from polyn/freerec_scripts/writeColormap
brikopt.View = opt.view; % from writeColormap
brikopt.verbose = 1;
brikopt.AppendHistory = 1;
brikopt.NoCheck = NoCheck; % 0 is full checking
brikopt.Frames = 1:nTimepoints; % is frames the number of TRs???
brikopt.Slices = (1:size(V,3)); % is slices the third dimension???
disp('Check that the brikopt frames and especially slices are right');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [info] = write_new_brik(allvols,head,brikopt)

[err err_message info] = WriteBrik(allvols,head,brikopt);
if err
    error(sprintf('error in WriteBrik -%s',err_message));
end


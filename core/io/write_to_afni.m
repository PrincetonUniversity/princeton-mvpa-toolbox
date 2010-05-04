function [] = write_to_afni(subj,objtype,objin,sample_filename,varargin)

% Writes an object to a file, using the header info from a specified file.
%
% [] = WRITE_TO_AFNI(SUBJ,OBJTYPE,OBJIN,SAMPLE_FILENAME,...)
%
% Writes an object in subject structure SUBJ, of type
% OBJTYPE to a file. OBJIN specifies the name of the object
% to write to BRIK; it must be a char. SAMPLE_FILENAME must
% currently be included to steal HEAD info from. This should
% ideally correspond to the data. If you can choose a
% SAMPLE_FILENAME that took part in the creation of the
% object, do so. If a pattern was created by concatenating
% multiple files, it makes no difference which is specified
% by SAMPLE_FILENAME. Currently, the difficulties in
% specifying a mask BRIK when writing a pattern OBJIN are
% minimal (ie., mislabeling the type of the object as FIM,
% not ORIG).
%
% N.B. At the moment, the script may balk if you try and use
% a sample BRIK that doesn't exist in the current directory,
% so don't try and feed in a sample brik path
% (e.g. afni/mybrik.BRIK)
%
% OUTPUT_FILENAME (optional, default = OBJIN) - the prefix
% of the BRIK to be saved.  This can be a filename, a group
% prefix, or a cell array of object names, and must
% correspond to the form of OBJIN. If this is left out, the
% prefix of the BRIK will be OBJIN.
%
% PATHNAME (optional, default = ''). If you want to put the
% OUTPUT_FILENAMES files somewhere other than the working
% directory, e.g. 'afni'
%
% RUNSNAME (optional, default = all ones) - a selector name that
% specifies run info. Writes a BRIK for each run of
% data. Checks to make sure the number of TRs in runsname is the
% same as the number in the pattern, and adjusts to
% compensate if the pattern has only 1 TR (i.e. is a
% statmap).
%
% OVERWRITE_IF_EXIST (optional, default = false). If you
% want to overwrite any existing briks with the same name,
% set this to true, otherwise you'll get an error
%
% DISPLAY_AFNI (optional, default = false)
%
% ONEMINUS (optional, default = false). If false, does
% nothing. If true, this will write out 1-M (where M is your
% matrix). This is useful if you're writing out an anova
% statmap of p values, where low is better. 1-p will reverse
% things so that higher is better when you write it out for
% convenience. Note: this has been tweaked so that zero
% values stay as zero
%
% CHECKBRIKHEAD (optional, default = true).
%
% ONLY_DO_ZEROIFY (optional, default = true). If true, skip
% spoofing and try the zeroifying method directly. The
% default should be fine. N.B. This used to be called
% just 'DO_ZEROIFY', but was renamed for clarity.
%
% DO_ZEROIFY (deprecated - see ONLY_DO_ZEROIFY).
%
% VIEW (optional, default = '+orig') you can change this if
% you want to write to +tlrc.
%
% TR_DUR (optional, default = 2). The length of the TR in seconds.
%
% - add option to create a singles 4D matrix

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


[objnames isgroup] = find_group_single(subj,objtype,objin);

defaults.output_filename = objin;
defaults.pathname = '';
defaults.runsname = [];
defaults.overwrite_if_exist = false;
defaults.display_afni = false;
defaults.oneminus = false;
defaults.checkbrikhead = true;
defaults.only_do_zeroify = true;
% this is only here as a test to warn the user that this
% argument has been renamed 'ONLY_DO_ZEROIFY'.
defaults.do_zeroify = [];
defaults.afni_location = '';
defaults.view = '+orig';
defaults.tr_dur = 2;
args = propval(varargin,defaults);

if ~strcmp(class(objin),'char') | ~strcmp(class(args.output_filename),'char')
    error('write_to_afni only writes one object at a time.');
end

if ~isempty(args.do_zeroify)
  error('DO_ZEROIFY argument has been renamed ONLY_DO_ZEROIFY.')
end

args.tr_dur = double(args.tr_dur);

spoof_failed = false;

if ~args.do_zeroify
  try
    % spoofing approach
    %
    % This is in contrast to the zeroify approach, which makes an
    % all-zeros copy of the entire sample file (both HEAD and BRIKs),
    % and then fills it with our data.
    
    try_spoof(subj,objtype,objin,sample_filename,args);
    
  catch
    disp('Problem using spoofing write method - trying again with zeroifying - you can safely ignore this message and the following error stack');
    
    spoof_failed = true;
    
    spoof_err = lasterror;
    disp(spoof_err.message);

  end % end try/catch
  
end

% only run the zeroify stuff if args.only_do_zeroify is set
% to true, OR if the spoofing method has already been
% unsuccessfully tried
if args.only_do_zeroify | spoof_failed
  
  if length(args.runsname)
    r = get_mat(subj,'selector',args.runsname);
    runTRs = get_run_TRs(r);
  else
    runTRs = {ones(size(get_mat(subj,objtype,objin),2))};
  end
  
  try_zeroify(subj,objtype,objin,sample_filename,args,runTRs);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = try_spoof(subj,objtype,objin,sample_filename,args)

% This will try the spoofing approach, where we create our own
% header, i.e. it will create fresh new header information, using
% the sample_filename HEAD file as a guide. This is cleaner, but
% only works some of the time (cos WriteBrik checks the header we
% create and finds it wanting for all sorts of interesting and
% inscrutable reasons)


[objnames isgroup] = find_group_single(subj,objtype,objin);

if ischar(args.output_filename)
  args.output_filename = {args.output_filename};
end

% Add the path to each output filename
for o=1:length(args.output_filename)
  output_pathfilenames{o} = fullfile(args.pathname,args.output_filename{o});

  if args.overwrite_if_exist
    curfilebrik = sprintf('%s%s.BRIK',output_pathfilenames{o},args.view);
    curfilehead = sprintf('%s%s.HEAD',output_pathfilenames{o},args.view);
    
    if exist(curfilebrik,'file')
      disp( sprintf('Deleting %s',curfilebrik) );
      disp( sprintf('Deleting %s',curfilehead) );
      delete(curfilebrik);
      delete(curfilehead);
    end
  end
end

% Error Checking: Cannot output multiple files w/ run info
if length(unique(args.runsname)) > 1 && length(objnames) > 1
  error('Cannot pass ARGS.RUNSNAME w/ multiple object names');
end
  
% Load the Brik Info
[err, Info] = BrikInfo(sample_filename);
if err
  error('Could not load BRIK info');
end
OrigInfo = Info;

% now we need to figure out how many timepoints there are,
% so we can write it into the BRIK metadata
matsize = get_objfield(subj,objtype,cur_objname,'matsize');
nTimepoints = matsize(2)

% Set the output format
switch objtype
case 'pattern'
    Info.TypeName    = 'float';
    Info.TypeBytes   = 3;
    Info.BRICK_TYPES = 3;
    ispattern = 1;
    Info.TYPESTRING = '3DIM_HEAD_ANAT';
    % see ZEROIFY_WRITE_AFNI for more info on these arguments
    Info.TAXIS_NUMS = [nTimepoints 0 77002];
    Info.TAXIS_FLOATS = [0 args.tr_dur 0 0 0];
case 'mask'
    Info.TypeName      = 'short';
    Info.TypeBytes     = 1;
    Info.BRICK_TYPES   = 0;
    Info.TAXIS_NUMS    = [];
    Info.TAXIS_OFFSETS = [];
    ispattern = 0;
end

for i=1:length(objnames)
  
  cur_objname = objnames{i};

  % Load the data
  d = get_mat(subj,objtype,cur_objname);
  dDim = size(d);
  
  % Determine the runs to be outputed
  if ispattern
    if isempty(args.runsname)
      runs = ones(1,dDim(2));
      if prod(dDim) > 1000000
	warning(['You''re trying to save a mighty large file... There' ...
		 ' may be a memory constraint']);
      end
      
    else
      runs = get_mat(subj,'selector',args.runsname);
      if length(runs) ~= dDim(2);
        if dDim(2) == 1
            runs = 1;
            warning('Ignoring RUNSNAME selector because pattern is a statmap.');
        else
            error('RUNSNAME selector does not match dataset length');
        end
      end
    end
  else
    runs = 1;
  end
  
  for j=unique(runs(find(runs)))
  
    if ispattern
      % Load masked_by mask in order to populate a 3D matrix
      masked_by = get_objfield(subj,'pattern', cur_objname,'masked_by');
      m = get_mat(subj,'mask',masked_by);
      mDim = size(m);
        
      cur_TRs = find(runs == j);    

      M = zeros([mDim,length(cur_TRs)]);
      
      for k=1:length(cur_TRs);
	tmp = zeros(mDim);
	tmp(find(m)) = d(:,k);
	M(:,:,:,k)   = tmp;
      end
      
      Opt.Frames = length(cur_TRs);
    else
      dDim(4) = 1;
      mDim    = dDim;
      M = d;
      m = d;
      Opt.Frames = 1;
    end
    
    % Determine output filename that WriteBrik will write
    if length(unique(runs(find(runs)))) > 1
      % Pattern w/ Runs
      Opt.Prefix = [output_pathfilenames{i} '_run' num2str(j)];
    else
      Opt.Prefix = output_pathfilenames{i};
    end    
    
    % Set pattern specific Info fields
    if ispattern
      Info.TAXIS_NUMS = [size(M,4) 0 0];
    end
    
    % Modify the INFO header to reflect the changes
    Info.DATASET_RANK = [3 size(M,4) 0 0 0 0 0 0];
    Info.BRICK_STATS = [min(reshape(M,prod(mDim),size(M,4))) max(reshape(M,prod(mDim),size(M,4)))];
    Info.BRICK_TYPES      = OrigInfo.BRICK_TYPES(1)      * ones(1,size(M,4));
    Info.BRICK_FLOAT_FACS = OrigInfo.BRICK_FLOAT_FACS(1) * ones(1,size(M, 4));
    
    % Write the BRIK
    Opt.Slices = [1:size(m,3)];
    Opt.Frames = [1:size(M,4)];
    
    if args.oneminus
      disp('M = 1 - M. Ignoring 0s');
      M(find(M==0)) = NaN;
      M = 1-M;
      M(find(isnan(M))) = 0;
    end
    
    if args.checkbrikhead
      Opt.NoCheck = 0; % full checking
    else
      Opt.NoCheck = 1; % no header checking
    end      
    
    [err, ErrMessage, Info] = WriteBrik (M, Info, Opt);
    if err
      error(ErrMessage);
    end
  end
end

if args.display_afni
  unix( sprintf('%s %s &',fullfile(args.afni_location,'afni'), ...
                args.pathname) );
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = try_zeroify(subj,objtype,objname,sample_filename,args,runTRs,varargin)

% Alternative to TRY_SPOOF.M
%
% [] = TRY_ZEROIFY(SUBJ,OBJTYPE,OBJNAME,SAMPLE_FILENAME,ARGS,RUNTRS, ...)
%
% Currently, this doesn't take in all of the same optional
% arguments as WRITE_TO_AFNI, and it can't deal with groups either
% yet. Nor can it deal with 4D patterns, so stick to statmap
% patterns and masks.
%
% All of the hard work is done by ZEROIFY_WRITE_AFNI.M


%defaults.output_filename = objname;
%args = propval(varargin,defaults,'ignore_missing_default',true);

if ~exist( sprintf('%s.BRIK',sample_filename),'file' ) & ~exist( sprintf('%s.BRIK.gz',sample_filename),'file' )
  error('Your sample BRIK %s doesn''t exist',sample_filename);
end

zeroify_args.view = args.view;
zeroify_args.afni_location = args.afni_location;
zeroify_args.tr_dur = args.tr_dur;

switch objtype
  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % pattern
 case 'pattern'
  pat = get_mat(subj,'pattern',objname);
%  [nVox nTimepoints] = size(pat);
  
  maskname = get_objfield(subj,'pattern',objname,'masked_by');
  % 3D boolean
  maskvol = get_mat(subj,'mask',maskname);
  
  % will contain a single timepoint's worth of pattern at a time
  singlepatvol = maskvol;
  
  % set up kill list
  kill = {};
  

  % do zeroify_write_afni once for each run

  for r = 1:length(runTRs)          

      disp(['Beginning to write run ' num2str(r) '...']);

      trs = runTRs{r}; % trs: double array with all TR numbers for this run
      nTimepoints = length(trs);
      trOff = trs(1)-1; % TR offset

      % zero-initialize allvols to be x y z t
      allvols = zeros([size(singlepatvol) nTimepoints]);
      for t=1:nTimepoints
        % add offset so we get the right TRs
        thisTR = t+trOff;
        % write a single timepoint of a pattern into singlepatvol
        singlepatvol(find(maskvol)) = pat(:,thisTR);
        allvols(:,:,:,t) = singlepatvol;
      end

      % need to adapt this to deal with splitting up runs to make the
      % RAM more manageable

      % need to get rid of this when we get rid of output_filenames xxx
%      for m=1:length(args.output_filenames)
      if length(runTRs) == 1
        cur_filename = fullfile(args.pathname, args.output_filename);
      else
        cur_filename = [fullfile(args.pathname, args.output_filename) '_run' num2str(r)];
        kill{length(kill)+1} = cur_filename;
      end
      cur_filename = fullfile(args.pathname,cur_filename);
      zeroify_write_afni(allvols,sample_filename,cur_filename,zeroify_args);
%      end  

  end % r runTRs

  % glue the resulting run BRIKs back together
  if length(runTRs) > 1
      final_brikname = fullfile(args.pathname, args.output_filename);
      tcat_str = ['3dTcat -prefix ' final_brikname];
      for r = 1:length(runTRs)
          tcat_str = [tcat_str ' ' final_brikname '_run' num2str(r) '+orig'];
      end % r runTRs
      disp(tcat_str);
      unix(tcat_str);

      % cleanup
      for k = 1:length(kill)
          disp(['rm -f ' kill{k} '+orig.*']);
          unix(['rm -f ' kill{k} '+orig.*']);
      end
  end

      
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % mask
 case 'mask'
  maskvol = get_mat(subj,'mask',objname);

%  for m=1:length(args.output_filenames)
  cur_filename = fullfile(args.pathname, args.output_filename);
  zeroify_write_afni(maskvol,sample_filename,cur_filename,zeroify_args);
%  end  
  
 otherwise
  error('Can only deal with patterns and masks');
end

if args.display_afni
  unix( sprintf('%s %s &',fullfile(args.afni_location,'afni'), ...
                args.pathname) );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [runTRs] = get_run_TRs(runs)

% Looks at the runs selector and returns a cell array of double arrays with
% the TRs for each run.

% If a run header was passed, use the 1D matrix instead
if strcmp(class(runs),'struct')
    r = r.mat;
end

m = max(runs);
for i = 1:m
    runTRs{i} = find(runs==i);
end

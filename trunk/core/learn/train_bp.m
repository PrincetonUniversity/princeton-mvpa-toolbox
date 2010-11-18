function [scratch] = train_bp(trainpats,traintargs,in_args,cv_args)

% Creates a backpropagation neural network and trains it.
%
% [SCRATCH] = TRAIN_BP(TRAINPATS,TRAINTARGS,IN_ARGS,CV_ARGS)
%
% You need to call TEST_BP afterwards to assess how well this
% generalizes to the test data.
%
% See the distpat manual and the Mathworks Neural Networks manual
% for more information on backpropagation
%
% Requires the Mathworks Neural Networks toolbox -
% http://www.mathworks.com/products/neuralnet. See CLASS_BP_NETLAB.M
% if you want to call the freely-distributable Netlab backprop
% implementation instead of the Mathworks Neural Networks toolbox
% one
%
% PATS = nFeatures x nTimepoints
% TARGS = nOuts x nTimepoints
%
% SCRATCH contains all the other information that you might need when
% analysing the network's output, most of which is specific to
% backprop. Some of this information is redundantly stored in multiple
% places. This gets referred to as SCRATCHPAD outside this function
%
% The classifier functions use a IN_ARGS structure to store possible
% arguments (rather than a varargin and property/value pairs). This
% tends to be easier to manage when lots of arguments are
% involved. xxx
%
% IN_ARGS required fields:
%
% - nHidden - number of hidden units (0 for no hidden
% layer). N.B. this refers to the number of units in a
% single hidden layer - we have not provided an interface
% for creating multiple hidden layers, since there's little
% benefit to this.
%
% IN_ARGS optional fields:
%
% - alg (default = 'trainscg'). The particular backpropagation
% algorithm to use
%
% - act_funct (default = 'logsig'). Activation function for each
% layer. Cell array with 1 or 2 cell strings set to 'purelin',
% 'tansig' etc. See NN manual for more information
%
% - goal (default = 0.001). Stopping criterion - stop training when
% the mean squared error drops below this
%
% - epochs (default = 500). Stopping criterion - stop training
% after this many epochs
%
% - show (default = NaN). Change this to 25, for instance, to make it
% pop up a graph and text progress report every 25 epochs of training
% - intrusive
%
% - showWindow (default = false). Change this to True to see
% the fancy new Neural Networks toolbox training GUI
% window. see
% http://groups.google.ca/group/comp.soft-sys.matlab/browse_thread/thread/08522b547059ef69
%
% - performFcn (default = 'mse'). Change this if you want to use
% 'cross_entropy' as your performance function, or regularization
% to keep your weights low ('msereg') - if so, see performParam_ratio
%
% - performParam_ratio (default = 1 for mse). Ratio of
% performance measure to weights size that contributes to
% the overall performance measure - see the BP manual
% section on 'Regularization' in 'Generalization'. Need
% to check that high ratio = emphasize error...
%
% - init_fcn (default = 'rand'). Affects how the weights are
% initialized. Try 'initnw' to generate initial weights and biases so
% that the active regions of the layer's neurons will be distributed
% evenly over the input space.
% 
% - valid (default = false). Normally, you just have training and
% testing data. If valid == true, then a portion of the training
% data gets treated *as though* its test data, and the training
% stops if generalization performance to this validation
% (i.e. 'pretend test') data worsens, which indicates
% overfitting. See also: the 'max_fail' arg below. See BP manual on
% 'Validation' in the 'Generalization' section
%
% - max_fail (default = 20) - see the 'valid' arg above. Determines how many
% times in a row performance on the validation vectors should drop
% before stopping training
%
% NOTE: AS OF MATLAB RELEASE 7.5 (2007b), THERE HAVE BEEN SIGNIFICANT
% CHANGES TO THE NEURAL NETWORK TOOLBOX. By default, MVPA tries to
% recreate the functionality of release 7.4. There are several
% additional arguments that control this:
%
% - processFcn (default = {}) - a cell array of pre- and post-processing
%   functions to be applied before training and after output. New
%   to Matlab 7.5. NOT RECOMMENDED.
%
% - divideFcn (default = '') - a string for a function to
%   automatically divide the training patterns into a train-train
%   and train-test set, so that the training algorithm can use
%   early stopping to increase generalization. New to Matlab
%   7.5.
%
%  - version - this is automatically determined by default for
%    whatever version of Matlab is currently running. If you want
%    to enforce version <7.4 behavior, set this to be 7.4, and you
%    will get a bunch of warning messages in Matlab 7.5, but the
%    results should be closer to what you would have gotten before
%    in Matlab 7.4. However, if you override this, networks with
%    hidden layers will not work. NOT RECOMMENDED.
% 

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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SORT ARGUMENTS

defaults.alg = 'trainscg';
defaults.act_funct{1} = 'logsig';
% Need separate activation functions for each layer
if isfield(in_args, 'nHidden') %in_args.nHidden
    defaults.act_funct{2} = 'logsig';
end
defaults.goal = 0.001;
defaults.epochs = 200;
defaults.show = NaN;
defaults.showWindow = false;
defaults.performFcn = 'mse';
defaults.performParam_ratio = 1;
defaults.valid = false;
defaults.max_fail = 5;
defaults.ignore_1ofn = false;

defaults.processFcns = {};
defaults.divideFcn = '';

% Figure out the version of matlab
verstruct = ver('matlab');
defaults.version = str2num(verstruct.Version);

% Args contains the default args, unless the user has over-ridden them
args = mergestructs(in_args,defaults);
scratch.class_args = args;

args = sanity_check(trainpats,traintargs,args);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTING THINGS UP

scratch.nOut = size(traintargs,1);

% Backprop needs to know the range of its input patterns xxx
patsminmax(:,1)=min(trainpats')'; 
patsminmax(:,2)=max(trainpats')';
scratch.patsminmax = patsminmax;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** CREATING AND INITIALIZING THE NET ***

% 2 layer BP (i.e. no hidden layer)
if ~args.nHidden
  % Initialize a feedforward net with nOut output units and
  % act_funct as the activation function

  %if args.version < 7.5
  if check_matlabVersion(7,5) < 0
    % Old way of initializing network
    scratch.net = newff(patsminmax,[scratch.nOut],args.act_funct);
  else
    % New way of initializing network as of 2007b
    scratch.net = newff(trainpats,traintargs,[],args.act_funct); 

    % Disable all the advanced (bad) functionality that was added
    scratch.net.inputs{1}.processFcns = args.processFcns;
    scratch.net.outputs{1}.processFcns = args.processFcns;
    scratch.net.divideFcn = args.divideFcn;
  end  

  % Get outputs from the output layer
  scratch.net.outputConnect = [1]; 

  % 3 layer BP (i.e. with hidden layer)
else

  % Old way of initializing networks
  %if args.version < 7.5 %this breaks at 7.10 or higher.
  if check_matlabVersion(7,5) < 0  %if matlab is below version 7.5 do this.
    scratch.net = newff(patsminmax,[args.nHidden scratch.nOut],args.act_funct);

    % Get outputs from both the hidden and output layers
    scratch.net.outputConnect = [1 1];

  else
    % New way of initializing network as of 2007b
    scratch.net = newff(trainpats,traintargs,[args.nHidden],args.act_funct); 

    % Disable all the advanced (bad) functionality that was added
    scratch.net.inputs{1}.processFcns = args.processFcns;
    scratch.net.outputs{2}.processFcns = args.processFcns;
    scratch.net.divideFcn = args.divideFcn;    
  end  
      
end % if 3 layer

scratch.net = init(scratch.net); % initializes it

% Setting the network's properties according to in_args
scratch.net.trainFcn = args.alg;
scratch.net.trainParam.goal = args.goal;
scratch.net.trainParam.epochs = args.epochs;
scratch.net.trainParam.show = args.show; 
scratch.net.trainParam.showWindow = args.showWindow;
scratch.net.performFcn = args.performFcn;

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** RUNNING THE NET ***

% This is the main training function - see TRAIN.M in the NN toolbox
[scratch.net, scratch.training_record, scratch.training_acts,scratch.training_error]= ...
    train(scratch.net,trainpats,traintargs);

% Note that these contain the activations for all the units (both
% hidden and output). OUTIDX indexes just the output layer (whether
% you have a hidden layer or not)
%if args.version < 7.5
if check_matlabVersion(7,5) < 0
  scratch.outidx = [args.nHidden+1:args.nHidden+scratch.nOut];
else
  % IN THE NEW VERSION OF MATLAB, WE DO NOT GET THE OUTPUTS OF
  % HIDDEN LAYER UNITS
  scratch.outidx = 1:rows(traintargs);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [args] = sanity_check(trainpats,traintargs,args)

if ~isfield(args,'nHidden')
  error('Need an nHidden field');
end

if args.nHidden < 0
  error('Illegal number of hidden units');
end

if size(trainpats,2)==1
  error('Can''t classify a single timepoint');
end

if size(trainpats,2) ~= size(traintargs,2)
  error('Different number of training pats and targs timepoints');
end

if ~iscell(args.act_funct)
  if ischar(args.act_funct)
    temp_act_funct = args.act_funct;
    args.act_funct = [];
    args.act_funct{1} = temp_act_funct;
  else
    error('Act_funct should be a cell array of two strings');
  end
end

if length(args.act_funct)~=1 && length(args.act_funct)~=2
  error('Can only deal with two act_funct cells');
end

if args.performParam_ratio ~= 1
  error('Haven''t implemented performParam ratio yet');
end

if strcmp(args.performFcn,'msereg')
  error('Haven''t implemented msereg yet');
end

if args.valid
  error('Haven''t implemented validation yet');
end

[isbool isrest isoveractive] = check_1ofn_regressors(traintargs);
if ~isbool || isrest || isoveractive
  if ~args.ignore_1ofn
    warning('Not 1-of-n regressors');
  end
end

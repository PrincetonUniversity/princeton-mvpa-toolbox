function [bp] = train_bp(trainpats,traintargs,in_args)

% Creates a backpropagation neural network and trains it.
%
% [BP] = TRAIN_BP(TRAINPATS,TRAINTARGS,IN_ARGS)
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
% BP contains all the other information that you might need when
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
% - nHidden - number of hidden units (0 for no hidden layer)
%
% IN_ARGS optional fields:
% - alg (default = 'traincgb'). The particular backpropagation
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
% This version is set up for ZeroOne normalized inputs alter newff
% function if this is not appropriate - xxx???



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SORT ARGUMENTS

defaults.alg = 'traincgb';
defaults.act_funct{1} = 'logsig';
% Need separate activation functions for each layer
if in_args.nHidden
    defaults.act_funct{2} = 'logsig';
end
defaults.goal = 0.001;
defaults.epochs = 500;
defaults.show = NaN;

% Args contains the default args, unless the user has over-ridden them
args = add_struct_fields(in_args,defaults);
bp.class_args = args;

sanity_check(trainpats,traintargs,args);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTING THINGS UP

bp.nOut = size(traintargs,1);

% Backprop needs to know the range of its input patterns xxx
patsminmax(:,1)=min(trainpats')'; 
patsminmax(:,2)=max(trainpats')';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** CREATING AND INITIALIZING THE NET ***

% 2 layer BP (i.e. no hidden layer)
if ~args.nHidden
  % Initialize a feedforward net with nOut output units and
  % act_funct as the activation function
  bp.net = newff(patsminmax,[bp.nOut],args.act_funct);
  % Set every unit in the input layer to be fully connected to
  % every unit in the output layer
  bp.net.outputConnect = [1]; % 2-layer feedforward connectivity

% 3 layer BP (i.e. with hidden layer)
else
  % Initialize as above, but setting both layers' activation
  % functions
  bp.net = newff(patsminmax,[args.nHidden bp.nOut],bp.act_funct);
  % Every input unit connected to every hidden unit, and every
  % hidden unit to every output unit
  bp.net.outputConnect = [1 1];
end % if 3 layer

bp.net = init(bp.net); % initializes it

% Setting the network's properties according to in_args
bp.net.trainFcn = args.alg;
bp.net.trainParam.goal = args.goal;
bp.net.trainParam.epochs = args.epochs;
bp.net.trainParam.show = args.show; 


  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** RUNNING THE NET ***

% This is the main training function - see TRAIN.M in the NN toolbox
[bp.net, bp.training_record, bp.training_acts,bp.training_error]= ...
    train(bp.net,trainpats,traintargs);

% Note that these contain the activations for all the units (both
% hidden and output). OUTIDX indexes just the output layer (whether
% you have a hidden layer or not)
bp.outidx = [args.nHidden+1:args.nHidden+bp.nOut];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(trainpats,traintargs,args)

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


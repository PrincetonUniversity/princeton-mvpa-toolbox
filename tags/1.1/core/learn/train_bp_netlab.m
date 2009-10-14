function [scratch] = train_bp_netlab(trainpats,traintargs,in_args,cv_args)

% Creates a Netlab backpropagation network and trains it
%
% [SCRATCHPAD] = TRAIN_BP_NETLAB(TRAINPATS,TRAINTARGS,IN_ARGS,CV_ARGS)
%
% You need to call TEST_BP_NETLAB afterwards to assess how well this
% generalizes to the test data. See the distpat manual and the Netlab
% MLP.M help for more information. Requires the open source Netlab
% Neural Networks toolbox that should be bundled with the toolbox:
%
%   http://www.ncrg.aston.ac.uk/netlab/
% 
% SeeTRAIN_BP.M for info on the input/output arguments
%
% NOTE: This script takes in the test/train pattterns and the
% targets in the same manner as the class_bp, but internally
% transposes the dimensions since the Netlab toolbox requires
% different arguments from the Matlab NN toolbox.
%
% xxx act_funct arguments

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


defaults.act_funct{1} = 'logistic';
defaults.act_funct{2} = 'logistic';
defaults.epochs = 500;
defaults.ignore_1ofn = false;

args = mergestructs(in_args,defaults);
scratch.class_args = args;

args = sanity_check(trainpats,traintargs,args);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set things up
scratch.nOut = size(traintargs,1);
nIn = size(trainpats,1);

% Transpose pats and targs for Netlab toolbox
trainpats = trainpats';
traintargs = traintargs';

% Creating the network 
net = mlp(nIn, args.nHidden, scratch.nOut, args.act_funct{1});

% Train the network
[net, errorfun] = mlptrain(net,trainpats,traintargs,args.epochs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scratch.net = net;
scratch.errorfun = errorfun;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [args] = sanity_check(trainpats,traintargs,args)

if ~isfield(args,'nHidden')
  error('Need an nHidden field');
end

if args.nHidden < 0
  error('Illegal number of hidden units');
end

if args.nHidden == 0
  error('Haven''t figured out how to do BP_Netlab with no hidden layer');
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

if length(args.act_funct)~=1 & length(args.act_funct)~=2
  error('Can only deal with two act_funct cells');
end

if ~strcmp(args.act_funct{1},args.act_funct{2})
  error('Haven''t figured out how to use different act_functs for BP_Netlab');
end


if isfield(args,'alg')
  warning('Ignoring ''alg'' in BP_Netlab');
end

if isfield(args,'goal')
  warning('Ignoring ''goal'' in BP_Netlab');
end

if isfield(args,'show')
  warning('Ignoring ''show'' in BP_Netlab');
end

if isfield(args,'performFcn')
  warning('Ignoring ''performFcn'' in BP_Netlab');
end

if isfield(args,'performParam_ratio')
  warning('Ignoring ''performParam_ratio'' in BP_Netlab');
end

if isfield(args,'init_fcn')
  warning('Ignoring ''init_fcn'' in BP_Netlab');
end

if isfield(args,'valid')
  warning('Ignoring ''valid'' in BP_Netlab');
end

if isfield(args,'max_fail')
  warning('Ignoring ''max_fail'' in BP_Netlab');
end


[isbool isrest isoveractive] = check_1ofn_regressors(traintargs);
if ~isbool || isrest || isoveractive
  warning('Not 1-of-n regressors');
end

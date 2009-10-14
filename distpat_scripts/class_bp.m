function [out,bp] = class_bp(class_args,trainpats,traintargs,testpats,testtargs)

% function [out,bp] = class_bp(class_args,trainpats,traintargs,testpats,testtargs)
%
% this is the new general-purpose bp script
%
% net is the structure that contains everything pertaining to
% the bp network:
% - the main matlab net structure itself;
% - a couple of performance measures;
% - the pats (input patterns) and targs (output targets) which get
% taken from the 'env' structure;
% - and various other statistics, measures and network parameters
% that get described below
%
% the 'EL' part used to stand for 'early late', since we thought
% that training on the last 5 trials of a miniblock and testing on
% the first five might work better. at the bottom of the script,
% you can see the original nets(block) structure which used patsSw
% and patsNSw (based on sean's subj structure)
%
% from sean's original comments:
%   Construct patterns and targets outside this file.
% 
%   *If using leabra-created pats, need to transpose them*.
%
%   Format for PATS: 
%      each row is an input unit, 
%      each column is a pattern
%      pats(:,1) is the first pattern
%   Format for TARGS:
%      each row is an output unit,
%      each column corresponds to the same-numbered input pattern
%      targs(:,1) is the target output state for the first input
%      pattern
% 
%   This version is set up for ZeroOne normalized inputs
%   alter newff function if this is not appropriate
%
% see the script itself for more detailed comments
% sean's original function is commented out at the bottom
%
% required class_args
%    nHidden
%    layers

bp.nOut = size(traintargs,1);

allpats = [trainpats testpats];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp( sprintf('\tinitialising bp') );

% *** SETTING UP THE TRAINING PATS AND OUTPUT TARGS ***

if( class_args.layers == 2 )
  bp.nHidden = 0;
end
if( class_args.layers == 3 )
  bp.nHidden = class_args.nHidden; % we've found that adding lots of hidden units
		   % doesn't appear to help v much - this is
		   % corroborated by the GLM's performance
		   % if you want a two-layer network, i think you
		   % just take the nHidden parameter out of the
		   % newff function call - confirm with Sean
end

bp.alg = 'traincgb'; % traincb is a funny conjugate gradient
                         % version of backprop that has good
                         % performance, and that sean has found to
                         % work well - for more details, see the
                         % Matlab NN manual at:
			 % http://www.mathworks.com/access/helpdesk/help/toolbox/nnet/nbp.shtml

bp.curActFunct = 'logsig'; % this parameter is useful if you
                               % want the activation function to be
                               % the same in both layers -
                               % otherwise, set it manually in the
                               % train function below
			       % we've tried various options,
                               % including:
			       % - tansig (which looks sigmoidal, but allows activations
                               % to range from -1 to 1)
			       % - purelin (which is just linear -
                               % seemed promising for the output layer)
                               % - lecuntf (which sean read about -
                               % see the related .m files in this
                               % directory - i don't think this has
                               % an upper bound)
			       % - logsig (basic logistic sigmoidal ranging
                               % from 0 to 1 - seems to work
                               % perfectly well)

% backprop needs to know the range of its input patterns	       
patsminmax(:,1)=min(allpats')'; 
patsminmax(:,2)=max(allpats')';

% *** CREATING AND INITIALISING THE NET ***
if( class_args.layers == 2 )
  % this creates a 2-layer BP with curActFunct as the output layer's activation
  % function - usually logsig works best
  bp.net = newff(patsminmax,[bp.nOut],{bp.curActFunct});
  bp.net.outputConnect = [1]; % 2-layer feedforward connectivity
end % if 2 layer

if( class_args.layers == 3 )
  bp.net = newff(patsminmax,[bp.nHidden bp.nOut],{bp.curActFunct,bp.curActFunct});
  bp.net.outputConnect = [1 1]; % standard 3-layer feedforward connectivity
end % if 3 layer

bp.net = init(bp.net); % initialises it

bp.net.trainFcn=bp.alg;
bp.net.trainParam.goal = 0.001; % i.e. stop when the mean
                                    % squared error drops below this
bp.net.trainParam.epochs = 500; % max number of epochs

bp.net.trainParam.show = NaN; % change this to 25, to make it pop
                                  % up a graph and text progress
                                  % report every so often -
                                  % intrusive
% bp.net.performFcn = 'msereg';
% bp.net.performParam.ratio = 0.5;
  % this is how to implement the regularisation version of mse,
  % where the size of the weights and biases gets factored into the
  % error score, as a more principled means of keeping them low
  % than weight decay - this is supposed to help generalisation

  
% *** RUNNING THE NET ***
disp( sprintf('\ttraining bp') );

bp.y_pretrain = sim(bp.net,allpats); % runs an untrained
                                              % network through its paces
[bp.net,bp.tr,bp.y_train,bp.e]= ...
    train(bp.net,trainpats,traintargs);
  % this is the main training function
  
bp.y_posttrain = sim(bp.net,allpats);
  % this runs the trained network through all the pats
  
bp.y_test = sim(bp.net,testpats);
  % this tests the network on just the testpats - this is what we
  % usually use to assess generalisation
  % it contains the activations for all the units (both hidden and
  % output) on all the test pats - below, the task_out vars index
  % just the output units, since those are the ones we really care about
  
  
% *** PERFORMANCE METRIC 1 ***

disp( sprintf('\tcalculating performance') );

% calculate the performance of the network on the test items
% aka generalization

% this next section is sean's preferred method of measuring
% generalisation - it basically does winner-take-all, and checks
% that the right unit won - i think it probably works better for
% category performance testing than my simple mean squared error
% statistic below (gen_perf_diff), but things would get more
% complicated if the kwta in the output layer > 1
% bp.outputs = bp.y_test(bp.nHidden+1:bp.nHidden+bp.nOut,:);

bp.outputs = bp.y_test(bp.nHidden+1:end,:); % takes the last nOut units
[v,inds_out]=max(bp.outputs); % correct answer is maximum valued output
[v,inds_targ]=max(testtargs);
bp.corrvector = (inds_out==inds_targ); % percent correct across all responses
bp.pct_correct_win = mean(bp.corrvector); % percent correct by condition
for j=1:bp.nOut
  if isempty(find(inds_targ==j))==0 % ???
    bp.corrbycond_win(j) = mean(bp.corrvector(find(inds_targ==j)));
  else
    bp.corrbycond_win(j) = -1;
  end
end
out.pct_correct = bp.pct_correct_win;
out.confidences_cats_across_units = bp.outputs';
out.corrects_each_timepoint = bp.corrvector;


% *** PERFORMANCE METRIC 2 ***
bp.differences = bp.outputs-testtargs;
bp.scores_diff = 1-round(abs(bp.differences));
bp.gen_perf_diff = mean(bp.scores_diff,2);
% this is a much simpler performance score than the one above

  
% *** FINISHING THINGS OFF ***  
% bp.outidx gives you the indices of the output units
% useful for referencing y_test, etc
bp.outidx = [bp.nHidden+1:bp.nHidden+bp.nOut]; % bp.nHidden == 0 for 2 layer nets


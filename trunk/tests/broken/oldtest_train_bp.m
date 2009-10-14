function [success errmsg] = test_train_bp()

% [success errmsg] = test_train_bp()


success = -1;
errmsg = 'Script unfinished';
return

success = 0;
errmsg = '';

nFeatures = 100;
nTimepoints = 1000;
nOuts = 2;

pat1 = rand([1:nFeatures/2 nTimepoints]);
pat2 = rand([1:nFeatures/2 nTimepoints])*2;
pat = [pat1; pat2];

% regressors = 


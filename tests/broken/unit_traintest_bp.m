function [errmsgs warnmsgs] = unit_traintest_bp()

% [ERRMSGS WARNMSGS] = UNIT_TRAINTEST_BP()
%
% Runs GENERIC_UNIT_CLASSIFIER with the bp class_args


class_args.train_funct_name = 'train_bp';
class_args.test_funct_name  = 'test_bp';
class_args.nHidden = 0;
class_args.epochs = 40;
[errmsgs warnmsgs] = generic_unit_classifier(class_args);

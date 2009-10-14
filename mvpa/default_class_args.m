function [class_args] = default_class_args(nHidden)

% [CLASS_ARGS] = DEFAULT_CLASS_ARGS([nHidden])
%
% nHidden (optional, default = 0)


if ~exist('nHidden')
  nHidden = 0;
end

class_args.train_funct_name = 'train_bp';
class_args.test_funct_name = 'test_bp';

if nHidden
  class_args.nHidden = nHidden;
  class_args.act_funct = {'logsig','purelin'};
else
  class_args.nHidden = 0;
end

function [class_args] = default_class_args(nHidden)

% [CLASS_ARGS] = DEFAULT_CLASS_ARGS([nHidden])
%
% nHidden (optional, default = 0)

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

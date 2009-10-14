% SCRIPT
%
% If you don't like the way that the ARGS structure created
% by PROPVAL stores your arguments as fields in a
% structure, this script will blurt them out into your
% workspace as full-fledged variables.
%
% e.g.
%
%   defaults.blah = 42;
%   args = propval(varargin,defaults);
%   args_into_workspace
%   disp(blah)


if exist('aiw_fnames','var')
  % since this is a script, it could mess up the user's
  % workspace. err on the side of caution, and refuse to
  % overwrite any existing variables
  error('Can''t splurge args into workspace because AIW_FNAMES already exists');
end
  
aiw_fnames = fieldnames(args);
for f=1:length(aiw_fnames)
  % e.g. eval('blah = args.blah;')
  eval(sprintf('%s = args.%s;', aiw_fnames{f}, aiw_fnames{f}));
end % f nFnames

% tidy up after ourselves
clear aiw_fnames

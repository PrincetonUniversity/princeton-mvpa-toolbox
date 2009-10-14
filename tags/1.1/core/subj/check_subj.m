function [isok] = check_subj(subj)

% This just runs some quickie tests to see whether your subj
% structure appears to be constructed correctly
%
% Still under development.

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


isok = true;

types = get_typeslist('plural');

for t=1:length(types)
  if ~isfield(subj,types{t})
    err = sprintf('You don''t have a %s cell array',types{t});
    err = strcat(err,'. Did you use init_subj to create your subj?');
    error(err);
  end
end


    
    


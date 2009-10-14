function [isok] = check_subj(subj)

% This just runs some quickie tests to see whether your subj
% structure appears to be constructed correctly


isok = true;

types = get_typeslist('plural');

for t=1:length(types)
  if ~isfield(subj,types{t})
    err = sprintf('You don''t have a %s cell array',types{t});
    err = strcat(err,'. Did you use init_subj to create your subj?');
    error(err);
  end
end


    
    


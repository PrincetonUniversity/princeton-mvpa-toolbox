function [] = progress(cur,total,nSteps)

% Display a text-based progress counter
%
% [] = PROGRESS(CUR,TOTAL,[NSTEPS])
%
% Displays a progress counter that counts up to 1,
% printing out cur/total proportion
%
% Don't forget to add a carriage return at the end of
% your for loop.
%
% nSteps (optional, default = 10). The number of increments
% towards completion to read out. Note: this is not a
% PROPVAL optional argument.
%
% See WAITBAR for a flashy progress bar that uses figures
% - less good if you're running over SSH.
%
% e.g.
%
%   for v=1:nVox
%     progress(v,nVox);
%     % do something
%   end % v
%   disp(' ')


if cur==1
  % let the user know that a long process is starting
  fprintf('\t...')
end

if ~exist('nSteps','var')
  nSteps = 10;
end

if cur==total
  fprintf('  %.f%%', 100); % prints 100%
  dispf('  done')
  return
end

if mod(cur, round(total/10)) == 0
  % fprintf('\t%.2f', cur/total); % prints e.g. 0.10
  fprintf('  %.f%%', (cur/total)*100); % prints e.g. 10%
end

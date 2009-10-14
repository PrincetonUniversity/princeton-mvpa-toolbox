function [fnames] = write_regs_1d(regs,regs_1d_name)

% Write your regressors out as .1d files
%
% [FNAMES] = WRITE_REGS_1D(REGS,REGS_1D_NAME)
%
% Writes a series of 1d files, one for each condition. Doesn't
% matter if your REGS_1D_NAME has a .1d extension, since it will be
% stripped off, to create individual files, e.g.
%   'hello.1d' -> 'hello_c1.1d'
%                 'hello_c2.1d'
% etc.
%
% Currently deletes existing 1d files with the same name after 5
% seconds.

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


[nConds nTRs] = size(regs);

% Strip off the file extension if it's there, so that we can then
% add it ourselves later after the c# suffix
if strfind(lower(regs_1d_name),'.1d')
  regs_1d_name = regs_1d_name(1:end-3);
end

fnames = {};

wait_before_overwriting(sprintf('%s_c1.1d',regs_1d_name))

for c=1:nConds
  cur_cond = regs(c,:)';
  cur_filename = sprintf('%s_c%i.1d',regs_1d_name,c);
  
  save(cur_filename,'cur_cond','-ascii');
  fnames{end+1} = cur_filename;
end

dispf('Writing regressors to %s_c#.1d files',regs_1d_name);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = wait_before_overwriting(cur_filename)

if exist(cur_filename,'file')
  % error('%s already exists',regs_1d_name);
  
  dispf('About to delete %s in 5 secs',cur_filename);
  pause(5)

end

function [alltests] = run_unit_tests(varargin)

% [ALLTESTS] = RUN_UNIT_TESTS(...)
%
% This is the main function for the test suite. It goes
% through the TESTSDIR, looking for test_*.m files. Then, it
% runs all those test functions and tells you how they
% did. Each one returns an 'errors' cell array of strings, which
% should be empty if everything went well. Each error is
% represented as a cell containing a string error
% message.
%
% There needs to be a way to signal that a test wasn't
% run for some reason, or that a result was unsure,
% i.e. somewhere between a success and a failure. The
% tests could return another 'unsuremsgs' cell array, or
% use '?' as an unsure message, but then you can't tell
% which test didn't get run.
%
% TESTSDIR (optional, default = '.')
%
% AUTO_EXIT (optional, default = false). If true, will exit matlab
% 5 seconds after finishing. This is so that you can call this from
% the shell and things continue if all is well, but they grind to a
% halt with an error if there's any kind of problem


defaults.testsdir = '.';
defaults.auto_exit = false;
args = propval(varargin,defaults);

allnames = add_names(args.testsdir,'unit_');
allmsgs = [];

successes = 0;
unsures = 0;
errors = 0;

nTestFunctions = length(allnames);

% disp( sprintf('nErrs\tFuncname (error msgs indented
% below)') );

for t=1:nTestFunctions
  curname = allnames{t};
  curname = strrep(curname,'.m','');
  % curname = sprintf('%s()',curname);
  curmsgs = eval(curname);
  allmsgs{end+1} = curmsgs;
  
  if isempty(curmsgs)
    curresult = 0;
    successes = successes + 1;
    disp( sprintf('0\t%s',curname) );
  
  else
    errors = errors + 1;
    curresult = 0;
    disp( sprintf('%i\t%s:%s', length(curmsgs), ...
		  curname,disperrs(curmsgs)) );

  end

  alltests(t).funcname = curname;
  alltests(t).success = curresult;
  alltests(t).msgs  = curmsgs;
end

disp('---------------------------------------------------------')
disp('---------------------------------------------------------')
disp('---------------------------------------------------------')
disp( sprintf('%i of %i successes',successes,nTestFunctions) );
disp( sprintf('%i of %i unsures',unsures,nTestFunctions) );
disp( sprintf('%i of %i errors',errors,nTestFunctions) );

if successes==nTestFunctions
  disp('Wahoo!');
end

if unsures>0
  disp('Could be a problem - look at the unsures');
  warning
end

if errors>0
  disp('Oh dear :(');
  disp( sprintf('\n\nDisplaying tests that had errors.\n') )
  
  for t=1:nTestFunctions
    % if it had an error, display it
    if length(alltests(t).msgs)
      alltests(t)
    end
  end
end

disp(' ');

if args.auto_exit
  if errors>0
    error('Test suite found errors');
  end
  disp('Exiting in 5 secs unless you press Ctrl-C');
  pause(5)
  exit
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allnames] = add_names(directory,prefix)

allnames = [];
cd(directory);
files = dir('unit_*.m');
for f=1:length(files)
  allnames{end+1} = files(f).name;
end % f nFiles



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errstr] = disperrs(errcell)

% Takes a cell array of strings, and spits them out indented
% one by one on separate lines

errstr = sprintf('\n');
for c=1:length(errcell)
  errstr = sprintf('%s\t\t''%s''\n',errstr,errcell{c});
end % c errcell





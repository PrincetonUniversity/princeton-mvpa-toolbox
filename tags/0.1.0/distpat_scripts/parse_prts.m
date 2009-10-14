function [subj] = parse_prts(subj,fnmprt1,fnmprt2,TRsPerRun)

% function [subj] = parse_prts(subj,fnmprt1,fnmprt2,TRsPerRun)
% called from within BVtoSubj


% The following code is specific for the format of BV .prt files 
% parses these .prt files.

nRuns = length(TRsPerRun);

for rn = 1:nRuns

  % open the prt file for the current run
  fname = strcat(fnmprt1,num2str(rn),fnmprt2,'.prt');
  fid = fopen(fname);

  % read in the header information
  cur_str = fgetl(fid);
  [text1,number1] = strread(cur_str,'%s%n%*[^\n]',1);
  Run(rn).FileVersion=number1;
  blank = fgetl(fid);
  cur_str = fgetl(fid);
  [text1,text2] = strread(cur_str,'%s%s%*[^\n]',1);
  Run(rn).ResOfTime=text2;
  blank = fgetl(fid);
  cur_str = fgetl(fid);
  [text1,text2] = strread(cur_str,'%s%s%*[^\n]',1);
  Run(rn).Expt=text2;
  for i=1:9
    blank = fgetl(fid);
  end
  % number of conditions in the prt file
  cur_str = fgetl(fid);
  [text1,number1] = strread(cur_str,'%s%n%*[^\n]',1);
  Run(rn).NrOfCond=number1; % figures out how many conditions
                                 % there are
  blank = fgetl(fid);

  % reading in the range of trs for each condition
  for i=1:Run(rn).NrOfCond
    cur_str = fgetl(fid);
    %  [text1] = strread(cur_str,'%s%*[^\n]',1);
    [text1] = strread(cur_str,'%s',1);
    Run(rn).Cond(i).name = text1;
    cur_str = fgetl(fid);
    [number1] = strread(cur_str,'%n%*[^\n]',1);
    NrOfTRblks = number1;
    for j=1:NrOfTRblks
      cur_str = fgetl(fid);
      % number 1 and 2 are start and end of block
      [number1 number2] = strread(cur_str,'%n%n%*[^\n]',1);
      Run(rn).Cond(i).TRlims(j,:) = [number1 number2];
    end
    % get rid of 2 lines
    blank = fgetl(fid);
    blank = fgetl(fid);  
  end

  fclose(fid);

end

% **CREATE TWO MATRICES out of TRlims
% regressors = nTRs rows x nCond cols
%              value indicates level of the regressor
%              usually 0/1 unless convolved with HRF
% runs = 1 row x nTRs cols
%        value (int) indicates which run this TR belongs to

% TRlims = start and end of every block across runs and
% conditions (out of 183 TRs/run)
% this is supposed to translate that number into an index relative
% to 1464
% for each run, go into the first condition (e.g. faceloc), you
% have the trlims to tell you when each block starts and ends -
% then you say what run i'm in, and you figure out what tr that
% corresponds to out of 1464 - that's why trs/run is important
% is it possible that trs/run varies across runs - to check that,
% do: load the vtc using [myvtc] = bv_read_vtc(vtc_filename) -
% myvtc will be a structure, and do a size(myvtc.data,1) for numTRs
% for that run
% subj.regressors is already screwed up by the end of parse_prts

% won't work if TRsPerRun is not the same each time
%
% zero-initialise the matrix - without this, some of the rest TRs
% seem to get left off the end of subj.regressors. we hope this
% isn't a big bug, but since the columns of the regressors add up,
% we're going to assume it all works beautifully

% number of conds is in Run(i).NrOfCond;
% * THIS IS A SANITY CHECK, condsByRun IS NOT USED AGAIN
condsByRun=[];
for i=1:length(Run)
  condsByRun(i)=Run(i).NrOfCond;
end
if length(unique(condsByRun))>1
  error('Error: Your .prt files have different numbers of conditions.');
else
  nConds = unique(condsByRun);
end

subj.regressors = zeros(sum(TRsPerRun),nConds);
disp( sprintf('\tcreating subj_regressors in parse_prts') );

% RunStarts is a vector that says when each run starts relative to
% the entire experiment
RunStarts(1) = 1;
for i=2:nRuns
  RunStarts(i) = sum(TRsPerRun(1:i-1))+1;
end

% subj.runs is a vector with the run number corresponding to each tr
for i=1:nRuns
  subj.runs(RunStarts(i):RunStarts(i)+TRsPerRun(i)-1) = i;
end

% creating the regressors matrix from the prt information
for i=1:nRuns
  for j=1:length(Run(i).Cond)
    % len is the number of blocks of this condition in this run
    len=size(Run(i).Cond(j).TRlims,1);
    for k=1:len
      TRstart = Run(i).Cond(j).TRlims(k,1) + RunStarts(i) - 1; % onset
      TRend = Run(i).Cond(j).TRlims(k,2) + RunStarts(i) - 1; % offset
      TRList = TRstart:TRend;
      subj.regressors(TRList,j) = 1; 
    end
  end
end 


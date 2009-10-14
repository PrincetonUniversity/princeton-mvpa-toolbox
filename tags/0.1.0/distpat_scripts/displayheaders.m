function [] = displayheaders(subj,results)

if exist('subj')
  disp( sprintf('\nsubj') );
  nHists = length(subj.header.history);
  for i=1:nHists
    disp( sprintf('\t%s',char(subj.header.history{i})) );
  end
else
  disp( 'no subj structure' );
end

% disp( sprintf('\n') );

if exist('results')
  disp( sprintf('\nresults') );
  nHists = length(results.header);
  for i=1:nHists
    disp( sprintf('\t%s',char(results.header{i})) );
  end
else
  disp( 'no results structure' );
end


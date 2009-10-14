% warning( 'not implemented yet' );

logs = dir('*.log');
nLogs = length(logs);

cr = sprintf('\n');

all_logs = [];
for i=1:nLogs
  exec = sprintf('more %s',logs(i).name);
  all_logs{length(all_logs)+1} = unix(exec);
end % nLogs

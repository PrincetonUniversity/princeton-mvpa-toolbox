function [] = save_subj(subj,filename,saveinfo,includedate)

% save_subj(subj,filename,saveinfo,includedate)
%
% appends the saveinfo to the subj.header.history
% displays the saveinfo
% saves the subj structure into filename_subjno(_datetime).mat
% and creates filename_subjno(_datetime).log with the current header info for easy reference
%
% if includedate is true, it appends the result of datetime() to the filename
%
% if saveinfo is blank, it creates a simple one

dt = datetime();

if( includedate == true )
  filename = sprintf('%s_%s_%s',filename,subj.no_lz_subj_no,dt);
else
  filename = sprintf('%s_%s',filename,subj.no_lz_subj_no);
end

if isempty(saveinfo)
  saveinfo = sprintf('saving %s in %s at %s',filename,pwd,dt);
end

subj = addheader(subj,saveinfo,true);
save(filename,'subj');
history = char(subj.header.history{:});

out = fopen(sprintf('%s.log',filename),'w');
nHists = size(history,1);
for i=1:nHists
  fprintf(out, sprintf('%s\n',history(i,:)) );
 end % nHists
fclose(out);



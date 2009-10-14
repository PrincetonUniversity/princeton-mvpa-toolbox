function [output] = ebc_feature_rater(subj, results, inum, subjnum, subfile, ...
                                      varargin)

% Create EBC Feature_Rater submission file
%
% [OUTPUT] = EBC_FEATURE_RATER(SUBJ, RESULTS, INUM, ...
%                              SUBJNUM, SUBFILE, VARARGIN)
%
% SUBJ is the subject that the results correspond to.  This
% is so that the original selectors can be extracted to pad
% rest if necessary.
%
% RESULTS should be an array of result structures returned
% by CROSS_VALIDATION().  It is assumed that the order of
% the array corresponds to the order of the EBC features.
%
% INUM is the iteration number of each result to use -- this
% MUST correspond to training on subject 1, movie 1, test on
% subject 1, movie 2!
%
% SUBJNUM = subject number (integer, ranging from 1 to 3)
%
% SUBFILE = the string filename of the submission text to be
% created by this script.
%
% GROUP (optional, default = 'My') the name of the group to
% be written in the EBC header.
%
% SCALE (optional, default = 1) a scalar that all results
% will be multiplied by before being saved.
%
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

defaults.group = 'My';
defaults.scale = 1;

args = propval(varargin, defaults);

scale = args.scale;
% create the EBC header
header = ['User\tSubmission Type\tSubject\tRun\tDataType' ...
          '\tHemodynamicFN\tReleaseNumber\tFormatID\tSampleRate' ...
          '\tNumberSamples\tFeatures\tLocation\tActors\tOther\tLabels' ...
          '\tSpecial_Notes\n', args.group, ...
          '\tTest\t',int2str(subjnum),'\t2\tSmoothed\tSPM\t2\tEBC1\t1.750000\t868' ...
          '\t13\t6\t8\t3\tRMS audio, Brightness, Blank' ...
          '\tThis is the second release of features\nTime'];

features = {'Amusement','Attention','Arousal','Body Parts', ...
            'Environmental Sounds','Faces','Food','Language', ...
            'Laughter','Motion','Music','Sadness','Tools', ...
            'Other Settings','Backyard','Garage','Kitchen', ...
            'LivingRoom/DiningRoom','ToolTime','Other People', ...
            'Mark','Randy','Brad','Tim','Jill','Al', ...
            'Wilson','RMS Sound','Brightness','Blank'};

for i = 1:numel(features);
  header = sprintf('%s\t%s', header, features{i});
end
header = sprintf('%s\n', header);

% get the selectors, so we know whether or not we need to pad
% indices -- we need the original selector, or we won't know
% exactly what size to make the output array (we don't know what
% run '0' corresponds to in the _xval selector

selname = results(1).iterations(inum).created.selname;

s_created = get_objfield(subj, 'selector', selname, 'created');
selmat = get_mat(subj, 'selector', s_created.runs_selname);

% create the blanksmat to mark which are rest in the runs
xvalmat = get_mat(subj, 'selector', selname);
blanksmat = ones(size(selmat));
blanksmat(find(xvalmat == 0)) = 0;

% get movie #2 test TRs to use out of the total selectors matrices
movie_num = 2;
TRs_to_use = find(selmat==movie_num);

T = numel(selmat(TRs_to_use));
blanksmat = blanksmat(TRs_to_use);

% create the time col containing the time, in seconds
% (i.e. the TR # * the TR length (1.75 seconds))
timecol = (1:T)' * 1.75;


outmat = timecol;

% extract predictions from results array
for r = 1:numel(results)

  % extract enough predictions to cover all of the test 
  acts = zeros(1,T);
  acts(find(blanksmat)) = results(r).iterations(inum).acts;

  % scale the data to avoid EBC errors
  acts = acts .* (1 / max(acts(:))) * scale;
  
  % check for "Inappropriate Data"
  if (max(acts) > 2) | (min(acts) < -2)
    warning(sprintf(['Acts matrix for regressor %d has values outside ' ...
                     '(-2, +2) - this will cause an error when you ' ...
                     'run the ''Feature_Rater'' program.  Use the ' ...
                     'optional ''scale'' parameter to scale the ' ...
                     'values by a constant.\n'], r));
  end
  
  % append them to output array
  outmat = horzcat(outmat, acts');
  
end

% pad the rest with zeros
numcols = 30;
outmat = horzcat(outmat, zeros(T, numcols - r));

% create the submission file with header:
fid = fopen(subfile, 'wt');
  fprintf(fid, header);
fclose(fid);

% fill in submission data
dlmwrite(subfile, outmat, '-append', 'delimiter', '\t');

fprintf('submission file %s created by ebc_feature_rater.m\n', subfile);

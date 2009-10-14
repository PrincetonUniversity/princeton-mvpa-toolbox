function [errors warnings] = test_write_to_afni ()

% [ERRORS WARNINGS] = test_write_to_afni ()
%
% IDEA: Test out write_to_afni's writing capabilities on a few different
% types of datasets.
%
% Warning: Will copy a BRIK from one of Matt's analyses to use as a sample.
% It should delete the BRIK when it's done, but you might check to make
% sure.
%
%
%       mjw 3/23/06

sampledir = '/jukebox/osherson/mattheww/similarity/201/analysis';
workingdir = pwd;
sz = [64 64 33];
szstr = [num2str(sz(1)) ' ' num2str(sz(2)) ' ' num2str(sz(3)) ' '];
nTRs = 100;
nTRs2 = 15;

kill = {};

cd(sampledir);
sb = findSampleBrik(szstr);
disp(['Copying ' sampledir '/' sb ' to ' pwd '/' sb '...']);
unix(['cp ' sb '.* ' workingdir '/.']);
disp('Copying successful.');
cd(workingdir);

kill{length(kill)+1} = [sb '.BRIK'];
kill{length(kill)+1} = [sb '.HEAD'];
kill{length(kill)+1} = ['allvolszeros_' sb '.*'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% SUBJECT CREATION                               %%%%%
%%%%%   Find "WTA TESTING" if you want to skip this. %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Initializing subject...');

% initialize subject
subj = init_subj('WTA_TEST','wta_subj');

% create a vol of zeros
zvol = zeros(sz);

% create & initialize a spherical mask
vctr = sz/2;
rad = 10;
mvol = sphmask(sz,vctr,rad);
subj = init_object(subj,'mask','wta_mask');
subj = set_mat(subj,'mask','wta_mask',mvol);

% create & initialize a masked pattern of random data
% this is a big pattern, and we want to write it to disk in steps, broken
% up into several-TR chunks.
nvox = length(find(mvol));
pat = NaN(nvox,nTRs);
%%% this pattern has high average values toward the middle voxels
%%% that's so we can get some variance in the statmap, which is just the
%%% mean.
coeffmat = ((nvox/2)*ones(nvox,1)-(1:nvox)').^2;
coeffmat = coeffmat/max(coeffmat);
coeffmat = 1 - coeffmat;
for i = 1:nTRs
    randTR = rand(nvox,1);
    currTR = .5*randTR + .5*coeffmat;    
    pat(:,i) = currTR;
end
subj = init_object(subj,'pattern','wta_data1');
subj = set_mat(subj,'pattern','wta_data1',pat);
subj = set_objfield(subj,'pattern','wta_data1','masked_by','wta_mask');

% create & initialize a smaller, multi-TR pattern that we can write out to
% disk all at once. This is going to look a bit different from the first
% pattern, just so I know what's going on -- here, voxels with bigger
% numbers are more active.
coeffmat = ((1:nvox)'/nvox);
for i = 1:nTRs2
    randTR = rand(nvox,1);
    currTR = .5*randTR + .5*coeffmat;
    pat2(:,i) = currTR;
end
subj = init_object(subj,'pattern','wta_data2');
subj = set_mat(subj,'pattern','wta_data2',pat2);
subj = set_objfield(subj,'pattern','wta_data2','masked_by','wta_mask');

% create & initialize a statmap from the big pat.
meanmap = mean(pat')';
subj = init_object(subj,'pattern','wta_statmap');
subj = set_mat(subj,'pattern','wta_statmap',meanmap);
subj = set_objfield(subj,'pattern','wta_statmap','masked_by','wta_mask');

% create a runs selector.
runs = ceil((1:nTRs)/25);
subj = init_object(subj,'selector','runs');
subj = set_mat(subj,'selector','runs',runs);

disp('Subject successfully initialized.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% WTA TESTING                                    %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function [] = write_to_afni(subj,objtype,objin,sample_filename,varargin)
% relevant varargin options:
% output_filename
% runs
% do_zeroify

errors = {};
warnings = {};

disp('Testing WTA on the mask.');
try
    current_test = 'mask';
    write_to_afni(subj,'mask','wta_mask',sb);
    kill{length(kill)+1} = 'wta_mask+orig.BRIK';
    kill{length(kill)+1} = 'wta_mask+orig.HEAD';
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end
    
disp('Testing WTA on the statmap.');
try
    current_test = 'statmap';
    write_to_afni(subj,'pattern','wta_statmap',sb);
    kill{length(kill)+1} = 'wta_statmap+orig.BRIK';
    kill{length(kill)+1} = 'wta_statmap+orig.HEAD';
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

disp('Testing WTA and ''output_filename'' option on the small pattern.');
try
    current_test = 'smallpat';
    write_to_afni(subj,'pattern','wta_data2',sb,'output_filename','wta_sm');
    kill{length(kill)+1} = 'wta_sm+orig.BRIK';
    kill{length(kill)+1} = 'wta_sm+orig.HEAD';
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

disp('Testing WTA and ''runs'' option on the big pattern.');
try
    current_test = 'bigpat';
    write_to_afni(subj,'pattern','wta_data1',sb,'runs','runs');
    kill{length(kill)+1} = 'wta_data1+orig.BRIK';
    kill{length(kill)+1} = 'wta_data1+orig.HEAD';
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

disp('Reading up the BRIKs and comparing to stored data...')

try
    current_test = 'Loading mask';
    subj = load_afni_mask(subj,'wta_mask_VAL','wta_mask+orig.BRIK');
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

try
    current_test = 'Loading statmap';
    subj = load_afni_pattern(subj,'wta_statmap_VAL','wta_mask','wta_statmap+orig');
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

try
    current_test = 'Loading small pattern';
    subj = load_afni_pattern(subj,'wta_data2_VAL','wta_mask','wta_sm+orig');
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

try
    current_test = 'Loading big pattern';
    subj = load_afni_pattern(subj,'wta_data1_VAL','wta_mask','wta_data1+orig');
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

try    
    current_test = 'Comparing masks';
    mat = get_mat(subj,'mask','wta_mask');
    matVAL = get_mat(subj,'mask','wta_mask_VAL');    
    badvox = find(~(mat==matVAL));
    if length(badvox)
        w = length(warnings) + 1;
        warnings{w} = 'Masks not equal.';
    end
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

try    
    current_test = 'Comparing statmaps';
    mat = get_mat(subj,'pattern','wta_statmap');
    matVAL = get_mat(subj,'pattern','wta_statmap_VAL');
    badvox = mat-matVAL > .0001;
    if length(find(badvox))
        w = length(warnings) + 1;
        warnings{w} = 'Statmaps not equal.';
    end
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

try
    current_test = 'Comparing small patterns';    
    mat = get_mat(subj,'pattern','wta_data2');
    matVAL = get_mat(subj,'pattern','wta_data2_VAL');
    badvox = mat-matVAL > .0001;
    if length(find(badvox))
        w = length(warnings) + 1;
        warnings{w} = 'Small patterns not equal.';
    end 
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

try
    current_test = 'Comparing big patterns';
    mat = get_mat(subj,'pattern','wta_data1');
    matVAL = get_mat(subj,'pattern','wta_data1_VAL');
    badvox = mat-matVAL > .0001;
    if length(find(badvox))
        w = length(warnings) + 1;
        warnings{w} = 'Big patterns not equal.';
    end    
catch
    e = length(errors) + 1;
    le = lasterror;
    ce.test = current_test;
    ce.lasterr = lasterror;
    errors{e} = ce;
end

for k = 1:length(kill)
    disp(['rm -f ' kill{k}]);
    unix(['rm -f ' kill{k}]);
end

if length(errors) | length(warnings)
    disp('Saving subj in case you want to examine it.');
    save_subj(subj);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create a spherical mask 
% 
function [mvol] = sphmask(sz,vctr,rad)

mvol = zeros(sz);

for x = 1:sz(1)
    for y = 1:sz(2)
        for z = 1:sz(3)
            c = [x y z]-vctr;
            if sqrt(c(1)^2+c(2)^2+c(3)^2) <= rad
                mvol(x,y,z) = 1;
            end
        end
    end
end

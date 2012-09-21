clear all

% Author: Alex Ahmed (alex.ahmed AT yale DOT edu)

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

%set data_dir equal to the path to your data directory
data_dir = '';
cd(data_dir)

%find all the files
files = dir(fullfile(data_dir));
numfiles = size(files,1);
subjects = {};
num_subjects = 1;

%Starts at 3 because 1 and 2 are "." and ".."
for n = 3:numfiles

    %this section is specific to our experiments and was made to find only
    %the directories that hold subject data. If all the folders in your
    %data directory correspond to subjects, you can remove this section and
    %simply let the array "subjects" be equal to all the folders in the
    %directory
    if files(n).isdir == 1
        if strcmp(files(n).name(1:2),'AC') || strcmp(files(n).name(1:2),'CC')
            subjects{num_subjects} = files(n).name;
            num_subjects = num_subjects+1;
        end
    end
    
end

%import VTC data of each subject. Change x to be a range of the folders
%that correspond to subjects. I ran into memory errors while doing this, 
%even while using "clear" to remove the present data after saving,
%so I had to do it in parts (hence why it only goes from 41 to 44 here)

%This creates a series of Subject1.mat...Subject"x".mat files that are used as input for load_bv_pattern 
for x = 41:44
   cd(subjects{x})
   vtcname = dir('*vtc');
   vtc_obj = xff(vtcname.name);
   
   vtc_data = vtc_obj.VTCData;
   
   save(['C:\Documents and Settings\pelphreylab\My Documents\MATLAB\mvpa\VTC Data\Subject' num2str(x) '.mat'],'vtc_data');
   clear vtc_obj
   clear vtc_data
   cd ..
end
function save = write_to_spm(subj,objtype,objin,varargin)

% Writes an MVPA data object or group to a SPM file.
%
% [] = WRITE_TO_SPM(SUBJ,OBJTYPE,OBJNAME,...)
%
%% Required Fields
%
% Writes an MVPA object in the subject structure SUBJ to an SPM file.  This
% structure is to be of type OBJTYPE and must corespond to the specified
% OBJNAME.  This OBJNAME can be either and object name, a group name or a
% cell arry of object names.
%
% SUBJ: The subject file that contains the data to be saved.  This object
% is required.
%
% OBJTYPE: The type of object to be saved by the function.  Currently it
% supports patterns and masks.  This is simply a string indicating the
% type.
%
% OBJNAME: The name of the object to be saved.  This is to be a string
% defining the name of the object.
%
%% Options:
%
% OUTPUT_FILENAME(string/*OBJNAME): Subverts OBJNAME as the string to be used when
% generating the output file name.  It must be of the same type and form of
% the OBJNAME provided earlier.  If this option is not used then the prefix
% for all output files will be the value of OBJNAME.
%
% PATHNAME(string/*''): This alters the distination of the final files to be
% created  This path is relative to the current working directory.  This
% directory must also already exsist.
%
% ONEMINUS(True/*False): If true, this will write out 1-M (where M is your
% matrix). This is useful if you're writing out an anova statmap of p
% values, where low is better. 1-p will reverse things so that higher is
% better when you write it out for convenience. Note: this has been tweaked
% so that zero values stay as zero
%
% NEW_HEADER(True/*False): This command option tells the script to generate
% a new header.
%
% VOXEL_DIMS([double double double]/*[2 2 2]): This function takes an array
% of 3 numbers that indicate the mm resolution of the voxels being saved.
% This value set can be retrieved using the function
% 'spm_extrac_voxel_dims' on a pre existing pattern
%
%
% PADDING(integer): This option is to be included if you wish to specify
% the number of numbers used in a naming scheme so if this is a five and
% you had 250 entries the filenames would include a number ranging from
% 00001 to 00250. (counting starts from zero.)  This will however be
% ignored if the number is smaller than the maximum width.  So if you
% specify a 2 with 300 entries, the numbers will display 001 - 300 not 1 -
% 300.  This function will only have an effect if you are saving a group of
% files.  Single patterns have no innate numeric association so this is not
% used in that context, files can still be tagged with arbitrary numbers by
% using the OUTPUT_FILENAME variable.
%
% FEXTENSION(*'.nii'/'.img')
% If unset, this will assume you wish to run the tutorial against nifti
% data.  If set to '.img' it will change to using the analyze data set.
%
% Notes: This function currently requires the use of the SPM5 library it
% will save files in 4D format, so all time series of a given pattern are
% in a single file.  Files in a group will each have a separate number
% starting at 1 and extending to the last object in the group.
%
% Other Potholes:  There is a special case of patterns in which this function
% will not work (currently).  This is the instance where multiple files
% worth of data are stores in one pattern area.  This will happen if you
% load several files into a single pattern object (eg. the 'epi' pattern
% created when running tutorial_easy_spm).  You can however save these
% patterns to disk but you will have to generate a new header and all of
% the data will be stored in a single spm file instead of multiple spm
% files.


%% License:
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

%% Test the basic validity of the object and setup some basics reqs.
% Test that the requested save is both a valid name and only a valid name
% for either a group or an object not both.  Also it makes sure there is
% only one instance of the name.
[obj_name isgroup] = find_group_single(subj,objtype,objin);



%% Handle the setup of all defaults for the function.
% assume the output filenames can be based off the object names
% assume there is no change to the current path by default
defaults.output_filename   = '';
defaults.pathname           = '';
% Turn off Oneminus effect unless it's called for in optional arguements.
defaults.oneminus           = false;
% set the initial file name padding to zero unless overwritten:
defaults.padding = 0;
%preload new headers option to false.
defaults.new_header = false;
%setup the default voxel dimensions
defaults.voxel_dims = [2 2 2];
defaults.fextension = '.nii';


% collect that other arguements made into a variable for analysis. and load
% them in as replacements for the defaults as applicable.

args = propval(varargin,defaults);

%populate the requisit values based on defaults or args.
%output_filename
if (isfield(args,'output_filename'))
    output_filename=args.output_filename;
else
    output_filename=defaults.output_filename;
end

%pathname

if (isfield(args,'pathname'))
    pathname=args.pathname;
else
    pathname=defaults.pathname;
end
%oneminus
if (isfield(args,'oneminus'))
    oneminus=args.oneminus;
else
    oneminus=defaults.oneminus;
end
%padding
if (isfield(args,'padding'))
    padding=args.padding;
else
    padding=defaults.padding;
end
%new_header
if (isfield(args,'new_header'))
    new_header=args.new_header;
else
    new_header=defaults.new_header;
end
%default voxel size
if (isfield(args,'voxel_dims'))
    voxel_dims=args.voxel_dims;
else
    voxel_dims=defaults.voxel_dims;
end
%setup the file extension to be used by the function.
if (isfield(args,'fextension'))

    %if STRCMP(args.type,'analyze')
    fextension=args.fextension;

else

    fextension = defaults.fextension;


end


%% Start loop based on the number of objects to be processed.
% The code should be run for each object in the group, or for the single
% object.  So cur_object is the single object or the current object in the group.
num_in_group=length(obj_name);

for cur_object_index=1:num_in_group


    %% Path Handling
    % generate the padded index string for this index
    s_cur_object_index=num2str(cur_object_index);

    if (padding > length(s_cur_object_index))
        tmp(1:padding)='0';

        tmp(end-(length(s_cur_object_index)-1):end)=s_cur_object_index(:);
        s_cur_object_index=tmp;

    end


    % Generate the final path if there is one to generate at all.
    final_path='';
    %first generate it based on output_filename
    if ~(strcmp(output_filename,''))


        if (isgroup)
            final_path= [output_filename '_' s_cur_object_index];
        else
            final_path = output_filename;
        end

        final_path=[final_path fextension]; %#ok<AGROW>

    end
    %if you have to add a path, overwrite the output_filename (since you
    %don't have internal knowledge of whether it was done or not, this
    %should be as fast as testing for final_path having changed).
    if ~(strcmp(pathname,''))

        if (strcmp(output_filename,''))
            final_path = [pathname '/' objname];
        else
            final_path = [pathname '/' output_filename];
        end

        if (isgroup)
            final_path= [final_path '_' s_cur_object_index]; %#ok<AGROW>
        end

        final_path = [final_path fextension]; %#ok<AGROW>

    end

    %% Capture the current object
    % capture the object name for future use.
    cur_obj_name = obj_name{cur_object_index};
    % Load the data into a local object to be processed.
    cur_pattern_matrix = get_mat(subj, objtype, cur_obj_name);
    % find out how many specific voxels you will be saving.
    cur_voxel_count = size(cur_pattern_matrix);


    %% Adjust for One Minus
    % Test for the oneminus flag and act on it now that you have the
    % cur_pattern_matrix.
    if (oneminus)
        cur_pattern_matrix=1-cur_pattern_matrix;
    end


    % switch statement will handle this nicely, allowing for setup before
    % saving each file.  The object type will also control how the loop is
    % executed and some early setup but otherwise the function is the same and
    % will simply be called once the setup is done.

    % Calculate the size of the pattern your working with.


    %% Selector for either mask or pattern saving.
    switch lower(objtype)
        case {'mask'}
            %% Switch/MASK: capture pattern
            masked_pattern_matrix=cur_pattern_matrix; %fix so that the mask and the pattern saves are inline with each other.
            % if you are working with a mask the 'mask' of the item being written is
            % simply an array of ones the size of the data set you are writing.  This
            % is due to the fact that we want to save a mask which means saving all of
            % it's ones and zero's not just it's non zero values (which are the
            % relevant values in other patterns).  The dimensions of the mask are
            % simply the size of the pattern_matrix (mask) being saved.  And the
            % pattern projection is simply the pattern matrix.  The loop must be based
            % on the number of different data sets that must be saved, these data sets
            % are 3D so the 4th value in the masks voxel count is in fact the 'time
            % index' which realistically should be one for all masks.  Unless you've
            % somehow defined a dynamic mask for relevant data.
            %% Switch/MASK: Adjust pattern to be treated as 4D
            pattern_size=size(cur_pattern_matrix);
            %if (length(pattern_size) ==3)
            if isequal(length(pattern_size),3)
                pattern_size(4)=1;
            end

            % capture the volume information from the previous spm load command. (this
            % should be modified to be more dynamic by say calling a function to parse
            % this information out of a centrally stored set of data.  This would allow
            % for on the fly format changes.)
            %% Switch/MASK: Setup volume
            % as a cell structure, generate new header if needed, also
            % set filenames if required
            cur_vol=cell(1);
            if (~new_header)
                cur_vol{:} = get_objsubfield(subj, objtype, cur_obj_name,'header','vol');

                if ~(strcmp(final_path,''))
                    for fname_index=1:pattern_size(4)
                        cur_vol{1}(fname_index).fname=final_path;
                        if (isfield(cur_vol,'private'))
                            cur_vol.private.dat.fname=final_path;
                        end
                    end

                end
            else
                %if you ask for a new header then it will be generated here instead of being retrieved from the obj sub field.
                % Current Work.

                if (strcmp(final_path,''))
                    if (isgroup)
                        cur_vol=gen_vol_info(pattern_size(1:3),pattern_size(4),[cur_obj_name '_' s_cur_object_index fextension],voxel_dims);
                    else
                        cur_vol=gen_vol_info(pattern_size(1:3),pattern_size(4),[cur_obj_name fextension],voxel_dims);
                    end
                else
                    cur_vol=gen_vol_info(pattern_size(1:3),pattern_size(4),final_path,voxel_dims);
                end
            end


            %% Switch/MASK: Legacy cell insurance
            % This being matlab a variety of the objects must be cell arrays for
            % things to behave properly.  As such some corrections must be made to the
            % volume that was extracted if it is not a cell array.  Rebuild it as a
            % cell array to fix this problem.
            if ~iscell(cur_vol)
                temp = cur_vol;
                cur_vol = cell(1);
                cur_vol{1} = temp;
                clear temp;
            end
            %% Switch/MASK: Loop to write out the file, masks should only loop once.
            for cur_vol_index=1:pattern_size(4)%i need the 1xn value, so this gets it.

                %This 'magic number' 1 in the cell call to vol is a necessary
                %evil.  Vol is populated as a 1x1 cell, this 1x1 cell contains
                %an array of structures that control the actual layout of each
                %section of the volume.
                save = spm_write_vol(cur_vol{1}(cur_vol_index), masked_pattern_matrix(:,:,:,cur_vol_index));
            end




        case {'pattern'}

            %% Switch/PATTERN:



            % first.  Establish the mask that you will be working with for a given
            % pattern matrix.
            %% Switch/PATTERN: Capture data and mask.
            masked_by = get_objfield(subj,'pattern',cur_obj_name,'masked_by');
            mask_matrix = get_mat(subj,'mask',masked_by);
            % second. Calculate the size of the mask so you know what's going to be
            % saved.
            mask_dims = size(mask_matrix);
            % Masked pattern projection creation: basically you take a mask and a
            % pattern.  For each time point in the pattern you apply it to the next 1
            % in the mask you have associated with it.  This builds a 3D image of the
            % particular time relevant pattern you are working with for saving.
            masked_pattern_matrix=zeros(mask_dims(1),mask_dims(2),mask_dims(3),cur_voxel_count(2));
            % Generate a map of the relative mask information, this is
            % basically an array of the relevant indexes in 1D space
            % instead of 3D space.
            relative_map_of_mask = find(mask_matrix);
            % calculate the mask volume.(LxWxH)
            mask_size=mask_dims(1)*mask_dims(2)*mask_dims(3);
            % Populate the masked_pattern_matrix based on the relative
            % maps list of indexes offset by so that you populate the
            % mask in 4D.
            %% Switch/PATTERN: Set to 4D if it is not already
            pattern_size=size(masked_pattern_matrix);
            %if (length(pattern_size) ==3)
            if isequal(length(pattern_size),3)
                pattern_size(4)=1;
            end


            %% Switch/PATTERN:Setup volume, header and filename info
            % capture the volume information from the previous spm load command. (this
            % should be modified to be more dynamic by say calling a function to parse
            % this information out of a centrally stored set of data.  This would allow
            % for on the fly format changes.)
            if (~new_header)
                cur_vol = get_objsubfield(subj, objtype, cur_obj_name,'header','vol');

                if ~(strcmp(final_path,''))
                    for fname_index=1:pattern_size(4)
                        cur_vol{1}(fname_index).fname=final_path;
                        if (isfield(cur_vol,'private'))
                            cur_vol.private.dat.fname=final_path;
                        end
                    end

                end
            else

                if (strcmp(final_path,''))
                    if (isgroup)
                        cur_vol=gen_vol_info(pattern_size(1:3),pattern_size(4),[cur_obj_name '_' s_cur_object_index fextension],voxel_dims);
                    else
                        cur_vol=gen_vol_info(pattern_size(1:3),pattern_size(4),[cur_obj_name fextension],voxel_dims);
                    end
                else
                    cur_vol=gen_vol_info(pattern_size(1:3),pattern_size(4),final_path,voxel_dims);
                end
            end


            %% Switch/PATTERN: Legacy cell insurance.  (may be able to deprecate)
            % This being matlab a variety of the objects must be cell arrays for
            % things to behave properly.  As such some corrections must be made to the
            % volume that was extracted if it is not a cell array.  Rebuild it as a
            % cell array to fix this problem.
            if ~iscell(cur_vol)
                temp = cur_vol;
                cur_vol = cell(1);
                cur_vol{1} = temp;
                clear temp;
            end

            %% Switch/PATTERN: Load 4D pattern using mask
            for index=1:cur_voxel_count(2)
                masked_pattern_matrix(relative_map_of_mask(:)+((index-1)*mask_size))=cur_pattern_matrix(:,index);
            end

            %% Switch/PATTERN: Loop to save file in 4D
            for cur_vol_index=1:pattern_size(4)%i need the 1xn value, so this gets it.

                %This 'magic number' 1 in the cell call to vol is a necessary
                %evil.  Vol is populated as a 1x1 cell, this 1x1 cell contains
                %an array of structures that control the actual layout of each
                %section of the volume.
                save = spm_write_vol(cur_vol{1}(cur_vol_index), masked_pattern_matrix(:,:,:,cur_vol_index));
            end

    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sub Function for Making fake headers.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [header] = gen_vol_info(dims, time_slices, file_name,voxel_dims)

%% code recommended by Thomas Nichols, SPM mailing list

unmasked_size = dims(1)*dims(2)*dims(3);

% blind default for sizing of voxels as a 'happy medium' value.
Origin = dims/2;
mat = diag([voxel_dims 1]);
mat(1:3,4)= -Origin.*voxel_dims;
%% end recommended code.





for index=1:time_slices
    header(index).dt = [spm_type('float64') spm_platform('bigend')]; %#ok<AGROW>
    header(index).dim = dims; %#ok<AGROW>
    header(index).mat=mat; %#ok<AGROW>
    header(index).n=[index 1]; %#ok<AGROW> %guarantees that the indexing is correct
    header(index).descrip = 'Generated by MVPA write_to analyze script'; %#ok<AGROW>
    header(index).fname = file_name; %#ok<AGROW>
    header(index).pinfo = [1; 0; (unmasked_size*(index-1))]; %#ok<AGROW>

end



end



















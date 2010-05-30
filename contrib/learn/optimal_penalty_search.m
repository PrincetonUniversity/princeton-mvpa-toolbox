function [subj best_penalties penalty_iteration_results results] = optimal_penalty_search(subj,patin,regsname,selgroup,runs_selname,mask,actives_selname,varargin)

% Determines effective penalties from training data and applies the best in
% a testing classification.
%
% [SUBJ BEST_PENALTIES PENALTY_ITERATION_RESULTS RESULTS] = OPTIMAL_PENALTY_SEARCH(SUBJ,PATIN,REGSNAME,SELGROUP,RUNS_SELNAME,MASK,ACTIVES_SELNAME...)
%
% This script first applies a broad range of penalties (0 0.01 0.1 1.0 10
% 100 1000 10000) to classifications on training data, then conducts a
% narrower targeted search around the penalty with the highest performance,
% and finally runs a classification on test data using the best overall
% penalty.  The preferred classifier can be specified in an optional
% argument (default = ridge regression).  Training data is used for penalty
% selection to avoid indirectly peeking (as otherwise subsequent
% classification success could in part be the result of choosing the
% perfect penalty for the test data).  To achieve this, the script creates
% an appropriate selector group with the final testing data zero'd out and
% a 'training' iteration labeled for testing.  Users also have the option
% of providing their own penalty selector group to use instead.
%
% One major option built into the script is whether the penalty search and
% final penalty selection is based on the total performance (i.e. averaged
% iteration performance) or if it is conducted on iterations independently.
% Why do this whole process separately for each iteration? Selecting
% penalties using the total (very, very) indirectly involves the test data:
% although each iteration is careful not to touch its particular testing
% dataset, the total performance is influenced by all the data (from
% averaging the iteration results), so strictly speaking every datapoint is
% then influencing the choice of penalty that later will be applied to all
% iterations.  This is subtle, and using iteration performance has a
% downside: each iteration ends up with its own (often different) penalty,
% therefore not giving one penalty for the entire classification.  For this
% reason the default is to use the total performance.  If the iteration
% approach is chosen (through setting USE_ITERATION_PERF to true), the
% narrower search and final classification are conducted on one iteration
% at a time, and the final results structure will contain results from
% iterations that have each used their own best penalty.
%
% The outputs include: 
% - The recommended penalties in BEST_PENALTIES.  This is one value if
%   total performance is used for the search (default) and a 1 x niterations
%   vector if iteration performance is selected.
% - A record of all penalties tried, with corresponding accuracies for
%   every iteration, in PENALTY_ITERATION_RESULTS.  The last row gives the
%   total performance if this is used for penalty selection.
% - A plot of classification accuracy against penalties.
% - Results structure from the final classification.  This will not be
%   produced if the PERFORM_FINAL_CLASSIFICATION optional argument is set
%   to false.
%
% Adds the following objects:
% - results structure (if PERFORM_FINAL_CLASSIFICATION is kept at default) 
% - nonpeeking selector group from the penalty search (if
%   CREATE_NONPEEKING_SELECTOR is kept at default)
% - a 'no rest' penalty search selector group (only if the user declines
%   the default creation of a selector and so provides a custom
%   NONPEEKING_SELECTOR, AND a 'no rest' selector i.e. ACTIVES_SELNAME is
%   not set to 'none').
% - a feature selection pattern group ('PATIN_pen_anova') and mask group
%   ('PATIN_pen_thresh0.05') if RUN_FEATURE_SELECT is changed to true.
%
% PATIN is the dataset that will be fed into the classifications.  It will
% be used by CROSS_VALIDATION ('help CROSS_VALIDATION' gives details on the
% form it can take).
%
% REGSNAME is the regressor matrix that will be given to CROSS_VALIDATION
% for evaluating penalties and performing the final classification.
%
% SELGROUP is the selector group for the final cross-validation i.e. when
% the best penalties are applied.  It should follow the same format as
% selectors produced by CREATE_XVALID_INDICES, where 2s indicate testing
% timepoints, 1s are for training, and 0s are ignored.  For creating the
% non-peeking penalty search selector (i.e. when CREATE_NONPEEKING_SELECTOR
% is kept at its default), it is important that SELGROUP follows the
% CREATE_XVALID_INDICES format of testing timepoints falling on an
% iteration number - e.g. for 3 runs containing 3 timepoints, the 2nd
% selector of the group would be: [111222111]. The easiest way to do this
% is to use CREATE_XVALID_INDICES.  SELGROUP can be anything (e.g. 'none')
% if PERFORM_FINAL_CLASSIFICATION is set to false, as it won't be used.
%
% RUNS_SELNAME is a selector of timepoints labeled by how they should be
% broken up during cross validation.  It is used to create the non-peeking
% penalty search selector but should be provided even if you provide your
% own search selector.  It is the same as RUNS_SELNAME in
% CREATE_XVALID_INDICES.  If you are training and testing on different runs
% and have 4 TRs in each run, it would look like: [1 1 1 1 2 2 2 2 3 3 3 3
% 4 4 4 4].  If your cross-validation is not across runs, this selector
% should reflect that. It cannot contain zeros (ACTIVES_SELNAME allows you
% to exclude timepoints).
%
% MASK is the group of masks (one per iteration) or single mask (e.g.
% anatomical) that will be fed into CROSS_VALIDATION during the penalty
% search and subsequent classification.  If RUN_FEATURE_SELECT (see below)
% is set to true, this can be anything e.g. 'none'.
%
% ACTIVES_SELNAME is a no rest selector to apply to the created non-peeking
% selector.  It is deliberately not an optional argument - for the penalty
% accuracies to be most applicable, the data used in selection should be as
% similiar as possible to the subsequent classification data. Note: this no
% rest selector is not applied to the final classification selector
% (SELGROUP), as it's assumed this has already been applied during
% CREATE_XVALID_INDICES.  Use 'none' (including apostrophes) if you do not
% want to apply a no rest selector.
%
% NPENALTIES(optional,default = 10). The number of penalties searched
% through in the narrower search.  If USE_ITERATION_PERF is set to true,
% this will be the number of penalties examined for every iteration. The
% best penalty is taken from the broad search and NPENALTIES distributed
% around it are evaluated. The lower bound for this narrower search is set
% at half the best penalty, and the upper bound is half the next broad
% search penalty. E.g. If 10 is the best from the broad search (where 1 and
% 100 were either side), this narrower search will look at NPENALTIES
% between 5 (50% of 10) and 50 (50% of 100).
%
% CREATE_NONPEEKING_SELECTOR(optional,default = true). If set to false, a
% nonpeeking selector will not be created for the penalty search. In this
% case you must specify a NONPEEKING_SELECTOR to use instead.
%
% NONPEEKING_SELECTOR(optional,default = []). The selector to use for the
% penalty search if CREATE_NONPEEKING_SELECTOR is switched to false.
%
% PERFORM_FINAL_CLASSIFICATION(optional,default = true). If false, stops
% the script just before the final classification.  This will give you the
% best penalties, a record of accuracies for different penalties, and any
% selectors created.  It will not give a results structure so this should
% not be included in the output arguments if this is set to false.
%
% PENALTY_SELNAME(optional,default = {'pen_selector'}). Specifies the
% name of the created nonpeeking penalty search selector.
%
% USE_ITERATION_PERF(optional,default = false). Performs the penalty search
% for each iteration separately, giving a different optimal penalty for
% every iteration, which are then applied in the final classification
% (see above for a description of why this is an option).
%
% CLASS_TRAIN(optional,default = 'train_ridge'). The training function
% given to class_args.train_funct_name.  This should be a penalty based
% classifier.  The script runs ridge regression if no argument is given.
%
% CLASS_TEST(optional,default = 'test_ridge'). The testing function
% given to class_args.test_funct_name.  This should be a penalty based
% classifier.  The script runs ridge regression if no argument is given.
%
% RUN_FEATURE_SELECT(optional,default = false). If set to true, implements
% an ANOVA feature selection (p < 0.05) specifically on data that doesn't
% later contribute to testing different penalties (or to the final
% classification). The feature selection masks are then used in the penalty
% search and final classification.  This gives the advantage of trying out
% penalties on data that hasn't contributed to feature selection, making it
% similar to the final classification data that the best penalty will be
% applied to. If set to true, the mask given in the input arguments can be
% anything (e.g. 'none') since the ANOVA masks will be used instead.
%
% =====================================================================
%
% Authored by Marc Coutanche, University of Pennsylvania.
%
% This script is written to work with the Princeton MVPA toolbox.  See
% http://www.csbmb.princeton.edu/mvpa for more information.
%
% No responsibility is taken for any problems that may be related to the
% use of this script.
%
% =====================================================================


defaults.npenalties = 10;
defaults.create_nonpeeking_selector = true;
defaults.nonpeeking_selector = [];
defaults.perform_final_classification = true;
defaults.penalty_selname = 'pen_selector';
defaults.use_iteration_perf = false;
defaults.class_train = 'train_ridge';
defaults.class_test = 'test_ridge';
defaults.run_feature_select = false;
args = propval(varargin, defaults);


% First, some error checking - Make sure users that ask for no final
% classification are not trying to collect a results structure:
if args.perform_final_classification == false
    if nargout == 4
        error('You cannot collect a results structure if PERFORM_FINAL_CLASSIFICATION is set to false.  Try again with just three output arguments.');
    end
end

% Ensure the user is not specifying which pre-existing selector should be
% used for the penalty search while also asking the script to create a
% non-peeking selector:
if args.create_nonpeeking_selector == true
    if exist_group(subj,'selector',args.nonpeeking_selector)== 1
        error('You have kept the CREATE_NONPEEKING_SELECTOR argument at its default (true) but have also given a name for NONPEEKING_SELECTOR.  Set CREATE_NONPEEKING_SELECTOR to false or remove the NONPEEKING_SELECTOR input argument.')
    end
end

runs_selname=get_mat(subj,'selector',runs_selname);

% Preparation for when object names will be needed later:
if args.run_feature_select == false
[masknames] = find_group_single(subj,'mask',mask,'repmat_times',max(runs_selname));
end
if args.perform_final_classification == true
    [selectornames] = find_group_single(subj,'selector',selgroup,'repmat_times',max(runs_selname));
end

% Create a non-peeking selector group, if the user hasn't said otherwise:
if args.create_nonpeeking_selector == true

    for i=1:max(runs_selname)
        pen_selector{i}=ones(1,length(runs_selname));
        for j=1:length(runs_selname)
            if runs_selname(j)==i
                pen_selector{i}(j)=0;
            end
        end
        if i == max(runs_selname)
            for j=1:length(runs_selname)
                if runs_selname(j)==1
                    pen_selector{i}(j)=2;
                end
            end
        else
            for j=1:length(runs_selname)
                if runs_selname(j)==i+1
                    pen_selector{i}(j)=2;
                end
            end
        end
    end

    % Apply any specified no-rest (or otherwise) selector:
    if strcmp(actives_selname,'none') == 0
        for i=1:length(pen_selector)
            pen_selector{i} = pen_selector{i}.* get_mat(subj,'selector',actives_selname);
        end
    end

    % Add the new selector group to the subject structure, with associated
    % details:
    for i=1:length(pen_selector)
        subj=initset_object(subj,'selector',sprintf('%s_%i',args.penalty_selname,i),pen_selector{i},'group_name',args.penalty_selname);

        sprintf('Created %s called %s','selector',sprintf('%s_%i',args.penalty_selname,i))
        created.function = 'optimal_penalty_search';
        created.runs_selname = runs_selname;
        if  strcmp(actives_selname,'none') == 0
            created.actives_selname = actives_selname;
        end
        subj = add_created(subj,'selector',sprintf('%s_%i',args.penalty_selname,i),created);
        object_hist = sprintf('Created by optimal_penalty_search for nonpeeking evaluation of penalties - iteration #%i',i);
        subj = add_history(subj,'selector',sprintf('%s_%i',args.penalty_selname,i),object_hist);
    end

else

    % If the user said no to creating a nonpeeking selector, check they
    % have given a selector group to use instead:
    if exist_group(subj,'selector',args.nonpeeking_selector)== 0
        error('You have set CREATE_NONPEEKING_SELECTOR to false but have either not provided an alternative selector group or have given an incorrect group name.  Use the NONPEEKING_SELECTOR argument to give a group name, or change CREATE_NONPEEKING_SELECTOR to true.');
    end

    % If a no-rest selector is specified, apply it to the given penalty
    % search selector:
    nonpeeking_selector_names  = find_group(subj,'selector',args.nonpeeking_selector);
    if strcmp(actives_selname,'none') == 0
        for i = 1:length(nonpeeking_selector_names)
            norest_selgroup{i} = get_mat(subj,'selector',nonpeeking_selector_names{i}) .* get_mat(subj,'selector',actives_selname);

            % Add the new 'no rest' penalty search selector group to the
            % subject structure, with associated details:
            subj=initset_object(subj,'selector',sprintf('%s_norest_%i',args.nonpeeking_selector,i),norest_selgroup{i},'group_name',sprintf('%s_norest',args.nonpeeking_selector));
            sprintf('Created %s called %s','selector',sprintf('%s_norest_%i',args.nonpeeking_selector,i))
            created.function = 'optimal_penalty_search';
            created.actives_selname = actives_selname;
            subj = add_created(subj,'selector',sprintf('%s_norest_%i',args.nonpeeking_selector,i),created);
            object_hist = sprintf('Created by optimal_penalty_search - iteration #%i',i);
            subj = add_history(subj,'selector',sprintf('%s_norest_%i',args.nonpeeking_selector,i),object_hist);
        end
        args.penalty_selname = sprintf('%s_norest',args.nonpeeking_selector);
    else
        args.penalty_selname = args.nonpeeking_selector;
    end
end

% If feature selection has been requested in order to exclude
% penalty-search testing data (as well as final classification testing
% data), do this now and use the generated masks for all subsequent
% classifications:
if args.run_feature_select == true
    subj=feature_select(subj,patin,regsname,args.penalty_selname,'new_map_patname',sprintf('%s_pen_anova',patin),'new_maskstem',sprintf('%s_pen_thresh',patin));
    mask=sprintf('%s_pen_thresh0.05',patin);
    [masknames] = find_group_single(subj,'mask',mask,'repmat_times',max(runs_selname));
end

penalties=[];
penalty_accuracy=[];

% Conduct the first pass of trying different penalties:

% Run through classification on a wide range of penalty values:
broad_range = [0 0.01 0.1 1.0 10 100 1000 10000];
for class_pen = broad_range

    % Keep track of which penalties have been tried:
    penalties = [penalties class_pen];

    class_args.train_funct_name = args.class_train;
    class_args.test_funct_name = args.class_test;
    class_args.penalty = class_pen;

    [subj results] = cross_validation(subj,patin,regsname,args.penalty_selname,mask,class_args);

    % Record the iteration accuracies for each penalty:
    for i=1:length(results.iterations)
        penalty_accuracy(i,length(penalties)) = [results.iterations(i).perf];
    end
end

% Bring together the penalty values and respective iteration results:
penalty_results = [penalties ; penalty_accuracy];

% Next, take the best penalty from the broad search and try classifying on
% NPENALTIES (default = 10) distributed around it. The lower bound for this
% narrower search is set at half the best penalty, and the upper bound is
% set at half the next broad-search penalty. E.g. If 10 is the best from
% the broad search (where 1 and 100 were either side), this narrower search
% will look at penalties between 5 (50% of 10) and 50 (50% of 100):

% First, if USE_ITERATION_PERF is set to false, perform the narrower search
% using total performance:
if args.use_iteration_perf == false

    % Find the most accurate penalty from the broad search:
    penalty_total_results = [penalty_results(1,:) ; mean(penalty_results(2:size(penalty_results,1),:))];
    [acc whichmax] = max(penalty_total_results(2,:));

    % If the best penalty is the first broad search penalty (zero), only
    % search between that and the upper bound (there is no lower bound):
    if whichmax == 1
        for class_pen = penalty_results(1,whichmax):(penalty_results(1,(whichmax+1))/2)/(args.npenalties-1):penalty_results(1,(whichmax+1))/2
            % Keep track of the penalties tried:
            penalties = [penalties class_pen];

            class_args.train_funct_name = args.class_train;
            class_args.test_funct_name = args.class_test;
            class_args.penalty = class_pen;

            % Perform cross validation:
            [subj results] = cross_validation(subj,patin,regsname,args.penalty_selname,mask,class_args);

            % Record the iteration accuracies and penalty:
            for i = 1:max(runs_selname)
                penalty_accuracy(i,length(penalties)) = [results.iterations(i).perf];
            end
        end

        % If the best penalty was the last broad search value, try
        % NPENALTIES between the normal lower bound and an upper bound
        % beyond the broad search penalties (i.e. for 10,000 the upper
        % bound would be 50,000, from 10,000*10 / 2):
    elseif whichmax == length(broad_range)
        for class_pen = penalty_results(1,(whichmax))/2:((penalty_results(1,whichmax)*10)/2-penalty_results(1,(whichmax))/2)/(args.npenalties-1):(penalty_results(1,whichmax))*10/2

            % Keep track of the penalties tried:
            penalties = [penalties class_pen];

            class_args.train_funct_name = args.class_train;
            class_args.test_funct_name = args.class_test;
            class_args.penalty = class_pen;

            % Perform cross validation:
            [subj results] = cross_validation(subj,patin,regsname,args.penalty_selname,mask,class_args);

            % Record the accuracy for this penalty:
            for i = 1:max(runs_selname)
                penalty_accuracy(i,length(penalties)) = [results.iterations(i).perf];
            end
        end

        % For when the best penalty is not the first or last:
    else
        for class_pen = penalty_results(1,(whichmax))/2:(penalty_results(1,(whichmax+1))/2-penalty_results(1,(whichmax))/2)/(args.npenalties-1):penalty_results(1,(whichmax+1))/2

            % Keeping track of the penalties tried:
            penalties = [penalties class_pen];

            class_args.train_funct_name = args.class_train;
            class_args.test_funct_name = args.class_test;
            class_args.penalty = class_pen;

            % Perform cross validation:
            [subj results] = cross_validation(subj,patin,regsname,args.penalty_selname,mask,class_args);

            % Record the accuracy for this penalty:
            for i = 1:max(runs_selname)
                penalty_accuracy(i,length(penalties)) = [results.iterations(i).perf];
            end
        end     
    end
     penalty_accuracy(i+2,:) = mean(penalty_accuracy(1:i,:));
else

    % If the user has chosen to search for penalties for each iteration
    % (not total performance), do this now:
    for i = 1:max(runs_selname)
        % CROSS_VALIDATION takes in selector groups, so each selector iteration
        % is temporarily being assigned its own group:
        subj = set_objfield(subj,'selector',sprintf('%s_%i',args.penalty_selname,i),'group_name',sprintf('%s_%i_cv',args.penalty_selname,i));

        % Find the most accurate penalty from the broad search:
        [acc whichmax] = max(penalty_results(i+1,:));

        % If the best penalty is the first broad search penalty (zero), only
        % search between that and the upper bound (there is no lower bound):
        if whichmax == 1
            for class_pen = penalty_results(1,whichmax):(penalty_results(1,(whichmax+1))/2)/(args.npenalties-1):penalty_results(1,(whichmax+1))/2
                % Keep track of the penalties tried:
                penalties = [penalties class_pen];

                class_args.train_funct_name = args.class_train;
                class_args.test_funct_name = args.class_test;
                class_args.penalty = class_pen;

                % Perform cross validation using the one-iteration selector
                % group created above, and the correct iteration mask:
                [subj results] = cross_validation(subj,patin,regsname,sprintf('%s_%i_cv',args.penalty_selname,i),masknames{i},class_args);

                % Record the accuracy for this iteration and penalty (there
                % is only one iteration in this particular classification):
                penalty_accuracy(i,length(penalties)) = [results.iterations(1).perf];
            end

            % If the best penalty was the last broad search value, try
            % NPENALTIES between the normal lower bound and an upper bound
            % beyond the broad search penalties (i.e. for 10,000 the upper
            % bound would be 50,000, from 10,000*10 / 2):
        elseif whichmax == length(broad_range)
            for class_pen = penalty_results(1,(whichmax))/2:((penalty_results(1,whichmax)*10)/2-penalty_results(1,(whichmax))/2)/(args.npenalties-1):(penalty_results(1,whichmax))*10/2

                % Keep track of the penalties tried:
                penalties = [penalties class_pen];

                class_args.train_funct_name = args.class_train;
                class_args.test_funct_name = args.class_test;
                class_args.penalty = class_pen;

                % Perform cross validation using the one-iteration selector
                % 'group' created above, and the correct iteration mask:
                [subj results] = cross_validation(subj,patin,regsname,sprintf('%s_%i_cv',args.penalty_selname,i),masknames{i},class_args);

                % Record the accuracy for this iteration and penalty (there
                % is only one iteration in this particular classification):
                penalty_accuracy(i,length(penalties)) = [results.iterations(1).perf];
            end

            % For when the best penalty is not the first or last:
        else
            for class_pen = penalty_results(1,(whichmax))/2:(penalty_results(1,(whichmax+1))/2-penalty_results(1,(whichmax))/2)/(args.npenalties-1):penalty_results(1,(whichmax+1))/2

                % Keeping track of the penalties tried:
                penalties = [penalties class_pen];

                class_args.train_funct_name = args.class_train;
                class_args.test_funct_name = args.class_test;
                class_args.penalty = class_pen;

                % Perform cross validation using the one-iteration selector
                % group created above, and the correct iteration mask:
                [subj results] = cross_validation(subj,patin,regsname,sprintf('%s_%i_cv',args.penalty_selname,i),masknames{i},class_args);

                % Record the accuracy for this iteration and penalty (there
                % is only one iteration in this particular classification):
                penalty_accuracy(i,length(penalties)) = [results.iterations(1).perf];
            end
        end

        % Put the groupnames back to their original form:
        subj = set_objfield(subj,'selector',sprintf('%s_%i',args.penalty_selname,i),'group_name',args.penalty_selname);
    end
end

penalty_results = [penalties ; penalty_accuracy];

% Plot the results:

if args.use_iteration_perf == false
    penalty_iteration_results = penalty_results;

    % Find the best penalty:
    [acc whichmax] = max(penalty_iteration_results(size(penalty_iteration_results,1),:));
    best_penalties = penalty_iteration_results(1,whichmax);

    % Create a plot of accuracy against penalties:
    pen_totalacc = [penalty_iteration_results(1,:) ; penalty_iteration_results(size(penalty_iteration_results,1),:)];
    sortedresults = sortrows(pen_totalacc');
    plot(sortedresults(:,1),sortedresults(:,2));
    legend('Total performance');
    title('Classification performance (non-peeking) for different penalties' );
    xlabel('Penalty')
    ylabel('Classification accuracy')

else

    % Create the PENALTY_ITERATION_RESULTS array by bringing together all tried
    % penalties and their associated accuracies for each iteration:
    for i=1:max(runs_selname)
        penalty_iteration_results{i} = [penalty_results(1,1:length(broad_range)) penalty_results(1,length(broad_range)+1+((i-1)*(args.npenalties)):(length(broad_range)+(args.npenalties*(i))));  penalty_results(i+1,1:length(broad_range)) penalty_results(i+1,(length(broad_range))+1+((i-1)*(args.npenalties)):(length(broad_range)+(args.npenalties*(i))))];
    end

    % Bring together the best penalties for each iteration:
    best_penalties=[];
    for i = 1:max(runs_selname)
        [acc whichmax] = max(penalty_iteration_results{i}(2,:));
        best_penalties = [best_penalties penalty_iteration_results{i}(1,whichmax)];
    end

    % Create a plot of accuracy against penalties:
    linecolors = {'b-' 'g-' 'r-' 'c-' 'm-' 'y-' 'k-' 'b-' 'g-' 'r-' 'c-' 'm-' 'y-' 'k-' 'b-' 'g-' 'r-' 'c-' 'm-' 'y-'};
    hold on
    for i = 1:max(runs_selname)
        index = num2str(i);
        sortedresults = sortrows(penalty_iteration_results{i}');
        plot(sortedresults(:,1),sortedresults(:,2),linecolors{i});
        forlegend{i} = ['' 'Iteration ' index ''];
    end
    title('Classification performance (non-peeking) for different penalties' );
    xlabel('Penalty')
    ylabel('Classification accuracy')
    legend(forlegend)
    hold off

end

% Improve the readability of the PENALTY_ITERATION_RESULTS output table:
format short g

% If the user hasn't declined this option, perform a final classification
% using the newly found penalty / penalties:
if args.perform_final_classification == true

    % Perform the final classification using the best penalty from the
    % total performance penalty search if this is kept at default:
    if args.use_iteration_perf == false
        class_args.train_funct_name = args.class_train;
        class_args.test_funct_name = args.class_test;
        class_args.penalty = best_penalties;

        % Run cross-validation using the best penalty:
        [subj results] = cross_validation(subj,patin,regsname,selgroup,mask,class_args);

        % Report the results to the command window:
        disp(sprintf('\nCross-validation with %s and %s using a searched for penalty of %i:',args.class_train,args.class_test,best_penalties));
        for i = 1:max(runs_selname)
            disp(sprintf('\t%i\t%.2f',i,results.iterations(i).perf) );
        end
        disp(sprintf('\n\tTotal\t%.2f',results.total_perf) );

    else

        % If USE_ITERATION_PERF is set to true, perform the final cross
        % validation one iteration at a time with an optimally chosen
        % penalty for each iteration:
        for i = 1:max(runs_selname)
            class_args.train_funct_name = args.class_train;
            class_args.test_funct_name = args.class_test;
            class_args.penalty = best_penalties(i);

            % Temporarily change each iteration selector's group name so
            % CROSS_VALIDATION is given a group:
            subj = set_objfield(subj,'selector',['' selectornames{i} ''],'group_name',['' selectornames{i} '_cv' '']);

            % Run cross-validation, one iteration at a time, with the
            % appropriate selector and mask, using the best penalty for that
            % iteration:
            [subj results] = cross_validation(subj,patin,regsname,['' selectornames{i} '_cv' ''],masknames{i},class_args);

            % Change the group name back to its original form:
            subj = set_objfield(subj,'selector',['' selectornames{i} ''],'group_name',selgroup);

            % Gather the results from each iteration:
            allresults{i} = results;
        end

        % Put together a results structure in the usual format, but where
        % each iteration has used its own best penalty:
        clear results;
        results.total_perf=0;
        for i = 1:max(runs_selname)
            results.iterations(i) = allresults{i}.iterations;
            results.total_perf = results.total_perf + allresults{i}.total_perf;
            results.header(i) = allresults{i}.header;
        end
        results.total_perf = results.total_perf / i;

        % Report the results to the command window:
        disp(sprintf('\nCross-validation with %s and %s using searched for penalties:',args.class_train,args.class_test));
        for i = 1:max(runs_selname)
            disp(sprintf('\t%i\t%.2f\t(penalty = %i)',i,results.iterations(i).perf,best_penalties(i)) );
        end
        disp(sprintf('\n\tTotal\t%.2f',results.total_perf) );
    end

else
    clear results;
end
end

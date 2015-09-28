# Howtos #


## Pre-classification ##



### How can I handpick timepoints to exclude from my analysis ###

Don't delete any timepoints from your patterns or regressors. Instead, just tell [m2html/create\_xvalid\_indices.html create\_xvalid\_indices.m]'' to use a selector as a kind of temporal mask to censor out the timepoints you don't want. Imagine you have 1000 TRs, and you want to exclude the 111th (because that's the point in your experiment where Bilbo disappears): ''

```
>> nTRs = 1000; 

>> temp_sel= ones(1,nTRs);

>> temp_sel(111) = 0;

>> subj = init_object(subj,'selector','no_bilbo');

>> subj = set_mat(subj,'selector',no_bilbo',temp_sel);

Now, when you call ''create_xvalid_indices.m'', feed in the ''no_bilbo'' selectors object as the ''actives_selname'':

>> subj = create_xvalid_indices(subj,'runs', ...

'actives_selname','no_bilbo'); 
```

Note: this method will only exclude these timepoints from functions that use the create\_xvalid\_indices.m''. They still exist in regressors or patterns or other objects. It's just that they will be ignored when creating the cross-validation selector group that gets used for feature selection and classification later on. Early functions like ''zscore\_runs.m'' that don't use the cross-validation selector group will still include these timepoints. This is deliberate, since we recommend that you include all your TRs when zscoring. ''

The main advantage of this method is that it doesn't require you to actually delete the TRs that you don't want from your patterns, so that if you change your mind, you can easily rerun your analysis by feeding in a different actives\_selname'' selector to ''create\_xvalid\_indices.m''. ''


### How can I exclude rest timepoints from my analysis ###

First, read '[:MVPA manual:How can I handpick timepoints to exclude from my analysis']'.

This time, instead of hand-picking the timepoints to exclude individually, you want to exclude all the timepoints in your regressors matrix that don't have an active condition. As above, this simply involves setting those timepoints in your actives\_selname'' selector to 0. For instance: ''

```
>> regs = get_mat(subj,'regressors','my_conds'); 

>> temp_sel = ones(1,size(regs,2));

>> temp_sel(find(sum(regs)==0)) = 0;

>> subj = init_object(subj,'selector','no_rest');

>> subj = set_mat(subj,'selector',no_rest',temp_sel);

>> subj = create_xvalid_indices(subj,'runs','actives_selname','no_rest');
```


### How can I exclude conditions from my analysis ###

We recommend using the same method as described first in '[How can I handpick timepoints to exclude from my analysis'](#_How_do_I.md)' and elaborated in '[How can I exclude rest timepoints from my analysis'](#_How_can_I_1.md)'.

The only difference here is that we are going to create a new regressors matrix with a reduced number of condition-rows beforehand. First, create a new regressors object by duplicating the current set of regressors. Then remove the appropriate condition-rows from the new regressors, and the appropriate condition-name string from the condnames'' field. For example, to create a new regressors object called ''regs\_no\_3 ''that lacks the third condition from ''regs\_original''. ''

```
>> subj = duplicate_object(subj,'regressors','regs_original','regs_no_3'); 

>> regs_no_3_mat = get_mat(subj,'regressors','regs_no_3');

>> regs_no_3_mat(3,:) = [];

>> subj = set_mat(subj,'regressors','regs_no_3',regs_no_3_mat);

>> condnames_no_3 = get_objfield(subj,'regressors','regs_no_3','condnames');

>> condnames_no_3(3) = [];

>> subj = set_objfield(subj,'regressors','regs_no_3','condnames',condnames_no_3); 
```

Now, regs\_no\_3'' will contain as many timepoints as ''regs\_original'', but fewer condition-rows, and more 'rest timepoints', i.e. timepoints with no active conditions. Now, we can just proceed as described above for [excluding rest](#_How_can_I_1.md) from your analysis to ensure that those 'rest' timepoints are ignored when generating the statmap and doing classification. In other words, the third condition won't feature at all in any steps of the analysis that use selectors in the group created by ''create\_xvalid\_indices.m''. ''

Proceeding from now on exactly as described in '[How can I exclude rest timepoints from my analysis'](#_How_can_I_1.md)':

```
>> regs = get_mat(subj,'regressors','my_conds'); 

>> temp_sel = ones(1,size(regs_no_3,2));

>> temp_sel(find(sum(regs_no_3)==0)) = 0;

>> subj = init_object(subj,'selector','sel_no_3');

>> subj = set_mat(subj,'selector',sel_no_3',temp_sel);

>> subj = create_xvalid_indices(subj,'runs','actives_selname','sel_no_3'); 
```


### How can I exclude rest and hand-picked timepoints and some conditions ###

Create a separate boolean temporal mask selector for each, as above. Then create a new selector that is the 'AND' of all of those selectors, and feed that in.
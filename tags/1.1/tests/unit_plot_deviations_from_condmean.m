function [errs warns] = unit_plot_deviations_from_condmean()

% [ERRS WARNS] = UNIT_PLOT_DEVIATIONS_FROM_CONDMEAN()


errs = {};
warns = {};

errs = basic_case(errs);

[errs warns] = alert_unit_errors(errs,warns);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs] = basic_case(errs);

[subj fake_meanpats fake_deviations fake_mean_deviations_per_cond] = ...
    create_fake_subj_simple();

[actual_deviations actual_meanpats actual_mean_deviations_per_cond] = ...
    plot_deviations_from_condmean(subj,'pat','regs','runs');

if ~isequalwithequalnans(fake_deviations, actual_deviations)
  errs{end+1} = 'Deviations don''t match up';
  keyboard
end
if ~isequalwithequalnans(fake_meanpats, actual_meanpats)
  errs{end+1} = 'Meanpats don''t match up';
end
if ~isequalwithequalnans(fake_mean_deviations_per_cond, actual_mean_deviations_per_cond)
  errs{end+1} = 'Mean deviations per cond don''t match up';
  disp('mean deviations per cond don''t match up')
  keyboard
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj fake_meanpats fake_deviations fake_mean_deviations_per_cond] = create_fake_subj_simple()

nVox = 3;
nTRs = 5;
nConds = 2;

regs_ind = [1 2 2 2 0];
regs = ind2vec_robust(regs_ind);

runs = ones(1,5);

% i just created these by hand. the idea is that the first
% TR will be perfectly similar to its condition mean (by
% being the only exemplar). the 2nd and 3rd TRs will be
% equidistant from their condition mean, and the 4th TR will
% be the same as its condition mean too. the 5th is rest,
% and shouldn't matter
pat = [0.0 0.4 0.6 0.5 0.3;
       1.0 0.5 0.5 0.5 0.3;
       0.7 0.6 0.4 0.5 0.3];

fake_meanpats = [0.0 0.5;
                 1.0 0.5;
                 0.7 0.5];

fake_deviations = [0 ...
                   NaN ...
                   NaN ...
                   NaN ...
                   NaN; ...
                   
                   NaN ...
                   euclidn(pat(:,2), fake_meanpats(:,2)) ...
                   euclidn(pat(:,3), fake_meanpats(:,2)) ...
                   0 ...
                   NaN];

% the mean for cond 1 = just the first timepoint, because
% there's only 1 timepoint in cond 1
%
% the mean for cond 2 = the mean of the 2nd, 3rd and 4th
% timepoints
fake_mean_deviations_per_cond = [ ...
    fake_deviations(1,1) ...
    mean([fake_deviations(2,2) fake_deviations(2,3) fake_deviations(2,4)]) ...
    ];

subj = init_subj('unit_plot_deviations_from_condmean','testsubj');
subj = initset_object(subj,'regressors','regs',regs);
subj = initset_object(subj,'selector','runs',runs);
subj = initset_object(subj,'mask','all1',ones(1,1,nVox));
subj = initset_object(subj,'pattern','pat',pat, ...
                      'masked_by','all1');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj fake_meanpats] = create_fake_subj()

% After writing this, I realized it was too complicated to
% be useful as a test dataset, because i'd have to
% effectively recode the function i'm testing
% identically. Better to use CREATE_FAKE_SUBJ_SIMPLE, where
% the right answers are simple to calculate.

% these are the parameters we're going to use to generate our fake data
nVox = 25;
nConds = 4;
nTRs = 50;
% this should leave 10 rest TRs, just to check that's working`
nTRsPerCond = 10;
noisiness = 0.5;

% create the regressors (in blocks, by each condition, with
% all the rest piled at the end)
regs_ind = [];
for c=1:nConds
  regs_ind = ones(1,nTRsPerCond)*c;
end
regs_ind(end:nTRs) = 0;

% turn those indices into a normal regressors matrix (nConds
% x nTRs), leaving zeros as inactive timepoints
regs = ind2vec_robust(regs_ind);

fake_meanpats = rand(nVox, nConds);

pat = nan(nVox, nTRs);
for t=1:nTRs
  c = regs_ind(t);
  if c==0
    % rest TR
    pat(:,t) = rand(nVox,1);
  else
    % active TR
    pat(:,t) = fake_meanpats(nVox,c) + rand(nVox,1)*noisiness;
  end
end % t nTRs

subj = init_subj('unit_plot_deviations_from_condmean','testsubj');
subj = initset_object(subj,'regressors','regs',regs);
subj = initset_object(subj,'mask','all1',ones(1,1,nVox));
subj = initset_object(subj,'pattern','pat',pat);



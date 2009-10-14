function [errs warns] = unit_get_group_as_matrix()

errs = {};
warns = {};

subj = init_subj(mfilename,'test');

nObjectsPerGroup = 4;

nVox = 10;
nTimepoints = 100;
p_1 = ones(nVox,nTimepoints) * 10;
p_2 = ones(nVox,nTimepoints) * 20;
p_3 = ones(nVox,nTimepoints) * 30;
p_4 = ones(nVox,nTimepoints) * 40;

nConds = 3;
r_1 = ones(nConds,nTimepoints) * 10;
r_2 = ones(nConds,nTimepoints) * 20;
r_3 = ones(nConds,nTimepoints) * 30;
r_4 = ones(nConds,nTimepoints) * 40;

s_1 = ones(1,nTimepoints) * 10;
s_2 = ones(1,nTimepoints) * 20;
s_3 = ones(1,nTimepoints) * 30;
s_4 = ones(1,nTimepoints) * 40;

nX = 5;
nY = 5;
nZ = 5;
m_1 = zeros(nX,nY,nZ); m_1(1,:,:) = 1;
m_2 = zeros(nX,nY,nZ); m_2(2,:,:) = 1;
m_3 = zeros(nX,nY,nZ); m_3(3,:,:) = 1;
m_4 = zeros(nX,nY,nZ); m_4(4,:,:) = 1;

subj = initset_object(subj,'mask','wholevol',ones(nX,nY,nZ));

subj = initset_object(subj,'pattern','p_1',p_1,'group_name','p','masked_by','wholevol');
subj = initset_object(subj,'pattern','p_2',p_2,'group_name','p','masked_by','wholevol');
subj = initset_object(subj,'pattern','p_3',p_3,'group_name','p','masked_by','wholevol');
subj = initset_object(subj,'pattern','p_4',p_4,'group_name','p','masked_by','wholevol');

subj = initset_object(subj,'regressors','r_1',r_1,'group_name','r');
subj = initset_object(subj,'regressors','r_2',r_2,'group_name','r');
subj = initset_object(subj,'regressors','r_3',r_3,'group_name','r');
subj = initset_object(subj,'regressors','r_4',r_4,'group_name','r');

subj = initset_object(subj,'selector','s_1',s_1,'group_name','s');
subj = initset_object(subj,'selector','s_2',s_2,'group_name','s');
subj = initset_object(subj,'selector','s_3',s_3,'group_name','s');
subj = initset_object(subj,'selector','s_4',s_4,'group_name','s');

subj = initset_object(subj,'mask','m_1',m_1,'group_name','m');
subj = initset_object(subj,'mask','m_2',m_2,'group_name','m');
subj = initset_object(subj,'mask','m_3',m_3,'group_name','m');
subj = initset_object(subj,'mask','m_4',m_4,'group_name','m');

all_p(1,:,:) = p_1;
all_p(2,:,:) = p_2;
all_p(3,:,:) = p_3;
all_p(4,:,:) = p_4;

all_r(1,:,:) = r_1;
all_r(2,:,:) = r_2;
all_r(3,:,:) = r_3;
all_r(4,:,:) = r_4;

all_s(1,1,:) = s_1;
all_s(2,1,:) = s_2;
all_s(3,1,:) = s_3;
all_s(4,1,:) = s_4;

all_m(1,:,:,:) = m_1;
all_m(2,:,:,:) = m_2;
all_m(3,:,:,:) = m_3;
all_m(4,:,:,:) = m_4;

if ~isequal(all_p, get_group_as_matrix(subj,'pattern','p'))
  errs{end+1} = 'Pattern group as single matrix is wrong';
end

if ~isequal(all_r, get_group_as_matrix(subj,'regressors','r'))
  errs{end+1} = 'Regs group as single matrix is wrong';
end

if ~isequal(all_s, get_group_as_matrix(subj,'selector','s'))
  errs{end+1} = 'Sel group as single matrix is wrong';
end

if ~isequal(all_m, get_group_as_matrix(subj,'mask','m'))
  errs{end+1} = 'Mask group as single matrix is wrong';
end

[errs warns] = alert_unit_errors(errs,warns);





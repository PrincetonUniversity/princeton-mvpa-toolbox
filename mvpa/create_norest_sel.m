function [subj] = create_norest_sel(subj,regsname,varargin)

% [SUBJ] = CREATE_REST_SEL(SUBJ,REGSNAME,...)
%
% Creates a boolean selector from the REGSNAME regressors with 1s
% everywhere except where there are rest timepoints
% (i.e. timepoints with no non-zero conditions).
%
% NEW_SELNAME (optional, default = REGSNAME + '_norest') - the name
% of the selector to be created


defaults.new_selname = sprintf('%s_norest',regsname);
args = propval(varargin,defaults);

regs = get_mat(subj,'regressors',regsname);

[isbool isrest isoveractive] = check_1ofn_regressors(regs);
if ~isrest
  disp( sprintf('No rest TRs in %s',regsname) );
end

temp_sel = ones(1,size(regs,2));
temp_sel(find(sum(regs)==0)) = 0;
subj = init_object(subj,'selector',args.new_selname);
subj = set_mat(subj,'selector',args.new_selname,temp_sel);




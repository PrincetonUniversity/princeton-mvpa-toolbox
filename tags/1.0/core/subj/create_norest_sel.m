function [subj] = create_norest_sel(subj,regsname,varargin)

% Creates a selector with 1s for non-rest timepoints
% 
% [SUBJ] = CREATE_NOREST_SEL(SUBJ,REGSNAME,...)
%
% Creates a boolean selector from the REGSNAME regressors with 1s
% everywhere except where there are rest timepoints
% (i.e. timepoints with no non-zero conditions).
%
% NEW_SELNAME (optional, default = REGSNAME + '_norest') - the name
% of the selector to be created

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


defaults.new_selname = sprintf('%s_norest',regsname);
args = propval(varargin,defaults);

regs = get_mat(subj,'regressors',regsname);

[isbool isrest isoveractive] = check_1ofn_regressors(regs);
if ~isrest
  disp( sprintf('No rest TRs in %s',regsname) );
end

% hmmmm. it might be easier just to do:
% temp_sel = sum(regs)>0;

temp_sel = ones(1,size(regs,2));
sumregs = sum(regs);

if find(regs<0)
  warning(['Your regressors matrix has negative values - could cause' ...
	   ' a problem here']);
end

temp_sel(find(sumregs==0)) = 0;
subj = init_object(subj,'selector',args.new_selname);
subj = set_mat(subj,'selector',args.new_selname,temp_sel);

created.function = mfilename;
created.dbstack = dbstack;
created.regsname = regsname;
created.args = args;
subj = add_created(subj,'selector',args.new_selname,created);

hist = sprintf('Created norest_sel called %s from %s regressors', ...
	       args.new_selname,regsname);
subj = add_history(subj,'selector',args.new_selname,hist,true);

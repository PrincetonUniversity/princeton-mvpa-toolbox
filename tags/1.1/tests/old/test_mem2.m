function [] = test_mem2()

% [] = test_mem2()
%
% This is just like test_mem, except that this is more akin to how
% init_object works. Either way, the conclusions are the
% same. Matlab only duplicates the particular cell in the cell
% array whose contents you changed.


disp('Clearing and packing');
clear all
pack
subj.patterns = [];
subj.patterns{end+1}.mat = zeros(64,64,34,250);
subj.patterns{end+1}.mat = zeros(64,64,34,250);
subj.patterns{end+1}.mat = zeros(64,64,34,250);
subj.patterns{end+1}.mat = zeros(64,64,34,250);
objcell = subj.patterns;

disp('About to start mem_control');
tic
objcell = mem_control(objcell);
subj.patterns = objcell;
toc

disp('About to start mem_no_duplicate');
tic
objcell = mem_no_duplicate(objcell);
subj.patterns = objcell;
toc

disp('Clearing and packing');
clear all
pack
subj.patterns = [];
subj.patterns{end+1}.mat = zeros(64,64,34,250);
subj.patterns{end+1}.mat = zeros(64,64,34,250);
subj.patterns{end+1}.mat = zeros(64,64,34,250);
subj.patterns{end+1}.mat = zeros(64,64,34,250);
objcell = subj.patterns;

disp('About to start mem_with_duplicate');
tic
objcell = mem_with_duplicate(objcell);
subj.patterns = objcell;
toc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [objcell] = mem_no_duplicate(objcell)

objcell{end+1}.mat = zeros(64,64,34,300);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [objcell]= mem_with_duplicate(objcell)

objcell{1}.mat(end) = 1;
objcell{end+1}.mat = zeros(64,64,34,300);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [objcell]= mem_control(objcell)

a = zeros(64,64,34,300);




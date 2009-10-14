function [] = test_mem3()

% This is to test how well matlab will deal with memory for set_object


disp('Clearing and packing');
clear all
pack
subj.patterns{1}.mat = zeros(64,64,34,1000);
objcell = subj.patterns;

%disp('About to start mem_control');
%tic
%objcell = mem_control(objcell);
%subj.patterns = objcell;
%toc


disp('About to start test condition');
tic
objcell = mem_test(objcell);
subj.patterns = objcell;
toc

disp('Clearing and packing');
clear all
pack
subj.patterns{1}.mat = zeros(64,64,34,1000);
objcell = subj.patterns;

disp('About to start mem_with_duplicate');
tic
objcell = mem_with_duplicate(objcell);
subj.patterns = objcell;
toc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [objcell] = mem_test(objcell)
objcell  = mem_with_duplicate2(objcell);
newcell{1}.mat = ones(64,64,34,300);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [objcell]= mem_with_duplicate(objcell)
objcell = mem_with_duplicate2(objcell);
objcell{end}.mat = ones(64,64,34,300);

function [objcell] = mem_with_duplicate2(objcell)
objcell{end+1}.mat = zeros(64,64,34,300);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [objcell]= mem_control(objcell)

a = zeros(64,64,34,300);




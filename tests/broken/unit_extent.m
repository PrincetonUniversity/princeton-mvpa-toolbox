function [errmsgs warnmsgs] = test_extent()

errmsgs = {};
warnmsgs = {};

fakedata = zeros(10,10,10);

fakedata(1,2,2) = 1; % size 1
fakedata(1,2,4:5) = 1; % size 2
fakedata(1,2,7:9) = 1; % size 3
fakedata(3,2:3,2:3) = 1; % size 4
fakedata(3:4,5:6,5:6) = 1; % size 8
fakedata(6:9,1:4,4:8) = 1; % size 80

subj = init_subj('blah','super great');
subj = init_object(subj,'mask',   'fakemask');
subj = set_mat(subj,'mask',   'fakemask',fakedata);
subj = extent_threshold(subj,'fakemask','kt_fakemask',2);

output = get_objfield(subj,'mask','kt_fakemask','clusters_found');

if length(output) ~= 6 | any(output - [1 2 3 4 8 80])
  blah
  errmsgs{1} = 'Clusters not properly identified by extent_threshold()';
end

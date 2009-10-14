function [errmsgs warnmsgs] = unit_and_bool_selectors()

% [ERRMSGS WARNMSGS] = UNIT_AND_BOOL_SELECTORS()


errmsgs = {};
warnmsgs = {};

a = round(rand(1,100));
b = round(rand(1,100));
c = round(rand(1,100));

subj = init_subj('unit_and_bool_selectors','');
subj = initset_object(subj,'selector','a',a);
subj = initset_object(subj,'selector','b',b);
subj = initset_object(subj,'selector','c',c);

actives = and_bool_selectors(subj,{'a','b','c'});

if ~isequal(a&b&c,actives)
  errmsgs{end+1} = {'Failed to AND together the selectors properly'};
end

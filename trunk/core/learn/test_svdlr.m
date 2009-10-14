function [acts scratchpad] = test_svdlr(testpats,testtargs,scratchpad)

% Generates predictions using a trained logistic regression model
%
% [ACTS SCRATCHPAD] = TEST_RIDGE(TESTPATS,TESTTARGS,SCRATCHPAD)
%
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


X = testpats';
W = scratchpad.W;

Z = [ W'*W \ W'*X']'; % project onto this new basis

[acts] = scratchpad.testfunc(Z', testtargs, ...
                             scratchpad.classifier);




  






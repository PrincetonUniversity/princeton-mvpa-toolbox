function [] = dispf(varargin)

% Like calling disp(sprintf(X)), or fprintf('...\n')
%
% function [] = dispf(...)


disp( sprintf(varargin{:}) )

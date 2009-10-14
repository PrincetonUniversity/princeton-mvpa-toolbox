function [out]=logRegFun(y,x,lambda,tol,maxrounds)

% Generic IRLS logistic regression algorithm.
%
% [OUT] = logRegFun(y, x, lambda, [tol, maxrounds])
%
% input:
%
%  y--(1,nSamps) vector of binary outcomes (0 1);
%  x--(nFeat,nSamps) matrix of feature values (real numbers), one
%     feature vector for each sample
%  lambda--ridge penalty on the weights.  a reasonable starting values
%     is lambda=nFeat;
%  tol--optimization tolerance, default 0.8
%  maxrounds--maximum # of optimization iterations
%
% output:
%
%  out.weights -- weights from optimization
%  out.ll -- log likelihood
%  out.rounds -- # of rounds used
%
% Given a vector of features x=x(1)...x(n) and a
% binary outcome y=(-1,1) we model the conditional probability
% p(y|w*x)=1/(1+exp(-y*w*x)); we then choose w to maximize
% p(y|x,w)p(w), e.g. maximum a posteriori (MAP) estimation.
% 
% The gaussian prior p(w) is determined by lambda, and is required if
% the data is linearly separable.
%
% Originally authored by Greg Stephens 2007
% This file follows notes from tom minka, "a comparision of numerical
% optimizers for logistic regression" (2004).

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

% Set default tolerance
if nargin == 3
  tol=1e-8;
end
% Set default maxrounds
if nargin <= 4
  maxrounds = 5000;
end

nFeat=size(x,1);
nSamp=size(x,2);

%make sure that y is a column vector
y=reshape(y,1,nSamp);

%the loglikelihood function
LL = @(w)(y*(w'*x)'-sum(log(1+exp(w'*x)))-lambda/2*w'*w);


wOld=zeros(nFeat,1);

%the error at each step
deltaLL=1;

p=[];
rounds = 0;
oldLL=LL(wOld);

C2 = lambda*eye(nFeat);

out.ll = zeros(maxrounds, 1);

while deltaLL>tol & rounds<maxrounds
  f=exp(wOld'*x);
  p=f./(1+f);
  A=diag(p.*(1-p));
  
  %B = x*A*x'+lambda*eye(nFeat); 
  C1 = x*A*x';
  B = C1+C2;
  %wGrad = inv(B)*(x*(y-p)'-lambda*wOld);
  wGrad = B \ (x*(y-p)'-lambda*wOld);
  
  wNew=wOld+wGrad;%inv(x*A*x'+lambda*eye(nFeat))*(x*(y-p)'-lambda*wOld);
  
  newLL=LL(wNew);

  wOld=wNew;
   
  deltaLL=abs((oldLL-newLL)/oldLL);
  rounds = rounds + 1;

  oldLL=newLL; 
  
  out.ll(rounds) = newLL;
end

% trim log likelihood output
out.ll = out.ll(1:rounds);
out.rounds = rounds;
out.weights=wOld;
out.classError = nan;


function [out]=logRegFun(y,x,lambda,tol)

if nargin==3
  %the required tolerance
  tol=1e-8;
end

%Greg Stephens 2007
%input  y--(1,nSamps) vector of binary outcomes (0 1);
%       x--(nFeat,nSamps) matrix of feature values (real numbers), one
%       feature vector for each sample
%       lambda--ridge penalty on the weights.  a reasonable starting values
%       is lambda=nFeat;
%output  out.weights the set of best weights
%        out.classError the classification error

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



%a tutorial function  on logistic regression, well really just an highly annotated
%m-file

%this file follows notes from tom minka, "a comparision of numerical
%optimizers for logistic regression" (2004).

%some sort of weight conditioning will be necessary....

%the basic model.  Given a vector of features x=x(1)...x(n) and a binary
%outcome y=(-1,1) we model the conditional probability p(y|w*x)=1/(1+exp(-y*w*x));
%and seek the vector of weights w(1)...w(n) that mimimize the trainng
%error, perhaps with a gaussian prior on w, which corresponds to ridge
%regression.

%x = [ones(1,cols(x)); x];

nFeat=size(x,1);
nSamp=size(x,2);

%make sure that y is a column vector
y=reshape(y,1,nSamp);

%now begin the function.  Find the weights that maximize the loglikelihood
%of the data for this model.
%use a newton-raphson update to find the maximum of the
%loglikelihood,lambda.  We've also included a gaussian prior on the weights
%(ridge penalty term)

%the loglikelihood function
LL = @(w)(y*(w'*x)'-sum(log(1+exp(w'*x)))-lambda/2*w'*w);
wOld=zeros(nFeat,1);
%the error at each step
Err=1;
p=[];
rounds = 0;
oldLL=LL(wOld);

C2 = lambda*eye(nFeat);
while Err>tol & rounds<5000
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
  oldLL=newLL;
    
  Err=abs((oldLL-newLL)/oldLL);
  rounds = rounds + 1;
end

out.weights=wOld;

%   matlab also has a built in solver but it doesn't include the weight
%   penalty term
%   wMat=glmfit(x',y','binomial','link','logit','constant','off');
%   fitMat=loglikehood(wMat);

%the reconstructed probability so we can look at the classification error
% p=[];
% classError=[];
% for i=1:nSamp
%     p(2)=exp(wOld'*x(:,i))/(1+exp(wOld'*x(:,i)));
%     p(1)=1-p(2);
%     [dummy,maxIdx]=max(p);
%     classError(i)=y(i)-(maxIdx-1);
% end
out.classError=nan;%classError;



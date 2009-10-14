%
% Computation of SVD in a way that is quicker and uses less memory
% than the svd that comes with matlab, by using PCA of XX' where
% X has fewer rows than columns
%
% In:
% - data matrix X - #examples x #features
% - optional (defaults to all components or all the variance):
%   - 'keepNumberComponents',<# of components to keep>
%   - 'keepVarianceFraction',<fraction of the variance to keep>
%
% Out:
% - U
% - S
% - V 
%
% Notes:
% - X ~ USV'
%
% Examples:
% [U,S,V] = compute_fastSVD(examples);
% [U,S,V] = compute_fastSVD(examples,'keepNumberComponents',4);
% [U,S,V] = compute_fastSVD(examples,'keepVarianceFraction',0.9);
%
% History:
% - 2008 Apr 14 - fpereira - created from previous version
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

function [U,S,V] = fastsvd(varargin)

%% process arguments

this = 'computeSVD';
X = varargin{1};
[nExamples,nFeatures] = size(X);

keepNumberComponents = 0;
keepVarianceFraction = 1;

idx = 2;
while idx <= nargin
  argValue = varargin{idx}; idx = idx + 1;
  switch argValue
   case {'keepNumberComponents'}
    keepNumberComponents = varargin{idx}; idx = idx + 1;
   case {'keepVarianceFraction'}
    keepVarianceFraction = varargin{idx}; idx = idx + 1;
   otherwise
    % ignore
  end
end

if keepNumberComponents < 0; keepNumberComponents = 0; end
if keepVarianceFraction < 0 | keepVarianceFraction > 1; keepVarianceFraction = 1; end

%% compute SVD

if nExamples < nFeatures; algorithm = 'economic'; else algorithm = 'matlab'; end

% 1) find the singular values

switch algorithm
 case {'economic'}
%  fprintf('%s: #examples < #features, using our algorithm\n',this);
  
  tmp   = X * X'; 
  [U,D] = eig(tmp); clear tmp;
  d     = diag(D);
  s     = sqrt(d);
  S     = diag(s);
  V     = (diag(1./s)*U'*X)';
  
 case {'matlab'}

%  fprintf('%s: #examples >= #features, using matlab SVD\n',this);
  [U,S,V] = svd(X,0);
  s = diag(S);
  d = s.^2;
  
end
clear X;

% 2) decide how many components to keep

% sort singular values in decreasing order
[discard,order] = sort(s,1); order = flipud(order);
ssorted = s(order);
dsorted = d(order);

% decide on how many components to keep
nAvailable = size(U,2);
if keepNumberComponents > nAvailable; keepNumberComponents = nAvailable; end  
if keepNumberComponents == nAvailable; keepVarianceFraction = 1; end

fractionExplained = cumsum(d)/sum(d);

if keepNumberComponents
  % takes priority over fraction
  nToUse = keepNumberComponents;
else
  % just use the fraction
  tmp    = find(fractionExplained >= keepVarianceFraction);
  nToUse = tmp(1);
end

order = order(1:nToUse);

% 3) adjust the number of components

switch algorithm
 case {'economic'}
  S   = diag(s(order));
  U   = U(:,order);
  V   = V(:,order);
 
 case {'matlab'}
  S = diag(s(order));
  U = U(:,order);
  V = V(:,order);
end

  
  



function [] = testThis;

X = randn(10,100); scale = prctile(X(:),[1 99]);

[U1,S1,V1] = svd(X);
minp = min(size(X,1),size(X,2));
S1 = S1(:,1:minp);
V1 = V1(:,1:minp);

[U2,S2,V2] = computeSVD(X,'keepNumberComponents',4);

X1 = U1*S1*V1';
X2 = U2*S2*V2';

clf; idx = 1;
subplot(2,4,idx); imagesc(U1); idx = idx + 1;
subplot(2,4,idx); imagesc(S1); idx = idx + 1;
subplot(2,4,idx); imagesc(V1); idx = idx + 1;
subplot(2,4,idx); imagesc(X1); idx = idx + 1;
subplot(2,4,idx); imagesc(U2); idx = idx + 1;
subplot(2,4,idx); imagesc(S2); idx = idx + 1;
subplot(2,4,idx); imagesc(V2); idx = idx + 1;
subplot(2,4,idx); imagesc(X2); idx = idx + 1;
pause

subplot(2,1,1);imagesc(abs(X1-X));colorbar('vert');
subplot(2,1,2);imagesc(abs(X2-X));colorbar('vert');

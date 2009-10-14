function [noisypat noisyinfo] = noisify_regressors(regs,nTiles,noisiness,noise_type,signal_coeffs_order,do_plot)

% Tile and add noise to regs matrix to create a synthetic pattern
%
% [NOISYPAT NOISYINFO] = NOISIFY_REGRESSORS( ...
%    REGS,NTILES,NOISINESS,NOISE_TYPE,SIGNAL_COEFFS_ORDER,DO_PLOT)
%
% This takes in a regressors matrix, tiles it a few times to
% create a clean and perfect pattern based on your model. It
% then adds noise to this model to create 'synthetic data'
% that mirrors your expectations. Depending on
% SIGNAL_COEFFS_ORDER, each feature (i.e. voxel) will be
% either randomly noisy or in ascending order of signal
%
% This should be useful as a generic synthetic pattern
% generator function which can sit inside a synthetic subj
% generator function. You could even create multiple
% synthetic data sets from different kinds of regressors
%
% e.g. [noisypat noisyinfo] = noisify_regressors(regs,5,0.3,'uniform','ascending',true);
%
% N.B. you will want to transpose this before inserting as a pattern, e.g.
%
% subj = initset_object(subj,'pattern','noisypat',noisypat','masked_by','my_mask');
%
%   Note the transpose apostrophe after the second NOISYPAT in the
%   line above.
%
% NTILES - You can't specify an arbitrary number of voxels,
% cos that was a pain to code for the slidies wraparound
% script, so instead, this repmats the REGS NTILES times, so
% your nVox will always end up divisible by nConds, e.g for
% nConds = 12 and NTILES = 5, nVox = 60
%
% NOISINESS - The amount of noise to add. Strictly, an
% nFeatures*nTiles x nTRs matrix of random NOISE_TYPE noise
% gets created which gets scaled by NOISINESS before being
% added to CLEANPAT
%
% NOISE_TYPE - add 'uniform' or 'normal' noise to the
% regressors to create the noisy pattern
%
% SIGNAL_COEFFS_ORDER
% - 'ascending' = your features will contain increasing
%   amounts of signal
% - 'random_uniform' = each feature will have a random
%   amount of signal
%
% DO_PLOT - if true, will show an imagesc of the various
% stages of noisification
%
% Returns:
%
% NOISYPAT - the noisy version of the regressors (tiled
% NTILES times) = NTILES*nConds x nTRs
%
% NOISYINFO - a structure containing:
%
% - CLEANPAT - REGS tiled NTILES times
%
% - NOISE - the noise matrix (see NOISINESS)
%
% - SIGNAL_COEFFS - an (nFeatures x 1) vector containing the
%   proportion of signal (higher is better) - see
%   SIGNAL_COEFFS_ORDER
%
% - ATTENUATEDPAT - CLEANPAT with each feature scaled by its
%   SIGNAL_COEFFS


% disp('Noisifying regressors');

[nConds nTRs] = size(regs);
nFeatures = nConds * nTiles;

% Create a load of noise the size of our pattern
switch lower(noise_type)
  case 'uniform'
   noise = rand([nFeatures nTRs]);

 case 'normal'
   noise = randn([nFeatures nTRs]);

 otherwise
  error('Unknown noise type');
end

switch lower(signal_coeffs_order)

  % Each feature will have a signalcoeff associated with it. The
  % higher the signalcoeff, the better that feature will match the
  % model
 case 'ascending'
  signal_coeffs = linspace(1/nFeatures,1,nFeatures)';
  
  % Each feature will have a random amount of signal associated with it
 case 'random_uniform'
  signal_coeffs = rand([nFeatures 1]);
  
 otherwise
  error('Unknown signal_coeffs_order %s',signal_coeffs_order);
end

cleanpat = repmat(regs,nTiles,1);
attenuatedpat = cleanpat;
for t=1:nTRs
  attenuatedpat(:,t) = signal_coeffs .* cleanpat(:,t);
end
noisypat = (noise * noisiness) + attenuatedpat;

if do_plot
  figure
  subplot(5,1,1);
  imagesc(regs)
  title('Regs');

  subplot(5,1,2);
  imagesc(cleanpat)
  title('Cleanpat');
  
  subplot(5,1,3);
  imagesc(attenuatedpat);
  title('Attenuatedpat');

  subplot(5,1,4);
  imagesc(noise);
  title('Noise');

  subplot(5,1,5);
  imagesc(noisypat);
  title('Noisypat');

%   figure
%   plot(signal_coeffs);
%   title('Signal coefficients for each feature');

end

noisyinfo.cleanpat = cleanpat;
noisyinfo.noise = noise;
noisyinfo.signal_coeffs = signal_coeffs;
noisyinfo.attenuatedpat = attenuatedpat;

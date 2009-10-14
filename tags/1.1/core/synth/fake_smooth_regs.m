function [regs] = fake_smooth_regs(nConds, nTimepoints, noisiness)

% [REGS] = FAKE_SMOOTH_REGS(NCONDS, NTIMEPOINTS, NOISINESS)
%
% Randomly generates nConds' worth of sine waves at roughly
% the same frequency, shifted relative to one another.
%
% e.g. regs = fake_smooth_regs(3, 240, 0.1);


% choose a random frequency to scale the sine wave by
freq_const = rand*30;

% choose a random amount to shift the sine waves
% horizontally by
shifts = 10 * rand(1,nConds) * nTimepoints;

% add some noise to it to create slightly different
% frequencies for the other conditions
%
% FREQ_CONST = 1 x nConds
freq_const = repmat(freq_const, 1, nConds) + rand(1,nConds);

for c=1:nConds
  % we want to create moderately smooth regressors (because
  % that's what the wavestrapping is designed for), and noisy
  % sine waves of varying frequencies seemed like the simplest
  % way to do it
  regs(c,:) = sind(freq_const(c)*(1:nTimepoints) + shifts(c));
  % shift the sine wave up to sit between 0 and 1
  regs(c,:) = regs(c,:)/2 + 0.5;
  
end % c nConds

% turn it up loud, let's make some noise
regs = regs + randn(size(regs))*noisiness;

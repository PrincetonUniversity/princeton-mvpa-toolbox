function [new_vects] = wavelet_scramble_multi(orig_vects,wavelet_name,lvls,nScramble)

% [NEW_VECTS] = WAVELET_SCRAMBLE_MULTI(ORIG_VECTS,WAVELET_NAME,LVLS,NSCRAMBLE)
%
% Example: [new_vects] = wavelet_scramble_multi(orig_vects,'db4',5,10000)
%
% This function takes a timeseries or set of timeseries as
% input and outputs a set of surrogate timeseries that have
% similar spectral characteristics to the original
% timeseries.  A wavelet decomposition is performed on the
% original timeseries and the coefficients are scrambled,
% then the timecourse is reconstructed.
%
% The decomposition is performed using WAVEDEC (part of the
% wavelets toolbox).  The reconstruction is performed using
% WAVEREC.  See help of these functions for more detail.
%
% N.B. See WAVESTRAPPER_RESULTS.M - that calls this
% appropriately on a RESULTS structure for you.
%
% INPUT ARGUMENTS
%
% orig_vects should contain one timeseries per row.
%      if orig_vects has only one row, then this is the only source
%      of coefficients.
%      if orig_vects has multiple rows, then the algorithm uses
%      coefficients pooled across all timeseries to generate the
%      surrogate timeseries.
%
% wavelet_name specifies the wavelet to be used.  Try help WAVEINFO
% to get started.
%      we suggest using a daubechies wavelet
%      wavelet_name = 'db4';
%
% lvls is the # of levels you want to use (each level is a set of
% coefficients).
%      this version scrambles all levels of coefficients, approx &
%      detail.
%
% nScramble is the number of reconstructed timeseries to include in
% the output matrix.
%      new_vects is nScramble by size(orig_vects,2)
%
%
% Forgive me if I've used terms like "levels" inappropriately in
% places.
%
% SCRIPT CREATED BY SEAN POLYN (polyn@psych.upenn.edu currently).
% LAST MODIFIED (to add extra comments): 10/18/2005


%d = []; % detail coefficients (pooled)
%a = []; % approximation coeff (pooled)

%l_coeff = []; % the a and d level coeff, following the ordering of l

% ***** the wavelet deconstruction of each vector *****
% C CONTAINS THE COEFFICIENTS
% L IS A GUIDE --- SAYS HOW MANY COEFF PER LEVEL (FOR ENTRIES 1:END-1) 
% FINAL ENTRY IN L IS LENGTH OF ORIG_VECT
% L is [#app coef,#det coef(lvls),#det coef(lvls-1),...,#det coef(1)]


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


% STEP THROUGH EACH OF THE TIMESERIES BEING FED IN

for i=1:size(orig_vects,1)

  % WAVELET DECOMPOSITION OF THIS VECTOR
  [c{i},l{i}] = wavedec(orig_vects(i,:),lvls,wavelet_name);   

  % INITIALIZE A PLACEHOLDER FOR THE COEFFICIENTS SEGREGATED BY LEVEL
  for j = 1:length(l{i})-1
    l_coeff{j} = [];
  end
  
  % SEGREGATE THE COEFFICIENTS BY LEVEL
  % APPEND THE COEFFICIENTS FOR SUBSEQUENT VECTORS TO THE END OF
  % THE LIST OF COEFFICIENTS
  for j=1:length(l{i})-1
    if j==1
      startpt = 1;
      endpt = l{i}(1);
    else
      startpt = sum(l{i}(1:j-1)) + 1;
      endpt = startpt + l{i}(j) - 1;
    end
    l_coeff{j} = [l_coeff{j},c{i}(startpt:endpt)];
  end
  
end

% ***** the wavelet reconstruction of scrambled vectors *****

for i=1:nScramble

%  progress(i, nScramble);

  % INITIALIZE PLACEHOLDERS FOR SCRAMBLED COEFFICIENTS
  scram_coeff = [];
  new_c = [];
  
  % SCRAMBLE AND TAKE THE FIRST GROUP 
  % STEP OVER LEVELS
  for j=1:length(l{1})-1

    this_perm = randperm(length(l_coeff{j}));
    these_idx = this_perm(1:l{1}(j));
    scram_coeff = l_coeff{j}(these_idx);
    new_c = [new_c,scram_coeff];
       
  end
  % we can use the first l{}, they are all the same
  new_vects(i,:) = waverec(new_c,l{1},wavelet_name);

end

%disp(' wavelet_scramble_multi complete')

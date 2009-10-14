function barerr(x, y, e, varargin)
% BARERR - Bar graph with error bars and significance marks.
%
% Usage:
%  
%  barerr(x, y, e, ...)
%  barerr(x, y, e, 'p_vals', p, ...)
%
% BARERR will plot a bar graph with error bars and (optionally)
% significance asterisks indicating that a given bar is
% statistically significant. Inputs Y, E, and (optionally) P
% must all be the same dimensions, or empty.
%
% If Y is a matrix, bars are plotted in groups, with each group
% containing COLS(Y) bars and a total of ROWS(Y) groups. If Y is a
% vector, each bar is plotted separately. It does not matter
% whether Y is a row or column vector, just so long as the size of
% Y is exactly the size of E. 
%
% X should be a numeric vector or cell array of strings of size
% ROWS(Y) if Y is a matrix or LENGTH(Y) if Y is a vector; that is, X
% is a label for each group if Y is a matrix, or a label for each
% bar if Y is a vector.
%
% Optional Arguments:
%
%   'p_vals'   - A vector or matrix of p-values for each element in Y.
%
%   'p_thr'    - A vector of thresholds indicating significance
%                levels. If the value of p for a given bar is
%                beneath the I'th threshold, the symbol in
%                P_MARK{I} will be plotted above the bar. 
%                (Default: [0.05 0.005 0.0005]
%
%   'p_mark'   - A cell array of strings indicating significance
%                levels on the plot. (Default: one, two, and three stars.)
%               
%   'colormap' - The colormap to use to generate colors for bars,
%                used only if Y is a matrix.
%
%   'err_color'- The color of the error bars in RGB
%                values. (Default: black.)
%
%   'width'    - The width of the bars. (Default: 0.8 if Y is a
%                vector, 1.0 if Y is a matrix.)
%
% SEE ALSO
%    BAR, ERRORBAR

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

defaults.p_vals = [];
defaults.p_mark = {'\ast','\ast\ast', '\ast\ast\ast'};
defaults.p_thr = [0.05 0.005 0.0005];

if ~isempty(e)
  defaults.p_height = double(max(y(:)+e(:))*1.05);
else
  defaults.p_height = double(max(y(:)*1.05));
end

defaults.colormap = jet;
defaults.err_color = 'black';

if isvector(y) == 1
  defaults.width = 0.8;
else
  defaults.width = 1;
end

args = propval(varargin, defaults);

if rows(y) == 1;
  y = y'; e = e';
  args.p_vals = args.p_vals';
end  

% Make the basic plot
bar(y, args.width); 

hold on
colormap(args.colormap);

nbars = cols(y);
ngrps = rows(y);

grpwidth = min(0.8, nbars/(nbars+1.5));

for i = 1:nbars % Plot errors for the first group
  ex = (1:ngrps) - grpwidth/2 + (2*i-1) * grpwidth/(2*nbars);

  if ~isempty(e)
    errorbar(ex,y(:,i),e(:,i), 'Marker', 'None', 'LineStyle','None','Color', args.err_color);
  end
  
  % Plot significance
  if ~isempty(args.p_vals)    
    for j = 1:numel(args.p_vals(:,i))
      
      idx = find(args.p_vals(j,i) < args.p_thr);
      if ~isempty(idx)
        h = text(ex(j), args.p_height, args.p_mark{idx(end)});
        set(h,'HorizontalAlignment','center');
      end
      
    end        
  end
  
end

hold off;

% Label the X axis accordingly:

set(gca,'XTick', 1:ngrps);

if ~isempty(x) && iscell(x)  
  set(gca, 'XTickLabel', x);
elseif ~isempty(x) && isnumeric(x)
  for i = 1:numel(x)
    s{i} = num2str(x(i));
  end
  set(gca, 'XTickLabel', s);
end


  





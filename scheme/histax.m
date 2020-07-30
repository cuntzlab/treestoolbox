% HISTAX   Corrected histogram counts.
% (scheme package)
%
% yax = histax (x, xax)
% ---------------------
%
% Produces correct edges for binning in order to plot yax against xax.
%
% Input
% -----
% - x        ::vector: x values
% - xax      ::vector: x values of bin centers
%
% Output
% ------
% - yax      ::vector: y values distributed along xax
%
% Example
% -------
% x          = randn (100000, 1);
% xax        = -10 : 0.1 : 10;
% yax        = histax (x, xax);
% plot       (xax, yax);
%
% See also
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2020  Hermann Cuntz

function yax = histax (x, xax)


xax = [(xax-(xax(2)-xax(1))/2) (xax(end)+(xax(2)-xax(1))/2)];
yax = histcounts (x, xax);




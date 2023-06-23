% TPRINT0   Simplified printing.
% (Utilities package)
%
% [name, path] = tprint (name, fsize)
% -----------------------------------
%
% Prints the current figure to a publication quality file without further
% bagage.
%
% Input
% -----
% - name     ::string: name of the output-file without extension
%     {DEFAULT : open gui fileselect}
%     Spaces and other weird symbols not allowed!
% - fsize    ::2-tupel: fixed size in cm [horiz. x vertical]
%     {DEFAULT 6cm x 4cm}
%
% Output
% ------
% - name     ::string: name of output file;
%     []     no file was selected -> no output
% - path     ::string: path of the file
%   complete file name is therefore: [path name]
%
% Example
% -------
% plot_tree    (sample_tree); tprint0;
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [tname, tpath] = tprint0 (tname, fsize)

if (nargin < 1) || isempty (tname)
    [tname, tpath] = uiputfile ('.*', 'print figure content', 'fig');
    if (tname    == 0)
        tname    = [];
        return
    end
else
    tpath        = '';
end
nstart           = unique ([ ...
    0 ...
    (strfind (tname, '/')) ...
    (strfind (tname, '\'))]);
if nstart (end)  > 0
    tpath        = [tpath (tname(1 : nstart (end)))];
    tname (1 : nstart (end)) = '';
end

if ~exist (tpath, 'dir')
    mkdir        (tpath);
end

% percent symbol makes problems with ghostscript:
tname (strfind (tname, '%')) = 'p';

if (nargin < 2) || isempty (fsize)
    fsize        = [6 4];
end

% ax = gca;
% t                = tiledlayout (1, 1, ...
%     'Padding',                 'tight');
set              (gca, ...
    'ActivePositionProperty',  'position', ...
    'position',                [0.2 0.2 0.75 0.75], ...
    'XMinorTick',              'on', ...
    'YMinorTick',              'on', ...
    'ticklength',              [0.096 0.24] ./ max (fsize), ...
    'tickdir',                 'out', ...
    'linewidth',               0.5, ...
    'fontsize',                6, ...
    'fontname',                'arial');

set              (gcf, ...
    'units',                   'centimeters', ...
    'PaperUnits',              'centimeters', ...
    'papersize',               fsize, ...
    'PaperPosition',           [0 0 fsize]);


print    ([tpath tname '.png'], '-dpng', '-r600');

% EXPORTGRAPHICS DOES NOT YET ALLOW SPECIFIC SIZES IN CM !!!
% exportgraphics (t, [tpath tname '.png'], ...
%    'ContentType',         'image', ...
%    'Resolution',          600);

print    ([tpath tname '.eps'], '-depsc2','-painters');




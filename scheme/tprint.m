% TPRINT   Simplified printing.
% (scheme package)
%
% [name path] = tprint (name, options, fsize, shineoptions)
% ---------------------------------------------------------
%
% Prints the current figure to a file.
%
% Input
% -----
% - name     ::string: name of the output-file without extension
%     {DEFAULT : open gui fileselect}
%     Spaces and other weird symbols not allowed!
% - options  ::string:
%     '-SHR' 1200 dpi
%     '-HR'  600  dpi
%     '-R'   300  dpi
%     '-LR'  150  dpi
%     '-jpg' as jpg
%     '-tif' as tif
%     '-eps' as eps  (more than one output format is possible!)
%     {DEFAULT '-R -jpg'}
% - fsize    ::2-tupel: fixed size in cm [horiz. x vertical]
%     {DEFAULT 8cm x 6cm}
% - shineoptions ::string:
%     '-a'   : axis invisible
%     '-f'   : full axis
%     '-s'   : scalebar in um
%     '-p'   : camlight and lighting gouraud
%     '-q'   : publication quality  
%     '-3d'  : 3D view
%     {DEFAULT: ''} , see shine
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
% plot_tree    (sample_tree); tprint;
%
% See also
% Uses shine
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2017  Hermann Cuntz

function [tname, tpath] = tprint (tname, options, fsize, shineoptions)

if (nargin < 1) || isempty (tname)
    [tname, tpath] = uiputfile ('.*', 'print figure content', 'fig');
    if tname    == 0
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

if ~exist(tpath,'dir')
    mkdir(tpath)
end
 % percent symbol makes problems with ghostscript:
tname (strfind (tname, '%')) = 'p';


if (nargin < 2) || isempty (options)
    options      = '-HR -q';
    switch       tname (end - 2 : end)
        case     {'pdf', 'eps', 'png', 'tif', 'svg'}
            options = strcat (options, ' -', tname (end - 2 : end));
        otherwise
            options = strcat (options, ' -png');
    end
end

if (nargin < 3) || isempty (fsize)
    fsize        = [8 6];
end

if (nargin < 4) || isempty (shineoptions)
    shineoptions = 'none';
end

if     ~isempty(regexp(options, '-HR','ONCE'))
    res          = 600;
elseif ~isempty(regexp(options, '-SHR','ONCE'))
    res          = 1200;
elseif ~isempty(regexp(options, '-LR','ONCE'))
    res          = 150;
else
    res          = 300;
end

if contains (options, '-q')
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
end

set              (gcf, ...
    'units',                   'centimeters', ...
    'PaperUnits',              'centimeters', ...
    'papersize',               fsize, ...
    'PaperPosition',           [0 0 fsize]);

if ~strcmp       (shineoptions, 'none')
    shine        (shineoptions);
end
usedFormats = 0;
if ~isempty(regexp(options, '-png','ONCE'))
    if ~isempty  (regexp (tname, '.png','ONCE'))
        print    ('-dpng',   ...
            ['-r' (num2str (res))], [tpath tname]);
    else
        print    ('-dpng',   ...
            ['-r' (num2str (res))], [tpath tname '.png']);
    end
    usedFormats = usedFormats +1;
end
if ~isempty(regexp(options, '-jpg','ONCE'))
    print        ('-djpeg',  ...
        ['-r' (num2str (res))], [tpath tname '.jpg']);
    usedFormats = usedFormats +1;
end
if ~isempty(regexp(options, '-tif','ONCE'))
    if ~isempty  (regexp (tname, '.tif','ONCE'))
        print    ('-dtiff', ...
            ['-r' (num2str (res))], [tpath tname]);
    else
        print    ('-dtiff', ...
            ['-r' (num2str (res))], [tpath tname '.tif']);
    end    
    usedFormats = usedFormats +1;
end
if ~isempty(regexp(options, '-eps','ONCE'))
    %     print        ('-depsc2', [tpath tname '.eps']);
    print        ('-painters', '-depsc2', ...
        [tpath tname '.eps']);
    usedFormats = usedFormats +1;
end
if ~isempty(regexp(options, '-pdf','ONCE'))
    if ~isempty  (regexp(tname, '.pdf','ONCE'))
        print    ('-painters', '-dpdf', ...
            ['-r' (num2str (res))], '-loose', [tpath tname]);
    else
        print    ('-painters', '-dpdf', ...
            ['-r' (num2str (res))], [tpath tname '.pdf']);
    end
    usedFormats = usedFormats +1;
end
if ~isempty(regexp(options, '-svg','ONCE'))
    axes         ( ...
        'Position',            [0.005 0.005 0.99 0.99], ...
        'xtick',               [], ...
        'ytick',               [], ...
        'box',                 'on');
    set          (gcf, 'children', flipud (get (gcf, 'children')));
    if exist('plot2svg','file')
        plot2svg ([tpath tname '.svg']);
    else
        warning  ('plot2svg not installed');
    end
    usedFormats = usedFormats +1;
end

if ~usedFormats
    error('No file format definition(s) found in option string "%s"',options)
end


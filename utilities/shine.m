% SHINE   Add some effects on current axis.
% (scheme package)
%
% shine (options)
% ---------------
%
% Polishes the graphical output. By default simply adds a camera light
% (therefore the name "shine"), which typically sets the figure renderer to
% opengl as a side effect.
%
% Input
% -----
% - options  ::string:
%     '-a'   : axis invisible
%     '-f'   : full axis
%     '-b'   : big axis (replaces '-f')
%     '-s'   : scalebar in um
%     '-p'   : camlight and lighting gouraud (sunshine)
%     '-3d'  : 3D view
%     {DEFAULT: '-p'}
%
% Output
% ------
%
% Example
% -------
% plot_tree    (sample_tree);
% shine;
%
% See also
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2017  Hermann Cuntz

function shine (options)

if (nargin < 1) || isempty (options)
    % {DEFAULT: add some sunshine}
    options  = '-p';
end

axis         equal;
set          (gcf, ...
    'color',                   [1 1 1]);
axs          = get (gcf, 'children');

if strfind   (options, '-p')   % sunshine option
    camlight;
    camlight;
    lighting gouraud;
end

if strfind   (options, '-s')   % add a scalebar
    scalebar ('\mum');
end

if strfind   (options, '-a')   % set all axes to off
    set      (axs, ...
        'visible',             'off');
end

if strfind   (options, '-f')   % fill the figure with the axes
    set      (axs, ...
        'position',            [0 0 1 1]);
end

if strfind   (options, '-b')   % larger axis than usual
    for counter      = 1 : length (axs)
        bset         = get (axs (counter), 'position');
        bset (3 : 4) = bset (3 : 4) * 1.5;
        set          (axs (counter), ...
            'position',        bset);
    end
end

if strfind (options, '-3d')    % a 3D view
    view     ([-5 55]);
end



% GM_TREE   Membrane conductances of the segments of a tree.
% (trees package)
%
% gm = gm_tree (intree, options)
% ------------------------------
%
% Returns the membrane conductance of all elements [in Siemens].
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% -------
% gm         ::Nx1 vector: membrane conductance values of each segment
%
% Example
% -------
% gm_tree      (sample_tree, '-s')
%
% See also gi_tree
% Uses surf_tree ver_tree Gm
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function gm  = gm_tree (intree, options)

ver_tree     (intree);             % verify that input is a tree structure
% use only membrane conductance vector/value for this function
Gm       = intree.Gm;

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

gm               = Gm .* surf_tree (intree) / 100000000;
% conversion from um2 to cm2 since electrotonic properties are per cm

if contains (options, '-s')   % show option
    ipart        = find (gm ~= 0); % single out non-0-length segments
    clf;
    hold         on;
    plot_tree    (intree, gm, [], ipart);
    colorbar;
    title        ([ ...
        'membrane conductances (total: ' ...
        (num2str (sum (gm))) ...
        ') [S]']);
    xlabel       ('x [\mum]'); 
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end


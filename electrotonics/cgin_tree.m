% CGIN_TREE   Collapsed input conductance.
% (trees package)
% 
% cgin = cgin_tree (intree, options)
% ----------------------------------
%
% Returns the input conductance corresponding to the amount of membrane
% assuming that the total leak is collapsed onto one location (point
% neuron). The total surface of the entire tree is taken into account and
% the leak is calculated through the specific membrane resistance value.
%
% Input
% -----
% - intree   ::integer:    index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - cgin     ::value: collapsed input conductance value in [nS]
%
% Example
% -------
% cgin_tree    (sample_tree, '-s')
%
% See also sse_tree
% Uses surf_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function cgin = cgin_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
% use only membrane conductance vector/value for this function:
Gm           = intree.Gm;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('s', false)
pars = parseArgs(p, varargin, {}, {'s'});
%==============================================================================%

cgin             = 1 / ...
    ((1 / Gm) / (sum (surf_tree (intree)) / 100000000));
% conversion here from [um2] to [cm2] since electrotonic properties
% are per cm2

if pars.s
    % calculate local input conductance in tree:
    gin          = 1 ./ (diag (sse_tree (intree)) * 1000000);

    clf;
    hold         on;
    plot_tree    (intree, gin ./ cgin, [], [], [], '-p');
    colorbar;
    title        ([ ...
        'local input conductance / collapsed input conductance (' ...
        (num2str (1000000000 * cgin)) ...
        ' nS)']);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end


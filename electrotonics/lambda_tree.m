% LAMBDA_TREE   Length constants of the segments of a tree.
% (trees package)
%
% lambda = lambda_tree (intree, options)
% --------------------------------------
%
% Returns the length constant for each segment in cm.
%
% Input
% -----
% - intree   ::integer:    index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% -------
% lambda     ::Nx1 vector: length constant values of each segment
%
% Example
% -------
% lambda_tree  (sample_tree, '-s')
%
% See also elen_tree gm_tree
% Uses D Gm Ri
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function lambda = lambda_tree (intree, varargin)

ver_tree     (intree);                   % verify that input is a tree
tree         = intree;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('s', false)
pars = parseArgs(p, varargin, {}, {'s'});
%==============================================================================%

lambda           = sqrt ((tree.D / 4) ./ (10000 .* tree.Gm .* tree.Ri));

if pars.s         % show option
    clf;
    hold         on; 
    plot_tree    (intree, lambda);
    colorbar;
    title        ('length constants [cm]');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end


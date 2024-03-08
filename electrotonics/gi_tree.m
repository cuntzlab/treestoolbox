% GI_TREE   Axial conductances of the segments of a tree.
% (trees package)
% 
% gi = gi_tree (intree, options)
% ------------------------------
%
% Returns the axial conductances of all elements [in Siemens].
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
% gi ::Nx1 vector: axial conductance values of each segment
%
% Example
% -------
% gi_tree      (sample_tree, '-s')
%
% See also gm_tree
% Uses cvol_tree ver_tree Ri
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function gi  = gi_tree (intree, varargin)

ver_tree     (intree);                   % verify that input is a tree
% use only axial resistance vector/value for this function
Ri       = intree.Ri;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('s', false)
pars = parseArgs(p, varargin, {}, {'s'});
%==============================================================================%

Hlov             = 1 ./ (cvol_tree (intree) * 10000);
% conversion cvol from 1/um to 1/cm Hlov is in [cm]
gi               = Hlov ./ Ri;

if pars.s         % show option
    ipart        = find (gi < 0.0099);   % single out non-0-length segments
    clf;
    hold         on;
    plot_tree    (intree, gi, [], ipart);
    colorbar;
    title        ('axial conductances [S]');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]'); 
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end


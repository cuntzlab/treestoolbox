% IDCHILD_TREE   Index to direct child nodes in a tree.
% (trees package)
% 
% idchild = idchild_tree (intree, ipart, options)
% -----------------------------------------------
%
% Returns the indices to the direct child nodes for each individual node in
% the tree.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - ipart    ::index:        index to the subpart to be plotted
%     {DEFAULT: all nodes}
% - options  ::string:
%     '-s'   : show
%     '-f'   : output only first child (Careful, it used to be '-1')
%     {DEFAULT: ''}
%
% Output
% ------
% - idchild  ::N x 2 vector: index of direct child node to each node
%
% Example
% -------
% idchild_tree (sample_tree, [], '-s')
%
% See also     ipar_tree child_tree
% Uses         ver_tree dA
%
% Contributed by Marcel Beining 2017
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function idchild = idchild_tree (intree, varargin)

ver_tree     (intree);                 % verify that input is a tree
% use only directed adjacency for this function
dA           = intree.dA;
N            = size (dA, 1);

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('ipart', (1 : N)', @isnumeric) % TODO check the size and type of ipart
p.addParameter('s', false, @isBinary)
p.addParameter('f', false, @isBinary)
pars = parseArgs(p, varargin, {'ipart'}, {'s', 'f'});
%==============================================================================%

idchild          = NaN (numel (pars.ipart), 2);
[row, col]       = find (dA (:, pars.ipart));

for n            = 1 : numel (pars.ipart)
    idchild (n, 1 : sum (col == n)) = row (col == n)';
end

if pars.f
   idchild       = idchild (:, 1); 
end

if pars.s            % show option
    clf; 
    HP           = plot_tree  (intree, [], [], [], [], '-b');
    set          (HP, ...
        'facealpha',           0.2, ...
        'edgecolor',           'none');
    T            = vtext_tree (intree, [], [0 0.5 0], [-2 3 5]);
    set          (T, ...
        'fontsize',            14);
    inan         = ~isnan     (idchild (:, 1));
    T            = vtext_tree (intree, idchild (inan, 1), [1 0 0],  ...
        [0 0 5], [], inan);
    set          (T, ...
        'fontsize',            14);
    inan         = ~isnan     (idchild (:, 2));
    T            = vtext_tree (intree, idchild (inan, 2), [1 0.5 0],  ...
        [0 5 0], [], inan);
    set          (T, ...
        'fontsize',            14);
    title        ('direct child ID');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end


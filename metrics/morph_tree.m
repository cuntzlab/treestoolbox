% MORPH_TREE   Morph a metrics preserving angles and topology.
% (trees package)
%
% tree = morph_tree (intree, v, options)
% --------------------------------------
%
% Morphs a tree's metrics without changing angles or topology. Attributes
% length values from v to the individual segments but keeps the branching
% structure otherwise intact. This can result in a huge mess (overlap
% between previously non-overlapping segments) or extreme sparseness
% depending on the tree. This is a META-FUNCTION and can lead to various
% applications. This funciton provides universal application to all
% possible morpho-electrotonic transforms and much much more. If the
% original lengths of segments are backed up in a vector len, the original
% tree can simply be regrown by:
% originaltree = morph_tree (morphedtree, len);
% HOWEVER: 0-length elements cannot be regrown.
%
% Input
% -----
% - intree   ::integer: index of tree in trees or structured tree
% - v        ::vertical vector: values to map on the length of the segments
%     {DEFAULT: 10 um pieces}
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     '-m'   : demo movie
%     {DEFAULT: '-w'}
%
% Output
% -------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% morph_tree   (sample_tree, [], '-s -m')
%
% See also flatten_tree zcorr_tree
% Uses ipar_tree tran_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function tree = morph_tree (intree, v, options)


ver_tree     (intree); % verify that input is a tree structure
tree         = intree;

if (nargin < 2) || isempty (v)
    % {DEFAULT vector: 10 um pieces between all nodes}
    v        = ones (size (tree.dA, 1), 1) .* 10; 
end

if (nargin < 3) || isempty(options)
    % {DEFAULT: waitbar}
    options  = '-w'; 
end

ipar             = ipar_tree (tree); % parent index structure
X0               = tree.X (1);
Y0               = tree.Y (1);
Z0               = tree.Z (1); % root coordinates
tree             = tran_tree (tree); % center on root
len              = len_tree  (tree); % length values of tree segments [um]

if contains      (options, '-m') % show movie option
    clf;
    HP           = plot_tree (tree);
    title        ('morph a tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (3);
    grid         on;
    axis         image;
end

if contains      (options, '-w') % waitbar option: initialization
    if length    (tree.X) > 998
        HW       = waitbar (0, 'morphing ...');
        set      (HW, 'Name', '..PLEASE..WAIT..YEAH..');
    end
end
for counter      = 2 : length (tree.X)
    if contains  (options, '-w') % waitbar option: update
        if  (mod (counter, 1000) == 999)
            waitbar (counter ./ length (tree.X), HW);
        end
    end
    if len (counter) ~= v (counter)
        % node to parent node differences:
        dX       = tree.X (counter) - tree.X (ipar (counter, 2));
        dY       = tree.Y (counter) - tree.Y (ipar (counter, 2));
        dZ       = tree.Z (counter) - tree.Z (ipar (counter, 2));
        XYZ      = sqrt ((dX.^2) + (dY.^2) + (dZ.^2)); % 3D segment length
        % find sub-tree indices:
%         [sub, ~] = ind2sub (size (ipar), find (ipar == counter));
        sub      = sub_tree (tree, counter);
        % correct for change loss of length, move sub-tree
        if XYZ   == 0 
            % if original length is zero no direction is given -> random:
            R    = rand (1, 3);
            R    = R ./ sqrt (sum (R.^2));
            dX   = R (1, 1);
            dY   = R (1, 2);
            dZ   = R (1, 3);
            XYZ  = 1;
        end
        tree.X (sub) = tree.X (sub) - dX + v (counter) .* (dX ./ XYZ);
        tree.Y (sub) = tree.Y (sub) - dY + v (counter) .* (dY ./ XYZ);
        tree.Z (sub) = tree.Z (sub) - dZ + v (counter) .* (dZ ./ XYZ);
        if contains (options, '-m') % show movie option: update
            set  (HP, ...
                'visible',     'off');
            HP   = plot_tree (tree);
            axis tight;
            drawnow;
        end
    end
end
if contains       (options, '-w') % waitbar option: close
    if length    (tree.X) > 998
        close    (HW);
    end
end

tree             = tran_tree (tree, [X0 Y0 Z0]); % move back the tree

if contains      (options, '-s') % show option
    clf;
    hold         on;
    HP           = plot_tree (intree);
    set          (HP, ...
        'facealpha',           0.5);
    HP           = plot_tree (tree, [1 0 0]);
    set          (HP, ...
        'facealpha',           0.5);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, ...
        {'before',             'after'});
    set          (HP, ...
        'visible',             'off');
    title        ('morph the tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]'); 
    zlabel       ('z [\mum]');
    view         (3);
    grid         on;
    axis         image;
end


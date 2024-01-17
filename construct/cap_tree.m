% CAP_TREE   Adds a cap to the soma of a tree.
% (trees package)
%
% [tree, idpar] = cap_tree (intree, options)
% ------------------------------------------
%
% Adds small segments to close open somata and optionally add axon.
%
% Inputs
% ------
% - intree   ::integer: index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show before and after
%     '-i1'  : 1 node each 1 µm
%     '-a'   : also add axon 
%     {DEFAULT: '-i1'}
%
% Output
% -------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% cap_tree  (soma_tree (resample_tree (sample_tree, 1), 30, 45), '-s')
%
% See also soma_tree
% Uses ver_tree X Y Z
%
% Contributed by Marcel Beining, 2017
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [tree, idpar] = cap_tree (intree, options)
% INACT-so : define soma???

ver_tree     (intree);
tree         = intree;

if (nargin < 2) || isempty (options)
    % {DEFAULT: 1 node each 1 µm}
    options  = '-i1';
end

direction        = direction_tree (tree, '-n');
width            = tree.D (1);
fun1             = @(x, y) (real (sqrt (x.^2 - 2 * y.^2)));
if contains (options, '-a')
    len2         = 1350;
    axondiam     = normrnd (0.45, 0);
    scale        = normrnd (-0.2, 0.02);
    fun2         = @(x, y) ...
        (0.8 * (x - axondiam) * exp (scale * y) + axondiam);
else
    len2         = width;
    fun2         = fun1;
end


if contains (options, '-i')  % std is 1 node each µm
    ind          = cell2mat (textscan (options, '-i%f'));
    if isempty   (ind)
        ind      = 1;
    end
    lin          = 0 : ind : floor (len2);
else
    lin          = linspace (0, width, ...
        ceil (width / mean (len_tree (tree))));
    if contains (options, '-a')
        lin (end + 1) = 1350;
    end
    
end

idpar            = 1;
for l            = lin (2 : end)
    if  fun1 (width, l) < fun2 (width, l)
        d        = fun2 (width, l);
    else
        d        = fun1 (width, l);
        il       = l;
    end
    if d > 0 
        [tree, idpar(end+1)] = insert_tree (tree, ...
            [0, 1, ...
            [(tree.X (1)) (tree.Y (1)) (tree.Z (1))] - ...
            (l * direction (2, :)), d, (idpar (end))],'none');
    else
       warning   ('diameter was zero or less. skipped') 
    end
end
tree.R (idpar)   = tree.R (idpar (1)); % give region same as root
pl               = Pvec_tree (tree);
if contains (options, '-a')
   if ~any (strcmp (tree.rnames, 'axon'))
       tree.rnames = [tree.rnames, 'axon'];
   end
   if ~any (strcmp (tree.rnames, 'axonh'))
       tree.rnames = [tree.rnames, 'axonh'];
   end
   indAIS        = pl (idpar) >= il & pl (idpar) < 3 * width;
   indaxon       = pl (idpar) > 3 * width;
   tree.R (idpar (indAIS))  = find (strcmp (tree.rnames, 'axonh'));
   tree.R (idpar (indaxon)) = find (strcmp (tree.rnames, 'axon'));
end

if contain       (options, '-s')
    clf; hold on;
    HP           = plot_tree (intree);
    set          (HP, 'facealpha', .5);
    HP           = plot_tree (tree, [1 0 0]);
    set          (HP, 'facealpha', .5);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, {'before', 'after'});
    set          (HP, 'visible', 'off');
    title        ('add a cap to your tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end


% SMOOTH_TREE   Smoothes a tree along its longest paths.
% (trees package)
%
% tree = smooth_tree (intree, pwchild, p, n, options)
% ---------------------------------------------------
%
% Smoothes a tree along its longest paths. This changes (shortens) the
% total length of the branch significantly. First finds the heavier
% sub-branches and puts them together to longest paths. Then a smoothing
% step is applied on the branches individually. smooth_tree calls
% smoothbranch but this subfunction can be replaced by any other one of a
% similar type.
%
% Input
% -----
% - intree   ::integer:   index of tree in trees or structured tree
% - pwchild  ::0.5..1:    sets the minimum weight asymmetry to choose
%     weighted subbranch
%     {DEFAULT: 0.5} 
% - p        ::0..1:      proportion smoothing at each iteration step
%     {DEFAULT: 0.9}
% - n        ::integer>0: number of smoothing iterations
%     {DEFAULT: 5}
% - options  ::string:
%     '-s'   : show
%     '-w'   : waitbar
%     {DEFAULT: '-w'}
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree     :: structured output tree
%
% Example
% -------
% smooth_tree (sample_tree, 0.5, 0.5, 2, '-s');
%
% See also smoothbranch MST_tree
% Uses dissect_tree ipar_tree child_tree smoothbranch
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function  tree = smooth_tree (intree, varargin)

ver_tree     (intree); % verify that input is a tree structure
tree         = intree;

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('pwchild', 0.5)
p.addParameter('p', 0.9)
p.addParameter('n', 5)
p.addParameter('w', true)
p.addParameter('s', false)
pars = parseArgs(p, varargin, {'pwchild', 'p', 'n'}, {'w', 's'});
%==============================================================================%

% starting and end points of all branches:
sect             = dissect_tree (tree);
% parent index structure (see "ipar_tree"):
ipar             = ipar_tree    (tree);
% vector containing index to direct parent:
idpar            = ipar         (:, 2);
% number of daugther nodes:
nchild           = child_tree   (tree);

if pars.w       % waitbar option: initialization
    HW           = waitbar (0, 'finding heavy sub-branches...');
    set      (    HW, ...
        'Name',                '..PLEASE..WAIT..YEAH..');
end
counter          = 1;
while counter    <= size (sect, 1)
    if pars.w   % waitbar option: update
        if mod   (counter, 500) == 0
            waitbar (counter / (size (sect, 1)), HW);
        end
    end
    % direct children nodes of branch counter:
    dchildren    = find   (idpar == sect (counter, 2));
    % index to branches which continue after branch counter
    indi1        = find   (sect (:, 1) == sect (counter, 2));
    % end nodes of these branches:
    ep           = sect   (indi1, 2);
    % weight of child trees:
    wchild       = nchild (dchildren);
    % relative weight of child trees
    rwchild      = wchild ./ sum (wchild);
    if sum       (rwchild > pars.pwchild)
        [~, i2]  = max (rwchild);
        % sub tree of heaviest child tree
        [subs, ~] = ind2sub (size (ipar), find (ipar == dchildren (i2)));
        % index to branch which contains this child tree
        [~, i2]  = intersect (ep, subs);
        sect     (counter,    2) = sect (indi1 (i2), 2);
        sect     (indi1 (i2), :) = [];
    else
        counter  = counter + 1;
    end
end

if pars.w   % waitbar option: reinitialization
    waitbar      (0, HW, 'smoothing heavy sub-branches...');
end
for counter      = 1 : size (sect, 1)
    if pars.w   % waitbar option: update
        waitbar  (counter / (size (sect, 1)), HW);
    end
    % corresponds to "plotsect_tree":
    indi2        = ipar (sect (counter, 2), 1 : ...
        find (ipar (sect (counter, 2), :) == sect (counter, 1)));
    % smooth the heavier branches (see "smoothbranch")
    [Xs, Ys, Zs] = smoothbranch ( ...
        tree.X (indi2), ...
        tree.Y (indi2), ...
        tree.Z (indi2), pars.p, pars.n);
    tree.X (indi2) = Xs;
    tree.Y (indi2) = Ys;
    tree.Z (indi2) = Zs;
end
if pars.w   % waitbar option: close
    close        (HW);
end

if pars.s   % show option
    clf;
    hold         on;
    plot_tree    (intree);
    plot_tree    (tree, [1 0 0]);
    HP (1)       = plot (1, 1, 'k-');
    HP (2)       = plot (1, 1, 'r-');
    legend       (HP, {'before', 'after'});
    set          (HP, 'visible','off');
    title        ('smooth tree');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end


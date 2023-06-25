%% check_rpoints_tree

%% test 1
clf; hold on;
tree         = hsn_tree;
[M, dX, dY, dZ] = gdens_tree (tree, 20, ...
    find (B_tree (tree) | T_tree (tree)),'none');
c            = hull_tree (tree, 20, [], [], [], '-2d');
rpoints_tree (M, 1290, [], dX, dY, dZ, 5, '-s');
tprint       ('./panels/rpoints_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf; hold on;
tree         = hsn_tree;
[M, dX, dY, dZ] = gdens_tree (tree, 20, ...
    find (B_tree (tree) | T_tree (tree)),'-s');
c            = hull_tree (tree, 20, [], [], [], '-2d');
[X, Y, Z]    = rpoints_tree (M, 100, [], dX,dY,dZ,5);
HP           = plot_tree    (tree, [0 0 0], [], [], 32);
set          (HP, 'facealpha', 0.5);
HP           = plot3 (X, Y, Z, 'r.');
axis         off tight;
tprint       ('./panels/rpoints_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
rpoints_tree (M, 50000, [], dX,dY,dZ,5);

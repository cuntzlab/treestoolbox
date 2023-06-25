%% check_vhull_tree

%% test 1
tree             = sample2_tree;
clf; shine;
axis off;
hp               = plot_tree (tree, [0 0 0], [], [], 32);
set              (hp, ...
    'facealpha',               0.5);
c                = hull_tree (tree, 15, [], [], [], 'none');
points           = c.vertices;
hp               = vhull_tree (tree, BO_tree (tree), points);
set              (hp, ...
    'facealpha',               0.1);
tprint           ('./panels/vhull_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
tree             = sample2_tree;
clf;
axis off;
plot_tree        (tree, [0 0 0], [0 0 5], [], [], '-b1');
c                = hull_tree  (tree, 15, [], [], [], '-2d');
[Xt, Yt]         = cpoints (c);
points           = [Xt Yt];
hp               = vhull_tree (tree, [], points, [], [], '-2d -s');
tprint           ('./panels/vhull_tree2', ...
    '-jpg -HR',                [10 10]);




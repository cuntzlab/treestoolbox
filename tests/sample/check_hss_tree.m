%% check_hss_tree

%% test 1
clf;
tree        = hss_tree;
plot_tree   (tree);
title       ('HSS tree');
axis        off;
tprint      ('./panels/hss_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

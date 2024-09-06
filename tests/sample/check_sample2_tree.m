%% check_sample2_tree

%% test 1
clf;
tree        = sample2_tree;
plot_tree   (tree);
title       ('Sample2 tree');
axis        off;
tprint      ('./panels/sample2_tree1', ...
    '-jpg -HR',                [10 10]); % documentation
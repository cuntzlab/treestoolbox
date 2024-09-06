%% check_sample_tree

%% test 1
clf;
tree        = sample_tree;
plot_tree   (tree);
title       ('Sample tree');
axis        off;
tprint      ('./panels/sample_tree1', ...
    '-jpg -HR',                [10 10]); % documentation

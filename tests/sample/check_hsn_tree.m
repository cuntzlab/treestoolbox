%% check_hsn_tree

%% test 1
clf;
tree        = hsn_tree;
plot_tree   (tree);
title       ('HSN tree');
axis        off;
tprint      ('./panels/hsn_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation





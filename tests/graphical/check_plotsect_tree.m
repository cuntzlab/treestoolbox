%% check_plotsect_tree

%% test 1
clf; hold on;
axis off;
tree             = sample_tree;
plot_tree        (tree);
plotsect_tree    (tree, [1 (size (tree.dA, 1))], [1 0 0], [0 0 10]);
tprint           ('./panels/plotsect_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

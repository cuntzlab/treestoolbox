%% check_pointer_tree

%% test 1
clf; hold on;
axis off;
tree             = sample_tree;
plot_tree        (tree);
pointer_tree     (tree, 1, [], [], [0 0 10]);
pointer_tree     (tree, 2, [], [0 1 0], [0 0 10], '-o');
pointer_tree     (tree, 30, [], [], [0 0 10], '-l');
pointer_tree     (tree, 50, [], [], [0 0 10], '-v');
pointer_tree     (tree, 60, [], [], [0 0 10], '-s');
tprint           ('./panels/pointer_tree1', ...
    '-jpg -HR',                [10 10]);

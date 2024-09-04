%% check_interpd_tree

%% test 1
clf;
tree        = sample_tree;
tree.D (1)  = 20;
treeD       = interpd_tree (tree, [1 10], '-s');
tprint           ('./panels/interpd_tree1', ...
    '-jpg -HR',                [10 10]);




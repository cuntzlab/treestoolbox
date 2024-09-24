%% check_ver_tree

%% test 1
tree        = sample_tree;
ver_tree    (tree);

%% test 2
tree.X      = 0;
ver_tree    (tree);

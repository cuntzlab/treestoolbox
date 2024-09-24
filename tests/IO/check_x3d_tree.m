%% check_x3d_tree

%% test 1
tree        = sample_tree;
x3d_tree    (tree, './test_save/x3d_tree1.x3d',...
    PL_tree (tree) / 20, [], [], '-w -o ->');


%% test 2
x3d_tree    (tree, './test_save/x3d_tree2.x3d', [0 1 0], [2 2 2],...
    BO_tree(tree), '-w -o ->');

%% test 3
x3d_tree    (tree, './test_save/x3d_tree3.x3d', [], [],...
    [], '-w -o -> -v -thin');
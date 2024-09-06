%% check_pov_tree

%% test 1
tree        = sample_tree;
pov_tree    (tree, './test_save/pov_tree1.pov', [], find (BO_tree (tree) > 3), '-w -b -s ->');

%% test 2
tree1       = sample_tree;
tree2       = sample2_tree;
pov_tree    ({tree1, tree2}, './test_save/pov_tree2.pov', [],...
    {(find (BO_tree (tree1) > 3)),(find (BO_tree (tree2) > 4))}, '-w -b -s ->');

%% test 3
pov_tree    (tree, './test_save/pov_tree3.pov', [],[], '-v -w -b -minmax -c');
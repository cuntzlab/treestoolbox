%% check_save_tree

%% test 1
tree      = sample_tree;
save_tree (tree, './test_save/save_tree1.mtr');

%% test 2
tree1     = sample_tree;
tree2     = sample2_tree;
save_tree ({tree1,tree2}, './test_save/save_tree2.mtr');

%% test 3
tree1     = sample_tree;
tree2     = sample2_tree;
tree3     = hsn_tree;
tree4     = hss_tree;
save_tree ({{tree1,tree2},{tree3,tree4}}, './test_save/save_tree3.mtr');
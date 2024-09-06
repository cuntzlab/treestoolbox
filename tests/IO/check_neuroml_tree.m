%% check_neuroml_tree
 
%% test 1
tree            = sample_tree;
path            = './test_save/sample_tree.xml';
neuroml_tree    (sample_tree, './test_save/sample_tree.xml');

%% test 2
tree            = sample2_tree;
path            = './test_save/sample2_tree.xml';
neuroml_tree    (sample2_tree, './test_save/sample2_tree.xml', '-v1l1')
%% check_cap_tree

%% test 1
tree         = resample_tree (sample_tree, 1, 'none');
stree        = soma_tree    (tree, 20, 30, 'none');
ctree        = cap_tree     (stree, '-i1 -s');
tprint       ('./panels/cap_tree1', ...
    '-jpg -HR',                [10 10]);


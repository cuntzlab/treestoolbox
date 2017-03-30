%% check_cap_tree

%% test 1
tree         = resample_tree (sample_tree, 1, 'none');
stree        = soma_tree    (tree, 20, 30, 'none'); % WRONG MEASURES!!!!
ctree        = cap_tree     (stree, '-i1 -s'); % WRONG MEASURES!!!!
tprint       ('./panels/cap_tree1', ...
    '-jpg -HR',                [10 10]);


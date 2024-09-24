%% check_restrain_tree

%% test 1
restrain_tree (sample_tree, 80, '-i -s')
tprint       ('./panels/restrain_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation



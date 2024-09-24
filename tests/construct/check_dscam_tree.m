%% check_dscam_tree

%% test 1
dscam_tree   (sample2_tree, 40, '-s')
tprint       ('./panels/dscam_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation


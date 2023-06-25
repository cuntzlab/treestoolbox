%% check_spread_tree

%% test 1
dLPTCs               = load_tree ('dLPTCs.mtr');
spread_tree          (dLPTCs{1}, [], [], '-s');
tprint               ('./panels/spread_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
dLPTCs               = load_tree ('dLPTCs.mtr');
spread_tree          (dLPTCs{2}, 200, 200, '-s');
tprint               ('./panels/spread_tree2', ...
    '-jpg -HR',                [10 10]);

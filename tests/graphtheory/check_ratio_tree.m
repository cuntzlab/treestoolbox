%% check_ratio_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        ratio_tree   (tree);
    end
end

%% test 2
ratio_tree       (sample_tree, [], '-s');
tprint           ('./panels/ratio_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
ratio_tree       (sample_tree, child_tree (sample_tree), '-s');
tprint           ('./panels/ratio_tree2', ...
    '-jpg -HR',                [10 10]);



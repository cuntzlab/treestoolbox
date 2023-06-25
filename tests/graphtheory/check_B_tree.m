%% check_B_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        B_tree   (tree);
    end
end

%% test 2
B_tree           (sample_tree, '-s')
tprint           ('./panels/B_tree1', ...
    '-jpg -HR',                [10 10]);
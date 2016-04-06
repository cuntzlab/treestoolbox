%% check_PL_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 100
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        PL_tree   (tree);
    end
end

%% test 2
PL_tree          (sample_tree, '-s');
tprint           ('./panels/PL_tree1', ...
    '-jpg -HR',                [10 10]);




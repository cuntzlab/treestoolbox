%% check_rindex_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 100
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        rindex_tree  (tree);
    end
end

%% test 2
rindex_tree      (sample2_tree, '-s');
tprint           ('./panels/rindex_tree1', ...
    '-jpg -HR',                [10 10]);



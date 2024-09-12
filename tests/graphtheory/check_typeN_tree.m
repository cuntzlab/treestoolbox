%% check_typeN_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        typeN_tree   (tree);
        typeN_tree   (tree, '-bct');
    end
end

%% test 2
typeN_tree       (sample_tree, '-s -bct');
tprint           ('./panels/typeN_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
typeN_tree       (sample2_tree, '-s');
tprint           ('./panels/typeN_tree2', ...
    '-jpg -HR',                [10 10]);

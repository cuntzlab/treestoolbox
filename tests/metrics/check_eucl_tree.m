%% check_eucl_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        eucl_tree  (tree);
    end
end

%% test 2
eucl_tree        (sample_tree, [], '-s')
tprint           ('./panels/eucl_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
eucl_tree        (sample_tree, [50 50 0], '-s')
tprint           ('./panels/eucl_tree2', ...
    '-jpg -HR',                [10 10]);



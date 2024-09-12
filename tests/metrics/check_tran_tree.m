%% check_tran_tree

%% test 1
tree             = sample_tree;
tran_tree        (tree, [20 10 14], '-s');
tprint           ('./panels/tran_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 2
tran_tree        (tree, 5, '-s')
tprint           ('./panels/tran_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        tran_tree (tree, [5 5 5]);
    end
end

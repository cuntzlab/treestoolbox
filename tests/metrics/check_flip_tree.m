%% check_flip_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        flip_tree (tree);
    end
end

%% test 2
flip_tree        (sample_tree, 1, '-s');
tprint           ('./panels/flip_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
flip_tree        (sample_tree, 2, '-s');
tprint           ('./panels/flip_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 4
flip_tree        (sample_tree, 3, '-s');
tprint           ('./panels/flip_tree3', ...
    '-jpg -HR',                [10 10]);


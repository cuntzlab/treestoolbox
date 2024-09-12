%% check_T_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        T_tree   (tree);
    end
end

%% test 2
T_tree           (sample_tree, '-s')
tprint           ('./panels/T_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation
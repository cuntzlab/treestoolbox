%% check_C_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        C_tree   (tree);
    end
end

%% test 2
C_tree           (sample_tree, '-s')
tprint           ('./panels/C_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation
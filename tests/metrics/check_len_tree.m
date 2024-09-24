%% check_len_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        len_tree (tree);
    end
end

%% test 2
len_tree         (sample_tree, '-s');
tprint           ('./panels/len_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
len_tree         (sample_tree, '-s -2d');
tprint           ('./panels/len_tree2', ...
    '-jpg -HR',                [10 10]);



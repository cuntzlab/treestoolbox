%% check_idpar_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        idpar_tree   (tree);
    end
end

%% test 2
idpar_tree       (sample2_tree, '-s');
tprint           ('./panels/idpar_tree1', ...
    '-jpg -HR',                [10 10]);




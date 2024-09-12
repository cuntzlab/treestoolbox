%% check_LO_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 100
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        LO_tree   (tree);
    end
end

%% test 2
LO_tree          (sample_tree, '-s');
tprint           ('./panels/LO_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation




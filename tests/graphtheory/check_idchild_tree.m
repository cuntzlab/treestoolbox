%% check_idchild_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        idchild_tree   (tree);
    end
end

%% test 2
idchild_tree     (sample2_tree, [], '-s');
tprint           ('./panels/idchild_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation




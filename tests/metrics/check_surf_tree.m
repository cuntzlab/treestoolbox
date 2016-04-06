%% check_surf_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        surf_tree (tree);
    end
end

%% test 2
surf_tree        (sample_tree, '-s');
tprint           ('./panels/surf_tree1', ...
    '-jpg -HR',                [10 10]);




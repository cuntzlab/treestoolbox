%% check_ssecat_tree

%% test 1
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 10
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        tree.Ri      = 100;
        tree.Gm      = 1 / 2500;
        tree.Cm      = 1;
        ssecat_tree  ( ...
            {(tran_tree (tree, [-50 30 0])), sample_tree}, ...
            2, 115, 0.01, [], 'none');
    end
end

%% test 2
ssecat_tree  ( ...
    {(tran_tree (sample2_tree, [-50 30 0])), sample_tree}, ...
    2, 115, 0.01, 8, '-s');
tprint           ('./panels/ssecat_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
ssecat_tree  ( ...
    {(tran_tree (sample2_tree, [-50 30 0])), sample_tree}, ...
    2, 115, 0.01, [], '-s');
tprint           ('./panels/ssecat_tree2', ...
    '-jpg -HR',                [10 10]);



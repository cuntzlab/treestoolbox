%% check_syncat_tree

%% test 1
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 10
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        tree.Ri      = 100;
        tree.Gm      = 1 / 2500;
        tree.Cm      = 1;
        syncat_tree  ( ...
            {(tran_tree (tree, [-50 30 0])), sample_tree}, ...
            2, 115, 0.01, ...
            100,  95, [], [], ...
            [], 'none');
    end
end

%% test 2
syncat_tree  ( ...
    {(tran_tree (sample2_tree, [-50 30 0])), sample_tree}, ...
    2, 55, 1, ...          % electrical synapse
    120,  105, [], [], ... % exc and inh synapse
    8, '-s');
tprint           ('./panels/syncat_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 2
syncat_tree  ( ...
    {(tran_tree (sample2_tree, [-50 30 0])), sample_tree}, ...
    2, 115, 1, ...         % electrical synapse
    120,  105, [], [], ... % exc and inh synapse
    [], '-s');
tprint           ('./panels/syncat_tree2', ...
    '-jpg -HR',                [10 10]);
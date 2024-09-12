%% check_syn_tree

%% test 1
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 100
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        tree.Ri      = 100;
        tree.Gm      = 1 / 2500;
        tree.Cm      = 1;
        syn_tree     (tree, 100,  95, [], [], [], 'none');
    end
end

%% test 2
syn_tree         (sample_tree, 100,  95, [], [], [], '-s')
tprint           ('./panels/syn_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
syn_tree         (sample_tree, 100,  105, [], [], [], '-s')
tprint           ('./panels/syn_tree2', ...
    '-jpg -HR',                [10 10]);
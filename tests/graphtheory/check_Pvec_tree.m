%% check_Pvec_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 100
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        Pvec_tree   (tree, []);
    end
end

%% test 2
Pvec_tree        (sample_tree, [], '-s');
tprint           ('./panels/Pvec_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
Pvec_tree        (sample_tree, BO_tree (sample_tree), '-s');
tprint           ('./panels/Pvec_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 4
Pvec_tree        (sample_tree, vol_tree (sample_tree), '-s');
tprint           ('./panels/Pvec_tree3', ...
    '-jpg -HR',                [10 10]);





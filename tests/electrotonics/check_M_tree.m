%% check_M_tree

%% test 1
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 100
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        tree.Ri      = 100;
        tree.Gm      = 1 / 2500;
        tree.Cm      = 1;
        M_tree       (tree, 'none');
    end
end

%% test 2
M_tree               (sample_tree, '-s')
tprint               ('./panels/M_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation
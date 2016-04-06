%% check_cyl_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        cyl_tree (tree);
    end
end

%% test 2
[X1, X2, Y1, Y2, Z1, Z2] = cyl_tree (sample_tree)




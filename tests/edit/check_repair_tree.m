%% check_repair_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        repair_tree  (tree, 'none');
    end
end

%% test 2
repair_tree      (sample2_tree, '-s');
tprint           ('./panels/repair_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
tree             = sample2_tree;
iB               = find (B_tree  (tree), 1);
dtree            = redirect_tree (tree, iB);
[tree, ntrif]    = repair_tree   (dtree, '-s');
display          (ntrif);
tprint           ('./panels/repair_tree2', ...
    '-jpg -HR',                [10 10]);


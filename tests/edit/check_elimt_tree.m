%% check_elimt_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 100
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        iB           = find (B_tree  (tree), 1);
        dtree        = redirect_tree (tree, iB);
        elimt_tree   (dtree, 'none');
    end
end

%% test 2
tree             = sample2_tree;
iB               = find (B_tree  (tree), 1);
dtree            = redirect_tree (tree, iB);
[etree, ntrif]   = elimt_tree    (dtree, '-s -e');
display          (ntrif);
axis             off
tprint           ('./panels/elimt_tree1', ...
    '-jpg -HR',                [10 10]);
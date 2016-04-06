%% check_BCT_tree

%% test 1
dLPTCs       = load_tree ('dLPTCs.mtr');
for counter  = 1 : length (dLPTCs{1})
    BCT_tree (sum (dLPTCs{1}{counter}.dA, 1));
end

%% test 2
BCT_tree         ([1 2 1 0 2 0 0], '-s');
tprint           ('./panels/BCT_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
hsn              = hsn_tree;
BCT              = sum (full (hsn.dA));
BCT_tree         (BCT, '-s -w');
tprint           ('./panels/BCT_tree2', ...
    '-jpg -HR',                [10 10]);

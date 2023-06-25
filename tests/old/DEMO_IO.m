% DEMOs reference

%% pov1_tree
pov_tree (sample2_tree, 'pov1.pov', [], '-b -s1 -w ->');

%% pov1_tree
pov_tree (sample2_tree, 'pov2.pov', [], '-b -s2 -w ->');

%% pov1_tree
pov_tree (sample2_tree, 'pov3.pov', [], '-b -s3 -w ->');

%% pov1_tree
pov_tree (sample2_tree, 'pov4.pov', [], '-b -s4 -w ->');

%% pov1_tree
pov_tree (sample2_tree, 'pov5.pov', [], '-b -s5 -w ->');

%% pov1_tree
pov_tree (sample2_tree, 'pov6.pov', [], '-b -s6 -w ->');

%% pov1_tree
pov_tree (sample2_tree, 'pov7.pov', eucl_tree (sample2_tree), '-b -s1 -w ->');

%% pov1_tree
dLPTCs = load_tree ('dLPTCs.mtr');
pov_tree (dLPTCs{1}, 'pov8.pov', [], '-b -s1 -c -w ->');
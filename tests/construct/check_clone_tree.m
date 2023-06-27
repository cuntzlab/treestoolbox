%% check_clone_tree

%% test 1
dLPTCs       = load_tree  ('dLPTCs.mtr');
tree         = clone_tree (dLPTCs{1}, 1, 0.1, '-s -2d');
tprint       ('./panels/clone_tree1', ...
    '-jpg -HR', [10 10]);

%% test 2 (3D)
tree         = clone_tree (dLPTCs{1}, 1, 0.1, '-s');
tprint       ('./panels/clone_tree2', ...
    '-jpg -HR', [10 10]);




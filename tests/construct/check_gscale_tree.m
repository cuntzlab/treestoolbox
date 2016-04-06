%% check_gscale_tree

%% test 1
dLPTCs       = load_tree  ('dLPTCs.mtr');
spanning     = gscale_tree (dLPTCs{1}, '-s');
display      (spanning);
tprint       ('./panels/gscale_tree1', ...
    '-jpg -HR', [10 10]);

%% test 2
L5           = load_tree  ([  ...
    './data/Markram - rat - ' ...
    'cerebral cortex pyramidal cell L5 - GROUNDTRUTH.mtr']);
spanning     = gscale_tree (L5, '-s -w');
display      (spanning);
tprint       ('./panels/gscale_tree2', ...
    '-jpg -HR', [10 10]);



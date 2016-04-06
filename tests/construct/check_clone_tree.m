%% check_clone_tree

%% test 1
dLPTCs       = load_tree  ('dLPTCs.mtr');
tree         = clone_tree (dLPTCs{1}, 1, 0.1, '-s -2d');
tprint       ('./panels/clone_tree1', ...
    '-jpg -HR', [10 10]);

%% test 2
L5           = load_tree  ([  ...
    './data/Markram - rat - ' ...
    'cerebral cortex pyramidal cell L5 - GROUNDTRUTH.mtr']);
for counter  = 1 : length (L5)
    L5{counter}.rnames{1} = 'primary';
end
tree         = clone_tree (L5, 1, 0.7, '-s');
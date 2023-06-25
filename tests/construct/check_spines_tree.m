%% check_spines_tree

%% test 1
tree         = resample_tree (sample_tree, 1, 'none');
spines_tree  (tree, [], [], [], [], [],[], '-s');
tprint       ('./panels/spines_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
tree         = resample_tree (sample2_tree, 0.2, '-d');
clf;
HP           = plot_tree ( ...
    spines_tree (tree, 200, [], [], [], [], find (tree.D < 3)), ...
    [0 0 0], [], [], [], '-b1');
axis         off tight;
tprint       ('./panels/spines_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
tree         = resample_tree (sample_tree, 1, 'none');
spines_tree  (tree, 3000, [], [], [], [], [], '-w -s');




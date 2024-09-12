%% check_quadfit_tree
tree         = resample_tree (sample2_tree, 1, '-d');

%% test 1
quadfit_tree (tree, '-s');
tprint       ('./panels/quadfit1_tree', ...
    '-jpg -HR',               [10 10]);    % documentation

%% test 2
clf;
[~, qtree]   = quadfit_tree  (tree);
HP           = plot_tree     ( ...
    tree,  [0 0 0], [], [], [], '-b1');
set          (HP, 'edgecolor', 'none');
HP           = plot_tree     ( ...
    qtree, [0.75 0.75 0.75], [10 0 0], [], [], '-b1');
set          (HP, 'edgecolor', 'none');
axis         off tight;
tprint       ('./panels/quadfit2_tree', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf;
tree         = resample_tree (sample_tree, 1, '-d');
[~, qtree]   = quadfit_tree  (tree, '-w');
HP           = plot_tree     ( ...
    tree,  [0 0 0], [], [], [], '-b1');
set          (HP, 'edgecolor', 'none');
HP           = plot_tree     ( ...
    qtree, [0.75 0.75 0.75], [10 0 0], [], [], '-b1');
set          (HP, 'edgecolor', 'none');
axis         off tight;
tprint       ('./panels/quadfit3_tree', ...
    '-jpg -HR',                [10 10]);




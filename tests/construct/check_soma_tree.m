%% check_soma_tree

%% test 1
tree         = resample_tree (sample_tree, 1, 'none');
tree         = redirect_tree (tree, 10, 'none');
soma_tree    (tree, 40, 40, '-s'); % WRONG MEASURES!!!!
tprint       ('./panels/soma_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf;
tree         = resample_tree (sample2_tree, 1, 'none');
tree         = redirect_tree (tree, 10, 'none');
stree        = cell (1, 10);
for counter  = 1 : 10
    stree{counter} = ...
        soma_tree (tree, 10 + counter);
end
dd           = spread_tree (stree);
for counter  = 1 : 10
    HP       = plot_tree ( ...
        stree{counter}, ...
        [0 0 0], dd{counter}, [], [], '-b1');
    set      (HP, 'edgecolor', 'none');
end
axis         off tight;
tprint       ('./panels/soma_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf;
tree         = resample_tree (sample2_tree, 1, 'none');
tree         = redirect_tree (tree, 10, 'none');
stree        = cell (1, 10);
for counter  = 1 : 10
    stree{counter} = ...
        soma_tree (tree, 20, 10 + 2 * counter);
end
dd           = spread_tree (stree);
for counter  = 1 : 10
    HP       = plot_tree ( ...
        stree{counter}, ...
        [0 0 0], dd{counter}, [], [], '-b1');
    set      (HP, 'edgecolor', 'none');
end
axis         off tight;
tprint       ('./panels/soma_tree3', ...
    '-jpg -HR',                [10 10]);


%% test 4
for counter  = 1 : 1000
    soma_tree (tree);
end

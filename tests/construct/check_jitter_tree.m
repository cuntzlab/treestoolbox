%% check_jitter_tree

%% test 1
clf;
tree         = resample_tree (sample2_tree, 1);
jtree        = cell (1, 10);
for counter  = 1 : 10
    jtree{counter} = jitter_tree (tree, counter / 20, 10, 'none');
end
dd           = spread_tree (jtree);
for counter  = 1 : 10
    HP       = plot_tree ( ...
        jtree{counter}, ...
        [0 0 0], dd{counter}, [], [], '-b1');
    set      (HP, 'edgecolor', 'none');
end
axis         off tight
tprint       ('./panels/jitter_tree1', ...
    '-jpg -HR', [10 10]);

%% test 2
clf;
tree         = resample_tree (sample2_tree, 1, 'none');
jtree        = cell (1, 10);
for counter  = 1 : 10
    jtree{counter} = jitter_tree (tree, 0.35, 2 * counter, 'none');
end
dd           = spread_tree (jtree);
for counter  = 1 : 10
    HP       = plot_tree ( ...
        jtree{counter}, ...
        [0 0 0], dd{counter}, [], [], '-b1');
    set      (HP, 'edgecolor', 'none');
end
axis         off tight
tprint       ('./panels/jitter_tree2', ...
    '-jpg -HR', [10 10]);

%% check_smooth_tree

%% test 1
smooth_tree (sample2_tree, 0.5, 0.5, 10, '-s');
tprint       ('./panels/smooth_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 2
clf; hold on;
tree         = resample_tree (sample2_tree, 1);
tree         = jitter_tree (tree, 0.5, 2, 'none');
stree        = cell (1, 10);
for counter  = 1 : 10
    stree{counter} = ...
        smooth_tree (tree, 0.5, (counter - 1) / 10, 5,'none');
end
dd           = spread_tree (stree);
for counter  = 1 : 10
    HP       = plot_tree ( ...
        stree{counter}, ...
        [0 0 0], dd{counter}, [], [], '-b1');
    set      (HP, 'edgecolor', 'none');
end
axis         off tight;
tprint       ('./panels/smooth_tree2', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
clf; hold on;
tree         = resample_tree (sample2_tree, 1);
tree         = jitter_tree (tree, 0.5, 2, 'none');
stree        = cell (1, 10);
for counter  = 1 : 10
    stree{counter} = ...
        smooth_tree (tree, 0.5, 0.9, counter, 'none');
end
dd           = spread_tree (stree);
for counter  = 1 : 10
    HP       = plot_tree ( ...
        stree{counter}, ...
        [0 0 0], dd{counter}, [], [], '-b1');
    set      (HP, 'edgecolor', 'none');
end
axis         off tight;
tprint       ('./panels/smooth_tree3', ...
    '-jpg -HR',                [10 10]);

%% test 4
smooth_tree (tree, 0.5, 0.9, 10000,'-w')



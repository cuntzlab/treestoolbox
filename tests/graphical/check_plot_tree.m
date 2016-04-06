%% check_plot_tree

tree             = sample_tree;

%% test 1
clf; hold on; shine;
axis off
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 10
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        plot_tree    (tree, rand (1, 3), [], [], [], '-p');
    end
end
tprint           ('./panels/plot_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf; hold on;
axis off
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 10
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        hp           = plot_tree  (tree, rand (1, 3), [], [], [], '-b');
        set          (hp, 'linestyle', 'none');
    end
end
tprint           ('./panels/plot_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf;
axis off
plot_tree            (tree, ...
    BO_tree (tree), [], find (BO_tree (tree) > 15));
tprint           ('./panels/plot_tree3', ...
    '-jpg -HR',                [10 10]);

%% test 4
clf;
axis off
hp               = plot_tree (tree, [], [], [], [], '-3l');
set              (hp, ...
    'linewidth',               2, ...
    'linestyle',               ':', ...
    'marker',                  '.', ...
    'markersize',              12);
tprint           ('./panels/plot_tree4', ...
    '-jpg -HR',                [10 10]);



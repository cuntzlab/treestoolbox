%% check_dist_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 100
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        dist_tree       (tree, [50 100]);
    end
end

%% test 2
dist_tree        (sample_tree, [50 100], '-s')
tprint           ('./panels/dist_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
clf;
hold             on;
tree             = sample2_tree;
dist             = dist_tree (tree, [40 60]);
HP               = plot_tree ( ...
    tree, [0 0 0], [], ...
    ~sum (dist, 2), [], '-b');
set              (HP, ...
    'facealpha',               0.2, ...
    'edgecolor',               'none');
for counter      = 1 : size (dist, 2)
    HP           = plot_tree ( ...
        tree, [1 0 0], [], ...
        dist (:, counter), [], '-b');
    set          (HP, ...
        'facealpha',           0.5, ...
        'edgecolor',           'none');
end
vtext_tree       (sample2_tree, [], [0 0 0]);
ylim             ([-15 50]);
xlim             ([0  100]);
scalebar;
view             (2);
grid             on;
axis             off tight;
tprint           ('./panels/dist_tree2', ...
    '-jpg -HR',                [10 10]);




%% check_hull_tree

%% test 1
clf; hold on; shine
axis off
dLPTCs           = load_tree ('dLPTCs.mtr');
for counter      = 1 : length (dLPTCs{1})
    display (counter)
    tree         = dLPTCs{1}{counter};
    [~, ~, hp]   = hull_tree (tree, [], 20, 20, 20, '-s');
    set          (hp, 'facecolor', rand (1, 3));
end
tprint           ('./panels/hull_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf; hold on;
hull_tree        (sample_tree, 25, 50, 50, 1000);
plot_tree        (sample_tree);
shine;
axis             off;
tprint           ('./panels/hull_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf; hold on;
hull_tree        (sample_tree, 25, 50, 50, 50, '-2d -s');
plot_tree        (sample_tree);
view             (3);
axis             off tight
tprint           ('./panels/hull_tree3', ...
    '-jpg -HR',                [10 10]);

%% check_chull_tree

%% test 1
clf; hold on; shine
axis off
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 20
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        chull_tree   (tree, [], rand (1, 3));
    end
end
tprint           ('./panels/chull_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf; hold on;
chull_tree       (sample_tree);
plot_tree        (sample_tree);
shine;
axis             off;
tprint           ('./panels/chull_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf; hold on;
chull_tree       (sample_tree, ...
    find (sub_tree (sample_tree, 10)), [1 0 0], 20, 1, '-2d');

plot_tree        (sample_tree);
view             (3);
axis             off tight
tprint           ('./panels/chull_tree3', ...
    '-jpg -HR',                [10 10]);

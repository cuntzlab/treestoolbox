%% check_gdens_tree

%% test 1
clf; hold on; shine
axis off
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 1
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        gdens_tree   (tree, 20);
    end
end
tprint           ('./panels/gdens_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf;
gdens_tree       (sample_tree, 20);
plot_tree        (sample_tree);
shine;
axis             off;
tprint           ('./panels/gdens_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf;
gdens_tree       (sample_tree, 10, find (sub_tree (sample_tree, 10)));
plot_tree        (sample_tree);
shine;
axis             off;
tprint           ('./panels/gdens_tree3', ...
    '-jpg -HR',                [10 10]);

%% test 4
clf;
[M, dx, dy, dz]  = gdens_tree (sample_tree, 20, [], 'none');
imagesc          (dx, dy, max (M, [], 3));
plot_tree        (sample_tree, [1 0 0]);
view             (3);
axis             off;
tprint           ('./panels/gdens_tree4', ...
    '-jpg -HR',                [10 10]);

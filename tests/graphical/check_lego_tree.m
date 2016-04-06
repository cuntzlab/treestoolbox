%% check_lego_tree

%% test 1
clf; hold on; shine
axis             off
dLPTCs           = load_tree ('dLPTCs.mtr');
for counter      = 1 : length (dLPTCs{1})
    display      (counter);
    tree         = dLPTCs{1}{counter};
    lego_tree    (tree, 15);
end

%% test 2
clf;
lego_tree        (sample_tree, 15);
plot_tree        (sample_tree);
shine;
view             ([45 45]);
axis             off;
tprint           ('./panels/lego_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf;
hp               = lego_tree (sample_tree, 15, [], '-f -e');
set              (hp, 'facecolor', [1 0 0]);
shine;
view             ([45 45]);
axis             off;
tprint           ('./panels/lego_tree2', ...
    '-jpg -HR',                [10 10]);


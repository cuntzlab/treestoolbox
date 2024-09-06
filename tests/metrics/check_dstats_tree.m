%% check_dstats_tree

%% test 1
tree         = sample_tree;
dstats_tree  (stats_tree (sample_tree), [], '-g -d')
tprint       ('./panels/dstats_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
trees        = {{sample_tree, sample2_tree}, {hss_tree, hsn_tree}};
g            = {'sample', 'hss'};
stats        = stats_tree(trees, g);
color        = [1 0 0; 0 0 1];
dstats_tree  (stats, color, '-g -d -c');
tprint       ('./panels/dstats_tree2', ...
    '-jpg -HR',                [10 10]);
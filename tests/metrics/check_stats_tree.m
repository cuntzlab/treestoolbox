%% check_stats_tree

%% test 1 
tree             = sample_tree;
stats_tree       (tree, [], [], '-s');
tprint           ('./panels/stats_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
trees            = {sample_tree, sample2_tree};
g                = {'sample'};
stats_tree       (trees, g, [], '-s -dim2');
tprint           ('./panels/stats_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
trees            = {{sample_tree, sample2_tree}, {hss_tree, hsn_tree}};
g                = {'sample', 'hss'};
test_path       = './panels/test_stats.m';   
stats_tree       (trees, g, test_path, '-s -f');

tprint           ('./panels/stats_tree3', ...
    '-jpg -HR',                [10 10]);


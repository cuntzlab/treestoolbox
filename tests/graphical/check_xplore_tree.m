%% check_xplore_tree
tree = sample2_tree;

%% test 1
clf;
xplore_tree      (tree);
axis off;
tprint           ('./panels/xplore_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf;
xplore_tree      (tree,'-2');
axis off;
tprint           ('./panels/xplore_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf;
xplore_tree      (tree, '-3');
tprint           ('./panels/xplore_tree3', ...
    '-jpg -HR',                [10 10]);


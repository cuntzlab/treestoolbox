%% check_vtext_tree

%% test 1
tree             = sample2_tree;
clf;
axis off;
plot_tree        (tree, [0 0 0], [], [], [], '-b');
ht               = vtext_tree (tree, ...
    BO_tree(tree), eucl_tree (tree), [0 0 10], [], 1 : 9);
set              (ht, ...
    'fontsize',                36, ...
    'fontname',                'times new roman');
tprint           ('./panels/vtext_tree1', ...
    '-jpg -HR',                [10 10]);



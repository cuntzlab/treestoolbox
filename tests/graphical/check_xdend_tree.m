%% check_xdend_tree

%% test 1
tree             = sample2_tree;
clf; hold on;
axis off;
dendrogram_tree  (tree, 0.1);
x                = xdend_tree (tree);
Plen             = Pvec_tree  (tree);
for counter      = 1 : length (x)
    ht           = text (x (counter), Plen (counter), num2str (counter));
    set          (ht, ...
        'fontsize',            18, ...
        'color',               [1 0 0]);
end
xlabel           ('x');
tprint           ('./panels/xdend_tree1', ...
    '-jpg -HR',                [10 10]);



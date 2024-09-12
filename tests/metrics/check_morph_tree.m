%% check_morph_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        morph_tree (tree, [], 'none');
    end
end

%% test 2
morph_tree       (sample_tree, [], '-m');

%% test 3
morph_tree       (sample_tree, [], '-s');
tprint           ('./panels/morph_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 4
clf;
tree             = sample_tree;
tree.D           = tree.D / 50;
mtree            = morph_tree (tree, elen_tree (tree), '-w');
plot_tree        (mtree);
tprint           ('./panels/morph_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 5
clf;
tree             = sample_tree;
sse              = sse_tree   (tree);
tree.D           = tree.D * 10;
mtree            = morph_tree (tree, sse (:, 1), '-w');
plot_tree        (mtree);
tprint           ('./panels/morph_tree3', ...
    '-jpg -HR',                [10 10]);

%% test 6
morph_tree       (hss_tree, [], '-s -w');
tprint           ('./panels/morph_tree4', ...
    '-jpg -HR',                [10 10]);



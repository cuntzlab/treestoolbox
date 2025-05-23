%% check_dendrogram_tree

%% test 1
clf; hold on;
axis off
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 10
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        dendrogram_tree   (tree, [], [], [], [], 1, '-p');
    end
end
tprint           ('./panels/dendrogram_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf;
dendrogram_tree  (sample2_tree)
tprint           ('./panels/dendrogram_tree2', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
clf;
tree             = sample_tree;
dendrogram_tree  (tree, ...
    tree.D, ...
    PL_tree (tree), ...
    BO_tree (tree), ...
    [10 10], ...
    5, '-p');
tprint           ('./panels/dendrogram_tree3', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf;
tree             = sample_tree;
dendrogram_tree  (tree, ...
    tree.D, ...
    PL_tree (tree), ...
    [1 0 0], ...
    [10 10], ...
    5, '-v');
tprint           ('./panels/dendrogram_tree4', ...
    '-jpg -HR',                [10 10]);

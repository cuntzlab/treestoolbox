%% check_BO_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 500
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        BO_tree (tree);
    end
end

%% test 2
BO_tree          (sample_tree, '-s');
tprint           ('./panels/BO_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf;
tree             = sample2_tree;
plot_tree        (tree, BO_tree (tree));
vtext_tree       (tree, BO_tree (tree), [1 0 0], [0 0 10]);
axis off tight;
tprint           ('./panels/BO_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 4
clf; 
BO               = BO_tree (sample_tree);
[h1, h2]         = hist    (BO, 0 : 15);
HP               = bar     (h2, h1);
set              (HP, ...
    'facecolor',               [0 0 0]);
tprint           ('./panels/BO_tree3', ...
    '-jpg -HR',                [10 10]);



%% check_sholl_tree

%% test 1
tree             = sample_tree;
sholl_tree       (tree, 20, '-s')
tprint           ('./panels/sholl_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
sholl_tree       (tree, 20, '-s3 -o')
tprint           ('./panels/sholl_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 3
dd               = randi([0 200], 20, 1);
sholl_tree       (tree, dd, '-s');
tprint           ('./panels/sholl_tree3', ...
    '-jpg -HR',                [10 10]);

%% test 4
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        sholl_tree   (tree);
    end
end

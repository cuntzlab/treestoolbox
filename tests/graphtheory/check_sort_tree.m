%% check_sort_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        sort_tree   (tree, '-LO');
    end
end

%% test 2
sort_tree        (sample2_tree, '-s');
tprint           ('./panels/sort_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
sort_tree        (sample2_tree, '-s -LO');
tprint           ('./panels/sort_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 4
tree             = redirect_tree (sample2_tree, 5);
sort_tree        (tree, '-s -LO');
tprint           ('./panels/sort_tree3', ...
    '-jpg -HR',                [10 10]);



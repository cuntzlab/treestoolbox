%% check_ipar_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 100
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        ipar_tree (tree);
    end
end

%% test 2
tree             = sample_tree;
ipar_tree        (tree, '-s');
tprint           ('./panels/ipar_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
ipar_tree        (tree, '-s', T_tree (tree));
tprint           ('./panels/ipar_tree2', ...
    '-jpg -HR',                [10 10]);







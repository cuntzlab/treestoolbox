%% check_redirect_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 50
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        redirect_tree   (tree, 5);
    end
end

%% test 2
redirect_tree    (sample2_tree, 5, '-s');
tprint           ('./panels/redirect_tree1', ...
    '-jpg -HR',                [10 10]);


%% check_insert_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        insert_tree (tree, [...
            1 1 30 -10 0 1 3; ...
            2 1 30   0 0 1 3], 'none');
    end
end

%% test 2
[~, ind]         = insert_tree (sample2_tree, [...
   1 1 30 -10 0 1 3; ...
   2 1 30   0 0 1 3], '-s -e');
display          (ind);
tprint           ('./panels/insert_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
insert_tree      (sample2_tree, [], '-s -e');
tprint           ('./panels/insert_tree2', ...
    '-jpg -HR',                [10 10]);    % documentation

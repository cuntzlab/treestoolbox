%% check_child_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 100
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        child_tree (tree);
    end
end

%% test 2
child_tree       (sample_tree, [], '-s')
tprint           ('./panels/child_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation


%% test 3
child_tree       (sample_tree, len_tree (sample_tree), '-s')
tprint           ('./panels/child_tree2', ...
    '-jpg -HR',                [10 10]);

%%
clf; 
plot_tree        ( ...
    sample2_tree, ...
    child_tree (sample2_tree));
vtext_tree       ( ...
    sample2_tree, ...
    child_tree (sample2_tree), [1 0 0], [0 0 10]);
axis             off
tprint           ('./panels/child_tree3', ...
    '-jpg -HR',                [10 10]);




%% check_loop_tree

%% test 1
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 100
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        tree.Ri      = 100;
        tree.Gm      = 1 / 2500;
        tree.Cm      = 1;
        loop_tree    (tree, 1, 100, 1, 'none');
    end
end

%% test 2
loop_tree        (sample_tree, 1, 100, 0.001, '-s')
tprint           ('./panels/loop_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
sse              = inv (loop_tree  (sample_tree, 1, 100, 1, 'none'));
clf;
plot_tree        (sample_tree, sse (:, 100));
tprint           ('./panels/loop_tree2', ...
    '-jpg -HR',                [10 10]);    % documentation



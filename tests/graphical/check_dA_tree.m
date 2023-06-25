%% check_dA_tree

%% test 1
clf; hold on;
axis off
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 10
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        dA_tree   (tree, rand (1, 3));
    end
end

%% test 2
clf;
dA_tree          (sample2_tree, [1 0 0]); axis off;
tprint           ('./panels/dA_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf;
dA_tree          (sample_tree); axis off;
tprint           ('./panels/dA_tree2', ...
    '-jpg -HR',                [10 10]);
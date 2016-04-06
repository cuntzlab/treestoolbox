%% check_bin_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        bin_tree (tree, [], 4);
    end
end

%% test 2
bin_tree     (sample_tree, [], [], '-s')
tprint           ('./panels/bin_tree1', ...
    '-jpg -HR',                [10 10]);


%% test 3
sample           = sample_tree;
X                = sample.X;
[ih ,i1, i2]     = bin_tree (sample_tree, [], 4);
clf;
plot_tree (sample_tree,ih);
axis off
tprint           ('./panels/bin_tree2', ...
    '-jpg -HR',                [10 10]);
%% test 4
HP               = bar(i2);
set              (HP, ...
    'facecolor',               [0 0 0]);
xlim             ([0.5 4.5]);
tprint           ('./panels/bin_tree3', ...
    '-jpg -HR',                [10 10]);

%% check_sse_tree

%% test 1
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 100
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        tree.Ri      = 100;
        tree.Gm      = 1 / 2500;
        tree.Cm      = 1;
        sse_tree     (tree, [], 'none');
    end
end

%% test 2
clf;
sse_tree             (sample_tree, [], '-s');
tprint               ('./panels/sse_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf;
sse_tree             (sample_tree, 100, '-s')
tprint               ('./panels/sse_tree2', ...
    '-jpg -HR',                [10 10]);
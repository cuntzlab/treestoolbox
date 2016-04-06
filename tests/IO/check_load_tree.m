%% check_load_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
spread_tree      (dLPTCs{1}, [], [], '-s');
tprint           ('./panels/load_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf;
hss              = load_tree ('25HSS.swc');
plot_tree        (hss, [], [], [], [], '-b');
tprint           ('./panels/load_tree2', ...
    '-jpg -HR',                [10 10]);

%% no test for .neu yet or .swc with multiple trees!
clf;
gc               = load_tree ('./test_neu_tree/GC1.neu');
plot_tree        (gc, [], [], [], [], '-b');
tprint           ('./panels/load_tree3', ...
    '-jpg -HR',                [10 10]);

%% check_asym_tree

%% test 1
Tasym            = [];
Lasym            = [];
dLPTCs           = load_tree ('dLPTCs.mtr');
for counter      = 1 : length (dLPTCs{1})
    tree         = dLPTCs{1}{counter};
    Tasym        = [ ...
        Tasym; (asym_tree (tree, T_tree   (tree), 'none'))];
    Lasym        = [ ...
        Lasym; (asym_tree (tree, len_tree (tree), 'none'))];
end

%% test 2
asym_tree        (sample_tree, [], '-m -s')
tprint           ('./panels/asym_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
clf;
hist             (Tasym, 0 : 0.05 : 0.5);
tprint           ('./panels/asym_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 4
clf;
hist             (Lasym, 0 : 0.05 : 0.5);
tprint           ('./panels/asym_tree3', ...
    '-jpg -HR',                [10 10]);
%% check_rot_tree
 
%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 50
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        rot_tree (tree, [], '-m3d');
    end
end

%% test 2
rot_tree         (sample_tree, [], '-s -m3dX');
tprint           ('./panels/rot_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
rot_tree         (sample_tree, [], '-s -m3dY');
tprint           ('./panels/rot_tree2', ...
    '-jpg -HR',                [10 10]);

%% test 4
rot_tree         (sample_tree, [], '-s -m3dZ');
tprint           ('./panels/rot_tree3', ...
    '-jpg -HR',                [10 10]);

%% test 5
clf;
for counter      = 0 : 30 : 90
    HP           = plot_tree ( ...
        rot_tree (sample_tree, [0 0 (counter / 4)]), [], [], [], 32);
    set          (HP, ...
        'facealpha',           counter / 100 + 0.1);
end
axis             off tight
tprint           ('./panels/rot_tree4', ...
    '-jpg -HR',                [10 10]);

%% test 6
clf;
for counter      = 0 : 30 : 90
    HP           = plot_tree ( ...
        rot_tree (sample_tree, [0 (counter / 2) 0]), [], [], [], 32);
    set          (HP, ...
        'facealpha',           counter / 100 + 0.1);
end
axis             off tight
tprint           ('./panels/rot_tree5', ...
    '-jpg -HR',                [10 10]);

%% test 7
clf;
for counter      = 0 : 30 : 90
    HP           = plot_tree ( ...
        rot_tree (sample_tree, [(counter) 0 0]), [], [], [], 32);
    set          (HP, ...
        'facealpha',           counter / 100 + 0.1);
end
axis             off tight
tprint           ('./panels/rot_tree6', ...
    '-jpg -HR',                [10 10]);

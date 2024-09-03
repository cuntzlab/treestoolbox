%% check_quaddiameter_tree

%% test 1
clf;
tree         = resample_tree     (sample2_tree, 1, 'none');
qtree        = quaddiameter_tree (tree, 1, 1,[],[],'-s');
tprint       ('./panels/quaddiameter1_tree', ...
    '-jpg -HR',                [10 10]);

%% test 2
clf;
tree         = resample_tree (sample2_tree, 1, 'none');
qtree        = cell (1, 10);
for counter  = 1 : 10
    qtree{counter} = quaddiameter_tree (tree, counter / 20, 1,[],[], 'none');
end
dd           = spread_tree (qtree);
for counter  = 1 : 10
    HP       = plot_tree ( ...
        qtree{counter}, ...
        [0 0 0], dd{counter}, [], [], '-b1');
    set      (HP, 'edgecolor', 'none');
end
axis         off tight
tprint       ('./panels/quaddiameter2_tree', ...
    '-jpg -HR',                [10 10]);

%% test 3
clf;
tree         = resample_tree (sample2_tree, 1, 'none');
qtree        = cell (1, 10);
for counter  = 1 : 10
    qtree{counter} = quaddiameter_tree (tree, 0.4, counter / 10,[],[], 'none');
end
dd           = spread_tree (qtree);
for counter  = 1 : 10
    HP       = plot_tree ( ...
        qtree{counter}, ...
        [0 0 0], dd{counter}, [], [], '-b1');
    set      (HP, 'edgecolor', 'none');
end
axis         off tight
tprint       ('./panels/quaddiameter3_tree', ...
    '-jpg -HR',                [10 10]);

%% test 4
dLPTCs       = load_tree ('dLPTCs.mtr');
for counter  = 1 : length (dLPTCs{1})
    % quaddiameter_tree (dLPTCs{1}{counter}, 1, 1,[],[], 'none');
    qtree{counter} = quaddiameter_tree (dLPTCs{1}{counter}, 1, 1,[],[], 'none'); 
end
dd           = spread_tree (qtree); 
for counter  = 1 : length (dLPTCs{1}) 
    HP       = plot_tree ( ... 
        qtree{counter}, ... 
        [0 0 0], dd{counter}, [], [], '-b1'); 
    set      (HP, 'edgecolor', 'none'); 
end 
axis         off tight 
tprint       ('./panels/quaddiameter4_tree', ... 
    '-jpg -HR',                [10 10]);



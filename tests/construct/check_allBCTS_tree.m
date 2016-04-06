%% check_allBCTS_tree

%% test 1
allBCTs_tree     (11, '-s -w');
tprint           ( ...
    './panels/allBCTs_tree1', ...
    '-jpg -HR',                [10 10]);

%% test2
xd               = 70;
clf; hold on;
[BCT, BCTtrees]  = allBCTs_tree (6);
dd               = spread_tree (BCTtrees);
for counter      = 1 : size (BCT, 1)
    pointer_tree (dd{counter});    
    plot_tree    (BCTtrees{counter}, [], dd{counter}, [], [], '-b1');
    s            = num2str (typeN_tree (BCTtrees{counter}, '-bct'))';
    HT           = text ( ...
        dd{counter}(1) - 10, ...
        dd{counter}(2) + 15, s);
    set          (HT, ...
        'horizontalalignment', 'center', ...
        'fontsize',            8);
end
set              (gca, 'visible', 'off');
tprint           ( ...
    './panels/allBCTs_tree2', ...
    '-jpg -HR',                [10 10]);

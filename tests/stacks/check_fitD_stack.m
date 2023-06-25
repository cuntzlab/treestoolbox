%% check_fitD_stack

%% test 1
tree = load_tree ('./data/auto_MSO.mtr');
stack = loadtifs_stack ('./data/stack_0002_MSO_P10_2-1_2.tif');
D = fitD_stack (tree, stack, [], '-m');
tprint           ('./panels/fitD_stack1', ...
    '-jpg -HR',                [10 10]);
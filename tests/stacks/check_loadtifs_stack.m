%% check_loadtifs_stack

%% test 1
stack            = loadtifs_stack ('./data/stack_0002_MSO_P10_2-1_2.tif', '-s');
tprint           ('./panels/loadtifs_stack1', ...
    '-jpg -HR',                [10 10]);    % documentation

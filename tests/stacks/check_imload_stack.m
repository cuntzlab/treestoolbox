%% check_imload_stack

%% test 1
clf;
stack        = imload_stack ('./data/stack_0002_MSO_P10_2-1_2.tif', '-s')
tprint       ('./panels/_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

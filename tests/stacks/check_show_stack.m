%% check_show_stack

%% test 1
clf;
stack        = imload_stack ('./data/stack_0002_MSO_P10_2-1_2.tif');
HP           = show_stack (stack, '-a');
tprint       ('./panels/show_stack1', ...
    '-jpg -HR',                [10 10]);    % documentation
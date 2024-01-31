function pars = parseArgs(p, inputArgs, argNames, optionsNames)

numArgs = numel(inputArgs);
if (numArgs > 0 && ischar(inputArgs{1}) && ~startsWith(inputArgs{1}, '-')) ...
        || numArgs == 0
    p.parse(inputArgs{:})
else
    args = parsePositionalArgs(inputArgs, argNames, optionsNames);
    p.parse(args{:})
end
pars = p.Results;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function args = parsePositionalArgs(inputArgs, argNames, optionsNames)

optionsPos = numel(argNames) + 1; % Always comes at the end after all the other arguments
% Check if the options argument is provided
if numel(inputArgs) >= optionsPos
    mask = cellfun(@(x) contains(inputArgs{optionsPos}, x), optionsNames);
    optionsNames = optionsNames(mask);
    numOptions   = numel(optionsNames);
    options          = cell(1, numOptions*2);
    options(1:2:end) = optionsNames;
    options(2:2:end) = repelem({true}, numOptions);

    inputArgs(optionsPos) = []; % Now delete the options argument from the input
end

numArgs = numel(inputArgs);
argNames(numArgs+1:end) = []; % remove the argument names that are not provided
args = cell(1, numArgs*2);

args(1:2:end) = argNames;
args(2:2:end) = inputArgs;

if exist('options', 'var')
    args = [args, options];
end

% Find if any arguments were provided empty and remove them
emptyArgs = find(cellfun(@isempty, args));
args([emptyArgs, emptyArgs-1]) = [];

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
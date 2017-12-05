% MECH_TREE   Output NEURON mechanisms.
% (T2N package)
%
% varargout = mech_tree (tree, neuron, mech, par, params)
% -------------------------------------------------------
%
% Returns the values of a mechanism parameter at each node of each tree as
% had been specified in the t2n structure "neuron". This function is useful
% in combinatin with plot_tree to validate or check distribution of a
% mechanism parameter over the trees' nodes. Supports only one neuron
% specification at a time.
%
% Inputs
% ------
% - intree   ::    morphologies in the TREES format. Can be single
%     structure or cell array of trees
% - neuron   ::    model description structure used in t2n
%     (see T2N documentation) 
% - mech     ::string: name of the mechanism to be investigated
% - par      ::string: name of the parameter of mechanism mech
%                      to be investigated
% - options  ::   -s      directly maps the parameter values on each tree
% - params   ::   (optional) the parameter structure used in t2n, which is then
%           used to search for the mod file of the mechanism
%
% See also load_tree swc_tree start_trees (neu_tree.hoc)
% Uses root_tree cyl_tree dissect_tree ver_tree D
%
% Output
% ------
% - tvec     ::vector or cell array of vectors: parameter values
%           at each node
%
% Example
% -------
% 
%
% T2N package - Marcel Beining 2017
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2017  Hermann Cuntz

function varargout = mech_tree (tree, neuron, mech, par, params)

if nargin < 1 || isempty(tree)
    tree = {sample_tree};
    display('Example tree is used')
end

if nargin < 2 || isempty(neuron)
    error 'neuron has not been defined or is no struct'
end
if iscell(neuron)
    neuron = neuron{1};
    warning('Only first neuron instance used')
end

if nargin < 4 || isempty(par)
    par = 'pas';
    display('pas is used as mechanism')
end

if nargin < 3 || isempty(mech)
    mech = 'g';
    display('g is used as parameter name')
end




stdval = NaN;
if nargin > 4 && isfield(params,'path') && exist(fullfile(params.path,'lib_mech',sprintf('%s.mod',mech)),'file')  % check if mod file of mechanism exists
    % read everything
    fid  = fopen(fullfile(params.path,'lib_mech',sprintf('%s.mod',mech)),'r');
    text = textscan(fid,'%s','Delimiter','');
    text = text{1};
    fclose(fid);
    % trim text to PARAMETER part
    LW = regexp(text,'PARAMETER','tokens');
    text = text(find(~cellfun(@isempty,LW)):end);
    LW = regexp(text,'}','tokens');
    text = text(1:find(~cellfun(@isempty,LW),1,'first'));
    % find lines that match the par name
    LW = regexp(text,par,'tokens');
    if sum(~cellfun(@isempty,LW)) > 1
        warning('Parameter name occurs more than once in the PARAMETER section of the mod file. Hence, standard parameter value cannot be read. Delete commented lines for proper reading of value.')
    else
        text = text{~cellfun(@isempty,LW)};
        LW = regexp(text,[par,'[\s\.=]+[+-]?(\d+)[\.]?(\d+)[\r\t\s]'],'tokens');  % extract numeric value
        LW = sprintf('%s.',LW{1}{:});  % stitch extracted number strings with decimal point
        stdval = str2double(LW(1:end-1)); % make number
    end
end


tvec = cell(numel(tree),1);
for t = 1:numel(tree)
    if isfield(tree{t},'artificial') && ~isempty(tree{t}.artificial)  % skip artificial neurons
        continue
    end
    tregnames = tree{t}.rnames;
    nregnames = fieldnames(neuron.mech{t});
    rvec = NaN(numel(tregnames),1);
    tvec{t} = NaN(numel(tree{t}.X),1);
    if any(strcmp(nregnames,'all')) && isfield(neuron.mech{t}.all, mech) && isfield(neuron.mech{t}.range.(mech),par)  % check if parameter is distributed with the all feature
        rvec(:) = neuron.mech{t}.all.(mech).(par);
    end
    for r = 1:numel(tregnames)  % go through region names of tree
        if ~isempty(intersect(nregnames,tregnames{r})) && isfield(neuron.mech{t}.(tregnames{r}), mech)
            rvec(r) = neuron.mech{t}.(tregnames{r}).(mech).(par);
        end
        tvec{t}(tree{t}.R == r) = rvec(r);
    end
    if any(strcmp(nregnames,'range')) && isfield(neuron.mech{t}.range, mech) && isfield(neuron.mech{t}.range.(mech),par)  % check for range value definition
        tvec{t}(~isnan(neuron.mech{t}.range.(mech).(par))) = neuron.mech{t}.range.(mech).(par)(~isnan(neuron.mech{t}.range.(mech).(par)));  % only replace with values that are not NaN
    end
    if ~isnan(stdval)
        tvec{t}(isnan(tvec{t})) = stdval;  % replace not defined values with value from mod file, if read was successful
    end
    
    if nargout == 0  % show mapping of value array on tree
        figure
        plot_tree(tree{t},tvec{t});
        if isfield(tree{t},'NID')  % get a proper name for the tree
            nam = tree{t}.NID;
        elseif isfield(tree{t},'name')
            nam = tree{t}.name;
        else
            nam = num2str(t);
        end
        nam = regexprep(nam,'_','\\_');
        title(sprintf('Map of %s_%s on tree %s',par,mech,nam));
        colorbar;
        axis off
    end
end
if nargout > 0 
    if numel(tree) == 1
        varargout{1} = tvec{1};
    else
        varargout{1} = tvec;
    end
end
end




classdef Trees < handle

    % constants
    properties (Constant=true, GetAccess='protected')
        DEBUG = false;
        DEFAULT_WAITBAR_MIN_SIZE = 100;
        TREE_PROPERTIES = {'dA', 'R', 'X', 'Y', 'Z', 'D', 'rnames', 'Ri', 'Gm', 'Cm'};
        POPULATION_FUNCTIONS = {
            'bouquet_tree'
            'plate_tree'
            'spread_tree'
        }
    end

    % private properties
    properties (GetAccess='protected', SetAccess='protected')
        trees_
        props_
        name_
        waitbar_
        waitbar_min_size_
        wait_msg_
        log_level_
    end

    % public properties
    properties
    end

    % private methods
    methods (Access='protected')
        function containee = CONTAINEE(self)
             containee = @trees.Tree;
        end
        function self = SELF(self)
             self = @trees.Trees;
        end

        function waitbar(self, s)
            if self.log_level_ <= 0
                return;
            end

            n = numel(self.ttrees());
            if self.wait_msg_
                msg = sprintf('%s: processing objects... [%d / %d]', self.wait_msg_, s, n);
            else
                msg = sprintf('Processing objects... [%d / %d]', s, n);
            end
            if self.log_level_ > 0
                if s > 0
                    if self.log_level_ > 1
                        fprintf('%s\n', msg);
                    else
                        k = 10 .^ max([0 round(log10(n)) - 2]);
                        if s == 1 || mod(s, k) == 0
                            fprintf('%s\n', msg);
                        end
                    end
                end
                return;
            end
            if self.waitbar_min_size_ > -1 && n >= self.waitbar_min_size_ && s > -1
                if numel(self.waitbar_) == 0 || ~self.waitbar_.isvalid
                    self.waitbar_ = waitbar(s / n, msg);
                else
                    waitbar(s / n, self.waitbar_, msg);
                end
            elseif s == -1
                self.set_waitbar_msg([])
                if numel(self.waitbar_) == 1 && self.waitbar_.isvalid
                    close(self.waitbar_);
                    self.waitbar_ = [];
                end
            end
        end
    end

    methods(Static, Access='protected')
    end

    methods(Static)

        function ttrees = load(filename)
            % ttrees = trees.Trees.load(filename)
            % ------------------------------
            %
            % Loads a collection of ttrees from a given file name via load_tree, static method.
            %
            % Input
            % -----
            % - filename ::string
            %
            % Output
            % ------
            % - ttrees     ::instance of trees.Trees class
            %
            % Example
            % -------
            % trees.Trees.load('mytrees.mtr');
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal ttrees
            % Copyright (C) 2009 - 2024  Hermann Cuntz

            if exist(filename, 'file')
               ttrees = load_tree(filename);
            else
               warning('File %s does not exist!', filename);
               ttrees = [];
               return;
            end
            ttrees = trees.Trees.from_trees(ttrees{1});
        end

        function ttrees = from_trees(ttrees)
        % ttrees = trees.Trees.from_trees(ttrees) is the same as ttrees = trees.Trees(ttrees)
        % where the input 'ttrees' is a cell array that contains tree structs
            ts = trees.Tree.empty();
            for i = 1 : numel(ttrees)
                ts(i) = trees.Tree(ttrees{i});
            end
            ttrees = trees.Trees(ts);
        end

    end

    % public methods
    methods
        % constructor
        function self = Trees(varargin)
            if nargin > 0
                ttrees = varargin{1};
            else
                ttrees = [];
            end
            if nargin > 1
                props = varargin{2};
            else
                props = {};
            end
            if nargin > 2
                name = varargin{3};
            else
                name = [];
            end
            self.name_ = name;
            if isstruct(ttrees)
                ts = trees.Tree.empty();
                ts(1) = trees.Tree(ttrees, props);
            elseif iscell(ttrees)
                ts = feval(self.CONTAINEE);
                idx = 1;
                for i=1:numel(ttrees)
                    n = ttrees{i};
                    if numel(n) == 0
                        warning('skipping empty cell at position %d', i);
                        continue;
                    end
                    if ~isa(n, 'trees.Tree')
                        n = trees.Tree(n, props);
                    end
                    ts(idx) = n;
                    idx = idx + 1;
                end
            else
                ts = ttrees;
            end
            self.trees_ = ts;
            self.props_ = props;
            self.name_ = name;
            self.waitbar_min_size_ = trees.Trees.DEFAULT_WAITBAR_MIN_SIZE;
            self.log_level_ = false;
        end

        function name = name(self)
            name = self.name_;
        end

        function self = set_name(self, n) 
            self.name_ = n;
        end

        function ttrees = ttrees(self)
            ttrees = self.trees_;
        end

        function ttrees = to_trees(self)
            ts = {};
            for i = 1:numel(self.trees_)
                t = self.trees_(i);
                ts = cat(1, ts, t.tree());
            end
            ttrees = ts;
        end

        function slf = add_tree(self, tree, varargin)
            % slf = add_tree(self, tree, varargin)
            % ------------------------------
            %
            % Appends a tree to the object trees.Trees.
            %
            % Input
            % -----
            % - tree      ::struct, or instance of trees.Tree class
            %
            % Output
            % ------
            % - ttrees     ::instance of trees.Trees class
            %
            % Example
            % -------
            % trees.Trees.load('mytrees.mtr');
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal ttrees
            % Copyright (C) 2009 - 2024  Hermann Cuntz
            if ~isa(tree, 'trees.Tree')
                if iscell(tree)
                    for i = 1:numel(tree)
                        self.add_tree(tree{i}, varargin{:});
                    end
                else
                    self.add_tree(trees.Tree(tree, varargin{:}));
                end
            else
                if numel(self.trees_) == 0
                    self.trees_ = tree;
                else
                    self.trees_(end + 1) = tree;
                end
            end
            slf = self;
        end

        function slf = add_trees(self, ttrees, varargin)
            if isa(ttrees, 'trees.Trees') || isa(ttrees, 'trees.Tree')
                if isa(ttrees, 'trees.Trees')
                    ttrees = ttrees.trees_;
                else
                    ttrees = ttrees.tree;
                end
                for i=1:numel(ttrees)
                    self.add_tree(ttrees(i), varargin{:});
                end
            elseif iscell(tree)
                for i = 1:numel(ttrees)
                    self.add_tree(ttrees{i}, varargin{:});
                end
            end
            slf = self;
        end

        function slf = remove_tree(self, i)
            self.trees_(i) = [];
            slf = self;
        end

        function n = size(self)
            n = self.numel();
        end

        function n = numel(self)
            n = numel(self.trees_);
        end

        function self = set_waitbar_min_size(self, n)
            self.waitbar_min_size_ = n;
        end

        function set_waitbar_msg(self, msg)
            self.wait_msg_ = msg;
        end

        function self = set_log_level(self, level)
            self.log_level_ = level;
        end

        function level = log_level(self)
            level = self.log_level_;
        end

        function n = numArgumentsFromSubscript(~, ~, callingContext)
           switch callingContext
              case matlab.mixin.util.IndexingContext.Statement
                 n = 1; % nargout for indexed reference used as statement
              case matlab.mixin.util.IndexingContext.Expression
                 n = 1; % nargout for indexed reference used as function argument
              case matlab.mixin.util.IndexingContext.Assignment
                 n = 1; % nargin for indexed assignment
           end
        end

        function out = subsref(self, s)
           switch s(1).type
              case '.'
                 if strcmp(s(1).subs, 'matrix')
                     out = self.subsref(s(2:end));
                     lens = arrayfun(@(x) numel(x{1}), out);
                     mat = nan(numel(out), max(lens));
                     for i=1:numel(out)
                         mat(i, 1:lens(i)) = out{i};
                     end
                     out = mat';
                 elseif strcmp(s(1).subs, 'flat')
                     out = self.subsref(s(2:end));
                     lens = arrayfun(@(x) numel(x{1}), out);
                     cs = cumsum(lens);
                     clens = [0; cs(:)];
                     flat = nan(clens(end), 1);
                     for i=1:numel(out)
                         flat(clens(i) + 1 : clens(i + 1)) = out{i};
                     end
                     out = flat';
                 elseif strcmp(s(1).subs, 'mean')
                     out = self.subsref(s(2:end));
                     mat = nan(numel(out), 1);
                     for i=1:numel(out)
                         mat(i) = mean(out{i}, 'omitnan');
                     end
                     out = mat';
                 elseif strcmp(s(1).subs, 'meanstd')
                     out = self.subsref(s(2:end));
                     mat = nan(numel(out), 2);
                     for i=1:numel(out)
                         mat(i, :) = [mean(out{i}, 'omitnan') std(out{i}, 'omitnan')];
                     end
                     out = mat;
                 elseif strcmp(s(1).subs, 'std')
                     out = self.subsref(s(2:end));
                     mat = nan(numel(out), 1);
                     for i=1:numel(out)
                         mat(i, :) = std(out{i}, 'omitnan');
                     end
                     out = mat';
                 elseif strcmp(s(1).subs, 'sum')
                     out = self.subsref(s(2:end));
                     mat = nan(numel(out), 1);
                     for i=1:numel(out)
                         mat(i) = sum(out{i}, 'omitnan');
                     end
                     out = mat';
                 elseif strcmp(s(1).subs, 'min')
                     out = self.subsref(s(2:end));
                     mat = nan(numel(out), 1);
                     for i=1:numel(out)
                         mat(i) = min(out{i}, 'omitnan');
                     end
                     out = mat';
                 elseif strcmp(s(1).subs, 'max')
                     out = self.subsref(s(2:end));
                     mat = nan(numel(out), 1);
                     for i=1:numel(out)
                         mat(i) = max(out{i}, 'omitnan');
                     end
                     out = mat';
                 elseif strcmp(s(1).subs, 'bptp')
                     out = self.subsref(s(2:end));
                     tp = self.perform('bptp');
                     for i=1:numel(out)
                         out{i} = out{i}(tp{i});
                     end
                 elseif strcmp(s(1).subs, 'sortby')
                     out = self.subsref(s(2:end));
                     lens = arrayfun(@(x) numel(x{1}), out);
                     cs = cumsum(lens);
                     clens = [0; cs(:)];
                     flat = nan(clens(end), 1);
                     for i=1:numel(out)
                         flat(clens(i) + 1 : clens(i + 1)) = out{i};
                     end
                     [~, perm] = sort(flat);
                     out = self.trees_(perm);
                 elseif strcmp(s(1).subs, 'arguments')
                     method = s(2).subs;
                     args = s(3).subs{1};
                     if ismatrix(args) && ~iscell(args)
                         args2 = cell(numel(args), 1);
                         for i=1:numel(args)
                             args2{i} = cell(num2cell(args(i)));
                         end
                         args = args2;
                     end
                     if numel(find(ismember(methods(self.ttrees()), method))) > 0
                         self.set_waitbar_msg(method);
                         x = self.perform_arguments(method, args);
                         out = x;
                     else
                         treefun = strcat(method, '_tree');
                         if exist(treefun, 'file')
                             self.set_waitbar_msg(treefun)
                             out = self.map_tree_arguments(str2func(treefun), args);
                         else
                             out = builtin('subsref', self, s);
                         end
                     end
                 elseif find(ismember(methods(self), s(1).subs))
                     out = builtin('subsref', self, s);
                 else
                     if numel(s) > 1
                         args = s(2).subs;
                     else
                         args = {};
                     end
                     if numel(find(ismember(methods(self.ttrees()), s(1).subs))) > 0 || ...
                            any(arrayfun(@(x) numel(x{1})==1, strfind(self.TREE_PROPERTIES, s(1).subs)))
                         self.set_waitbar_msg(s(1).subs);
                         x = self.perform(s(1).subs, args{:});
                         out = x;
                     else
                         treefun = strcat(s(1).subs, '_tree');
                         if exist(treefun, 'file')
                             tf = str2func(treefun);
                             self.set_waitbar_msg(treefun);
                             if numel(find(strcmp(trees.Trees.POPULATION_FUNCTIONS, treefun))) > 0
                                out = tf(self.to_trees(), args{:});
                             else
                                out = self.map_tree(tf, args{:});
                             end
                         else
                             out = builtin('subsref', self, s);
                         end
                     end
                 end
              case '{}'
                 st = s(1);
                 st.type = '()';
                 out = builtin('subsref', self.trees_, st);
                 if ~strcmp(class(out), class(self)) && ~isscalar(out) && strcmp(class(out), class(self.ttrees()))
                    out = feval(sprintf('%s', class(self)), out, self.props_, self.name_);
                    if numel(s) > 1
                        out = out.subsref(s(2:end));
                    end
                 else
                     if numel(s) > 1
                        out = builtin('subsref', out, s(2:end));
                     end
                 end
              case '()'
                 out = builtin('subsref', self.trees_, s(1));
                 if ~strcmp(class(out), class(self)) && ~isscalar(out) && strcmp(class(out), class(self.ttrees()))
                    out = feval(sprintf('%s', class(self)), out, self.props_, self.name_);
                    if numel(s) > 1
                        out = out.subsref(s(2:end));
                    end
                 else
                     if numel(s) > 1
                        out = builtin('subsref', out, s(2:end));
                     end
                 end
           end
           if ~strcmp(class(out), class(self)) && ~isscalar(out) && strcmp(class(out), class(self.ttrees()))
               out = feval(sprintf('%s', class(self)), out, self.props_, self.name_);
               out.set_log_level(self.log_level_);
           end
        end

        function prop = gprop(self, name)
            if isfield(self.props_, name)
                prop = self.props_.(name);
            else
                prop = nan;
            end
        end
        
        function self = set_gprop(self, name, value)
            self.props_.(name) = value;
        end
        
        function exists = has_gprop(self, name)
            exists = isfield(self.props_, name);
        end
        
        function self = save(self, filename, varargin)
            if numel(varargin) > 0
                varname = varargin{1};
            else
                varname = 'ttrees';
            end
            S = struct();
            S.(varname) = self;
            save(filename, '-struct', 'S');
        end

        function ttrees = sort_by_prop_value(self, prop)
            ts = self.trees_;
            ttrees = feval(sprintf('%s', class(self.trees_)));
            props = self.perform('prop', prop);
            [~, idx] = sort(props);
            for i=1:numel(ts)
                ttrees(i) = ts(idx(i));
            end
        end

        function ttrees = split_forests(self)
            ts = self.trees_;
            ttrees = feval(sprintf('%s', class(self.trees_)));
            k = 1;
            for i=1:numel(ts)
                self.waitbar(i);
                tss = ts(i).split_forest();
                tssn = tss.ttrees();
                for j=1:numel(tssn)
                    ttrees(k) = tssn(j);
                    k = k + 1;
                end
            end
            self.waitbar(-1);
            if k == 1
                ttrees = [];
            end
        end

        function map = prop_count_map(self, prop)
            map = containers.Map();
            ts = self.ttrees();
            for idx = 1:numel(ts)
                tree = ts(idx);
                value = tree.prop(prop);
                if ~map.isKey(value)
                    map(value) = 1;
                else
                    map(value) = map(value) + 1;
                end
            end
            %keys_values = vertcat(map.keys(), map.values());
        end

        function props = prop(self, name, flat)
            if nargin < 3
                flat = false;
            end
            if nargin < 2
                name = [];
            end
            ts = self.ttrees();
            if iscell(name)
                props = struct();
                for i = 1:numel(name)
                    n = name{i};
                    value = self.prop(n);
                    if flat
                        value = full(cell2mat(value));
                    end
                    props.(n) = value;
                end
            else
                if flat
                    props = nan(1, numel(ts));
                    for idx = 1:numel(ts)
                        tree = ts(idx);
                        value = tree.prop(name);
                        props(idx) = value;
                    end
                else
                    props = cell(1, numel(ts));
                    for idx = 1:numel(ts)
                        tree = ts(idx);
                        value = tree.prop(name);
                        props{idx} = value;
                    end
                end
            end
        end

        function ttrees = filter_func(self, func, varargin)
            tree = feval(sprintf('%s', class(self.trees_)));
            idx = [];
            s = 1;
            for i = 1:numel(self.trees_)
                self.waitbar(i);
                n = self.trees_(i);
                if func(n, varargin{:})
                    tree(s) = n;
                    s = s + 1;
                end
            end
            if s == 1
                tree = [];
            end
            ttrees = feval(class(self), tree, self.props_, self.name_);
            self.waitbar(-1);
        end

        function ttrees = filter_prop_equals(self, prop, value)
            ttrees = self.filter_func(...
                @(tree) (ischar(tree.prop(prop)) && strcmp(tree.prop(prop), value)) || ...
                    (~ischar(tree.prop(prop)) && tree.prop(prop) == value));
        end

        function ttrees = filter_empty(self)
            self.set_waitbar_msg('filter_empty');
            ttrees = self.filter_func(@(t) ~t.isempty());
        end

        function idx = index_prop(self, prop, value)
            idx = [];
            for i = 1:numel(self.trees_)
                tree = self.trees_(i);
                if ((ischar(tree.prop(prop)) && strcmp(tree.prop(prop), value)) || ...
                    (~ischar(tree.prop(prop)) && tree.prop(prop) == value))
                    idx = [idx; i];
                end
            end
        end

        function idx = index_func(self, func, varargin)
            idx = [];
            for i = 1:numel(self.trees_)
                self.waitbar(i);
                n = self.trees_(i);
                if func(n, varargin{:})
                    idx = [idx; i];
                end
            end
            self.waitbar(-1);
        end

        function groups = group_prop(self, prop)
            groups = self.group_func(@(tree) tree.prop(prop));
        end

        function groups = group_func(self, func, varargin)
            if numel(varargin) > 0
                propname = varargin{1};
            else
                propname = [];
            end
            bins = containers.Map();
            for i = 1:numel(self.trees_)
                tree = self.trees_(i);
                key = func(tree);
                if ~isstring(key)
                    key = num2str(key);
                end
                key = char(key);
                if propname
                    tree.set_prop(propname, key);
                end
                if bins.isKey(key)
                    ts = bins(key);
                    ts(end + 1) = tree;
                    bins(key) = ts;
                else
                    bins(key) = tree;
                end
            end
            g = {};
            for key=bins.keys
                g{end + 1} = ...
                    feval(class(self), bins(char(key)), self.props_, key);
            end
            groups = TreesGroups(g, bins.keys);
        end

        %function out = normalize_population(self)
        %    out = {};
        %    bb = self.perform('bbox');
        %    s = max(abs(min([dx(:); dy(:); dz(:)])), abs(max([dx(:); dy(:); dz(:)])));
        %    for idx = 1:numel(self.ttrees())
        %        out{idx} = self.ttrees(idx).scale(s);
        %    end
        %end

        function typen = typeN_points(self)
            typen = [];
            for idx = 1:numel(self.ttrees())
                tn = typeN_tree(self.ttrees(idx).tree());
                tnc = [numel(tn(tn == 0)), numel(tn(tn == 1)), numel(tn(tn == 2))];
                typen = [typen; tnc];
            end
        end

        function slf = perform_tree(self, func, varargin)
            for i=1:numel(self.trees_)
                fprintf('perform %d/%d\n', i, numel(self.trees_));
                self.waitbar(i);
                self.trees_(i).perform_tree(func, varargin{:});
            end
            self.waitbar(-1);
            slf = self;
        end

        function out = map_tree_arguments(self, func, args)
            out = {};
            N = numel(self.trees_);
            if ~iscell(args)
                args = num2cell(args);
            end
            for i=1:numel(self.trees_)
                self.waitbar(i);
                try
                    if ~iscell(args{i})
                        ai = num2cell(args{i});
                    else
                        ai = args{i};
                    end
                    x = self.trees_(i).map_tree(func, ai{:});
                    out{i} = x;
                catch err
                    fprintf('map_tree_arguments: Error processing object %d/%d, skipping..\n', i, N);
                    fprintf('--> %s: %s\n', err.identifier, err.message);
                    for j=1:numel(err.stack)
                        fprintf('%s:%d %s\n', err.stack(j).file, err.stack(j).line, err.stack(j).name);
                    end
                    out{i} = [];
                end
            end
            self.waitbar(-1);
        end

        function out = map_tree(self, func, varargin)
            out = {};
            N = numel(self.trees_);
            wrap = true;
            for i=1:N
                self.waitbar(i);
                try
                    t = self.trees_(i);
                    x = t.map_tree(func, varargin{:});
                    out{i} = x;
                    if ~isa(x, 'trees.Tree')
                        wrap = false;
                    end
                catch err
                    fprintf('map_tree: Error processing object %d/%d, skipping..\n', i, N);
                    fprintf('--> %s: %s\n', err.identifier, err.message);
                    for j=1:numel(err.stack)
                        fprintf('%s:%d %s\n', err.stack(j).file, err.stack(j).line, err.stack(j).name);
                    end
                    out{i} = [];
                    wrap = false;
                end
            end
            if wrap && numel(out) > 0
                out2 = feval(sprintf('%s', class(self.trees_)));
                for i=1:numel(out)
                    out2(i) = out{i};
                end
                out = out2;
            end
            self.waitbar(-1);
        end

        function out = map_tree_varout(self, func, varargin)
            out = {};
            for i=1:numel(self.trees_)
                self.waitbar(i);
                try
                    x = {};
                    [x{1:nargout}] = self.trees_(i).map_tree(func, varargin{:});
                    out{i} = x;
                catch err
                    fprintf('map_tree_varout: Error processing object %d/%d, skipping..\n', i, N);
                    fprintf('--> %s: %s\n', err.identifier, err.message);
                    for j=1:numel(err.stack)
                        fprintf('%s:%d %s\n', err.stack(j).file, err.stack(j).line, err.stack(j).name);
                    end
                    out{i} = [];
                end
            end
            self.waitbar(-1);
        end

        function mat = map_tree_mat(self, func, varargin)
            cmats = self.map_tree(func, varargin{:});
            lens = arrayfun(@(m) numel(m{1}), cmats);
            l = max(lens);
            mat = zeros(numel(cmats), l);
            for i=1:numel(cmats)
                mat(i,1:numel(cmats{i})) = cmats{i};
            end
        end

        function list = map_tree_scalar(self, func, varargin)
            list = cell2mat(self.map_tree(func, varargin{:}));
        end

        function translate_rotate(self)
            self.perform('translate_rotate');
        end

        function varargout = perform_(self, name, varargin)
            [varargout{1:nargout}] = arrayfun(@(x) x.(name)(varargin{:}), self.ttrees(), 'UniformOutput', false);
        end

        function out = perform_arguments(self, name, args)
            N = numel(self.ttrees());
            out = cell(N, 1);
            wrap = true;
            j = 1;
            if ~iscell(args)
                args = num2cell(args);
            end
            for i=1:N
                self.waitbar(i);
                n = self.trees_(i);
                try
                    if ~iscell(args{i})
                        ai = num2cell(args{i});
                    else
                        ai = args{i};
                    end
                    out{j} = n.(name)(ai{:});
                    if isa(out{j}, 'trees.Trees')
                        ts = out{j}.trees_;
                        for k=1:numel(ts)
                            out{j + k - 1} = ts(k);
                        end
                        j = j + numel(ts) - 1;
                    elseif ~isa(out{j}, 'trees.Tree')
                        wrap = false;
                    end
                    j = j + 1;
                catch err
                    fprintf('perform_arguments: Error processing object %d/%d, skipping..\n', i, N);
                    fprintf('--> %s: %s\n', err.identifier, err.message);
                    for i=1:numel(err.stack)
                        fprintf('%s:%d %s\n', err.stack(i).file, err.stack(i).line, err.stack(i).name);
                    end
                    out{j} = [];
                end
            end
            if wrap
                out = feval(class(self), out, self.props_, self.name_);
            end
            self.waitbar(-1);
        end

        function out = perform(self, name, varargin)
            N = numel(self.ttrees());
            out = cell(N, 1);
            wrap = true;
            j = 1;
            for i=1:N
                self.waitbar(i);
                n = self.trees_(i);
                try
                    out{i} = n.(name)(varargin{:});
                    if isa(out{j}, 'trees.Trees')
                        ts = out{j}.trees_;
                        for k=1:numel(ts)
                            out{j + k - 1} = ts(k);
                        end
                        j = j + numel(ts) - 1;
                    elseif isa(out{j}, 'trees.Tree') && numel(out{j}) > 1
                        ts = out{j};
                        for k=1:numel(ts)
                            out{j + k - 1} = ts(k);
                        end
                        j = j + numel(ts) - 1;
                    elseif ~isa(out{j}, 'trees.Tree')
                        wrap = false;
                    end
                    j = j + 1;
                catch err
                    fprintf('perform: Error processing object %d/%d, skipping..\n', i, N);
                    fprintf('--> %s: %s\n', err.identifier, err.message);
                    for k=1:numel(err.stack)
                        fprintf('%s:%d %s\n', err.stack(k).file, err.stack(k).line, err.stack(k).name);
                    end
                    out{j} = [];
                    %out{i} = [];
                end
            end
            if wrap
                out = feval(class(self), out, self.props_, self.name_);
            end
            self.waitbar(-1);
        end

        function out = perform_func(self, func, varargin)
            N = numel(self.ttrees());
            out = cell(N, 1);
            wrap = true;
            for i=1:N
                self.waitbar(i);
                n = self.trees_(i);
                try
                    out{i} = func(n, varargin{:});
                catch
                    out{i} = [];
                end
                if ~isa(out{i}, 'trees.Tree')
                    wrap = false;
                end
            end
            if wrap
                out = feval(class(self), out);
            end
            self.waitbar(-1);
        end

        function varargout = perform_uniform_(self, name, varargin)
            [varargout{1:nargout}] = arrayfun(@(x) x.(name)(varargin{:}), self.ttrees());
        end

        function varargout = perform_uniform(self, name, varargin)
            N = numel(self.ttrees());
            out = [];
            for i=1:N
                self.waitbar(i);
                n = self.trees_(i);
                out = [out; n.(name)(varargin{:})];
            end
            self.waitbar(-1);
            [varargout{1:numel(out)}] = out;
        end

        function out = spread(self, varargin)
            ns = self.trees_;
            ts = [];
            for i=1:numel(ns)
                ts{i} = ns(i).tree();
            end
            out = spread_tree(ts, varargin{:});
        end

        function varargout = gscale(self, varargin)
            [varargout{1:nargout}] = gscale_tree(self.ttrees(), varargin{:});
        end

        function ttrees = clone_tree(self, num, bf, options)
            ts = clone_tree(self.ttrees(), num, bf, options);
            ttrees = trees.Trees.from_trees(ts);
        end

        function mat = hist_eucl_tree_fun(self, func, varargin)
            function h = hf(t, f, ds, m)
                e = eucl_tree(t);
                h = histc(e(f(t)), 0:ds:m);
            end
            if numel(varargin) < 1
                ds = 5;
            else
                ds = varargin{1};
            end
            dists = arrayfun(@(t) max(eucl_tree(t{1})), self.ttrees());
            mat = self.map_tree_mat(@hf, func, ds, max(dists) + ds);
        end

        function mat = T_eucl(self, varargin)
            mat = self.hist_eucl_tree_fun(@T_tree, varargin{:});
        end

        function mat = B_eucl (self, varargin)
            mat = self.hist_eucl_tree_fun(@B_tree, varargin{:});
        end

        function mat = bangles(self, varargin)
            mat = self.map_tree_mat(@angleB_tree, varargin);
        end

        function mat = blens(self, varargin)
            function bl = blen(t)
                len =  len_tree(t);  % vector containing length values of tree segments [um]
                Plen = Pvec_tree(t, len); % path length from the root [um]
                sect = dissect_tree(t);
                bl = diff(Plen(sect), [], 2);
            end
            mat = self.map_tree_mat(@blen, varargin);
        end

        function list = convhull_vols(self)
            function v = vol(t)
                [~, v] = convhulln([t.X, t.Y, t.Z]);
            end
            list = self.map_tree_scalar(@vol);
        end

        function mat = dens(self)
            function vol = vol(t)
                bt = T_tree(t) | B_tree(t);
                dhull = hull_tree(t,[],[],[],[],'none');
                points = dhull.vertices;
                [~, ~, ~, vol] = vhull_tree(t, [], points, find(bt), [], 'none');
            end
            mat = self.map_tree_mat(@vol);
        end

        function stats = stats(self, varargin)
            s = self.map_tree(@stats_tree, varargin);

            gstats = {};
            names = fieldnames(s{1}.gstats);
            for i=1:numel(names)
                n = names{i};
                gstats.(n) = arrayfun(@(x) x{1}.gstats.(n), s);
            end

            dstats = {};
            names = fieldnames(s{1}.dstats);
            for i=1:numel(names)
                n = names{i};
                dstats.(n) = arrayfun(@(x) x{1}.dstats.(n){1}, s, 'UniformOutput', false);
            end
            stats = {};
            stats.gstats = gstats;
            stats.dstats = dstats;
        end

        function basic_stats(self, name)
            stats = self.stats();
            names = fieldnames(stats.gstats);
            for i=1:numel(names)
                data = stats.gstats.(names{i});
                fig = figure;
                set(fig, 'Visible', 'off');
                hist(data, 30);
                xlabel(names{i});
                ylabel('#');
                saveas(fig, sprintf('out/basic-g-%s-%s.png', names{i}, name));
                close(fig);
            end

            names = fieldnames(stats.dstats);
            for i=1:numel(names)
                if strcmp(names{i}, 'sholl')
                    continue
                end
                data = stats.dstats.(names{i});
                d = [];
                for j=1:numel(data)
                    dd = data{j};
                    d = [d dd(:)'];
                end
                fig = figure;
                set(fig, 'Visible', 'off');
                hist(d, 30);
                xlabel(names{i});
                ylabel('#');
                saveas(fig, sprintf('out/basic-d-%s-%s.png', names{i}, name));
                close(fig);
            end
        end

        function [cells1, cells2] = versus(self, func1, args1, func2, args2)
            cells1 = self.map_tree(func1, args1);
            cells2 = self.map_tree(func2, args2);
        end

        function [list1, list2] = versus_scalar(self, func1, args1, func2, args2)
            list1 = self.map_tree_scalar(func1, args1);
            list2 = self.map_tree_scalar(func2, args2);
        end

        function [mat1, mat2] = versus_mat(self, func1, args1, func2, args2)
            mat1 = self.map_tree_mat(func1, args1);
            mat2 = self.map_tree_mat(func2, args2);
        end

        function [cells1, cells2] = versus_segment_scalar(self, func1, args1, func2, args2, varargin)
            if numel(varargin) > 1
                label1 = varargin{1};
                label2 = varargin{2};
            else
                label1 = '';
                label2 = '';
            end

            if numel(varargin) > 2
                options = varargin{3};
            else
                options = '';
            end

            [cells1, cells2] = self.versus(func1, args1, func2, args2);

            if contains(options, '-s')
                trees.Trees.plot_versus_scalar(label1, cells1, label2, cells2);
            end
        end

        function out = segment_distance(self, t)
            len =  len_tree(t);  % vector containing length values of tree segments [um]
            Plen = Pvec_tree(t, len); % path length from the root [um]
            sect = dissect_tree(t);
            starting = Plen(sect);
            out = starting(:,1);
        end

        function out = segment_length(self, t)
            len =  len_tree(t);  % vector containing length values of tree segments [um]
            Plen = Pvec_tree(t, len); % path length from the root [um]
            sect = dissect_tree(t);
            out = diff(Plen(sect), [], 2);
        end

        function out = segment_surface(self, t)
            surf =  surf_tree(t);
            Psurf = Pvec_tree(t, surf);
            sect = dissect_tree(t);
            out = diff(Psurf(sect), [], 2);
        end

        function out = segment_volume(self, t)
            vol =  vol_tree(t);
            Pvol = Pvec_tree(t, vol);
            sect = dissect_tree(t);
            out = diff(Pvol(sect), [], 2);
        end

        function out = segment_mean_radius(self, t)
            vol =  vol_tree(t);
            Pvol = Pvec_tree(t, vol);
            len =  len_tree(t);
            Plen = Pvec_tree(t, len);

            sect = dissect_tree(t);

            len = diff(Plen(sect), [], 2);
            vol = diff(Pvol(sect), [], 2);

            out = sqrt(vol ./ (len * pi));
        end

        function versus_stats(self, name)
            funcs = {@self.segment_distance @self.segment_length ...
                @self.segment_surface @self.segment_volume ...
                @self.segment_mean_radius};
            labels = {'segment distance from root [um]'...
                'segment length [um]', 'segment surface [um2]' ...
                'segment volume [um3]', 'segment mean radius [um]'};
            labels_short = {'distance' 'length', 'surface' 'volume', ...
                'radius'};

            for i=1:numel(funcs)
                for j=i+1:numel(funcs)
                     [c1, c2] = self.versus_segment_scalar(funcs{i}, {}, funcs{j}, {});
                     fig = figure();
                     set(fig, 'Visible', 'off');
                     trees.Trees.plot_versus_scalar(labels{i}, c1, labels{j}, c2, fig);
                     saveas(fig, sprintf('out/%s-%s-%s.png', labels_short{i}, labels_short{j}, name));
                     close(fig);
                end
            end
        end

        function varargout = vs_segment_length_volume(self, varargin)
            [varargout{1:nargout}] = self.versus_segment_scalar(...
                @self.segment_length, {}, @self.segment_volume, {}, ...
                'segment length [um]', 'segment volume [um3]', varargin{:});
        end

        function varargout = vs_segment_distance_volume(self, varargin)
            [varargout{1:nargout}] = self.versus_segment_scalar(...
                @self.segment_distance, {}, @self.segment_volume, {}, ...
                'segment distance from root [um]', 'segment volume [um3]', varargin{:});
        end

        function varargout = vs_segment_distance_length(self, varargin)
            [varargout{1:nargout}] = self.versus_segment_scalar(...
                @self.segment_distance, {}, @self.segment_length, {}, ...
                'segment distance from root [um]', 'segment length [um]', varargin{:});
        end

        function [ua, ca, idxs, bs2, ts2, bps, tps, bps2, tps2] = bs_ts_points(self, varargin)
           bs = self.map_tree(@B_tree);
           ts = self.map_tree(@T_tree);
           idxs = arrayfun(@(x) find(bs{x} | ts{x}), 1:numel(bs), 'UniformOutput', false);
           bs2 = arrayfun(@(x) bs{x}(idxs{x}), 1:numel(bs), 'UniformOutput', false);
           ts2 = arrayfun(@(x) ts{x}(idxs{x}), 1:numel(ts), 'UniformOutput', false);

           a = arrayfun(@(x) numel(x{1}), idxs);
           ua = unique(a);
           ca = histc(a, ua);

           if nargin > 1
               n = varargin{1};
               idx1 = find(a == n);
               m = n;
           else
               n = 0;
               idx1 = find(a > 5);
               m = max(a);
           end

           bps = [];
           tps = [];
           for i=idx1
               tmp = nan(1, m);
               tmp(1:numel(bs2{i})) = bs2{i};
               bps = [bps; tmp];
               tmp = nan(1, m);
               tmp(1:numel(ts2{i})) = ts2{i};
               tps = [tps; tmp];
           end

           tps2 = [];
           bps2 = [];
           for i=idx1
               bps2 = [bps2; find(bs2{i}) ./ a(i)];
               tps2 = [tps2; find(ts2{i}) ./ a(i)];
           end

        end

        function self = save_png(self, name)
            ttrees = self.ttrees();
            digits = num2str(ceil(log10(numel(ttrees))));
            for i=1:numel(ttrees)
                n = ttrees(i);
                nname = sprintf(strcat(name, '-%0', digits, 'd'), i);
                n.savepng(nname);
            end
        end

        function self = plot_bouquet(self)
            clf;
            for i = 1 : numel(self.trees_)
                plot_tree(self.trees_(i).tree, rand(1, 3), [], [], [], '-p1');
            end
            scalebar;
            drawnow;
            axis off tight;
        end

        function featg = calc_prop(self, featfun, featname, varargin)
            defaultFlat = false;
            p = inputParser;
            addOptional(p, 'scalar', defaultFlat, @islogical);
            parse(p, varargin{:});
            if nargin < 3
                featname = [];
            end
            flat = p.Results.scalar;
            if flat
                featg = [];
            else
                featg = {};
            end
            for i = 1 : numel(self.trees_)
                self.waitbar(i);
                t = self.trees_(i);
                try
                    x = featfun(t);
                    if flat
                        featg = [featg x];
                    else
                        featg{i} = x;
                    end
                    if numel(featname) > 0
                        if iscell(featname)
                            for j=1:numel(featname)
                                if iscell(x)
                                    t.set_prop(featname{j}, x{j});
                                else
                                    t.set_prop(featname{j}, x(j));
                                end
                            end
                        else
                            t.set_prop(featname, x);
                        end
                    end
                catch err
                    if numel(featname) > 0
                        if iscell(featname)
                            for j=1:numel(featname)
                                t.set_prop(featname{j}, nan);
                            end
                        else
                            t.set_prop(featname, nan);
                        end
                    end
                    if flat
                        featg = [featg nan];
                    else
                        featg{i} = [];
                    end
                    fprintf('calc_feature: Error processing object %d/%d, skipping..\n', i, numel(self.trees_));
                    fprintf('--> %s: %s\n', err.identifier, err.message);
                    for k=1:numel(err.stack)
                        fprintf('%s:%d %s\n', err.stack(k).file, err.stack(k).line, err.stack(k).name);
                    end
                end
            end
            self.waitbar(-1);
        end
    end
end

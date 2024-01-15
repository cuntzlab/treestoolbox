classdef Tree < handle
    % Tree    Tree class that stores tree structure along with other
    %         properties.
    % (trees package)
    %
    % See
    %
    % tree = Tree (intree, properties)
    % ------------------------------
    %
    % Creates an instance of a Tree class from the given tree structure in tree_struct. Optionally takes a second
    % structure properties that stores properties of the tree.
    %
    % Input
    % -----
    % - intree ::struct: stuctured tree
    % - properties ::stuct: structure of tree properties
    %     {DEFAULT: {}}
    %
    % Output
    % ------
    % - tree     ::instance of Tree class representing intree
    %
    % Example
    % -------
    % Tree(sample_tree);
    % Tree(sample_tree, struct('name', 'mytree'));
    %
    % the TREES toolbox: edit, generate, visualise and analyse neuronal trees
    % Copyright (C) 2009 - 2016  Hermann Cuntz

    % constants
    properties (Constant=true, GetAccess='protected')
    end

    % private properties
    properties (GetAccess='protected', SetAccess='protected')
        container_
        tree_
        props_
        cache_
        feature_
    end

    % public properties
    properties
    end

    % private methods
    methods (Access='protected')
        function container = CONTAINER(self)
             container = @Trees;
        end

        function self = SELF(self)
             self = @Tree;
        end

        function tree = make_tree_(self, t)
            if iscell(t)
                tree = feval(sprintf('%s', class(self)));
                for i=1:numel(t)
                    tree(i) = feval(sprintf('%s', class(self)), t{i}, self.props_);
                end
            else
                tree = feval(sprintf('%s', class(self)), t, self.props_);
            end
        end
    end

    methods(Static)
        function tree = load(filename)
            % tree = Tree.load(filename)
            % ------------------------------
            %
            % Loads a tree from a given file name via load_tree, static method.
            %
            % Input
            % -----
            % - filename ::string
            %
            % Output
            % ------
            % - tree     ::instance of Tree class
            %
            % Example
            % -------
            % Tree.load('mytree');
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal trees
            % Copyright (C) 2009 - 2016  Hermann Cuntz

            if exist(filename, 'file')
               tree = load_tree(filename);
            else
               warning('File %s does not exist!', filename);
               trees = [];
               return;
            end
            tree = Tree(tree);
        end

        function t = random_beta(n, a, b)
            t = tree.rand_split_beta(n, a, b);
            t = Tree(t.totrees());
        end

        function tree = random_binary_tree(n)
            t = {};
            edge1 = zeros(2 * (n - 1) - 1, 1);
            edge2 = zeros(2 * (n - 1) - 1, 1);
            edge1(:) = -1;
            edge2(:) = -1;

            intnod = n - 1;
            e = 1;
            edge1(e) = 1;
            edge2(e) = 2;
            for ternod=2:n
                ichose = randi([1, e]);
                e = e + 1;
                edge2(e) = edge2(ichose);
                intnod = intnod + 1;
                edge1(e) = intnod;
                edge2(ichose) = intnod;
                e = e + 1;
                edge1(e) = intnod;
                edge2(e) = ternod;
            end

            N = max([edge1(:); edge2(:)]);
            dA = sparse(N, N);
            for i=1:numel(edge1)
                m = min([edge1(i) edge2(i)]);
                M = max([edge1(i) edge2(i)]);
                dA(m, M) = 1;
            end

            t.dA = dA;
            t.X = zeros(N, 1);
            t.Y = zeros(N, 1);
            t.Z = zeros(N, 1);

            tree = Tree(t);
        end

        function tree = random_bct(n)
            T = [0];
            while sum(T == 0) < n
                idx = find(T == 0);
                p = randi(numel(idx));
                T = [T(1:idx(p) - 1) 2 0 T(idx(p):end)];
            end
            t = BCT_tree(T);
            tree = Tree(t);
        end

        function tree = random_gw(pel, pbr, maxsize, varargin)
            if numel(varargin) > 0
                classical = 0;
            else
                classical = 1;
            end
            pc = [0 cumsum([1 - pel - pbr pel pbr])];
            T = [0];
            while sum(T == 0) > 0 && sum(T == -1) + sum(T == 0) < maxsize
                idx = find(T == 0);
                if classical
                    T(T == 0) = -1;
                end
                for p=1:numel(idx)
                    i = find(histc(rand(), pc));
                    if i == 2
                        T = [T(1:idx(p) - 1) 1 0 T(idx(p) + 1:end)];
                    elseif i == 3
                        T = [T(1:idx(p) - 1) 2 0 0 T(idx(p) + 1:end)];
                    else
                        T(idx(p)) = -1;
                    end
                end
            end
            T(T == -1) = 0;
            if length(T) == 1
                t = struct();
                t.X = 0;
                t.Y = 0;
                t.Z = 0;
                t.D = 0;
                t.dA = 0;
            else
                try
                    t = BCT_tree(T);
                catch
                    disp('error!');
                    t = struct();
                    t.X = 0;
                    t.Y = 0;
                    t.Z = 0;
                    t.D = 0;
                    t.dA = 0;
                end
            end
            tree = Tree(t);
        end

        function t = random_gw_fixed(s)
            t = tree.galton_watson_fixed_size(s);
            t = Tree(t.totrees());
        end
        
        
        % template for factory method
        function tree = MST(varargin)
            tree = MST_tree(varargin{:});
            if iscell(tree)
                tree = Trees(tree);
            else
                tree = Tree(tree);
            end
        end

        function [z, table] = ZZ(n, varargin)
           if numel(varargin) == 0
               table = zeros(n, 1);
           else
               table = varargin{1};
           end

           if n <= 1
               z = n;
               return;
           end
           if n <= 3
               z = 1;
               return;
           end
           if floor(n) ~= n
               z = 0;
               return;
           end

           if table(n) > 0
               z = table(n);
               return;
           end

           if mod(n, 2) == 0
               [s, table] = Tree.ZZ(fix(n / 2), table);
               z = fix(s * (s + 1) / 2);
               upper = fix(n / 2) - 1;
           else
               z = 0;
               upper = fix((n - 1) / 2);
           end

           for k=1:upper
               [s1, table] = Tree.ZZ(k, table);
               [s2, table] = Tree.ZZ(n - k, table);
               z = z + s1 * s2;
           end

           table(n) = z;
        end

    end

    methods(Static, Access='private')
        function ent = entropy_(h)
            N = sum(h);
            p = h ./ N;
            eps = 1e-6;
            p(p < eps) = 1;
            ent = sum(p .* -log2(p)) / log2(N);
        end
    end

    % public methods
    methods
        function self = Tree(varargin)
            % tree = Tree (intree, properties)
            % ------------------------------
            %
            % Creates an instance of a Tree class from the given tree structure in tree_struct. Optionally takes a second
            % structure properties that stores properties of the tree.
            %
            % Input
            % -----
            % - intree ::struct: stuctured tree
            % - properties ::stuct: structure of tree properties
            %     {DEFAULT: {}}
            %
            % Output
            % ------
            % - tree     ::instance of Tree class representing intree
            %
            % Example
            % -------
            % Tree(sample_tree);
            % Tree(sample_tree, struct('name', 'mytree'));
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal trees
            % Copyright (C) 2009 - 2016  Hermann Cuntz

            if nargin > 0
               self.tree_ = varargin{1};
            else
               self.tree_ = {};
            end
            if nargin > 1
               self.props_ = varargin{2};
            else
               self.props_ = {};
            end
        end
        
        function self = repair(self)
            while isa(self.tree_, 'Tree')
                self.tree_ = self.tree_.tree_;
            end
        end

        function varargout = subsref(self, s)
           switch s(1).type
              case '.'
                 name = s(1).subs;
                 %if ~strcmp(name, 'plot') && ~strcmp(name, 'plot_lines') && self.has_cached(name) && numel(s) == 1
                 %   [varargout{1:nargout}] = self.cache_.(name);
                 %else
                    if strcmp(name, 'bptp')
                        [varargout{1:nargout}] = self.subsref(s(2:end)); %builtin('subsref', self, s(2:end));
                        t = self.tree();
                        varargout{1} = varargout{1}(T_tree(t) | B_tree(t));
                    elseif find(ismember(methods(self), name))
                         %[varargout{1:nargout}] = self.(name)(s(2).subs{:});
                         [varargout{1:nargout}] = builtin('subsref', self, s);
                     elseif isfield(self.tree(), name)
                         [varargout{1:nargout}] = builtin('subsref', self.tree(), s);
                     else
                         treefun = strcat(name, '_tree');
                         if exist(treefun, 'file')
                             % TODO update tree / cache result
                             if numel(s) > 1
                                 args = s(2).subs;
                             else
                                 args = {};
                             end
                            [varargout{1:nargout}] = feval(treefun, self.tree(), args{:});
                         else
                             builtin('subsref', self, s);
                             return;
                         end
                     end
                     if numel(varargout) == 1 && isstruct(varargout{1}) && ~isa(varargout{1}, 'Tree') && isfield(varargout{1}, 'dA') && ~strcmp(name, 'tree')
                         varargout{1} = feval(sprintf('%s', class(self)), varargout{1}, self.props_);
                     end
                     %if numel(varargout) == 1
                     %   self.set_cached(name, varargout{1});
                     %else
                     %   self.set_cached(name, varargout);
                     %end
                 %end
              case '{}'
                 [varargout{1:nargout}] = builtin('subsref', self, s);
              case '()'
                 [varargout{1:nargout}] = builtin('subsref', self, s);
           end
        end

        function slf = set_container(self, c)
           self.container_ = c;
           slf = self;
        end

        function set_tree(self, t)
           self.tree_ = t;
        end

        function tree = tree(self)
           tree = self.tree_;
        end

        function props = props(self)
            % props = props()
            % ------------------------------
            %
            % Returns the properties of a Tree instance.
            %
            % Input
            % -----
            % nothing
            %
            % Output
            % ------
            % - props     ::structure of properties
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal trees
            % Copyright (C) 2009 - 2016  Hermann Cuntz
            props = self.props_;
        end

        function prop = prop(self, name, varargin)
            % props = props(name)
            % ------------------------------
            %
            % Gets the value of the property specified by name.
            %
            % Input
            % -----
            % - name      ::string property name
            %
            % Output
            % ------
            % - prop      ::value of the property
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal trees
            % Copyright (C) 2009 - 2016  Hermann Cuntz
            if nargin < 2 || numel(name) == 0
                prop = self.props_;
                return;
            end
            if ischar(name)
                if isfield(self.props_, name)
                    prop = self.props_.(name);
                else
                    prop = nan;
                end
            elseif iscell(name)
                prop = struct();
                for i=1:numel(name)
                    n = name{i};
                    prop.(n) = self.prop(n);
                end
            elseif isa(name, 'function_handle')
                prop = name(self.props_);
            end
            if nargin > 2
                if numel(prop) >= varargin{1}
                    prop = prop(varargin{1});
                end
            end
        end

        function exists = has_prop(self, name)
            % props = props(name)
            % ------------------------------
            %
            % Gets the value of the property specified by name.
            %
            % Input
            % -----
            % - name      ::string property name
            %
            % Output
            % ------
            % - prop      ::value of the property
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal trees
            % Copyright (C) 2009 - 2016  Hermann Cuntz
            exists = isfield(self.props_, name);
        end

        function slf = set_prop(self, name, value)
            % props = props(name, value)
            % ------------------------------
            %
            % Sets the value of the property specified by name to the new
            % value.
            %
            % Input
            % -----
            % - name      ::string property name
            % - value     ::property value
            %
            % Output
            % ------
            % nothing
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal trees
            % Copyright (C) 2009 - 2016  Hermann Cuntz
            if ischar(name)
                if ~isa(name, 'function_handle')
                    self.props_.(name) = value;
                else
                    self.props_.(name) = value(self.props_);
                end
            elseif iscell(name)
                for i=1:numel(name)
                    self.set_prop(name{i}, value{i});
                end
            end
            slf = self;
        end
        
        function ps = struct_props(self, props)
            ps = struct();
            for i=1:numel(props)
                n = props{i};
                ps.(n) = self.prop(n);
            end
        end

        function prop = subprop(self, name, sname)
           prop = self.props_.(name).(sname);
        end

        function self = set_subprop(self, name, sname, value)
           self.props_.(name).(sname) = value;
        end

        function exists = has_subprop(self, name, sname)
           exists = isfield(self.props_.(name), sname);
        end

        function value = excluded(self)
            value = self.prop('excluded');
        end

        function self = set_excluded(self, value)
            self.set_prop('excluded', value);
        end

        function trees = split_forest(self)
            % trees = split_forest()
            % ------------------------------
            %
            % Some operations on a tree (for example deleting nodes)
            % can result in a splitting of a tree into several ones
            % (a forest). Then the internal tree structure contains a
            % collection of trees rather than a single one.
            %
            % Input
            % -----
            % - name      ::string property name
            % - value     ::property value
            %
            % Output
            % ------
            % nothing
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal trees
            % Copyright (C) 2009 - 2016  Hermann Cuntz
            t = self.tree();
            c = self.CONTAINER();
            if ~isstruct(t)
               ts = feval(sprintf('%s', class(self)));
               for i=1:numel(t)
                   n = self.make_tree_(t{i});
                   % TODO update name / property
                   ts(i) = n;
               end
               trees = c(ts);
            else
               trees = c(self);
            end
        end

        function tree = perform_tree(self, func, varargin)
           if ismatrix(self.tree_) && numel(self.tree_) == 0
               tree = self;
               return;
           end
           if ~isstruct(self.tree_)
               t = arrayfun(@(t) func(t{1}, varargin{:}), self.tree(), 'UniformOutput', false);
               c = self.CONTAINER();
               ts = feval(sprintf('%s', class(self)));
               for i=1:numel(t)
                   n = self.make_tree_(t{i});
                   % TODO update name / property
                   ts(i) = n;
               end
               tree = c(n);
           else
               t = func(self.tree(), varargin{:});
               tree = self.make_tree_(t);
           end
        end

        function tree = perform_stringfun(self, str)
           if ismatrix(self.tree_) && numel(self.tree_) == 0
               tree = self;
               return;
           end
           if ~isstruct(self.tree_)
               % TODO FELIX
               %t = arrayfun(@(t) func(t{1}, varargin{:}), self.tree(), 'UniformOutput', false);
               %c = self.CONTAINER();
               %ts = feval(sprintf('%s', class(self)));
               %for i=1:numel(t)
               %    n = self.make_tree_(t{i});
                   % TODO update name / property
               %    ts(i) = n;
               %end
               %tree = c(n);
           else
               t = self.tree();
               eval(strcat(str, ';'));
               tree = self.make_tree_(t);
           end
        end

        function varargout = map_tree(self, func, varargin)
           if ~isstruct(self.tree())
               [varargout{1:nargout}] = arrayfun(@(t) func(t{1}, varargin{:}), self.tree(), 'UniformOutput', false);
           else
               [varargout{1:nargout}] = func(self.tree(), varargin{:});
           end
        end

        function result = isempty(self)
            t = self.tree();
            if isa(t, 'Tree')
                result = 1;
                return;
            end
            result = (numel(t) == 0 || numel(t.dA) == 0);
        end

        function tree = strip_idx(self, idx)
           t = self.tree();
           try
              stripped = delete_tree(t, idx);
           catch
              disp('WARNING, could not strip tree');
              tree = self;
              return;
           end
           tree = self.make_tree_(stripped);
        end

        function tree = strip(self, mask, split)
           t = self.tree();
           if split
               options = '-x';
           else
               options = '';
           end
           try
              stripped = delete_tree(t, find(mask), options);
           catch
              disp('WARNING, could not strip tree');
              tree = self;
              return;
           end
           tree = self.make_tree_(stripped);
        end

        function tree = strip_show(self, mask)
           t = self.tree();
           try
              stripped = delete_tree(t, find(mask), '-s -x');
           catch
              disp('WARNING, could not strip tree');
              tree = self;
              return;
           end
           tree = self.make_tree_(stripped);
        end

        function tree = strip_region_but(self, keep, split)
           t = self.tree();
           if ~isfield(t, 'R')
              disp('WARNING, tree missing region field');
              tree = self;
              return;
           end
           mask = zeros(size(t.R));
           for i=1:numel(keep)
               mask = mask | t.R == keep(i);
           end
           tree = self.strip(~mask, split);
        end

        function tree = strip_region(self, strip, split)
           t = self.tree();
           if ~isfield(t, 'R')
              disp('WARNING, tree missing region field');
              tree = self;
              return;
           end
           mask = zeros(size(t.R));
           for i=1:numel(strip)
               mask = mask | t.R == strip(i);
           end
           tree = self.strip(mask, split);
        end

        function tree = strip_region_show(self, strip)
           t = self.tree();
           if ~isfield(t, 'R')
              disp('WARNING, tree missing region field');
              tree = self;
              return;
           end
           mask = zeros(size(t.R));
           for i=1:numel(strip)
               mask = mask | t.R == strip(i);
           end
           tree = self.strip_show(mask);
        end

        function tree = strip_typeN(self, keep, split)
           tn = typeN_tree(self.tree());
           mask = zeros(size(tn));
           for i=1:numel(keep)
               mask = mask | tn == keep(i);
           end
           tree = self.strip(~mask, split);
        end

        function tree = strip_region_axon(self, split)
           tree = self.strip_region([2], split);
        end

        function tree = strip_region_soma(self, split)
           tree = self.strip_region([1], split);
        end

        function tree = strip_region_soma_axon(self, split)
           tree = self.strip_region([1 2], split);
        end

        function tree = strip_region_but_dendrite(self, split)
           tree = self.strip_region([1 2], split);
        end

        function tree = strip_region_axon_soma(self, split)
           % strip all but dendrite
           % assumes standard swc labeling of regions
           % http://www.neuronland.org/NLMorphologyConverter/MorphologyFormats/SWC/Spec.html
           % 1 - soma, 2 - axon, 3 - (basal) dendrite, 4 - apical
           % dendrite
           tree = self.strip_region([1 2], split);
        end

        function x = calc_prop(self, featfun, featname, varargin)
            if nargin < 3
                featname = [];
            end
            try
                x = featfun(self);
                if numel(featname) > 0
                    if iscell(featname)
                        for j=1:numel(featname)
                            if iscell(x)
                                self.set_prop(featname{j}, x{j});
                            else
                                self.set_prop(featname{j}, x(j));
                            end
                        end
                    else
                        self.set_prop(featname, x);
                    end
                end
            catch err
                if numel(featname) > 0
                    if iscell(featname)
                        for j=1:numel(featname)
                            self.set_prop(featname{j}, nan);
                        end
                    else
                        self.set_prop(featname, nan);
                    end
                end
                fprintf('calc_feature: Error!\n');
                fprintf('--> %s: %s\n', err.identifier, err.message);
                for k=1:numel(err.stack)
                    fprintf('%s:%d %s\n', err.stack(k).file, err.stack(k).line, err.stack(k).name);
                end
            end
        end

        function successors = successor_nodes(self, inodes)
           successors = cell(1,1);
           dA = self.tree().dA;
           for i=1:numel(inodes)
               tdA = dA(:,inodes(i));
               successors{i} = find(tdA);
           end
           if numel(successors) == 1
               successors = successors{1};
           end
        end

        function n = subtree(self, inode)
           [~, s] = sub_tree(self.tree(), inode);
           n = self.make_tree_(s);
        end

        function r = rrank(self, varargin)
           if numel(varargin) > 0
               t = varargin{1};
           else
               t = self.strip_but_top();
           end
           n = t.mag();
           if n == 1
               % TODO what is end recursion?
               r = 1;
               return;
           end
           s = t.successor_nodes(1);
           tl = t.subtree(s(1));
           tr = t.subtree(s(2));
           alpha = tl.mag();
           beta = tr.mag();
           if alpha >= beta
               [beta, alpha] = deal(alpha, beta);
               [tr, tl] = deal(tl, tr);
           end
           rl = self.rrank(tl) - 1;
           rr = self.rrank(tr) - 1;
           if alpha - 1 >= 1
                z = @(n, k) sum(arrayfun(@(i) self.Z(i) * self.Z(n - i), 1:k));
                zn = z(n, alpha - 1);
           else
                zn = 0;
           end
           if alpha < beta
               r = zn + rl * self.Z(beta) + rr;
           elseif alpha == beta
               delta = @(m) m * (m + 1) / 2;
               za = self.Z(alpha);
               r = zn + delta(za) - delta(za - rl) + rr - rl;
           else
               disp('invalid sorting!');
               r = 0;
           end
           r = r + 1;
        end

        function tree = strip_but_top(self)
           tree = self.strip_typeN([0 2], false);
        end

        function tree = perform_tree_once(self, property, func, varargin)
           if ~self.prop(property)
               tree = self.perform_tree(func, varargin{:});
               tree.set_prop(property, true);
           else
               tree = self;
           end
        end

        function [perc, smooth, ent, h] = quality_segment_lengths_detailed(self, varargin)
           if numel(varargin) > 0
               bw = varargin{1};
               if bw <= 0
                   bw = .1;
               end
           else
               bw = .1;
           end
           if numel(varargin) > 1
               options = varargin{2};
           else
               options = '';
           end
           t = self.tree();
           if ~isstruct(t)
               l = [];
               for i=1:numel(t)
                   l = [l; len_tree(t{i})];
               end
           else
               l = len_tree(t);
           end

           m = min(l);
           M = max(l);
           bins = m:bw:M + bw;
           h = histc(l, bins);
           smooth = 1 - sum(abs(diff(h))) ./ (2 * numel(l));

           s = M - m;
           md = median(l);
           pc1 = sum(abs([prctile(l, 25) prctile(l, 75)] - md)) * 2;
           pc2 = sum(abs([prctile(l, 5) prctile(l, 95)] - md));
           perc = 1 - (pc1 + pc2) / (2*s);

           ent = Tree.entropy_(h);

           if numel(l) < 50
               perc = 0;
               ent = 0;
           end

           if strfind(options, '-s')
               figure;
               bar(bins, h, 'histc');
               xlabel('segment length [um]');
               ylabel('#');
               title(sprintf('q = %.3f, centrality = %.3f, smoothness = %.3f, H = %.3f', perc * smooth * ent, perc, smooth, ent));
           end
        end

        function q = quality_segment_lengths(self, varargin)
           [perc, smooth, ent, ~] = self.quality_segment_lengths_detailed(varargin{:});
           q = perc * smooth * ent;
        end

        function d = diameter(self)
           t = self.tree();
           l = len_tree(t);
           s = surf_tree(t);
           idx = find(l > 0);
           l = l(idx);
           s = s(idx);
           d = s ./ ( l * pi);
        end

        function [perc, smooth, ent, h] = quality_segment_diameters_detailed(self, varargin)
           if numel(varargin) > 0
               bw = varargin{1};
               if bw <= 0
                   bw = .05;
               end
           else
               bw = .05;
           end
           if numel(varargin) > 1
               options = varargin{2};
           else
               options = '';
           end
           eps = 1e-6;
           t = self.tree();
           if ~isstruct(t)
               l = [];
               s = [];
               for i=1:numel(t)
                   l = [l; len_tree(t{i})];
                   s = [s; surf_tree(t{i})];
               end
           else
               l = len_tree(t);
               s = surf_tree(t);
           end

           idx = find(l > 0);
           l = l(idx);
           s = s(idx);
           d = s ./ ( l * pi);
           m = min(d);
           M = max(d);

           bins = m:bw:M + bw;
           h = histc(d, bins);
           smooth = 1 - sum(abs(diff(h))) ./ (2 * numel(l));

           spread = M - m;
           md = median(d);
           pc1 = sum(abs([prctile(d, 25) prctile(d, 75)] - md)) * 2;
           pc2 = sum(abs([prctile(d, 5) prctile(d, 95)] - md));
           perc = 1 - (pc1 + pc2) / (2*spread);

           ent = Tree.entropy_(h);

           %if m < 0
           %    perc = perc / 4;
           %    has_neg = true;
           %else
           %    has_neg = false;
           %end

           if m < eps || M - m < eps
               perc = perc / 2;
               has_zero = true;
           else
               has_zero = false;
           end

           %if spread > 5
           %    perc = perc / (spread - 4);
           %    has_spread = true;
           %else
           %    has_spread = false;
           %end

           has_spread = false;

           %numfilled = sum(h > 0);
           %if numfilled < 10
           %    perc = perc * (numfilled/10);
           %end

           if strfind(options, '-s')
               figure;
               hist(d, bins);
               xlabel('segment diameter [um]');
               ylabel('#');
               title(sprintf('q = %.3f, centrality = %.3f, smoothness = %.3f, H = %.3f', perc * smooth * ent, perc, smooth, ent));
           end
        end

        function q = quality_segment_diameters(self, varargin)
           [perc, smooth, ent, ~] = self.quality_segment_diameters_detailed(varargin{:});
           q = perc * smooth * ent;
        end

        function [q, ql, qd] = quality_segment(self, varargin)
           ql = self.quality_segment_lengths(varargin{:});
           qd = self.quality_segment_diameters(varargin{:});
           q = ql .* qd;
        end

        function typen = count_typeN(self)
            tn = typeN_tree(self.tree());
            typen = [numel(tn(tn == 0)), numel(tn(tn == 1)), numel(tn(tn == 2))];
        end

        function n = num_nodes(self)
            t = self.tree();
            n = size(t.dA, 1);
        end

        function out = terminal_branch_order(self, varargin)
            t = self.tree();
            bo =  BO_tree(t);
            out = bo(T_tree(t));
        end

        function out = terminal_dist(self, varargin)
            t = self.tree();
            l =  Pvec_tree(t, len_tree(t));
            out = l(find(T_tree(t)));
        end

        function out = branch_order(self, varargin)
            t = self.tree();
            bo =  BO_tree(t);
            try
                sect = dissect_tree(t);
            catch
                disp('error calling dissect_tree!');
                out = [];
                return;
            end
            out = bo(sect(:, 2));
            if numel(varargin) > 0
                out = out(find(varargin{1}(t)));
            end
        end

        function out = branch_lengths(self)
            t = self.tree();
            len =  len_tree(t);  % vector containing length values of tree segments [um]
            Plen = Pvec_tree(t, len); % path length from the root [um]
            try
                sect = dissect_tree(t);
            catch
                disp('error calling dissect_tree!');
                out = [];
                return;
            end
            out = diff(Plen(sect), [], 2);
        end

        function out = branch_dists(self, varargin)
            t = self.tree();
            len =  len_tree(t);  % vector containing length values of tree segments [um]
            Plen = Pvec_tree(t, len); % path length from the root [um]
            try
                sect = dissect_tree(t);
            catch
                disp('error calling dissect_tree!');
                out = [];
                return;
            end
            out = Plen(sect(:, 2));

            if numel(varargin) > 0
                out = out(find(varargin{1}(t)));
            end
        end


        function out = branch_surfaces(self)
            t = self.tree();
            surf =  surf_tree(t);
            Psurf = Pvec_tree(t, surf);
            sect = dissect_tree(t);
            out = diff(Psurf(sect), [], 2);
        end

        function out = branch_volumes(self)
            t = self.tree();
            vol =  vol_tree(t);
            Pvol = Pvec_tree(t, vol);
            sect = dissect_tree(t);
            out = diff(Pvol(sect), [], 2);
        end

        function out = branch_mean_radii(self)
            t = self.tree();
            vol =  vol_tree(t);
            Pvol = Pvec_tree(t, vol);
            len =  len_tree(t);
            Plen = Pvec_tree(t, len);

            sect = dissect_tree(t);

            len = diff(Plen(sect), [], 2);
            vol = diff(Pvol(sect), [], 2);

            out = sqrt(vol ./ (len * pi));
        end


        function v = vol_convhull(self)
            t = self.tree();
            try
                [~, v] = convhull(t.X, t.Y, t.Z);
            catch
                v = NaN;
            end
        end

        function d = d_frac(self)
            t = self.tree();
            [x, y, z] = self.bbox();
            raster = zeros(round(x(2) - x(1) + 1), round(y(2) - y(1) + 1), round(z(2) - z(1) + 1));
            for i = 1:numel(t.X)
                raster(round(t.X(i) - x(1)) + 1, round(t.Y(i) - y(1)) + 1, round(t.Z(i) - z(1))  + 1) = 1;
            end
            [n, r] = boxcount(raster);
            p = polyfit(log(r), log(n), 1);
            d = -p(1);
        end

        function a = asym_vanpelt(self)
            a = asym_tree(self.tree(), [], '-vp');
        end

        function h = height(self)
            h = max(BO_tree(self.tree())) + 1;
        end

        function h = ext_path_len(self)
            t = self.tree();
            terminals = find(T_tree(t));
            bo = BO_tree(t);
            h = sum(bo(terminals));
        end

        function h = total_height(self)
            t = self.tree();
            bt = find(T_tree(t) | B_tree(t));
            bo = BO_tree(t);
            h = sum(bo(bt));
        end

        function m = mag(self)
            m = numel(find(T_tree(self.tree())));
        end

        function s = numnodes(self)
            m = numel(find(T_tree(self.tree())));
            if m < 2
                s = m;
            else
                s = 2*m - 1;
            end
        end

        function varargout = plot_lines(self)
            t = self.tree();
            varargout{1:nargout} = plot_tree(t, [], [], [], [], '-3l');
        end

        function xyz = XYZ(self)
            t = self.tree();
            xyz = [t.X t.Y t.Z];
        end

        function self = resample_inplace(self, varargin)
            t = resample_tree(self.tree(), varargin{:});
            self.tree_ = t;
        end

        function h = distsig(self, n)
            dists = pdist2(self.XYZ, self.XYZ);
            dists = dists(find(~tril(ones(size(dists)))));
            if sum(size(dists)) < 1
                h = zeros(n, 1);
                return;
            end
            dists = dists ./ max(dists(:));
            dists(dists > n) = NaN;
            bins = linspace(0, n, n - 1);
            h = histc(dists, bins);
            h = h ./ sum(h(:));
        end

        function h = distsig_eucl(self, n)
            t = self.tree();
            e = Pvec_tree(t, len_tree(t));
            dists = pdist2(e, e);
            dists = dists(find(~tril(ones(size(dists)))));
            dists = dists ./ max(dists(:));
            bins = linspace(0, 1, n);
            h = histc(dists, bins);
            h = h ./ sum(h(:));
        end

        function n = prune_terminal_branches(self, l)
            t = self.tree();
            len =  len_tree(t);  % vector containing length values of tree segments [um]
            Plen = Pvec_tree(t, len); % path length from the root [um]
            terminals = T_tree(t);
            try
                sect = dissect_tree(t);
            catch
                disp('error calling dissect_tree!');
                n = self;
                return;
            end
            blens = diff(Plen(sect), [], 2);
            idx = find(blens <= l);
            didx = [];
            for j=1:numel(idx)
                i = idx(j);
                if ~terminals(sect(i, 2))
                    continue;
                end
                t = delete_tree(t, didx);
                %didx = [didx sect(i, 1):sect(i, 2)];
            end
            %t = delete_tree(t, sort(didx));
            n = self.make_tree_(t);
        end

        function [feat, short, name] = features(self, options)
            if numel(nargin) < 2
                options = '';
            end
            [feat, short, name] = features_tree(self.tree_, strcat(options, '-n -l'));
            for i=1:numel(short)
                self.set_prop(short{i}, feat{i});
            end
        end
    end
end

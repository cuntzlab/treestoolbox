classdef Tree < handle
    % trees.Tree    trees.Tree class that stores tree structure along with other
    %         properties.
    % (trees package)
    %
    % See
    %
    % tree = trees.Tree (intree, properties)
    % ------------------------------
    %
    % Creates an instance of a trees.Tree class from the given tree structure in tree_struct. Optionally takes a second
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
    % - tree     ::instance of trees.Tree class representing intree
    %
    % Example
    % -------
    % trees.Tree(sample_tree);
    % trees.Tree(sample_tree, struct('name', 'mytree'));
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
             container = @trees.Trees;
        end

        function self = SELF(self)
             self = @trees.Tree;
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
            % tree = trees.Tree.load(filename)
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
            % - tree     ::instance of trees.Tree class
            %
            % Example
            % -------
            % trees.Tree.load('mytree');
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal trees
            % Copyright (C) 2009 - 2024  Hermann Cuntz

            if exist(filename, 'file')
               tree = load_tree(filename);
            else
               warning('File %s does not exist!', filename);
               tree = [];
               return;
            end
            tree = trees.Tree(tree);
        end
        
        % template for factory method
        function tree = MST(varargin)
            tree = MST_tree(varargin{:});
            if iscell(tree)
                tree = Trees(tree);
            else
                tree = trees.Tree(tree);
            end
        end

    end

    % public methods
    methods
        function self = Tree(varargin)
            % tree = trees.Tree (intree, properties)
            % ------------------------------
            %
            % Creates an instance of a trees.Tree class from the given tree structure in tree_struct. Optionally takes a second
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
            % - tree     ::instance of trees.Tree class representing intree
            %
            % Example
            % -------
            % trees.Tree(sample_tree);
            % trees.Tree(sample_tree, struct('name', 'mytree'));
            %
            % the TREES toolbox: edit, generate, visualise and analyse neuronal trees
            % Copyright (C) 2009 - 2024  Hermann Cuntz

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
            while isa(self.tree_, 'trees.Tree')
                self.tree_ = self.tree_.tree_;
            end
        end

        function varargout = subsref(self, s)
           switch s(1).type
               case '.'
                   name = s(1).subs;
                   if strcmp(name, 'bptp')
                       [varargout{1:nargout}] = self.subsref(s(2:end)); %builtin('subsref', self, s(2:end));
                       t = self.tree();
                       varargout{1} = varargout{1}(T_tree(t) | B_tree(t));
                   elseif find(ismember(methods(self), name))
                       [varargout{1:nargout}] = builtin('subsref', self, s);
                   elseif isfield(self.tree(), name)
                       [varargout{1:nargout}] = builtin('subsref', self.tree(), s);
                   else
                       treefun = strcat(name, '_tree');
                       if exist(treefun, 'file')
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
                   if numel(varargout) == 1 && isstruct(varargout{1}) && ~isa(varargout{1}, 'trees.Tree') && isfield(varargout{1}, 'dA') && ~strcmp(name, 'tree')
                       varargout{1} = feval(sprintf('%s', class(self)), varargout{1}, self.props_);
                   end
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
            % Returns the properties of a trees.Tree instance.
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
            % Copyright (C) 2009 - 2024  Hermann Cuntz
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
            % Copyright (C) 2009 - 2024  Hermann Cuntz
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
                for i = 1 : numel(name)
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
            for i = 1 : numel(props)
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
            % Some operations on a tree (for example deleting nodes) can result
            % in a splitting of a tree into several ones (a forest). Then the
            % internal tree structure contains a collection of trees rather than
            % a single one.
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

        function varargout = map_tree(self, func, varargin)
           if ~isstruct(self.tree())
               [varargout{1:nargout}] = arrayfun(@(t) func(t{1}, varargin{:}), self.tree(), 'UniformOutput', false);
           else
               [varargout{1:nargout}] = func(self.tree(), varargin{:});
           end
        end
        
        function n = subtree(self, inode)
           [~, s] = sub_tree(self.tree(), inode);
           n = self.make_tree_(s);
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


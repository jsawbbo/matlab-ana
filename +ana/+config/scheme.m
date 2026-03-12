classdef scheme < handle 
    %ana.config.scheme Configuration scheme.
    %
    %   Detailed explanation goes here
    %
    
    properties(SetAccess=protected)
        Version 
        Tree
    end

    methods
        function makeMap(obj,node,item)
            node.(item.key) = ana.config.node.map(...
                Parent=node,...
                Scheme=ana.config.scheme(Tree=item,Version=obj.Version));
        end
        function makeSequence(obj,node,item)
            node.(item.key) = ana.config.node.seq(...
                Parent=node,...
                Scheme=ana.config.scheme(Tree=item,Version=obj.Version));
        end
        function makeValue(obj,node,item)
            if isfield(item,"default")
                %FIXME
            end
        end

        function checkMap(obj,node,item)
            FIXME
        end
        function checkSequence(obj,node,item)
            FIXME
        end
        function checkValue(obj,node,item)
            FIXME
        end
    end
    
    methods
        function obj = scheme(filename,options)
            %SCHEME     Construct an instance of this class
            %
            arguments
                filename string = []
                options.Tree = []
                options.Version = []
            end

            % load
            if ~isempty(filename)
                filename = ana.fs.path(filename);
                if filename.isrelative()
                    toolboxdir = ana.os.paths('toolboxdir');
                    filename = toolboxdir / 'scheme' / filename + '.yml';
                end
    
                if ~isfile(filename)
                    error('ANA:CONFIG:SCHEME:NO_SUCH_FILE', 'scheme file does not exist');
                end
    
                obj.Tree = ana.file.yaml.load(fullfile(filename));
                obj.Version = obj.Tree.version;
            else
                obj.Tree = options.Tree;
                obj.Version = options.Version;
            end
        end

        function apply(obj,node,options)
            %APPLY      Apply scheme to node (possibly filling defaults).
            arguments
                obj ana.config.scheme
                node ana.config.node
                options.Version (1,1) string = ""
            end

            sch = obj.Tree;
            if isfield(sch,"version") % top-level scheme
                % check version
                if strlength(options.Version) ~= 0
                    docver = ana.util.version(options.Version);
                    schver = ana.util.version(sch.version);
                    
                    FIXME
                end
                
                % insert into "unified" config
                % u = ana.config.unified;
                % FIXME
            end

            % check node type
            switch (sch.type)
                case 'map'
                    assert(isa(node,'ana.config.node.map'))
                case {'table','seq'}
                    assert(isa(node,'ana.config.node.seq'))
                    if isempty(node) && ~isfield(sch,"default")
                        return
                    end
                otherwise 
                    assert(isa(node,'ana.config.node.value'))
            end            
            
            % check or populate
            cnt = sch.contents;
            if iscell(cnt)
                getidx = @(i) cnt{i};
            else
                getidx = @(i) cnt(1);
            end

            for i = 1:numel(cnt)
                item = getidx(i);

                % sub-node
                if isfield(node,item.key)
                    switch item.type
                        case "map"
                            obj.checkMap(node,item);
                        case {"table","seq"}
                            obj.checkSequence(node,item);
                        otherwise
                            obj.checkValue(node,item);
                    end
                else
                    switch item.type
                        case "map"
                            obj.makeMap(node,item);
                        case {"table","seq"}
                            obj.makeSequence(node,item);
                        otherwise
                            obj.makeValue(node,item);
                    end
                end
            end

            % apply actions
            % FIXME
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski

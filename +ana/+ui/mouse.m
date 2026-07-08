classdef mouse < handle
    %ANA.UI.MOUSE       Mouse dispatcher.
    %
    % Usage:
    %   ana.ui.mouse(handle,name,options...)
    %
    %     handle      Graphics handle (such as a uiaxes).
    %     name        Callback name (ButtonDown,ButtonUp,ButtonMotion, or, ScrollWheel)
    %     callback    The callback function @(src,ev) ...
    %

    properties(Hidden,SetAccess=private)
        Figure (1,1) matlab.ui.Figure
        Callbacks (1,:) struct = struct(...
            'handle', {}, ...
            'name', {}, ...
            'callback', {}, ...
            'auto', {})
    end

    methods (Hidden)
        function dispatch(obj, src, event)
            object = hittest(obj.Figure);
            if isempty(object)
                return
            end
            handle = object;

            % find object, that wants to receive callbacks
            idx = [];
            try
                while isempty(idx)
                    idx = find([obj.Callbacks(:).handle] == handle);
                    if isempty(idx)
                        if isprop(handle,"Parent")
                            handle = handle.Parent;
                        else
                            return
                        end
                    end
                end
            catch
            end
            if isempty(idx)
                return
            end

            % select callback by event name
            cur = find([obj.Callbacks(idx).name] == event.EventName);
            if isempty(cur) 
                return
            elseif numel(cur) > 1
                %FIXME emit warning 
                return
            end
            idx = idx(cur);

            % run callback (with the object, that was hit as source!)
            try 
                obj.Callbacks(idx).callback(src, event, object);
            catch ME
                if obj.Callbacks(idx).auto
                    obj.Callbacks(idx) = []; % remove offending callback
                else
                    warning('Callback execution failed: %s', ME.message);
                end
            end
        end
    end

    methods
        function obj = mouse(handle, name, callback, options)
            %MOUSE      Create or modify an instance of this class.
            %
            arguments
                handle (1,1)
                name (1,1) string
                callback (1,1) % FIXME check for function
                options.Auto (1,1) {mustBeNumericOrLogical} = true
            end
            %TODO: avoid duplicate registration

            fig = ancestor(handle,'figure');
            if isempty(fig)
                error("Could not find parent figure handle.")
            end

            field = "Window"+name+"Fcn";
            assert(isprop(fig, field), "Invalid callback name (neither ButtonDown,ButtonUp,ButtonMotion, nor, ScrollWheel).");

            if isa(fig.UserData, "ana.ui.mouse")
                try delete(obj); catch, end
                obj = fig.UserData;
            else
                obj.Figure = fig;
                fig.UserData = obj;
            end
            if isempty(fig.(field))
                %TODO: possibly need to check, if a "foreign" callback was installed
                fig.(field) = @(src,ev) obj.dispatch(src,ev);
            end
            
            switch (name)
                case "ButtonDown"
                    name = "WindowMousePress";
                case "ButtonUp"
                    name = "WindowMouseRelease";
                case "ButtonMotion"
                    name = "WindowMouseMotion";
                case "ScrollWheel"
                    name = "WindowScrollWheel";
            end

            obj.Callbacks(end+1) = struct(...
                handle=handle,...
                name=name,...
                callback=callback,...
                auto=options.Auto);
        end

        function clear(obj)
            %CLEAR    Remove all callbacks
            obj.Callbacks = struct('handle', {}, 'name', {}, 'callback', {}, 'auto', {});
        end        

        function delete(obj)
            %DELETE Clean up dispatcher

            if ~ishandle(obj.Figure)
                return
            end

            % Clear UserData if this dispatcher owns it
            if isa(obj.Figure.UserData, 'ana.ui.mouse') && ...
                    obj.Figure.UserData == obj
                obj.Figure.UserData = [];
            else
                return
            end

            % Remove figure callbacks
            events = ["ButtonDown", "ButtonUp", "ButtonMotion", "ScrollWheel"];
            for ev = events
                field = "Window" + ev + "Fcn";
                obj.Figure.(field) = [];
            end
        end
    end

    methods (Static)
        function unregister(handle)
            %UNREGISTER     Remove all callbacks for a handle

            fig = ancestor(handle,'figure');
            if isempty(fig)
                return
            end

            obj = fig.UserData;
            if ~isa(obj, 'ana.ui.mouse')
                return
            end
            
            obj.Callbacks = obj.Callbacks([obj.Callbacks(:).handle] ~= handle);
        end
    end
end

classdef input < handle
    %ANA.UI.INPUT       Mouse and keyboard input dispatcher
    %
    % Usage:
    %   input = ana.ui.input(handle,event,callback,options...);
    %
    %     handle      Graphics handle (such as a uiaxes).
    %     event       Event type (e.g. "MousePress")
    %     callback    The callback function.
    %                 Note: the callback is passed three arguments:
    %                 - the "source" of the event,
    %                 - the "event" structure, and,
    %                 - the ana.ui.input object handling the callbacks.
    %
    % Event types:
    %   MouseMotion         The mouse pointer was moved (while a button was pressed, see Hover below).
    %   MousePress          Mouse button is pressed.
    %   MouseButton         Mouse button is released.
    %   ScrollWheel         Mouse scroll wheel.
    %   KeyPress            A key is pressed.
    %   KeyRelease          A key is released.
    %
    % Options:
    %   Auto                Ignore and cleanup failed callbacks immediately.
    %   Hover               The "MouseMotion" event is also handled when no button is pressed.
    %

    properties (SetAccess = protected)
        Button = []             % Mouse button currently pressed.
        Hit = []                % Object under the mouse pointer.
                                % Note: this is only updated when a mouse event occurs.

        % Modifier keys:
        Shift    (1,1) logical = false
        Control  (1,1) logical = false
        Alt      (1,1) logical = false
    end

    properties (Hidden, SetAccess = private)
        Figure (1,1) matlab.ui.Figure           % The figure we're dispatching input events for.
        Callbacks (1,:) struct = struct(...     % List of callbacks.
            handle={}, ...
            event={}, ...
            callback={},...
            options={})
        Hover = false                           % Handle mouse motion without button pressed.
    end

    methods (Hidden)
        function dispatch(obj, src, event)
            %DISPATCH       The callback handler (installed in the parent figure).
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
        function obj = input(handle, event, callback, options)
            %INPUT          Create or modify an instance of this class.
            %
            arguments
                handle (1,1) matlab.graphics.Graphics
                event (1,1) string
                callback (1,1) function_handle
                options.Auto (1,1) {mustBeNumericOrLogical} = true
                options.Hover (1,1) {mustBeNumericOrLogical} = false
            end
            %TODO: avoid duplicate registration

            % find associated figure window
            fig = ancestor(handle,'figure');
            if isempty(fig)
                error("Could not find parent figure handle.")
            end

            fcn = "Window"+event+"Fcn";
            switch (event)
                case "MousePress"
                    fcn = "WindowButtonDownFcn";
                case "MouseRelease"
                    fcn = "WindowButtonUpFcn";
                case "MouseMotion"
                    fcn = "WindowButtonMotionFcn";
            end

            assert(isprop(fig, fcn), "Invalid callback name, figure has no property ""%s"".", fcn);

            % use or install "us"
            if isa(fig.UserData, "ana.ui.mouse")
                obj = fig.UserData;
            else
                obj.Figure = fig;
                fig.UserData = obj;
            end
            if isempty(fig.(fcn))
                %TODO: possibly need to check, if a "foreign" callback was installed
                fig.(fcn) = @(src,ev) obj.dispatch(src,ev);
            end
            
            % book keeping
            obj.Hover = obj.Hover | options.Hover;
            obj.Callbacks(end+1) = struct(...
                handle=handle,...
                event="Window"+event,...
                callback=callback,...
                options = struct( ...
                    Auto=options.Auto,...
                    Hover=options.Hover));
        end

        function clear(obj)
            %CLEAR    Remove all callbacks
            obj.Callbacks = struct('handle', {}, 'event', {}, 'callback', {}, 'options', {});
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

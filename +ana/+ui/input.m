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
    %   Replace             Flag, if existing callback should be replaced.
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
            auto={},...
            hover={})
        Hover = false                           % Handle mouse motion without button pressed.
    end

    methods (Hidden)
        function dispatchMouseMotion(obj, src, event)
            if isempty(obj.Button) && ~obj.Hover
                return
            end

            obj.Hit = hittest(obj.Figure);
            if isempty(obj.Hit)
                return
            end
            
            obj.dispatchMouse(src,event);
        end

        function dispatchMousePress(obj, src, event)
            obj.Button = event.Source.SelectionType;

            obj.Hit = hittest(obj.Figure);
            if isempty(obj.Hit)
                return
            end

            obj.dispatchMouse(src,event);
        end

        function dispatchMouseRelease(obj, src, event)
            obj.Button = [];

            obj.dispatchMouse(src,event);
        end

        function dispatchMouseScroll(obj, src, event)
            obj.Hit = hittest(obj.Figure);
            if isempty(obj.Hit)
                return
            end

            obj.dispatchMouse(src,event);
        end

        function dispatchKeyPress(obj, src, event)
            switch event.Key
                case 'shift'
                    obj.Shift = true;
                case 'control'
                    obj.Control = true;
                case 'alt'
                    obj.Alt = true;
                % case 'escape'
                otherwise
                    idx = find([obj.Callbacks(:).event] == event.EventName);
                    for i = idx
                        obj.Callbacks(idx).callback(src,event,obj);
                    end
            end
        end

        function dispatchKeyRelease(obj, src, event)
            switch event.Key
                case 'shift'
                    obj.Shift = false;
                case 'control'
                    obj.Control = false;
                case 'alt'
                    obj.Alt = false;
                % case 'escape'
                otherwise
                    idx = find([obj.Callbacks(:).event] == event.EventName);
                    for i = idx
                        obj.Callbacks(idx).callback(src,event,obj);
                    end
            end
        end

        function dispatchMouse(obj, src, event)
            handle = obj.Hit;
            if isempty(handle)
                return
            end

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
            cur = find([obj.Callbacks(idx).event] == event.EventName);
            if isempty(cur) 
                return
            elseif numel(cur) > 1
                warning("multiple callbacks for the same event registered")
                cur = cur(1);
            end
            idx = idx(cur);

            % run callback
            try 
                obj.Callbacks(idx).callback(src, event, obj);
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
                options.Replace (1,1) {mustBeNumericOrLogical} = false
            end

            % find associated figure window, install input handler
            fig = ancestor(handle,'figure');
            if isempty(fig)
                error("Could not find parent figure handle.")
            end
            
            if isa(fig.UserData, "ana.ui.input")
                obj = fig.UserData;
            else
                obj.Figure = fig;
                fig.UserData = obj;

                fig.WindowButtonDownFcn = @obj.dispatchMousePress;
                fig.WindowButtonUpFcn = @obj.dispatchMouseRelease;
                fig.WindowButtonMotionFcn = @obj.dispatchMouseMotion;
                fig.WindowScrollWheelFcn = @obj.dispatchMouseScroll;

                fig.WindowKeyPressFcn = @obj.dispatchKeyPress;
                fig.WindowKeyReleaseFcn = @obj.dispatchKeyRelease;
            end

            % sanity check
            idx = find([obj.Callbacks(:).handle] == handle);
            if ~isempty(idx)
                cur = find([obj.Callbacks(idx).event] == "Window"+event);
                if ~isempty(cur) 
                    if options.Replace
                        idx = idx(cur);
                        obj.Callbacks(idx) = [];
                    else
                        error("Callback for '%s' for given handle already installed.", event);
                    end
                end
            end

            % book keeping
            obj.Hover = obj.Hover | options.Hover;
            obj.Callbacks(end+1) = struct(...
                handle=handle,...
                event="Window"+event,...
                callback=callback,...
                auto=options.Auto,...
                hover=options.Hover);
        end

        function clear(obj)
            %CLEAR    Remove all callbacks
            obj.Callbacks = struct(handle={},event={},callback={},auto={},hover={});
            obj.Hover = false;
        end        

        function delete(obj)
            %DELETE Clean up dispatcher
            if ~ishandle(obj.Figure)
                return
            end

            % clear UserData if this dispatcher owns it
            if isa(obj.Figure.UserData, 'ana.ui.mouse') && ...
                    obj.Figure.UserData == obj
                obj.Figure.UserData = [];
            else
                return
            end

            % remove figure callbacks
            events = ["ButtonDown", "ButtonUp", "ButtonMotion", "ScrollWheel","KeyPress","KeyRelease"];
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
            obj.Hover = any([obj.Callbacks(:).hover]);
        end
    end
end

classdef mouse < handle & matlab.mixin.indexing.RedefinesParen & matlab.mixin.Scalar
    %ANA.UI.MOUSE       Mouse dispatcher.
    %
    % FIXME

    properties(Hidden,SetAccess=private)
        Callbacks = struct(uiitem={}, callback={}, auto={})
    end

    methods (Access=protected)
        function varargout = parenReference(obj, indexOp)
            % Window*Fcn functor
            for i = 1:numel(obj.Callbacks)
                if hittest(obj.Callbacks(i).uiitem)
                    % ...
                end
            end
        end
    end

    methods
        function obj = mouse(uiitem, callback, options)
            %DISPATCH           FIXME
            %
            arguments
                uiitem (1,1)
                callback (1,1) string
                options.Callback (1,1)
            end

            fig = ancestor(uiitem,'figure');
            if isa(fig.("Window"+callback+"Fcn"), "ana.ui.dispatch")
                obj = fig.("Window"+callback+"Fcn");
            else
                fig.("Window"+callback+"Fcn") = obj;
            end

            % ...
        end
    end
end
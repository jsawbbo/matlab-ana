classdef singleton 
    %ANA.TOOL.SINGLETON    Named singleton objects.
    %
    %   This static class provides tools for creating and managing named,
    %   reference counted singletons.
    %
    %Example:
    %
    %   classdef mysignleton < handle
    %       methods
    %           function obj = mysignleton()
    %               [obj,exists] = ana.tool.singleton.instatiate(obj,'mysingleton');
    %               if ~exists
    %                   % initialize singleton...
    %               end
    %           end
    %       end
    %   end
    %
    %See also: ana.config
    
    methods(Static)
        function [h,exists] = instantiate(obj,name)
            %INSTANTIATE   Instantiate a singleton or increase reference count.
            [h,exists] = ana.tool.singleton.update(1,obj,name);
        end

        function release(obj)
            %RELEASE    Release singleton.
            %
            %Note:
            %   When using INSTANTIATE, this function is automatically added as
            %   listener for the ObjectBeingDestroyed event and, therefore, must
            %   not be called. It is here for reference only.
            ana.tool.singleton.update(-1,obj);
        end
    end

    methods(Static,Hidden)
        function [h,exists] = update(ref,obj,name)
            persistent db
            if ~isa(db,'dictionary')
                db = dictionary;
            end

            h = obj;
            exists = false;
            
            if ref > 0
                % set or increment reference count
                if db.isConfigured() && db.isKey(name) && isvalid(db(name).obj.Handle)
                    db(name).ref = db(name).ref + 1;
                    h = db(name).obj.Handle;
                    exists = true;
                else
                    db(name) = struct( ...
                        ref = 1, ...
                        obj = matlab.lang.WeakReference(obj));

                    addlistener(obj,'ObjectBeingDestroyed',@(~,~) ana.tool.singleton.update(-1,obj));
                end
            else
                % find object
                name = [];
                fn = keys(db,'cell');
                for i = 1:numel(fn)
                    if db(fn{i}).obj.Handle == obj
                        name = fn{i};
                        break
                    end
                end

                if isempty(name)
                    % ignored
                    return
                end

                % decrease reference count
                db(name).ref = db(name).ref - 1;

                % destroy
                if db(name).ref <= 0
                    h = [];
                    exists = false;
                    db = remove(db, name);
                end
            end
        end
    end
end


function info(fmt,varargin)
    %ana.log.info      Log informational message.
    %
    % See also: ana.log.level, ana.log.message, ana.log.to

    ana.log.message('info',fmt,varargin{:});
end

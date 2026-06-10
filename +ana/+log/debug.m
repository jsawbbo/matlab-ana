function debug(fmt,varargin)
    %ana.log.debug      Log debug message.
    %
    % See also: ana.log.level, ana.log.message, ana.log.to

    ana.log.message('error',fmt,varargin{:});
end

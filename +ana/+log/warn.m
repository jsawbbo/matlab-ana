function warn(fmt,varargin)
    %ana.log.error      Log warning message.
    %
    % See also: ana.log.level, ana.log.message, ana.log.to
    
    ana.log.message('warn',fmt,varargin{:});
end

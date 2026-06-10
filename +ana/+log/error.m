function error(fmt,varargin)
    %ana.log.error      Log error message.
    %
    % See also: ana.log.level, ana.log.message, ana.log.to
    
    ana.log.message('error',fmt,varargin{:});
end

function notice(fmt,varargin)
    %ana.log.notice      Log a notice.
    %
    % See also: ana.log.level, ana.log.message, ana.log.to
    
    ana.log.message('notice',fmt,varargin{:});
end

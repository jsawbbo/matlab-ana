function bootstrap()
    %ana.bootstrap     Discover and prepare ANA's runtime environment.
    %
    % FIXME
    %

    persistent initialized

    if isempty(initialized)
        ana.config.scheme.scan();

        initialized = true;
    end
end
function bootstrap()
    %ana.bootstrap     Discover and prepare ANA's runtime environment.
    %
    % This function is used internally (but can also be used manually) for scanning
    % the environment of ANA (such as, for example, detecting schemes).
    %

    persistent initialized

    if isempty(initialized)
        tic();

        ana.config.scheme.scan();
        initialized = true;

        t = toc();
        if t > 1
            warning("ana:AuthorWarning:Duration", "Author warning: bootstrap took too long.");
        end
    end
end

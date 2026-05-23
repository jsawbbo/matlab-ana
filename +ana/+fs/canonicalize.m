function s = canonicalize(s)
    %ANA.FS.CANONICALIZE       Canonicalize a path.
    %
    % ANA internally only uses POSIX notation (ie. a forward slash) to separate path elements.
    %
    s = regexprep(s, '[\\/]+', '/');
end

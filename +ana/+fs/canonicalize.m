function s = canonicalize(s)
    %ana.fs.canonicalize       Canonicalize a path (string representation).
    %
    % ANA internally only uses POSIX notation (ie. a forward slash) to separate 
    % path elements (note, that, Windows understands forward slashes as path
    % separators).
    %
    s = regexprep(s, '[\\/]+', '/');
end

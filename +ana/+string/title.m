function str = title(str)
    %ana.string.title       Make string title-case.
    %

    arguments
        str (1,1) string
    end

    words = split(lower(str));
    words = upper(extractBefore(words, 2)) + extractAfter(words, 1);
    str = join(words, " ");
end
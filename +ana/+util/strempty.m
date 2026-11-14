function res = strempty(s)
    %ana.util.strempty      Check if string (or char array) is empty.
    %
    arguments
        s string
    end

    res = isempty(s) || strlength(s) == 0;
end

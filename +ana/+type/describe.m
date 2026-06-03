function txt = describe(v)
    %ana.type.describe      Get a string description of a value.
    %
    % This method returns the equivalent of Matlab's display style for
    % struct entries as a string.
    %
    % See also: e.g. ana.type.dict
    %

    if isscalar(v) && isnumeric(v)
        txt = num2str(v);
    elseif ischar(v)
        txt = sprintf('''%s''', v);
    elseif isstring(v) && isscalar(v)
        txt = sprintf('"%s"', v);
    else
        sz = size(v);

        dims = join(string(sz), '×');

        txt = sprintf('[%s %s]', ...
            dims, class(v));
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
%
% Development assistance:
%   ChatGPT (OpenAI, GPT-5.5)

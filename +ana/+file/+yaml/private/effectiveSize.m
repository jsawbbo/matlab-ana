function n = effectiveSize(A)

% Return the "real" number of dimensions of A, i.e., return 0 or 1, if it is a
% scalar or vector.

if isscalar(A)
    n = 0;
elseif isvector(A)
    n = 1;
else
    n = ndims(A);
end

end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% Copyright (c) 2022 Martin Koch
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Martin Koch
%
% Originally licensed under MIT License, see accompanying file in the parent folder.

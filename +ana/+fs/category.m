classdef category
    %ana.fs.category    Classification of storage locations.
    %
    % Categories describe the characteristics of storage locations,
    % particularly with respect to availability and access.
    %
    % A location is represented by a pair:
    %
    %   location    Filesystem path or resource location.
    %   category    Storage category (see enumeration below).
    %
    % The category is stored as a string in YAML configuration files.
    %
    % See also: ana.fs.alias
    %
    enumeration
        local       % Storage that is permanently connected to the host (usually the default).
        network     % Storage that is provided via network to the host (such as Windows network drives or NTFS).
        external    % External storage device (such as a pluggable hard-disk).
        remote      % Remote storage (such as cloud services).
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski

function [total,free] = memory()
    %ANA.OS.MEMORY Get total and available physical RAM.
    %
    %Syntax:
    %   [total,free] = ana.system.memory
    %
    %Note:
    %   This function was only tested on Linux and Windows. 
    %
    try
        [~, systemview] = memory;
        total = systemview.PhysicalMemory.Total;
        free = systemview.PhysicalMemory.Available;
    catch
        try
            [status,cmdout] = system("free -b");
            if status ~= 0
                error("command 'free -b' failed")
            end
            cmdout = strsplit(cmdout);
            total = str2double(cmdout{9});
            used = str2double(cmdout{10});
            free = total - used;
        catch
            warning("could not determine physical memory size");
            total = 4*1024*1024;
            free = total;
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later


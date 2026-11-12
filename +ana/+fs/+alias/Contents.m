% File-system aliases
%
% ANA uses aliases of the form "{alias}" to avoid embedding machine-specific
% absolute paths in configuration files. For example, a file within a project
% directory may be referenced as "{project}/data/file.data".
%
% An alias may represent a single location or an ordered search path.
%
% Standard aliases:
%
%    {storage}      A configurable search path for central data storage.
%                   Locations may reside on local disks, network file systems,
%                   external drives, or remote services.
%
%                   The search path is defined in the general configuration.
%                   Using this alias is optional.
%
%    {project}      The directory containing the loaded project configuration
%                   file. References to files within this directory remain
%                   valid when the project directory is moved.
%
%    {scratch}      A project-specific directory for transient analysis data,
%                   located below the scratch directory defined in the general
%                   configuration.
%
%                   The directory is reused when the project is reopened,
%                   allowing existing working data to be recovered after
%                   an ANA or MATLAB crash.
%
%                   Note: Retention depends on the underlying storage and its
%                   cleanup policy; scratch is not permanent project storage.
%
% Projects may define additional aliases. Alias definitions may reference
% other aliases; for example, an alias "{results}" could be defined as
% "{project}/results".
%
% Commands:
%
% <a href="matlab:help ana.fs.alias.find">find</a>         - Find an existing file, resolving aliases as needed.
% <a href="matlab:help ana.fs.alias.expand">expand</a>     - Expand aliases into candidate paths without checking file existence.
% <a href="matlab:help ana.fs.alias.collapse">collapse</a> - Replace a matching path prefix with an alias.
%
% Configuration nodes.
%
% FIXME
%
% Details
%
% Note: Chained indexing may not be fully supported, particularly for methods
% returning multiple output arguments.
%
% Instead of
%   [a,b] = obj.key.method(...);
% or 
%   [a,b] = obj(1).method(...);
%
% retrieve the node first:
%   node = obj.key;
% or 
%   node = obj(1);
% followed by
%   [a,b] = node.method(...);
%
% This avoids limitations of the custom indexing implementation.
%
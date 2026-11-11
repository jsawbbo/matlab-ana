classdef sql < handle
    %ANA.DB.SQL     Common SQL methods.
    %   

    %% PROTECTED
    methods(Access=protected)
        function query = statement(obj, query, varargin)
            %STATEMENT Safely assemble a SQL statement by replacing ? with escaped values
            %
            % Input:
            %   query - SQL query string with ? placeholders
            %   varargin - Values to replace ? placeholders (in order)
            %
            % Output:
            %   query - Assembled SQL string with values properly escaped
            %
            % Example:
            %   query = obj.statement("SELECT * FROM file_cache WHERE id = ?", "video_123")
            %   % Returns: "SELECT * FROM file_cache WHERE id = 'video_123'"
            %
            
            %TODO:
            %       obj.statement( ...
            %           "SELECT '?' AS marker, name FROM files WHERE id = ?", ...
            %           42);
            % is not parsed correctly (chatGTP)


            % If no parameters, return as-is
            if isempty(varargin)
                query = string(query);
                return;
            end
            
            % Convert to string
            queryStr = string(query);
            
            % Validate placeholder count
            placeholderCount = count(queryStr, '?');
            numParams = length(varargin);
            
            if placeholderCount ~= numParams
                error('Parameter count mismatch: %d placeholders but %d parameters provided', ...
                    placeholderCount, numParams);
            end
            
            % Replace placeholders
            
            % Split the query by '?'
            parts = split(queryStr, '?');

            % Rebuild with escaped values
            queryStr = parts{1};
            for i = 1:numParams
                escapedValue = obj.escape(varargin{i});
                queryStr = queryStr + escapedValue + parts{i+1};
            end

            query = queryStr;
        end
        
        function escaped = escape(obj, value)
            %ESCAPE     Escape a value for safe SQL insertion.
            %
            
            %TODO:
            % - A numeric array containing NaN or Inf bypasses the scalar-specific NULL conversion.
            % - Logical arrays produce string arrays rather than parenthesized SQL lists.
            % - Multidimensional numeric arrays are not reliably formatted as a single SQL expression.
            % - Missing string values and undefined categorical values aren't explicitly handled.
            % (chatGPT)

            % Handle empty/NULL
            if isempty(value) && ~ischar(value)
                escaped = 'NULL';
                return;
            end
            
            % Handle different types
            if ischar(value) || isstring(value)
                % String: escape single quotes by doubling them
                str = string(value);
                str = strrep(str, "'", "''");
                escaped = "'" + str + "'";
                
            elseif isnumeric(value)
                % Numeric: direct conversion
                if isscalar(value)
                    if isnan(value) || isinf(value)
                        escaped = 'NULL';
                    else
                        escaped = string(value);
                    end
                else
                    % Array: format as comma-separated list
                    escaped = "(" + join(string(value), ", ") + ")";
                end
                
            elseif islogical(value)
                % Logical: convert to 1/0
                escaped = string(double(value));
                
            elseif isdatetime(value)
                % Datetime: format as SQLite datetime
                escaped = "'" + datestr(value, 'yyyy-mm-dd HH:MM:SS') + "'";
                
            elseif isduration(value)
                % Duration: convert to seconds
                escaped = string(seconds(value));
                
            elseif iscategorical(value)
                % Categorical: convert to string and escape
                str = string(value);
                str = strrep(str, "'", "''");
                escaped = "'" + str + "'";
                
            elseif iscell(value)
                % Cell array: escape each element
                if isscalar(value)
                    escaped = obj.escape(value{1});
                else
                    escaped = "(";
                    for i = 1:length(value)
                        if i > 1
                            escaped = escaped + ", ";
                        end
                        escaped = escaped + obj.escape(value{i});
                    end
                    escaped = escaped + ")";
                end
                
            else
                % Fallback: convert to string and escape
                str = string(value);
                str = strrep(str, "'", "''");
                escaped = "'" + str + "'";
            end
            
            escaped = string(escaped);
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
%
% Development assistance:
%   DeepSeek (深度求索)

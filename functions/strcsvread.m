function table = strcsvread(varargin)
% Read a CSV file containing non-numeric fields (strings) and
% return a cell array. Numbers are converted to double and, if contiguous,
% can be easily converted to arrays with cell2mat. The remaining
% are left as strings.
%
% Usage:
% table = strcsvread(filename,delimiter,end-of-line)
% 
% - filename = CSV file to be read
% - delim    = Field separator.  Default = ','
% - eol      = Record separator. Default = '\n'
%
% _____________________________________
% Anderson M. Winkler
% Yale University / Institute of Living
% Oct/2010
% http://brainder.org

% Accept the inputs
narginchk(1,3);
filename = varargin{1};
if nargin == 3
    delimiter = sprintf(varargin{2});
    eolmark   = sprintf(varargin{3});
elseif nargin == 2
    delimiter = sprintf(varargin{2});
    eolmark   = sprintf('\n');
elseif nargin == 1
    delimiter = sprintf(',');
    eolmark   = sprintf('\n');
end

% Read the whole CSV file as a single stream of data
fid = fopen(filename,'r');
stream = fread(fid,Inf,'uint8=>char')';
fclose(fid);

% Add an EOL at the end of the stream if not existing
% This prevents an error later
if stream(end) ~= eolmark
    stream = [stream eolmark];
end

% Identify where the EOLs and delimiters are
eolpos = find(stream == eolmark);
delpos = find(stream == delimiter);

% Allocate a provisory table (cell array) with a size estimated from
% the number of delimiters and EOLs found. It grows later if needed
table = cell(numel(eolpos),floor(numel(delpos)/numel(eolpos)));

% Loop over each EOL get the content between each
eolpos = [0 eolpos];
for r = 1:numel(eolpos)-1
    rowtmp = stream(eolpos(r)+1 : eolpos(r+1)-1);
    
    % Loop over each delimiter per row and get the content between
    delpos = find(rowtmp == delimiter);
    delpos = [0 delpos numel(rowtmp)+1]; %#ok
    for c = 1:numel(delpos)-1
        
        % Store in the cell array of results
        table{r,c} = rowtmp(delpos(c)+1 : delpos(c+1)-1);
        
        % If the content can be converted to number, do so
        % and deal with the NaN case
        if isempty(deblank(table{r,c})) || strcmpi(strtrim(table(r,c)),'NaN')
            table{r,c} = NaN;
        end
        testnum = str2double(table{r,c});
        if ~ isnan(testnum)
            table{r,c} = testnum;
        end
    end
end

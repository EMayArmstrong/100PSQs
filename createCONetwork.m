function G = createCONetwork(COTable,weightMode)
%
% createCONetwork                           Copyright 2020, The MathWorks, Inc.
%
% Create co-occurence network from co-occuernce table
%
% Syntax: G = createCONetwork(collTable [, weightMode])
%
% Input; 
%   collTable [table] Co-occurence table (output of createCOTable.m)
%     .Word           Keyword
%　   .Counts         Occurence of the keyword
%     .COWord         Co-occurence word
%     .COCount        Occurrence of the co-occurrence word
%     .COCountAll     Occurrence of the co-occurrence word in the document
%     .T              T-value
%     .MI             MI-value
%
%  weightMode [string] The weight to be added to each edge.  Default is 'none'
%
%    'none'  -> Equal weight
%    'count' -> Frequency of the co-occurence
%    'T'     -> T-value
%    'MI'    -> MI-value
%

%% Check input parameters

% Default is "equal weight" if the argument "weightMode" is not provided.
if nargin < 2
  weightMode = 'none';
end

% determine the weight assigned to each edge according to "weightMode"
switch weightMode
  case 'none'
    edgeWeight = ones(height(COTable),1);
  case 'count'
    edgeWeight = COTable.Coll_Count;
  case 'T'
    edgeWeight = COTable.T;
  case 'MI'
    edgeWeight = COTable.MI;
end

%% Create Graph object

% Extract the co-occurrence words and their frequencies wihtout duplication. 
allWords  = [COTable.Word;   COTable.COWord];
allCounts = [COTable.Counts; COTable.COCountAll];

[uniqueWords, iUniqueWords] = unique(allWords);
countUniqueWords = allCounts(iUniqueWords);

% Create the node table
nodeTable = table(uniqueWords,countUniqueWords,'VariableNames',{'Name','Counts'});

% Create the directed graph object with given edge weight.
G = digraph(COTable.Word,COTable.COWord,edgeWeight,nodeTable);

end
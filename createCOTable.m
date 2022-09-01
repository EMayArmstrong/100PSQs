function COTable = createCOTable(doc,span, nKeywords, nCO, mode)
%              
% createCOTable                              Copyright 2020, The MathWorks, Inc.
%                      
% Create a co-occurence table for given keywords.  This function finds top N
% most frequently occurring words (co-occurrence words) and their frequency
% within given sapn for given keywords. It also calculates T-value and MI-value
% for each co-occcurence words. [Note: Text Analytics Toolbox is required.]
%  
%
%
% Syntax: COTable = createCOTable(doc, span, nKeyWords, nCO, mode)
%
% Input:
%   doc       [tokenizedDocument] 
%   span      [double] Range in which co-occurence of words are counted
%
%   nKeyWords [double|string array] 
%     (double) Number of keywords for which co-occurence words are sought.
%              Tne top nKeyWords words in the doc are set as keywords.
% 
%     (string array) An array of keywords
%
%   nCO [double] Number of co-occurence words 
%  mode [string] Position of the keyword in the span
%                 'forward' -> The keyword is at the end of the span
%                 'center'  -> The keyword is in the middle of the span
%                 'backword'-> The keyword is at the beginning of the span
%
% Output: 
%   colTable [ nKeyWords*nCO x 10 table] Co-occurence table.
% 
%   colTable.Word        Keyword
%   colTable.Count       Number of occurence of the Keyword in the document
%   colTable.COWord      Co-occurenece word
%   colTable.COCount     Number of occurrence of the co-occurence word within
%                        the span
%   colTable.COCountAll  Number of occurrence of the co-occurence word in the
%                        document
%   colTable.T           T-Value of the co-occurence word
%   colTable.MI          MI-Value of the co-occuence word
%

%% Check of the argumetns and selection of the keywords

% Check of argument.  
if nargin < 5
    mode = 'center';
end

% Determine keywords
bows = bagOfWords(doc);

if isnumeric(nKeywords)
    wordsTable = topkwords(bows, nKeywords);

elseif isstring(nKeywords)
    % When the nKeywords is a string array, select the elements (i.e., keywords)
    % that also exist in the document.
    tmp_index = ismember(bows.Vocabulary, nKeywords);
    tmp_word  = bows.Vocabulary(tmp_index)';
    tmp_count = bows.Counts(tmp_index)';
  
    wordsTable = table(tmp_word, tmp_count,'VariableNames',{'Word','Count'});
    nKeywords = numel(tmp_word);
    
else
    error('The argument "nWords" must be a scalar or a string array\n');
end

% Determine the location of the keyword (xIdx) in the N-gram according to the
% input parameter 'mode'
switch mode
    case 'forward'
        xIdx = span;
    case 'center'
        xIdx = ceil((span-1)/2)+1;
    case 'backward'
        xIdx = 1;
    otherwise
        error('The parameter ''mode'' must be ''forward'',''center'', or ''backward''');
end

%% Prepare COTable 

collVarNames = ["Word","Counts", "COWord","COCount","COCountAll","T","MI"];
collVarTypes = ["string","double", "string","double","double","double","double"];

COTable = table('size',[nKeywords*nCO numel(collVarNames)],...
    'VariableTypes',collVarTypes,...
    'VariableNames',collVarNames);

%% Prepare a list of words 
% Create N-gram of which length is specified by "span".  

bong = bagOfNgrams(doc,'NgramLengths',span);
ngrams = bong.Ngrams;
nWords = size(bong.Vocabulary,2);

%% Populate the co-occurence table 
% Populate the co-occurence table for each raw. 

for kk = 1:nKeywords
    % For each keyword, select the N-gram that has the keyword at the
    % position xIdx, and put the words but the keyword into a bagOfWords. 
    
    idxSelectedNgrams = strcmp(ngrams(:,xIdx),wordsTable.Word(kk));
    selectedNgrams = ngrams(idxSelectedNgrams,:);
  
    wordsInNgrams = selectedNgrams(:)';
    
    idxAllCoWords = wordsInNgrams ~= wordsTable.Word(kk);
    allCoWords = wordsInNgrams(idxAllCoWords);
  
    boacw = bagOfWords(allCoWords);
  
    % Choose nCO-most-frequently-occured co-occurence words, put the words and
    % thier occurrence into the co-occurence table
    coWords = topkwords(boacw,nCO);
  
    rowRange = (kk-1)*nCO+(1:nCO);
    COTable{rowRange, 1} = wordsTable.Word(kk);
    COTable{rowRange, 2} = wordsTable.Count(kk);
    COTable{rowRange, 3} = coWords.Word;
    COTable{rowRange, 4} = coWords.Count;
end

%% Computation of T-value and MI-value

% Find the occurence of the co-occurence words in the document.
[~, tmp_i] = ismember(COTable.COWord, bows.Vocabulary);

COCountAll = sum(bows.Counts(:,tmp_i));
COTable.COCountAll = COCountAll(:);

% Calculate T-Value

expectationT = COTable.COCount./nWords.*COTable.Counts*(span-1);

COTable.T = (COTable.COCount-expectationT)./sqrt(COTable.COCount);

% Calculate MI-Value

expectationMI = COTable.COCountAll./nWords;

COTable.MI = log2(COTable.COCount./expectationMI);

end



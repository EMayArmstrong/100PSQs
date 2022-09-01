% analysis of 100 plant science questions long list

%% set up file paths
% update this paths so Matlab can find the required files on your computer
LocalPath = '/Users/vg21639/Documents/MATLAB/';

WhereIsMyRawData = [LocalPath,'PSQs'];
WhereIsMyMatlabCode = [LocalPath,'PSQs/matlabcode'];
addpath(WhereIsMyRawData)
addpath(WhereIsMyMatlabCode)

% change working directory to location of code
cd(WhereIsMyMatlabCode)
% path to ficlele exchange functions createCONetwork.m, createCOTable.m in
% directory TextAnalysisGraph
addpath([LocalPath,'/MatlabFileExchange/TextAnalysisGraph'])

%% Import raw data 
% import category, question and frequency as a table
% each question is contained in a single string
PSQLongList = AllSubQs("final.xlsx", "Sheet1", [1, 101]);

%% split data by question category - only 1 category: all submitted
% A= specified region - see sheet name
PSQAll = PSQLongList.Ques; 
PSQCatA = PSQLongList.Ques(PSQLongList.Category == "A");


%% Pre-process data
% split into words removing 2 letter words and any
% words longer than 15 letters
% function "preprocessTextData" also processes data to extract separate words and removes "stop" words 
% to see list of stop words type following into command window: words = stopWords; reshape(words,[25 9])

% set minimum and maximum word length
MinWordLength = 3; % minimum word length to keep
MaxWordLength = 15; % maximum word length to keep

documentsRemoveLTE2GTE15 = preprocessTextData(PSQAll,MinWordLength,MaxWordLength);

% create list of words that don't want to be included on word cloud
words = ["aka" "climate" "change" "address" "result" "own" "plant" "result" "impact" "perception" "thus" "way" ...
    "big" "issue" "face" "key" "scientist" "question" "work" "next" "good" "science" ...
    "make" "sure" "view" "nuanced" "around" "research" "raise" "ensure" "vary" "goal" "role" ...
    "become" "easy" "small" "new" "things" "well" "why" "off" "due" "per" "part" ...
    "amount" "day" "leave" "try" "two" "accept" "five" "top" "upon" "ever" "easily" "know" "yes" "say" ...
    "anyway" "3000000" "300000" "50100" "down" "datum" "confidentially" "own" "next" "year" "give" "solve" "affect" "smallerscale" "nonmonoculture"];

% use inbuilt function removeWords to remove all the words we don't want from each
% question
documents = removeWords(documentsRemoveLTE2GTE15,words);

% for some reason it has decided to misspell species so correct this
documents = replaceWords(documents,'specie','species');
documents = replaceWords(documents,'fungus','fungi');
%%
% create a special type of data store called bagOfWords whcih contains
% bag.Vocabulary - list of all words to be included in analysis
% bag.NumWords - total number of distinct words extracted
% bag.NumDocuments - number of questions
% bag.Counts - Frequency counts of words corresponding to uniqueWords, specified as a matrix of nonnegative integers. The value counts(i,j) corresponds to the number of times the word uniqueWords(j) appears in the ith document.
bag = bagOfWords(documents);
UniqueWords = sort(bag.Vocabulary'); % alphabetical list of words in bag

% find most frequent individual words
NumTopWords = 50; % set number of words you would like included in the table
tblmostFrequentWords = topkwords(bag,NumTopWords) 
%%
% find words that occur next to one another either in pairs or triples
% (remembering we have removed stop words and our own set of words)
bagWordPairs = bagOfNgrams(documents,'NgramLengths',[2 3]); % sequence of two or three words
% table of top ten word pairs
TopTenPairs = topkngrams(bagWordPairs,10,'NGramLengths',2)
% table of top ten word triples
TopTenTriples = topkngrams(bagWordPairs,10,'NGramLengths',3)


counts = bag.Counts;

%% word cloud
numTopics = 10;
mdl = fitlda(bag,numTopics,'Verbose',0);


figure
tiledlayout(1,1,'TileSpacing','Compact')


for topicIdx = 1
    nexttile(topicIdx)
    wordcloud(mdl,topicIdx);
    title("Topic" + topicIdx)
    wordcloud(mdl,topicIdx,'HighlightColor',[0.4660 0.6740 0.1880],'Color','#000000','shape','oval', 'MaxDisplayWords', [30]);
     
  
     
end

%% network graph: looking for pairs of words in questions
% the functions used here are from file exchange
% nkeywords: the number of keywords, for which the co-occuring words are sought.  
% Here, we selected top 10 most occurring words in the data as keywords.  
% (The function also allows users to define the keywords as a cell array of words.)
% span: length of window in which co-occuring words are sought within each
% question
% nCooc: number of coocuring word for each keyword to find
% mode: where is the key word in the span: forward, backward or center (I
% think center best
nKeywords =7;
span = 3;
nCooc = 3;
mode = 'center';

COTable = createCOTable(documents,span, nKeywords, nCooc, mode)


% output Word: keyword for which co-occurring words are sought
% Counts: occurence of the keyword in the entire document
% COWord: co-occuring word within the span of the keyword
% COCount: occurrence of the COWord within the span of the keyword
% COCountAll: occurence of the COWord in the entire data
% T : T-value
% MI: MI-value

% visualise#
figure
CONetwork = createCONetwork(COTable,'MI')
visualizeCO(CONetwork,'NodeColor',[0.9290 0.6940 0.1250],'FontSize',14,'MarkerSize',30,'EdgeColor',[0.7     0.7     0.7], 'TextColor',[0     0     0],'EdgeWidth',3);

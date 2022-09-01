function documents = preprocessTextData(textData,MinWordLength,MaxWordLength)

if nargin < 2
    MinWordLength = 3;
    MaxWordLength = 15;
end

% Tokenize the text.
documents = tokenizedDocument(textData);

% Lemmatize the words. To improve lemmatization, first use 
% addPartOfSpeechDetails.
documents = addPartOfSpeechDetails(documents);
documents = normalizeWords(documents,'Style','lemma');

% Erase punctuation.
documents = erasePunctuation(documents);

% correct spelling
%documents = correctSpelling(documents);

% Remove a list of stop words.
% Words like "a", "and", "to", and "the" (known as stop words) can add noise to data
% list of all english stop words can be seen by 
% words = stopWords;
% reshape(words,[25 9])
documents = removeStopWords(documents);

% Remove words with fewer characters than min word length, and words or more
% characters than max word length.
documents = removeShortWords(documents,MinWordLength-1);
documents = removeLongWords(documents,MaxWordLength+1);
% correct spelling errors
% documents = correctSpelling(documents);
end
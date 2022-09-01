function Copyof100PSQsLonglistMarch2022CRWS2 = importLongListCatQsFreq(workbookFile, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  COPYOF100PSQSLONGLISTMARCH2022CRWS2 = IMPORTFILE(FILE) reads data
%  from the first worksheet in the Microsoft Excel spreadsheet file
%  named FILE.  Returns the data as a table.
%
%  COPYOF100PSQSLONGLISTMARCH2022CRWS2 = IMPORTFILE(FILE, SHEET) reads
%  from the specified worksheet.
%
%  COPYOF100PSQSLONGLISTMARCH2022CRWS2 = IMPORTFILE(FILE, SHEET,
%  DATALINES) reads from the specified worksheet for the specified row
%  interval(s). Specify DATALINES as a positive scalar integer or a
%  N-by-2 array of positive scalar integers for dis-contiguous row
%  intervals.
%
%  Example:
%  Copyof100PSQsLonglistMarch2022CRWS2 = importfile("D:\Cerian\OneDrive - University of Cambridge\HundredQuestionsPlantSciences\Copy of 100 PSQs Longlist March 2022CRW.xlsx", "QuestionLonglistNoDuplicates", [1, 196]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 30-Mar-2022 12:04:49

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [1, 196];
end

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 5);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":E" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["Ques", "Category"];
opts.SelectedVariableNames = ["Ques", "Category"];
opts.VariableTypes = ["string", "categorical"];



% Import the data
Copyof100PSQsLonglistMarch2022CRWS2 = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":E" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    Copyof100PSQsLonglistMarch2022CRWS2 = [Copyof100PSQsLonglistMarch2022CRWS2; tb]; %#ok<AGROW>
end

end
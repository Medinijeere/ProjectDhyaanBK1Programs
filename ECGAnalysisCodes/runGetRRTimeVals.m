clear
clc

[allSubjectNames,expDateList] = getDemographicDetails('BK1');
[goodSubjectList,~,~] = getGoodSubjectsBK1;

folderSourceString = 'C:\Users\medin\Documents\material';
dataFolder = fullfile(folderSourceString,'Data');
saveFolderName = fullfile(dataFolder,'savedData');

useTheseIndices = 1:length(goodSubjectList);

for i = 1:length(useTheseIndices)

    subjectName = goodSubjectList{useTheseIndices(i)};

    disp(['Processing subject: ' subjectName])

    expDate = expDateList{strcmp(subjectName,allSubjectNames)};

    getRRTimeVals(subjectName,expDate,fullfile(folderSourceString,'Data','segmentedDataLong'),saveFolderName);

end

disp('Finished')
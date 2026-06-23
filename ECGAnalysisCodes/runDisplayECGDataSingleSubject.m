clear; close all

[allSubjectNames,expDateList] =getDemographicDetails('BK1');
[goodSubjectList, meditatorList, controlList] = getGoodSubjectsBK1;
folderSourceString = 'C:\Users\medin\Documents\material';
saveFolderName = 'ECGResultsSingleSubject';

saveFileFlag     = 1;

useTheseIndices = 1:length(goodSubjectList);

for i=1:length(useTheseIndices)
    fh=figure(1); clf(fh);
    %fh.WindowState = 'maximized';
    subjectName = goodSubjectList{useTheseIndices(i)};
    disp(['Analyzing for the subject ' subjectName]);
    expDate = expDateList{strcmp(subjectName,allSubjectNames)};
    displayECGDataSingleSubject(subjectName,expDate,folderSourceString);
    pause;

    % if saveFileFlag
    %     makeDirectory(saveFolderName);
    %     fileNameTif = fullfile(saveFolderName,[subjectName badTrialNameStr '_badElecChoice' num2str(badElectrodeRejectionFlag) '_raw' num2str(plotRawTFFlag) '_sort' num2str(sortByBadTrialFlag) '.tif']);
    %     print(fh,fileNameTif,'-dtiff','-r300');
    % end
end
clc; clear;

fileToLoadSourceString = 'C:\Users\medin\Documents\material\Data\BK1\BK1\commonAnalysisCodes\informationFiles';
fileName = 'BK1AllSubjectList.mat';

load(fullfile(fileToLoadSourceString,fileName),'allSubjectList');

targetNames = {'099SP', '095KM'};

[~, idx] = ismember(targetNames, allSubjectList);

idx = idx(idx>0);   % remove any not-found entries (optional)

disp(idx(:))        % force column output


%-------------------------------------------------------------------------------------------------
%M1 ptotocol problematic indices = (1, 9, 13, 14, 15, 16, 19, 20, 18, 21,
%27, 30, 31, 37, 47, 49, 50, 51, 53, 57, 59, 61, 65, 67,69,74)
%EC1 protocol problematic indices= as in runSegmentAndSave
%EC2 protocol problematic indices= as in runSegmentAndSave
%G1 protocol problematic indices= 081SN; 61
%M2- 5, 73
%none in G2 protocol

%check for these indices which are not compatible after removing 2 trials
%before and after the start/stop time = 
%064PK- EC1
%019CKa 053DR - EO1
%099Sp 095KM - M2
%---------------------------------------------------------------------------------------------------

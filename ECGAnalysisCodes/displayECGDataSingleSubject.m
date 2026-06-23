function displayECGDataSingleSubject(subjectName,expDate,folderSourceString)

if ~exist('folderSourceString','var'); folderSourceString=[]; end

if isempty(folderSourceString)
    folderSourceString = 'N:\Projects\ProjectDhyaan\BK1';
end

protocolNameList = [{'EO1'} {'EC1'} {'G1'} {'M1a'} {'M1b'} {'M1c'} {'G2'} {'EO2'} {'EC2'} {'M2a'} {'M2b'} {'M2c'}];
colorNames = [{[0.9 0 0]} {[0 0.9 0]} {[0 0 0.9]} {[0.9 0.9 0.9]}  {[0.7 0.7 0.7]} {[0.5 0.5 0.5]} {[0 0 0.3]} {[0.3 0 0]} {[0 0.3 0]} {[0.3 0.3 0.3]} {[0.2 0.2 0.2]} {[0.1 0.1 0.1]}];
numProtocols = length(protocolNameList);

filteringInfo = filterECGData;

hECGPlots = getPlotHandles(numProtocols,1,[0.05 0.05 0.68 0.85],0.025,0.025,1);
linkaxes(hECGPlots);

hHRPlot = axes( ...
    'Units','normalized',...
    'Position',[0.75 0.55 0.23 0.35]);

for i = 1:numProtocols

    tmpFile = fullfile(folderSourceString,...
        'data','segmentedDataLong',subjectName,'EEG',expDate,...
        protocolNameList{i},'segmentedData','LFP','elec66.mat');

    if exist(tmpFile,'file')

        tmp = load(tmpFile);
        ecgData = tmp.analogData;

        tmp = load(fullfile(folderSourceString,...
            'data','segmentedDataLong',subjectName,'EEG',expDate,...
            protocolNameList{i},'segmentedData','LFP','lfpInfo.mat'));

        timeVals = tmp.timeVals;
        timeVals = timeVals - timeVals(1);

        allECGRaw{i} = ecgData;
        allTime{i}   = timeVals;
        Fs(i)        = 1/mean(diff(timeVals));

        rrFile = fullfile(folderSourceString,...
            'data','segmentedDataLong',subjectName,'EEG',expDate,...
            protocolNameList{i},'segmentedData','LFP','RR.mat');

        if exist(rrFile,'file')

            tmpRR = load(rrFile);

            allRPeakTimes{i} = seconds(tmpRR.data.R_loc{1});

        else

            allRPeakTimes{i} = [];

        end

    else

        disp([tmpFile 'not found']);

    end

end

allECGFiltered = allECGRaw;
maxTime = 0;

for k = 1:numProtocols

    if ~isempty(allTime{k})

        maxTime = max(maxTime,max(allTime{k}));

    end

end

hShowPeaks = uicontrol(...
    'Style','checkbox',...
    'String','Show R Peaks',...
    'Value',1,...
    'Units','normalized',...
    'Position',[0.05 0.94 0.12 0.04],...
    'Callback',@applyFilter);

uicontrol('Style','text',...
    'String','HPF',...
    'Units','normalized',...
    'Position',[0.20 0.94 0.04 0.03]);

hHPF = uicontrol('Style','edit',...
    'String',num2str(filteringInfo.HPF),...
    'Units','normalized',...
    'Position',[0.24 0.94 0.06 0.04]);

uicontrol('Style','text',...
    'String','LPF',...
    'Units','normalized',...
    'Position',[0.34 0.94 0.04 0.03]);

if isinf(filteringInfo.LPF)
    lpstr = 'Inf';
else
    lpstr = num2str(filteringInfo.LPF);
end

hLPF = uicontrol('Style','edit',...
    'String',lpstr,...
    'Units','normalized',...
    'Position',[0.38 0.94 0.06 0.04]);

uicontrol('Style','pushbutton',...
    'String','Apply',...
    'Units','normalized',...
    'Position',[0.48 0.94 0.08 0.04],...
    'Callback',@applyFilter);

displayPlotSingleSubject( ...
    hHRPlot,...
    subjectName,...
    fullfile(folderSourceString,'data','segmentedDataLong'));

applyFilter;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALLBACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function applyFilter(~,~)

        filteringInfo.HPF = str2double(hHPF.String);

        tmp = str2double(hLPF.String);

        if isnan(tmp)
            filteringInfo.LPF = Inf;
        else
            filteringInfo.LPF = tmp;
        end

        for kk = 1:numProtocols

            data = allECGRaw{kk};

            HPF = filteringInfo.HPF;
            LPF = filteringInfo.LPF;

            if ~filteringInfo.applyFilter

                out = data;

            elseif HPF==0 && isinf(LPF)

                out = data;

            elseif HPF>0 && isinf(LPF)

                [b,a] = butter(filteringInfo.filterOrder,...
                    HPF/(Fs(kk)/2),'high');

                out = filtfilt(b,a,double(data));

            elseif HPF==0 && isfinite(LPF)

                [b,a] = butter(filteringInfo.filterOrder,...
                    LPF/(Fs(kk)/2),'low');

                out = filtfilt(b,a,double(data));

            else

                [b,a] = butter(filteringInfo.filterOrder,...
                    [HPF LPF]/(Fs(kk)/2),'bandpass');

                out = filtfilt(b,a,double(data));

            end

            allECGFiltered{kk} = out;

        end

        redrawPlots;

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REDRAW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function redrawPlots

        for k = 1:numProtocols

            out = allECGFiltered{k};
            t   = allTime{k};

            tStart = min(t);
            tEnd   = max(t);

            idx = true(size(t));

            cla(hECGPlots(k))

            plot(hECGPlots(k),...
                t(idx),...
                out(idx),...
                'color',colorNames{k})
            xlim(hECGPlots(k),[tStart tEnd])

        hold(hECGPlots(k),'on')

        if hShowPeaks.Value

            peakTimes = allRPeakTimes{k};

            peakMask = peakTimes>=tStart & peakTimes<=tEnd;

            peakTimes = peakTimes(peakMask);

            if ~isempty(peakTimes)

                peakY = zeros(size(peakTimes));

                for pp = 1:length(peakTimes)

                    [~,idxTmp] = min(abs(t-peakTimes(pp)));

                    peakY(pp) = out(idxTmp);

                end

                plot(hECGPlots(k),...
                    peakTimes,...
                    peakY,...
                    'ro',...
                    'MarkerFaceColor','r',...
                    'MarkerSize',5);

            end

        end

        hold(hECGPlots(k),'off')

        title(hECGPlots(k),protocolNameList{k})

    end

end

end
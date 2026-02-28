%% LIST YOUR FILES HERE
filePaths = {
"C:\Users\medin\Documents\material\Data\segmentedData\064PK\EEG\290722\EC1\segmentedData\LFP\elec66.mat"
"C:\Users\medin\Documents\material\Data\segmentedData\019CKa\EEG\030422\EO1\segmentedData\LFP\elec66.mat"
};

Fs = 1000;
nfft = 1000;

%% LOOP
for f = 1:length(filePaths)

    filePath = filePaths{f};

    if ~exist(filePath,'file')
        disp("Missing file: " + filePath);
        continue
    end

    load(filePath,'analogData');

    [nTrials, nSamples] = size(analogData);
    freqs = (0:nfft/2-1)*(Fs/nfft);
    powerMatrix = zeros(nTrials,length(freqs));

    %% Compute power per trial
    for t = 1:nTrials
        signal = analogData(t,:);
        Y = fft(signal,nfft);
        P = abs(Y(1:nfft/2)).^2;
        powerMatrix(t,:) = P;
    end

    %% Extract subject name automatically from path
    [~, subjectName] = fileparts(fileparts(fileparts(fileparts(fileparts(filePath)))));

    %% Plot
    figure;
    imagesc(1:nTrials, freqs, 10*log10(powerMatrix'));
    axis xy;
    xlabel('Trial Number');
    ylabel('Frequency (Hz)');
    title(['Power across Trials - ' subjectName]);
    colorbar;
    colormap jet;

end

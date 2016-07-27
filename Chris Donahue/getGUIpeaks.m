function ICpeaks = getGUIpeaks(curIC,thresh)
% curIC is current figure's IC timecourse
% thresh is threshold of signal in standard deviations

% peakParams.thresh = number of standard deviations above baseline
% peakParams.prominence = peakProminence: 
peakParams.thresh = thresh;
peakParams.prominence = 10; % hard-coded for now: number of timebins on each side to separate peaks (10 frames)

peakInfo = [];
% turn off warning message:
warning('off','signal:findpeaks:largeMinPeakHeight');

nFrames = size(curIC,2);
recSig = curIC;
recSig(find(curIC<0)) = 0; % rectify to remove negative transients

s = std(recSig)*peakParams.thresh;
[pks locs] = findpeaks(curIC,'minpeakheight',s);
count = 1;
% NOW FIND PEAK PROMINENCE:
for k = 1:length(pks)
    ref = pks(k);
    if (locs(k)-peakParams.prominence)<1 % if outside of range of pp
        test = max(curIC(1:(locs(k)+peakParams.prominence)));
    elseif (locs(k)+peakParams.prominence)>nFrames
        test = max(curIC(locs(k)-peakParams.prominence:end));
    else
        test = max(curIC((locs(k)-peakParams.prominence:(locs(k)+peakParams.prominence))));
    end
    if ref==test
        peakInfo(count,:) = [locs(k) pks(k)/std(recSig)];
        count = count+1;
    end
end


% turn warning back on:
warning('on','signal:findpeaks:largeMinPeakHeight');

ICpeaks.data = peakInfo;
ICpeaks.params = peakParams;
ICpeaks.sig = curIC./std(recSig); % in z-score!! 
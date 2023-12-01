function bandpass_data = New_BandPassEvent(bp_param, sw_data, mapChanData)

chan = find(mapChanData.Channel == bp_param.Channel);
ChanList = mapChanData.ChannelStr;
chan_str = ChanList(mapChanData.Channel(chan,:));
fs = mapChanData.SamplingRate(chan,:);

%select unique label
%bp_param.Label = UniqueLabel(event_data, bp_param.Label);

%more verbose label - TODO: I don't think this is needed anymore
label = sprintf('%s %s %s-%s [bandpass %.3f to %.3f Hz]',...
    bp_param.Label, chan_str,...
    sw_data.StartTime,sw_data.EndTime,...
    bp_param.MinFrequency,bp_param.MaxFrequency);

%extract data
part = mapChanData.ProcessedData(chan,sw_data.StartIndex:sw_data.EndIndex);

%ALIGNMENT and window widening
baseline = sw_data.BaseLineIndex;
eegForAlignment = FilterDataSW(part,fs,sw_data.MinFrequency,sw_data.MaxFrequency,sw_data.FilterOrder);
waveLocations = sw_data.WaveIndex-sw_data.StartIndex;
wide_pre_time = round(bp_param.LeftFrame*fs);
wide_post_time = round(bp_param.RightFrame*fs);
%create wide windows
wideWaveWindows = zeros(size(waveLocations,1)+wide_pre_time+wide_post_time,size(waveLocations,2));
%wideWaveWindows = zeros(size(waveLocations,1),size(waveLocations,2));

for ww=1:size(waveLocations,2)
    wideWaveWindows(:,ww) = -wide_pre_time+waveLocations(1,ww):waveLocations(end,ww)+wide_post_time;
end
wideBaseline = zeros(size(baseline,1)+wide_pre_time+wide_post_time,size(baseline,2));
for ww=1:size(baseline,2)
    wideBaseline(:,ww) = -wide_pre_time+baseline(1,ww):baseline(end,ww)+wide_post_time;
end

    
%extract event numbers
event_number = sw_data.EventNumber;

%chop ends if beyond bounds
while wideWaveWindows(1)<=eegForAlignment(1) 
    wideWaveWindows = wideWaveWindows(:,2:end);
    event_number = event_number(2:end);
end
while wideWaveWindows(end)>length(eegForAlignment)
    wideWaveWindows = wideWaveWindows(:,1:end-1);
    event_number = event_number(1:end-1);
end

waves = eegForAlignment(wideWaveWindows);
eventIndex = sw_data.EventIndex+wide_pre_time;

nOffCenter=25;
centerRegion = -nOffCenter:nOffCenter;
centerRegion = centerRegion+eventIndex+1;
for ii=1:size(waves,2)
    if sw_data.Type == EventType.SlowWaves
        [~,peakValueLocBP] = max(abs(waves(centerRegion,ii)));
    else
        [~,peakValueLocBP] = max(waves(centerRegion,ii));
    end
    del = eventIndex-(peakValueLocBP+centerRegion(1)-1);
    wideWaveWindows(:,ii) = wideWaveWindows(1,ii)-del:wideWaveWindows(end,ii)-del;
end


%detrend and filter channel data
eeg = FilterDataSW(part, fs, ...
    bp_param.MinFrequency, bp_param.MaxFrequency, bp_param.FilterOrder);

%chop ends if beyond bounds
base = wideBaseline-sw_data.StartIndex;
while base(1)<=0
    base = base(:,2:end);
end
while base(end)>sw_data.EndIndex
    base = base(:,1:end-1);
end

bandpass_params = struct(...
    'MinFrequency',  bp_param.MinFrequency, ...
    'MaxFrequency', bp_param.MaxFrequency, ...
    'FilterOrder', bp_param.FilterOrder);


% bandpass_data = struct(...
%     'Label', label, ...
%     'StartIndex', sw_data.StartIndex, ... 
%     'StartTime', sw_data.StartTime, ... 
%     'EndIndex', sw_data.EndIndex, ... 
%     'EndTime', sw_data.EndTime, ... 
%     'EventIndex', eventIndex, ...
%     'TimeSeries', eeg(wideWaveWindows), ... 
%     'BaseLineIndex', base, ...
%     'BaseLine', eeg(base), ...
%     'WaveIndex', wideWaveWindows, ...
%     'EventNumber', event_number, ...
%     'Parameters', bandpass_params, ...
%     'Type', 'Rebandpassed');


bandpass_data = sw_data;
bandpass_data.Type = sw_data.Type;
bandpass_data.TimeSeries = eeg(wideWaveWindows);
bandpass_data.MinFrequency = bandpass_params.MinFrequency;
bandpass_data.MaxFrequency = bandpass_params.MaxFrequency;
bandpass_data.Label = label;
% bandpass_data.BaseLineIndex = base;
% bandpass_data.BaseLine = eeg(base);




function bp_data = NewSWBandPass(sw_data, mapChanData)

% wt_param, sw_param, StageData, channel, wave_ind; taking this out of the
% code logic. Not necessary. 
num_events = size(sw_data.TimeSeries, 2);  % Number of events
trough_values = zeros(1, num_events);  % Initialize array for trough values
trough_indices = zeros(1, num_events); % Initialize array for trough indices

for event = 1:num_events
    [trough_values(event), trough_indices(event)] = min(sw_data.TimeSeries(:, event));
end

% Now update your data structures with these new trough values and indices
% ...

%chan = event_data{wave_ind}.MapChanIndex;
chan = sw_data.MapChanIndex;
ChanList = mapChanData.ChannelStr;
chan_str = ChanList(mapChanData.Channel(chan,:));

bp_param = New_BandpassParameters(sw_data, chan_str);
if isempty(bp_param)
    warning('User canceled. Bandpass parameters not set.')
    return;
end

%ChanList = sw_data.ChannelStr;
bp_chan_ind = find(strcmpi(strtrim(ChanList), strtrim(bp_param.ChannelStr)));
if ~any(mapChanData.Channel == bp_chan_ind)
    % Add channel to mapped data
    ProcessNewChannel(sw_data.FromFile, bp_chan_ind, sw_data.ChannelFile);
end

bp_param.Channel = bp_chan_ind;
bp_param.MapChanIndex = find(mapChanData.Channel == bp_chan_ind);
if ~mapChanData.IsProcessed(bp_param.MapChanIndex,:)
    PreProcessChannelData(sw_data.ChannelFile, bp_param.MapChanIndex);
end
 
%%% Computes new time series data
bp_data = New_BandPassEvent(bp_param, sw_data, mapChanData); 

[zero_cross_pairs, PeakIndex] = Update_ZCP(bp_data);

bp_data.EventMarkers.ZeroCrossPairs = zero_cross_pairs;
bp_data.EventMarkers.PeakIndex = PeakIndex;

% save('C:\Users\Colin\OneDrive\Desktop\SWS Code\Outside_GUI\sw_dataFile.mat', 'sw_data');
% save('C:\Users\Colin\OneDrive\Desktop\SWS Code\Outside_GUI\bp_dataFile.mat', 'bp_data');
%look at subset of zerocrosspairs, try shifting the pairs that have matched
%indices %use binary vectot to pull good indices. 
end
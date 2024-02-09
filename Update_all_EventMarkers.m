function sw_data = Update_all_EventMarkers(PeakIndex, TroughIndex, zero_cross_pairs, og_zcp, sw_data, og_PeakIndex)

% Compute distances between events, and shift according to zcp_1
numEvents = size(PeakIndex, 2);
dist1 = zeros(size(PeakIndex)); %aligning with zerocross1 essentially
dist2 = zeros(size(dist1)); %distance between trough and zcp1
dist3 = zeros(size(dist1)); %distance between zcp2 - trough
dist4 = zeros(size(dist1)); %distance between peak - zcp2
dist5 = zeros(size(dist1)); %distance between zcp3 - peak

for k=1:numEvents
    dist1(k) = og_zcp(1, k) - zero_cross_pairs(1, k);
    dist2(k) = TroughIndex(k) - zero_cross_pairs(1, k);
    dist3(k) = zero_cross_pairs(2, k) - TroughIndex(k);
    dist4(k) = PeakIndex(k) - zero_cross_pairs(2, k);
    dist5(k) = zero_cross_pairs(3, k) - PeakIndex(k);
end    

for j=1:numEvents
    sw_data.EventMarkers.ZeroCrossPairs(1, j) = sw_data.EventMarkers.ZeroCrossPairs(1, j) - dist1(j);
    sw_data.EventMarkers.TroughIndex(j) = sw_data.EventMarkers.ZeroCrossPairs(1, j) + dist2(j);
    sw_data.EventMarkers.ZeroCrossPairs(2, j) = sw_data.EventMarkers.TroughIndex(j) + dist3(j);
    sw_data.EventMarkers.PeakIndex(j) = sw_data.EventMarkers.ZeroCrossPairs(2, j) + dist4(j);
    sw_data.EventMarkers.ZeroCrossPairs(3, j) = sw_data.EventMarkers.PeakIndex(j) + dist5(j);
end

zcp_shift = zeros(size(zero_cross_pairs));
peak_shift = zeros(size(PeakIndex));
trough_shift = zeros(size(TroughIndex));

for i=1:size(TroughIndex, 2)
    zcp_shift(i) = zero_cross_pairs(i) - og_zcp(i);
    peak_shift(i) = PeakIndex(i) - og_PeakIndex(i);
    trough_shift(i) = TroughIndex(i) - 320;
end


for i=1:size(TroughIndex, 2)
    sw_data.WaveIndex(:, i) = sw_data.WaveIndex(:, i) + trough_shift(i);
end

sw_data.EventMarkers.ZeroCrossPairs = sw_data.EventMarkers.ZeroCrossPairs + zcp_shift;
sw_data.EventMarkers.TroughIndex = sw_data.EventMarkers.TroughIndex + trough_shift;
sw_data.EventMarkers.PeakIndex = sw_data.EventMarkers.PeakIndex + peak_shift;
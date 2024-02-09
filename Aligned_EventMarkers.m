function sw_data = Aligned_EventMarkers(zero_cross_pairs, PeakIndex, TroughIndex, sw_data)

%align trough at 320
trough = 320;

align_zcp = zeros(size(zero_cross_pairs));
align_peak = zeros(size(PeakIndex));
align_trough = zeros(size(TroughIndex));

 for i=1:size(TroughIndex, 2)
     shift(i) = TroughIndex(:, i) - trough; 
     align_zcp(:, i) = zero_cross_pairs(:, i) - shift(i); 
     align_peak(:, i) = PeakIndex(:, i) - shift(i);
     align_trough(:, i) = trough;
     %Wave Index might need to be altered.
%     for row=1:size(sw_data.WaveIndex, 1)
%         if row ~= 320
%             sw_data.WaveIndex(row, i) = sw_data.WaveIndex(row, i) - shift(i);
%         end
%     end
 end

 bp_zcp = sw_data.EventMarkers.ZeroCrossPairs;
 bp_trough = sw_data.EventMarkers.TroughIndex;
 bp_pi = sw_data.EventMarkers.PeakIndex;

 for i=1:size(align_trough, 2)
     bp_zcp(1, i) = bp_trough(i) - (align_trough(i) - align_zcp(1, i));
     bp_zcp(2, i) = (align_zcp(2, i) - align_trough(i)) + bp_trough(i);
     bp_pi(i) = (align_peak(i) - align_trough(i)) + bp_trough(i);
     bp_zcp(3, i) = (align_zcp(3, i) - align_trough(i)) + bp_trough(i);  
 end


sw_data.EventMarkers.ZeroCrossPairs =  bp_zcp;
sw_data.EventMarkers.TroughIndex =  bp_trough;
sw_data.EventMarkers.PeakIndex = bp_pi;
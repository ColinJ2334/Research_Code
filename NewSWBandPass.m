function sw_data = NewSWBandPass(sw_data, mapChanData)

%Finds indices of individual slow wave events for the original time series
%data, from the whole set of EEG data.
data = sw_data.TimeSeries;
%This function detects zero crossings, trough, and peak indices
[og_zcp, og_PeakIndex, og_trough] = Update_ZCP(data); 

%This function orders events so that the event match histogram data works
%ie if it finds event markers that are not well ordered as defined in the
%data structure it will make an apprximation.
[og_zcp, og_PeakIndex] = Ordered_Events(og_zcp, og_PeakIndex);

%Lets you re bandpass the time series data directly without changing the
%number of events
bp_data = re_bp_data(sw_data);
 
sw_data.TimeSeries = bp_data;
[zero_cross_pairs, PeakIndex, TroughIndex] = Update_ZCP(bp_data);

%Make sure they are ordered.
[zero_cross_pairs, PeakIndex] = Ordered_Events(zero_cross_pairs, PeakIndex);

%This function updates all event markers.
sw_data = Update_all_EventMarkers(PeakIndex, TroughIndex, zero_cross_pairs, og_zcp, sw_data, og_PeakIndex);

%check_ordered function just checks to see if the event markers are in in
%fact well ordered.
%disorder = check_ordered(sw_data.EventMarkers.ZeroCrossPairs, sw_data.EventMarkers.TroughIndex, sw_data.EventMarkers.PeakIndex);

%sw_data = Aligned_EventMarkers(zero_cross_pairs, PeakIndex, TroughIndex, sw_data);

%disorder = check_ordered(sw_data.EventMarkers.ZeroCrossPairs, sw_data.EventMarkers.TroughIndex, sw_data.EventMarkers.PeakIndex);

end
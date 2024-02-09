function bp_data = re_bp_data(sw_data)
    data = sw_data.TimeSeries;

    % Prompt user for filter parameters
%     fs = input('Enter the sampling frequency (fs): ');
%     min_freq = input('Enter the minimum frequency (min_freq): ');
%     max_freq = input('Enter the maximum frequency (max_freq): ');
%     filter_order = input('Enter the filter order: ');

    fs = 128;
    min_freq = 0.4;
    max_freq = 0.9;
    filter_order = 3;

    % Calculate half of the sampling rate and create the Butterworth filter
    half_sr = 0.5 * fs;
    [B, A] = butter(filter_order, [min_freq, max_freq] / half_sr);

    % Initialize the filtered data matrix
    bp_data = zeros(size(data));

    % Loop over each column and apply the filter
    for i = 1:size(data, 2)
        % Detrend and filter each column of the data
        bp_data(:, i) = filtfilt(B, A, detrend(data(:, i)));
        %bp_data(:, i) = filtfilt(B, A, data(:, i));
    end
end

% function bp_data = re_bp_data(sw_data)
%     data = sw_data.TimeSeries;
% 
%     % Set default parameter values
%     defaultFs = 128; % Default sampling rate
%     defaultMinFreq = 0.5; % Default minimum frequency
%     defaultMaxFreq = 4; % Default maximum frequency
%     defaultFilterOrder = 3; % Default filter order
% 
%     % GUI for parameter selection
%     prompt = { ...
%         'Sampling Frequency (fs):', ...
%         'Minimum Frequency (min_freq) [Hz]:', ...
%         'Maximum Frequency (max_freq) [Hz]:', ...
%         'Filter Order:'};
%     dlgTitle = 'Bandpass Filter Parameters';
%     numLines = 1;
%     defaultAns = {...
%         sprintf('%d', defaultFs), ...
%         sprintf('%.1f', defaultMinFreq), ...
%         sprintf('%.1f', defaultMaxFreq), ...
%         sprintf('%d', defaultFilterOrder)};
%     answer = inputdlg(prompt, dlgTitle, numLines, defaultAns);
% 
%     % If user cancels, exit the function
%     if isempty(answer)
%         bp_data = [];
%         return
%     end
% 
%     % Convert user input from string to numeric values
%     fs = str2double(answer{1});
%     min_freq = str2double(answer{2});
%     max_freq = str2double(answer{3});
%     filter_order = str2double(answer{4});
% 
%     % Validate input (optional, based on your requirement)
% 
%     % Calculate half of the sampling rate and create the Butterworth filter
%     half_sr = 0.5 * fs;
%     [B, A] = butter(filter_order, [min_freq, max_freq] / half_sr);
% 
%     % Initialize the filtered data matrix
%     bp_data = zeros(size(data));
% 
%     % Loop over each column and apply the filter
%     for i = 1:size(data, 2)
%         bp_data(:, i) = filtfilt(B, A, data(:, i));
%     end
% end


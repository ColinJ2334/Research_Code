function [zero_cross_pairs, PeakIndex] = Update_ZCP(bp_data)

data = bp_data.TimeSeries;
numEvents = size(data, 2);
zero_cross_pairs = NaN(3, numEvents); % Initialize with NaNs
PeakIndex = NaN(1, numEvents);
middlePoint = 320;

    for i = 1:numEvents
%         data = bpTimeseries(:, w); % Extract data for the current window

        % Find troughs in the timeseries data
            [~, troughLocs] = findpeaks(-data(:,i)); % Invert data to find troughs
            [~, closestTroughIdx] = min(abs(troughLocs - middlePoint)); % Find the trough closest to the middle point
            closestTrough = troughLocs(closestTroughIdx);

        % Find peaks in the timeseries data
            [~, peakLocs] = findpeaks(data(:, i)); % Use findpeaks on original data to locate peaks

        % Identify the nearest peaks on either side of the closest trough
            leftPeakCandidates = peakLocs(peakLocs < closestTrough);
            rightPeakCandidates = peakLocs(peakLocs > closestTrough);

        % Assign a default peak if no peak is found
            if isempty(leftPeakCandidates)
                leftPeak = round((1 + closestTrough) / 2);
            else
                leftPeak = max(leftPeakCandidates);
            end

            if isempty(rightPeakCandidates)
                rightPeak = round((641 + closestTrough) / 2);
            else
                rightPeak = min(rightPeakCandidates);
            end

        % Find zero crossings in the timeseries data
            zeroCrossings = find(diff(sign(data(:,i))) ~= 0); % Indices where sign change occurs

        % Find or estimate relevant zero crossings around the peaks and trough
            zeroCrossBeforeLeftPeak = findZeroCrossing(zeroCrossings, leftPeak, 'before');
            zeroCrossBeforeTrough = findZeroCrossing(zeroCrossings, closestTrough, 'before', leftPeak);
            zeroCrossAfterTrough = findZeroCrossing(zeroCrossings, closestTrough, 'after', rightPeak);
            zeroCrossAfterRightPeak = findZeroCrossing(zeroCrossings, rightPeak, 'after');

        % Estimate missing zero crossings
            if isempty(zeroCrossBeforeLeftPeak)
                distanceToFirstPeak = closestTrough - leftPeak;
                zeroCrossBeforeLeftPeak = max(1, closestTrough - 2 * distanceToFirstPeak); % Bound to leftmost sample
            end
            if isempty(zeroCrossAfterRightPeak)
                distanceToSecondPeak = rightPeak - closestTrough;
                zeroCrossAfterRightPeak = min(641, closestTrough + 2 * distanceToSecondPeak); % Bound to rightmost sample
            end

        % Compute distances between zero crossings
            dist1 = zeroCrossBeforeTrough - zeroCrossBeforeLeftPeak;
            dist2 = zeroCrossAfterTrough - zeroCrossBeforeTrough;
            dist3 = zeroCrossAfterRightPeak - zeroCrossAfterTrough;

        % Compute amplitudes at peaks and trough
            amplitudePeakLeft = data(leftPeak);
            amplitudeTrough = data(closestTrough);
            amplitudePeakRight = data(rightPeak);

        % Compute slopes between peaks and trough
            slope1 = (amplitudeTrough - amplitudePeakLeft) / (closestTrough - leftPeak);
            slope2 = (amplitudePeakRight - amplitudeTrough) / (rightPeak - closestTrough);

            zero_cross_pairs(:, i) = [zeroCrossBeforeTrough; zeroCrossAfterTrough; zeroCrossAfterRightPeak];
            PeakIndex(i) = rightPeak;

        % Flatten and concatenate all features into a single row vector
            features = [dist1, dist2, dist3, amplitudePeakLeft, amplitudeTrough, amplitudePeakRight, ...
                    slope1, slope2, zeroCrossBeforeLeftPeak, zeroCrossBeforeTrough, ...
                    zeroCrossAfterTrough, zeroCrossAfterRightPeak, leftPeak, rightPeak, closestTrough];
        
        % Store the concatenated feature vector for the current window
%             waveformFeatures{w} = features;

    end
end

function zeroCross = findZeroCrossing(zeroCrossings, referencePoint, position, altReferencePoint)
    % Find zero crossings relative to a reference point
    if strcmp(position, 'before')
        candidates = zeroCrossings(zeroCrossings < referencePoint);
        zeroCross = max(candidates);
    elseif strcmp(position, 'after')
        candidates = zeroCrossings(zeroCrossings > referencePoint);
        zeroCross = min(candidates);
    else
        zeroCross = [];
    end

    % If zero crossing is not found, assign it halfway between reference points
    if isempty(zeroCross) && nargin == 4
        zeroCross = round((referencePoint + altReferencePoint) / 2);
    end
end
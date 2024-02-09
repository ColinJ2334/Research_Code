function disorder = check_ordered(zero_cross, trough_idx, peak_idx)

num_columns = size(zero_cross, 2); % Assuming all matrices have the same number of columns
is_ordered = true; % Flag to keep track of order status

zcp = zero_cross;
trough_index = trough_idx;
peak_index = peak_idx;
disorder = [];

for i = 1:num_columns
    if ~(zcp(1,i) <= trough_index(i) && ...
         trough_index(i) <= zcp(2,i) && ...
         zcp(2,i) <= peak_index(i) && ...
         peak_index(i) <= zcp(3,i))
        % If the sequence is not in order, set the flag to false and break
        disorder(end+1) = i;
    end
end
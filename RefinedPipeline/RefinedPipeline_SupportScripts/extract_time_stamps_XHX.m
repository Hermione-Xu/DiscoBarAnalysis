function timestamps = extract_time_stamps_XHX(ops)
%% Created by Hermione Xu, xinmeng.xu@duke.edu
% In binary mode the first 16 pixels will be filled with the time stamp 
% information (binary code). The numbers are coded in BCD with one byte per 
% pixel, which means that every pixel contains 2 digits. If the pixels have 
% more resolution than 8 bits, then the BCD digits are right bound placed 
% and the upper bits are zero. (1 BCD digit ≙ 4 bits; 2 numbers ≙ 2 BCD ≙ 
% 8 bits = 1 byte; every pixel contains 2 digits). 
file_1 = ops.vfile_1;
file_2 = ops.vfile_2;
tiff_info_1 = imfinfo(file_1);
tiff_info_2 = imfinfo(file_2);

timestamps_1 = zeros(size(tiff_info_1,1),3);
timestamps_2 = zeros(size(tiff_info_2,1),3);

parfor ind_1 = 1:size(tiff_info_1,1)
    frame_1 = imread(file_1,ind_1);

    binaryCode_1 = frame_1(1,1:16);
    timestamp_1 = zeros([1,32]);
    for binaryCodeind_1 = 1:size(binaryCode_1,2)
        temp_1 = dec2bin(binaryCode_1(binaryCodeind_1),8);
        first_1 = temp_1(1:4);
        second_1 = temp_1(5:8);
        timestamp_1(1,2*binaryCodeind_1-1) = bin2dec(first_1);
        timestamp_1(1,2*binaryCodeind_1) = bin2dec(second_1);
    end
    % frame number, e.g. '00000001' (8 bits)
    framenum_1 = strjoin(string(timestamp_1(1:8)),'');
    % date (year-month-day)
    date_1 = strjoin(string(timestamp_1(9:16)),'');
    % exact time
    time_1 = strjoin(string(timestamp_1(17:28)),'');
    timestamps_1(ind_1,:) = [framenum_1, date_1, time_1];
end
parfor ind_2 = 1:size(tiff_info_2,1)
    frame_2 = imread(file_2,ind_2);

    binaryCode_2 = frame_2(1,1:16);
    timestamp_2 = zeros([1,32]);
    for binaryCodeind_2 = 1:size(binaryCode_2,2)
        temp_2 = dec2bin(binaryCode_2(binaryCodeind_2),8);
        first_2 = temp_2(1:4);
        second_2 = temp_2(5:8);
        timestamp_2(1,2*binaryCodeind_2-1) = bin2dec(first_2);
        timestamp_2(1,2*binaryCodeind_2) = bin2dec(second_2);
    end
    % frame number, e.g. '00000001' (8 bits)
    framenum_2 = strjoin(string(timestamp_2(1:8)),'');
    % date (year-month-day)
    date_2 = strjoin(string(timestamp_2(9:16)),'');
    % exact time
    time_2 = strjoin(string(timestamp_2(17:28)),'');
    timestamps_2(ind_2,:) = [framenum_2, date_2, time_2];
end

timestamps = [timestamps_1; timestamps_2];
end
function [FinalData, namingVec, volts, amps] = filereadin() 

    a=dir('*mA');


    for i=1:length(a)
        data = readmatrix(a(i).name);
        rowsWithNaNs = any(isnan(data), 2);
        validRows = ~rowsWithNaNs;
        cleanedData = data(validRows, :);
        % how to get voltage and amperage from file names?
        % - options include strsplit, regex, etc.
        % ultimately, we need to use the format of each file name
        % 'material'_'volts'V_'amps'mA
        b = strsplit(a(i).name,'_'); % gives a cell array (b) that is 1x3
        % {'material','voltsV','ampsmA'} -- now split by 'V' and 'mA'
        v = strsplit(b{2},'V'); % volts are always in the second portion
        ampval= strsplit(b{3},'mA'); % amps are always in the third portion
        volts(i) = str2num(v{1}); % convert string to number (vector)
        amps(i) = str2num(ampval{1});

        A = convertCharsToStrings(b);
        namingVec(:, i) = A'; 
        

        % Store the data from each column into corresponding variables
        FinalData(i).time = cleanedData(:, 1);
        FinalData(i).CH1 = cleanedData(:, 2);
        FinalData(i).CH2 = cleanedData(:, 3);
        FinalData(i).CH3 = cleanedData(:, 4);
        FinalData(i).CH4 = cleanedData(:, 5);
        FinalData(i).CH5 = cleanedData(:, 6);
        FinalData(i).CH6 = cleanedData(:, 7);
        FinalData(i).CH7 = cleanedData(:, 8);
        FinalData(i).CH8 = cleanedData(:, 9);
      

    end
 
end



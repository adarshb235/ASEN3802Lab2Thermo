clc;
clear;
close all;


[data, filenames] = filereadin();

for i = 1:length(data)
    time(:, i) = {data(i).time};
    CH1(:, i) = {data(i).CH1};
    CH2(:, i) = {data(i).CH2};
    CH3(:, i) = {data(i).CH3};
    CH4(:, i) = {data(i).CH4};
    CH5(:, i) = {data(i).CH5};
    CH6(:, i) = {data(i).CH6};
    CH7(:, i) = {data(i).CH7};
    CH8(:, i) = {data(i).CH8};

    initialTempDist(i, :) = [CH1{1, i}(1) CH2{1, i}(1) CH3{1, i}(1) CH4{1, i}(1) CH5{1, i}(1) CH6{1, i}(1) CH7{1, i}(1) CH8{1, i}(1)];
end

labels = ["CH1", "CH2", "CH3", "CH4", "CH5", "CH6", "CH7", "CH8"];



figure(100);
hold on;
plot(initialTempDist', 'o');
xscale = 1:8;
xticks(xscale);
xticklabels(labels);
title('Initial Temperature Distribution vs Channel Position');
xlabel('Channel Label');
ylabel('Temperature ')

num_files = size(initialTempDist, 1);
num_cols = ceil(sqrt(num_files));
num_rows = ceil(num_files / num_cols);

figure(200);
inChannelsDistScale = [1.375:0.5:4.875];
channelsDistScale = 0.0254 * inChannelsDistScale;
distScale = 0.0254 * [0 channelsDistScale 5.875];
sgtitle('Initial Temperature Distribution vs X Location Along L')
for i = 1:num_files
    fitCoeff(i, :) = polyfit(channelsDistScale, initialTempDist(i, :), 1);
    fitDist(i, :) = polyval(fitCoeff(i, :), distScale);
    subplot(num_rows, num_cols, i);
    hold on;
    plot(channelsDistScale, initialTempDist(i, :)', 'or');
    plot(distScale, fitDist(i, :), 'b-');
    plot(distScale, fitDist(i, :) - 2, 'k--');
    plot(distScale, fitDist(i, :) + 2, 'k--');
    givenTitle = append("Material: ", filenames(1, i), ' ', "Voltage: ", filenames(2, i), ' ', "Current: ", filenames(3, i));
    title(givenTitle);
    legend('Experimental', 'Best Fit', 'Error Bars +/- 2 deg C', 'Location', 'best')
    xlabel('Position (m)');
    ylabel('Temperature (degrees C)');
    hold off;
end
M_ext = fitCoeff(:,1);
hold off;

filename = 'part1task2_initialtempdistfig';
ax = gca; 
set(ax, 'LooseInset', get(ax, 'TightInset'));
print(filename,'-r500','-dpng')


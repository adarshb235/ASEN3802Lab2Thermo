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
end

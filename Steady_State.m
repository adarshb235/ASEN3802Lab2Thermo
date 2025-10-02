clear;
close all;
clc;
%aluminium.row  % kg.m^3
%aluminium.cp  % J/gk*K
%aluminium.k  %W/M*K
aluminium = struct("row", 2810, "cp", 960, "k", 130);
brass = struct("row", 8500, "cp", 380, "k", 115);
steel = struct("row", 8000, "cp", 500, "k", 16.2);

case1_data = readmatrix("Aluminum_25V_240mA");
case1 = struct("material", aluminium, "V", 25, "Amp", 0.240, "t", case1_data(:,1), "T_sense", case1_data(:, 2:9));

[case1.T_0, case1.H] = analyitical_line(case1);

case1.T_steady = mean([case1.T_sense([322:342], :)] , 1);
T_sense_position = linspace(1.375, 1.375 + 1.27 * 7, 8);
P = polyfit(T_sense_position, case1.T_steady,1)


figure();
hold on;
x = linspace(0, 11, 100);
T_analyitical = P(2) + P(1)*x;
plot(x, T_analyitical);
T_sense_position;
T_actual = case1.T_steady;
plot(T_sense_position, T_actual)







function [T_0, H] = analyitical_line(case_x);
D  = 0.0254;
Area = (D/2)^2 * pi;
Q_dot = case_x.V * case_x.Amp;
H = Q_dot/(case_x.material.k * Area);
T_0 = mean(case_x.T_sense(1,:));
end


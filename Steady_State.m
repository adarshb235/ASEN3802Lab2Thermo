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
case1 = struct("name", "Aluminum 25V 240mA","material", aluminium, "V", 25, "Amp", 0.240, "t", case1_data(:,1), "T_sense", case1_data(:, 2:9));
[case1.T_0, case1.H] = analyitical_line(case1);
case1.T_steady = mean([case1.T_sense(322:342, :)] , 1);

case2_data = readmatrix("Aluminum_30V_290mA");
case2 = struct("name", "Aluminum 30V 290mA","material", aluminium, "V", 30, "Amp", 0.290, "t", case2_data(:,1), "T_sense", case2_data(:, 2:9));
[case2.T_0, case2.H] = analyitical_line(case2);
case2.T_steady = mean([case1.T_sense(322:342, :)] , 1);

case3_data = readmatrix("Brass_25V_237mA");
case3 = struct("name", "Brass 25V 237mA","material", brass, "V", 25, "Amp", 0.237, "t", case3_data(:,1), "T_sense", case3_data(:, 2:9));
[case3.T_0, case3.H] = analyitical_line(case3);
case3.T_steady = mean([case1.T_sense(322:342, :)] , 1);

case4_data = readmatrix("Brass_30V_285mA");
case4 = struct("name", "Brass 30V 285mA","material", brass, "V", 30, "Amp", 0.285, "t", case4_data(:,1), "T_sense", case4_data(:, 2:9));
[case4.T_0, case4.H] = analyitical_line(case4);
case4.T_steady = mean([case1.T_sense(322:342, :)] , 1);

case5_data = readmatrix("Steel_22V_203mA");
case5 = struct("name", "Steel 22V 203mA","material", steel, "V", 22, "Amp", 0.203, "t", case5_data(:,1), "T_sense", case5_data(:, 2:9));
[case5.T_0, case5.H] = analyitical_line(case5);
case5.T_steady = mean([case1.T_sense(322:342, :)] , 1);




T_sense_position = linspace(1.375, 1.375 + 1.27 * 7, 8);
P = polyfit(T_sense_position, case1.T_steady,1)


compare(case1)
compare(case2)
compare(case3)
compare(case4)
compare(case5)





function compare(case_x);

[case_x.T_0, case_x.H] = analyitical_line(case_x);
case_x.T_steady = mean([case_x.T_sense(322:342, :)] , 1);
T_sense_position = linspace(1.375, 1.375 + 1.27 * 7, 8);
P = polyfit(T_sense_position, case_x.T_steady,1);
figure();
hold on;
grid on;

set(0, 'defaultFigureUnits', 'inches', 'defaultFigurePosition', [1 1 8 5]);
% figures are 8" wide and 5" tall, with the bottom left corner of the figure beginning 1" up, and 1" to the right from the bottom left corner
%of your screen -- adjust the size of the figure to your liking
set(0,'defaultLineLineWidth',2.5) % sets all line widths of plotted lines
set(0,'DefaultaxesLineWidth', 1.5) % sets line widths of axes
set(0,'DefaultaxesFontSize', 14)
set(0,'DefaultTextFontSize', 14)
set(0,'DefaultaxesFontName', 'Times new Roman')
set(0,'DefaultlegendFontName', 'Times new Roman')
set(0,'defaultAxesXGrid', 'on')
set(0,'defaultAxesYGrid','on')

x = linspace(0, 11);
T_analyitical = P(2) + P(1)*x;
plot(x, T_analyitical,'-', 'LineWidth', 1.5, 'DisplayName','Linear fit: T_0 + Hx');
T_sense_position;
T_actual = case_x.T_steady;
plot(T_sense_position, T_actual, 'o', 'MarkerSize', 6, 'DisplayName','Measured T at sensors')
xlabel('x (m) [0 at x_0; Th1 at 1-3/8 in]');
ylabel('Temperature (°C)');
title('Steady-State Temperature — ' + case_x.name);
legend('Location','best');

filename = ( case_x.name + '_comparison'); 
print(filename,'-r300','-dpng') % saves a png with a resolution of 300 dots/inch

end



function [T_0, H] = analyitical_line(case_x);
D  = 0.0254;
Area = (D/2)^2 * pi;
Q_dot = case_x.V * case_x.Amp;
H = Q_dot/(case_x.material.k * Area);
T_0 = mean(case_x.T_sense(1,:));
end


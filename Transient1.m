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
case1.m = 0.469;

case2_data = readmatrix("Aluminum_30V_290mA");
case2 = struct("name", "Aluminum 30V 290mA","material", aluminium, "V", 30, "Amp", 0.290, "t", case2_data(:,1), "T_sense", case2_data(:, 2:9));
[case2.T_0, case2.H] = analyitical_line(case2);
case2.T_steady = mean([case2.T_sense(322:342, :)] , 1);
case2.m = 0.094;

case3_data = readmatrix("Brass_25V_237mA");
case3 = struct("name", "Brass 25V 237mA","material", brass, "V", 25, "Amp", 0.237, "t", case3_data(:,1), "T_sense", case3_data(:, 2:9));
[case3.T_0, case3.H] = analyitical_line(case3);
case3.T_steady = mean([case3.T_sense(322:342, :)] , 1);
case3.m = 4.312;

case4_data = readmatrix("Brass_30V_285mA");
case4 = struct("name", "Brass 30V 285mA","material", brass, "V", 30, "Amp", 0.285, "t", case4_data(:,1), "T_sense", case4_data(:, 2:9));
[case4.T_0, case4.H] = analyitical_line(case4);
case4.T_steady = mean([case4.T_sense(322:342, :)] , 1);
case4.m = 4.874;

case5_data = readmatrix("Steel_22V_203mA");
case5 = struct("name", "Steel 22V 203mA","material", steel, "V", 22, "Amp", 0.203, "t", case5_data(:,1), "T_sense", case5_data(:, 2:9));
[case5.T_0, case5.H] = analyitical_line(case5);
case5.T_steady = mean([case5.T_sense(322:342, :)] , 1);
case5.m = 18.466;




T_sense_position = linspace(1.375, 1.375 + 0.5 * 7, 8);


%T = Transient_Solution(linspace(1.375, 1.375 + 0.5 * 7, 8), 0:3410, case1);



figure()
% hold on;
% timespan = 0:10:max(case3.t)
% T = Transient_Solution(T_sense_position, timespan, case3);
% for i = 1:8
%     plot(case3.t,case3.T_sense(:,i))
% plot(timespan,T(:,i))
% end
% %compare(case1)
% %compare(case2)
% %compare(case3)
% %compare(case4)
% %compare(case5)

%  Model IA — 5 Subplots (Rainbow Thermocouple Colors)

cases = {case1, case2, case3, case4, case5};
T_sense_position = linspace(1.375, 1.375 + 0.5 * 7, 8);

figure();

cmap = jet(8);    % or use hsv(8) or parula(8) depending on preference

for j = 1:length(cases)
    case_x = cases{j};
    timespan = 0:10:max(case_x.t);
    T_model = Transient_Solution(T_sense_position, timespan, case_x, 2); % value at the end determines case 0 is task 2 model 1 is task 3 model 2 is task 4 model
    T_exp   = case_x.T_sense;

    nexttile;
    hold on; grid on; box on;

    % plot experimental + analytical for all 8 thermocouples
    for i = 1:8
        % Experimental in dark gray for clarity
        plot(case_x.t, T_exp(:,i), 'Color', [0.2 0.2 0.2], 'LineWidth', 1.0);
        % Analytical with rainbow color
        plot(timespan, T_model(:,i), '-', 'Color', cmap(i,:), 'LineWidth', 1.8);
    end

    title(case_x.name, 'FontWeight', 'bold');
    xlabel('Time (s)');
    ylabel('T (°C)');
    set(gca, 'FontSize', 11, 'FontName', 'Times New Roman');
end

% Legend and save
lg = legend({'Experimental (all Th)', 'Th1–Th8 Analytical (Rainbow)'}, ...
             'Orientation','horizontal', 'Location','southoutside');
lg.Layout.Tile = 'south';

print('ModelIA_5Subplots_Rainbow','-dpng','-r300');





function [T] = Transient_Solution(x,t,case_x, hexp)

    n_end = 10;
    L = (max(x) + 1) * 0.0254;
    x = x * 0.0254;
    P = polyfit(x, case_x.T_steady,1);
    H = case_x.H;
    if hexp ~= 0
        H = P(1);
    end
    if hexp == 2
        M = case_x.m;
    else
        M = 0;
    end

    T_0 = case_x.T_0;
    alpha = case_x.material.k / (case_x.material.cp * case_x.material.row);
    

    sum = zeros([length(t),length(x)]);
     x_mat = repmat(x,length(t),1);
     mat = ones([length(t),length(x)]);
     timemat = transpose(repmat(t, length(x), 1));
    for n = 1:n_end

        lam_n = ((2*n - 1)* pi) / (2 * L);
        
        b_n = -(8*(M - H)*L*(-1)^n) / ((2*n-1)^2*pi^2);
        
        sum = sum + exp(-(lam_n^2) * alpha * timemat) .* (b_n * sin(lam_n * x_mat));
        
    end

   T = T_0 * mat + H * x_mat + sum;
end


function compare(case_x);

[case_x.T_0, case_x.H] = analyitical_line(case_x);
case_x.T_steady = mean([case_x.T_sense(322:342, :)] , 1);
T_sense_position = linspace(1.375, 1.375 + 0.5 * 7, 8);
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

x = linspace(0, 6);
T_analyitical = case_x.T_0 + case_x.H * x * 0.0254;
plot(x, T_analyitical,'-', 'LineWidth', 1.5, 'DisplayName','Linear fit: T_0 + Hx');
T_sense_position;
T_actual = case_x.T_steady;
plot(T_sense_position, T_actual, 'o', 'MarkerSize', 6, 'DisplayName','Measured T at sensors')
plot(x, (P(1) .* x + P(2)), '--', 'MarkerSize', 6, 'DisplayName','Experimental Line of Best Fit')
xlabel('x (m) [0 at x_0; Th1 at 1-3/8 in]');
ylabel('Temperature (°C)');
title('Steady-State Temperature — ' + case_x.name);
legend('Location','best');

filename = ( case_x.name + '_comparison_actual'); 
print(filename,'-r300','-dpng') % saves a png with a resolution of 300 dots/inch

end



function [T_0, H] = fit_line(case_x)
D  = 0.0254;
Area = (D/2)^2 * pi;
Q_dot = case_x.V * case_x.Amp;
H = Q_dot/(case_x.material.k * Area);
T_0 = mean(case_x.T_sense(1,:));
end


function [T_0, H] = analyitical_line(case_x)
D  = 0.0254;
Area = (D/2)^2 * pi;
Q_dot = case_x.V * case_x.Amp;
H = Q_dot/(case_x.material.k * Area);
T_0 = mean(case_x.T_sense(1,:));
end
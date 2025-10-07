clear; close all; clc;

% 
aluminium = struct("row", 2810, "cp", 960, "k", 130);
brass     = struct("row", 8500, "cp", 380, "k", 115);
steel     = struct("row", 8000, "cp", 500, "k", 16.2);

%
X0_TO_TH1 = 1.375 * 0.0254;   % Th1 is 1-3/8 in from x0
DX        = 0.5   * 0.0254;   % sensor spacing = 0.5 in
D_ROD     = 1.0   * 0.0254;   % rod diameter = 1 in
A_ROD     = pi*(D_ROD/2)^2;   % cross-sectional area (m^2)

%
case1_data = readmatrix("Aluminum_25V_240mA");
case1 = struct("name","Aluminum 25V 240mA","material",aluminium,"V",25,"Amp",0.240,...
               "t",case1_data(:,1),"T_sense",case1_data(:,2:9));

case2_data = readmatrix("Aluminum_30V_290mA");
case2 = struct("name","Aluminum 30V 290mA","material",aluminium,"V",30,"Amp",0.290,...
               "t",case2_data(:,1),"T_sense",case2_data(:,2:9));

case3_data = readmatrix("Brass_25V_237mA");
case3 = struct("name","Brass 25V 237mA","material",brass,"V",25,"Amp",0.237,...
               "t",case3_data(:,1),"T_sense",case3_data(:,2:9));

case4_data = readmatrix("Brass_30V_285mA");
case4 = struct("name","Brass 30V 285mA","material",brass,"V",30,"Amp",0.285,...
               "t",case4_data(:,1),"T_sense",case4_data(:,2:9));

case5_data = readmatrix("Steel_22V_203mA");
case5 = struct("name","Steel 22V 203mA","material",steel,"V",22,"Amp",0.203,...
               "t",case5_data(:,1),"T_sense",case5_data(:,2:9));

Cases = {case1, case2, case3, case4, case5};

% subplot
figure('Color','w'); sgtitle('Steady-State Temperature Profiles (All Cases)');

for i = 1:numel(Cases)
    subplot(3,2,i);                 % pick subplot pane
    compare_on_axes(Cases{i}, X0_TO_TH1, DX, A_ROD, gca);
end


function compare_on_axes(case_x, X0_TO_TH1, DX, A_ROD, ax)
    Nrows = size(case_x.T_sense,1);
    if Nrows >= 342, idx = 322:342; else, w = min(21, Nrows); idx = (Nrows-w+1):Nrows; end

    T_steady = mean(case_x.T_sense(idx, :), 1, 'omitnan');
    Ns = numel(T_steady);
    x  = X0_TO_TH1 + (0:Ns-1)*DX;

    P     = polyfit(x, T_steady, 1);
    H_exp = P(1);
    T0    = P(2);

    Qdot  = case_x.V * case_x.Amp;
    k     = case_x.material.k;
    H_an  = Qdot / (k * A_ROD);

    hold(ax,'on'); grid(ax,'on');
    p1 = plot(ax, x, T_steady, 'o', 'MarkerSize',6, 'DisplayName','Measured');
    xx = linspace(min(x), max(x), 200);
    p2 = plot(ax, xx, polyval(P,xx), '-', 'LineWidth',1.5, 'DisplayName','Fit: T_0 + Hx');

    xlabel(ax,'x (m)');
    ylabel(ax,'Temperature (°C)');
    title(ax, case_x.name, 'Interpreter','none');

    % —— toolbox-free placement using diff instead of range ——
    xl = xlim(ax); yl = ylim(ax);
    dx = diff(xl); dy = diff(yl);
   legend(ax, [p1 p2], {'Measured','Linear fit'}, 'Location','best');


    fprintf('%s -> T0 = %.2f °C, H_exp = %.3f K/m, H_an = %.3f K/m\n', ...
            case_x.name, T0, H_exp, H_an);
end

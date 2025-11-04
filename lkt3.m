clear; clc; close all;

in2m  = 0.0254;
x_in  = linspace(1.375, 1.375 + 0.5*7, 8);
x     = x_in * in2m;
L     = (max(x_in) + 1) * in2m;
Nmax  = 50;
n     = (1:Nmax).';
lambda = (2*n - 1)*pi/(2*L);

% case data
cases = {
    'Al 25 V', 'Aluminum_25V_240mA', 17.06,  54.948, 4.82e-5
    'Al 30 V', 'Aluminum_30V_290mA', 17.17,  78.789, 4.82e-5
    'Br 25 V', 'Brass_25V_237mA',    16.67, 103.893, 3.56e-5
    'Br 30 V', 'Brass_30V_285mA',    16.92, 149.263, 3.56e-5
    'St 22 V', 'Steel_22V_203mA',    14.41, 242.447, 4.05e-6
};

% figure setup
f = figure('Color','w','Name','Part 3 Task 3 – Model IB vs Model III (TH8)');
tiledlayout(f,3,2,'TileSpacing','compact','Padding','compact');

for k = 1:size(cases,1)
    name     = cases{k,1};
    fname    = cases{k,2};
    T0       = cases{k,3};
    Hexp     = cases{k,4};
    alphaTab = cases{k,5};

    % load data
    T = readtable(fname,'VariableNamingRule','preserve'); 
    T = rmmissing(T);
    t = T{:,1};
    Texp = T{:,2:9};
    t = t - t(1); % start at zero

    % early transient
    tidx = (1:min(200,numel(t)))';

    % model IB
    T_IB_all = transient_all_sensors(t,T0,Hexp,alphaTab,L,n,lambda,x);
    rmse_IB  = rmse_all(T_IB_all,Texp,tidx);

    % optimize alpha
    scale = linspace(0.35,1.85,61);
    alphaGrid = alphaTab * scale;
    rmseGrid  = zeros(size(alphaGrid));
    for m = 1:numel(alphaGrid)
        T_try = transient_all_sensors(t,T0,Hexp,alphaGrid(m),L,n,lambda,x);
        rmseGrid(m) = rmse_all(T_try,Texp,tidx);
    end
    [rmse_MIII,idxBest] = min(rmseGrid);
    alphaBest = alphaGrid(idxBest);

    % final model III
    T_MIII_all = transient_all_sensors(t,T0,Hexp,alphaBest,L,n,lambda,x);

    % RMSE summary
    fprintf('%-12s  RMSE(IB)=%.3f  RMSE(III)=%.3f  α_tab=%.2e  α_opt=%.2e\n',...
        name,rmse_IB,rmse_MIII,alphaTab,alphaBest);

    % plot with error bars
    TH8 = Texp(:,8);
    T_IB_8   = T_IB_all(:,8);
    T_MIII_8 = T_MIII_all(:,8);

    nexttile;
    hold on; 
    grid on; 
    box on;

    idxPlot = 1:max(1,round(numel(t)/50)):numel(t);
    errorbar(t(idxPlot), TH8(idxPlot), 2*ones(size(idxPlot)), 'k.', 'MarkerSize', 4, 'DisplayName', 'TH8 Exp ±2°C');

    plot(t, T_IB_8,   'b-',  'LineWidth', 1.3, 'DisplayName', 'Model IB (α_{tab})');
    plot(t, T_MIII_8, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('Model III (α_{opt}=%.2e)', alphaBest));

    title(name,'FontWeight','bold');
    xlabel('Time (s)');
    ylabel('Temperature (°C)');
    set(gca,'FontSize',9);

    % only first legend
    if k == 1
        leg = legend('Location','southoutside','Orientation','horizontal');
        leg.Box = 'off';
        leg.FontSize = 9;
    else
        legend off
    end
end



sgtitle('Comparison of Model IB and Model III at TH8','FontWeight','bold','FontSize',12);

function Tmat = transient_all_sensors(t,T0,Hexp,alpha,L,n,lambda,x)
    bn = (8*Hexp*L).* ((-1).^n) ./ ((2*n - 1).^2*pi^2);
    sx = sin(lambda .* x(:).');
    Tmat = zeros(numel(t),numel(x));
    for ii = 1:numel(t)
        decay = exp(-(lambda.^2)*alpha*t(ii));
        add = (bn.*decay).*ones(1,size(sx,2));
        Tmat(ii,:) = (T0 + Hexp*x) + sum(add.*sx,1);
    end
end

function val = rmse_all(Tmodel,Texp,tidx)
    D = Tmodel(tidx,:) - Texp(tidx,:);
    val = sqrt(mean(D(:).^2));
end

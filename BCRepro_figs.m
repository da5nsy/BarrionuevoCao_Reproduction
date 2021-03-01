% Code for reproducing figures

% Proposed modification (not coded for):
% Plot absolute component co-efficients and indicate cut-off (0.1)
% Downside: loses sign info, upside: easier to see which are contributing
%   vs which are not, and avoids confusion when analysing (easy to think
%   that higher up the graph = more meaningful, even when below zero).

% TO DO:
% - add SDs 
% - work out how to manage flips
% - refactorize everything (the below is really the same code 4 times over
%       with small tweaks each time)

function [f2,f3] = BCRepro_figs(res,D_CCT_range,imn)

%% General set up

fs = 4; % font size
ms = 3; % marker size

ylb = {'1st Component Coefficients','2nd Component Coefficients','3rd Component Coefficients','4th Component Coefficients','5th Component Coefficients'};

%% Reproduce Figure 2

f2 = figure('units','normalized','outerposition',[0 0 0.4 1]); hold on

%-% First column

CCT_t   = [res([res.level] == 1 & [res.imn] == imn & [res.Tn] == 4).CCT]; % CCT temp
coeff_t = [res([res.level] == 1 & [res.imn] == imn & [res.Tn] == 4).P_coeff]; % coeff temp

markers = {'o','s','^','o'};
legendNames = {'L','M','S','R'};
mfc = {'k','k','k',[1,1,1]}; %marker face color

for j = 1:4
    subplot(4,2,j*2-1), hold on
    plot([0,D_CCT_range(end)],[0,0],'k:','HandleVisibility','off')
 
    for i = 1:4
    plot(CCT_t,coeff_t(i,j:4:end),...
        'Marker',markers{i},'MarkerSize',ms,...
        'MarkerFaceColor',mfc{i},'MarkerEdgeColor',[0,0,0],'color','k',...
        'DisplayName', legendNames{i});
    end
    ylim([-1,1])
    ylabel(ylb(1,j),'FontSize', fs,'fontweight','bold')    
    xticks(D_CCT_range([1,floor(length(D_CCT_range)/2),end]))
    xlim([min(xticks)-1000,max(xticks)+1000])
    xticklabels([])
    if j == 1
        legend('Location','best','FontSize',fs,'Box','off');
    end
    ax = gca; 
    ax.YAxis.FontSize = fs;
end
xticklabels('auto')
ax = gca; 
ax.XAxis.Exponent = 0;
ax.XAxis.FontSize = fs;
xlabel('Illuminant CCT (K)','FontSize',fs+1,'fontweight','bold')

%-% Second column

CCT_t   = [res([res.level] == 2 & [res.imn] == imn & [res.Tn] == 3).CCT]; % CCT temp
coeff_t = [res([res.level] == 2 & [res.imn] == imn & [res.Tn] == 3).P_coeff]; % coeff temp

markers = {'o','^','o'};
legendNames = {'L/(L+M)','S/(L+M)','R/(L+M)'};
mfc = {'k','k',[1,1,1]}; %marker face color

for j = 1:3
    subplot(4,2,j*2+2), hold on
    plot([0,D_CCT_range(end)],[0,0],'k:','HandleVisibility','off')
 
    for i = 1:3
    plot(CCT_t,coeff_t(i,j:3:end),...
        'Marker',markers{i},'MarkerSize',ms,...
        'MarkerFaceColor',mfc{i},'MarkerEdgeColor',[0,0,0],'color','k',...
        'DisplayName', legendNames{i});
    end
    ylim([-1,1])
    ylabel(ylb(1,j),'FontSize', fs,'fontweight','bold')    
    xticks(D_CCT_range([1,floor(length(D_CCT_range)/2),end]))
    xlim([min(xticks)-1000,max(xticks)+1000])
    xticklabels([])
    if j == 1
        legend('Location','best','FontSize',fs,'Box','off');
    end
    ax = gca; 
    ax.YAxis.FontSize = fs;
end
xticklabels('auto')
ax = gca; 
ax.XAxis.Exponent = 0;
ax.XAxis.FontSize = fs;
xlabel('Illuminant CCT (K)','FontSize',fs+1,'fontweight','bold')

subplot(4,2,1)
title('A: First Level Analysis','FontSize', fs+2)

subplot(4,2,4)
title('B: Second Level Analysis','FontSize', fs+2)


%% Reproduce Figure 3

f3 = figure('units','normalized','outerposition',[0 0 0.4 1.2]); hold on

%-% First column

CCT_t   = [res([res.level] == 1 & [res.imn] == imn & [res.Tn] == 5).CCT]; % CCT temp
coeff_t = [res([res.level] == 1 & [res.imn] == imn & [res.Tn] == 5).P_coeff]; % coeff temp

markers = {'o','s','^','o','v'};
legendNames = {'L','M','S','R','I'};
mfc = {'k','k','k',[1,1,1],[1,1,1]}; %marker face color

for j = 1:5
    subplot(5,2,j*2-1), hold on 
    plot([0,D_CCT_range(end)],[0,0],'k:','HandleVisibility','off')
 
    for i = 1:5
    plot(CCT_t,coeff_t(i,j:5:end),...
        'Marker',markers{i},'MarkerSize',ms,...
        'MarkerFaceColor',mfc{i},'MarkerEdgeColor',[0,0,0],'color','k',...
        'DisplayName', legendNames{i});
    end
    ylim([-1,1])
    ylabel(ylb(1,j),'FontSize', fs,'fontweight','bold')    
    xticks(D_CCT_range([1,floor(length(D_CCT_range)/2),end]))
    xlim([min(xticks)-1000,max(xticks)+1000])
    xticklabels([])
    if j == 1
        legend('Location','best','FontSize',fs,'Box','off');
    end
    ax = gca; 
    ax.YAxis.FontSize = fs;
end
xticklabels('auto')
ax = gca; 
ax.XAxis.Exponent = 0;
ax.XAxis.FontSize = fs;
xlabel('Illuminant CCT (K)','FontSize',fs+1,'fontweight','bold')

%-% Second column

CCT_t   = [res([res.level] == 2 & [res.imn] == imn & [res.Tn] == 4).CCT]; % CCT temp
coeff_t = [res([res.level] == 2 & [res.imn] == imn & [res.Tn] == 4).P_coeff]; % coeff temp

markers = {'o','^','o','v'};
legendNames = {'L/(L+M)','S/(L+M)','R/(L+M)','I/(L+M)'};
mfc = {'k','k',[1,1,1],[1,1,1]}; %marker face color

for j = 1:4
    subplot(5,2,j*2+2), hold on
    plot([0,D_CCT_range(end)],[0,0],'k:','HandleVisibility','off')
 
    for i = 1:4
    plot(CCT_t,coeff_t(i,j:4:end),...
        'Marker',markers{i},'MarkerSize',ms,...
        'MarkerFaceColor',mfc{i},'MarkerEdgeColor',[0,0,0],'color','k',...
        'DisplayName', legendNames{i});
    end
    ylim([-1,1])
    ylabel(ylb(1,j),'FontSize', fs,'fontweight','bold')    
    xticks(D_CCT_range([1,floor(length(D_CCT_range)/2),end]))
    xlim([min(xticks)-1000,max(xticks)+1000])
    xticklabels([])
    if j == 1
        legend('Location','best','FontSize',fs,'Box','off');
    end
    ax = gca; 
    ax.YAxis.FontSize = fs;
end
xticklabels('auto')
ax = gca; 
ax.XAxis.Exponent = 0;
ax.XAxis.FontSize = fs;
xlabel('Illuminant CCT (K)','FontSize',fs+1,'fontweight','bold')

subplot(5,2,1)
title('A: First Level Analysis','FontSize', fs+2)

subplot(5,2,4)
title('B: Second Level Analysis','FontSize', fs+2)

end
% Code for reproducing figures

% Proposed modification (not coded for):
% Plot absolute component co-efficients and indicate cut-off (0.1)
% Downside: loses sign info, upside: easier to see which are contributing
%   vs which are not, and avoids confusion when analysing (easy to think
%   that higher up the graph = more meaningful, even when below zero).

% TO DO:
% - add SDs
% - work out how to manage flips

function [f2,f3] = BCRepro_figs(res,D_CCT_range,imn)

%% General set up

fs = 4; % font size
ms = 3; % marker size

ylb = {'1st Component Coefficients','2nd Component Coefficients','3rd Component Coefficients','4th Component Coefficients','5th Component Coefficients'};

%% Reproduce Figure 2

markers = {{'o','s','^','o'},...
    {'o','^','o'},...
    {'o','s','^','o','v'},...
    {'o','^','o','v'}};
legendNames = {{'L','M','S','R'},...
    {'L/(L+M)','S/(L+M)','R/(L+M)'},...
    {'L','M','S','R','I'},...
    {'L/(L+M)','S/(L+M)','R/(L+M)','I/(L+M)'}};
mfc = {{'k','k','k',[1,1,1]},...
    {'k','k',[1,1,1]},...
    {'k','k','k',[1,1,1],[1,1,1]},...
    {'k','k',[1,1,1],[1,1,1]}}; %marker face color

for fig = [2,3] %figures 2 and 3
    if fig == 2        
        f2 = figure('units','pixels','outerposition',[0 0 500 700]); hold on
    elseif fig == 3        
        f3 = figure('units','pixels','outerposition',[0 0 500 800]); hold on
    end
    for col = [1,2]
        panels = 5-col+fig-2; % [4,3,5,4] % number of panels in each column
        pc = (fig-2)*2 + col; % [1,2,3,4] % plot counter
        
        CCT_t   = [res([res.level] == col & [res.imn] == imn & [res.Tn] == panels).CCT];       % CCT temp
        coeff_t = [res([res.level] == col & [res.imn] == imn & [res.Tn] == panels).P_coeff];   % coeff temp
        
        for j = 1:panels
            if col == 1
                subplot(fig+2,2,j*2-1), hold on
            elseif col == 2
                subplot(fig+2,2,j*2+2), hold on
            end
            
            plot([0,D_CCT_range(end)],[0,0],'k:','HandleVisibility','off')
            
            for i = 1:panels
                plot(CCT_t,coeff_t(i,j:panels:end),...
                    'Marker',markers{1,pc}{1,i},'MarkerSize',ms,...
                    'MarkerFaceColor',mfc{1,pc}{1,i},'MarkerEdgeColor',[0,0,0],'color','k',...
                    'DisplayName', legendNames{1,pc}{1,i});
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
        
    end
    subplot(fig+2,2,1)
    title('A: First Level Analysis','FontSize', fs+2)
    
    subplot(fig+2,2,4)
    title('B: Second Level Analysis','FontSize', fs+2)
end

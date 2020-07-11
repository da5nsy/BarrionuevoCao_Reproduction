% Code for reproducing figures

% Proposed modification (not coded for):
% Plot absolute component co-efficients and indicate cut-off (0.1)
% Downside: loses sign info, upside: easier to see which are contributing
%   vs which are not, and avoids confusion when analysing (easy to think 
%   that higher up the graph = more meaningful, even when below zero).

function [f2,f3] = BCRepro_figs(res,D_CCT_range,imn)

% Reproduce figure 2

% TO DO:
% - add plot lines between different CCTs
% - get legends in the right place
% - change x-axis notation

fs = 10; % font size

f2 = figure('units','normalized','outerposition',[0 0 0.4 1]); hold on
ylb = {'1st Component Coefficients','2nd Component Coefficients','3rd Component Coefficients','4th Component Coefficients','5th Component Coefficients'};

for j = 1:4
    subplot(4,2,j*2-1), hold on
    plot([0,D_CCT_range(end)],[0,0],'k:')
    for i = 1:length(res)
        if (min(size(res(i).P_coeff) == [4,4])) && (res(i).level == 1) && (res(i).imn == imn)
            h1 = scatter(res(i).CCT,res(i).P_coeff(1,j),'k','filled',                'MarkerEdgeColor',[0,0,0]);
            h2 = scatter(res(i).CCT,res(i).P_coeff(2,j),'ks','filled',               'MarkerEdgeColor',[0,0,0]);        
            h3 = scatter(res(i).CCT,res(i).P_coeff(3,j),'k^','filled',               'MarkerEdgeColor',[0,0,0]);              
            h4 = scatter(res(i).CCT,res(i).P_coeff(4,j),'MarkerFaceColor',[1,1,1],   'MarkerEdgeColor',[0,0,0]);
        end
    end
    ylim([-1,1])
    ylabel(ylb(1,j),'FontSize', fs)    
end
xlabel('Illuminant CCT (K)')

for j = 1:3
    subplot(4,2,j*2+2), hold on
    plot([0,D_CCT_range(end)],[0,0],'k:')
    for i = 1:length(res)
        if (min(size(res(i).P_coeff) == [3,3])) && (res(i).level == 2) && (res(i).imn == imn)
            h5 = scatter(res(i).CCT,res(i).P_coeff(1,j),'k','filled',                'MarkerEdgeColor',[0,0,0]);
            h6 = scatter(res(i).CCT,res(i).P_coeff(2,j),'k^','filled',               'MarkerEdgeColor',[0,0,0]);             
            h7 = scatter(res(i).CCT,res(i).P_coeff(3,j),'MarkerFaceColor',[1,1,1],   'MarkerEdgeColor',[0,0,0]);
        end
    end
    ylim([-1,1])
    ylabel(ylb(1,j),'FontSize', fs)    
end
xlabel('Illuminant CCT (K)','FontSize', fs)

subplot(4,2,1)
title('A: First Level Analysis','FontSize', fs)
legend([h1 h2 h3 h4],{'L','M','S','R'})

subplot(4,2,4)
title('B: Second Level Analysis','FontSize', fs)
legend([h5 h6 h7],{'L/(L+M)','S/(L+M)','R/(L+M)'})


% - %

% Reproduce figure 3

f3 = figure('units','normalized','outerposition',[0 0 0.4 1]); hold on

for j = 1:5
    subplot(5,2,j*2-1), hold on
    plot([0,D_CCT_range(end)],[0,0],'k:')
    for i = 1:length(res)
        if (min(size(res(i).P_coeff) == [5,5])) && (res(i).level == 1) && (res(i).imn == imn)
            h1 = scatter(res(i).CCT,res(i).P_coeff(1,j),'k','filled',                'MarkerEdgeColor',[0,0,0]);
            h2 = scatter(res(i).CCT,res(i).P_coeff(2,j),'ks','filled',               'MarkerEdgeColor',[0,0,0]);        
            h3 = scatter(res(i).CCT,res(i).P_coeff(3,j),'k^','filled',               'MarkerEdgeColor',[0,0,0]);              
            h4 = scatter(res(i).CCT,res(i).P_coeff(4,j),'MarkerFaceColor',[1,1,1],   'MarkerEdgeColor',[0,0,0]);             
            h5 = scatter(res(i).CCT,res(i).P_coeff(5,j),'v','MarkerFaceColor',[1,1,1],   'MarkerEdgeColor',[0,0,0]);
        end
    end
    ylim([-1,1])
    ylabel(ylb(1,j),'FontSize', fs)    
end
xlabel('Illuminant CCT (K)','FontSize', fs)

for j = 1:4
    subplot(5,2,j*2+2), hold on
    plot([0,D_CCT_range(end)],[0,0],'k:')
    for i = 1:length(res)
        if (min(size(res(i).P_coeff) == [4,4])) && (res(i).level == 2) && (res(i).imn == imn)
            h6 = scatter(res(i).CCT,res(i).P_coeff(1,j),'k','filled',                'MarkerEdgeColor',[0,0,0]);
            h7 = scatter(res(i).CCT,res(i).P_coeff(2,j),'k^','filled',               'MarkerEdgeColor',[0,0,0]);             
            h8 = scatter(res(i).CCT,res(i).P_coeff(3,j),'MarkerFaceColor',[1,1,1],   'MarkerEdgeColor',[0,0,0]);
            h9 = scatter(res(i).CCT,res(i).P_coeff(4,j),'v','MarkerFaceColor',[1,1,1],   'MarkerEdgeColor',[0,0,0]);
        end
    end
    ylim([-1,1])
    ylabel(ylb(1,j),'FontSize', fs)    
end
xlabel('Illuminant CCT (K)','FontSize', fs)

subplot(5,2,1)
title('A: First Level Analysis','FontSize', fs)
legend([h1 h2 h3 h4 h5],{'L','M','S','R','I'})

subplot(5,2,4)
title('B: Second Level Analysis','FontSize', fs)
legend([h6 h7 h8 h9],{'L/(L+M)','S/(L+M)','R/(L+M)','I/(L+M)'})

end
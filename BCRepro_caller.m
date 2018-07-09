clc, clear, close all
% Calls BCRepro_main with appropriate range of inputs

% Load images
load('C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Foster Lab Images\2002\scene3.mat')
im = reflectances; clear reflectances

im = im(1:750,:,:);
% for i=1:31
%     imshow(im(:,:,i))
%     drawnow
%     pause(0.5)
% end

D_CCT=3600:1020:25000; %defined here for ease, but it's actually only and index that gets passed to the main function rather than the CCT itself

res=struct(); %res=results

try load('results.mat')
catch
    tic
    for imn = 1 %!!!!!!!!!!!!!
        for D_ind = 1:21 %!!!!!!!!!!!!
            for level = [1,2]
                if level == 1
                    for Tn = [3,4,5] %LMS,LMSR,LMSRI
                        [res(end+1).P_coeff,res(end+1).P_explained] = BCRepro_main(im,D_ind,level,Tn);
                        res(end).imn     = imn;
                        res(end).D_ind  = D_ind;
                        res(end).CCT    = D_CCT(D_ind);
                        res(end).level  = level;
                        res(end).Tn     = Tn;
                    end
                elseif level == 2
                    for Tn = [2,3,4] %ls,lsr,lsri
                        [res(end+1).P_coeff,res(end+1).P_explained] = BCRepro_main(im,D_ind,level,Tn);
                        res(end).imn     = imn;
                        res(end).D_ind  = D_ind;
                        res(end).CCT    = D_CCT(D_ind);
                        res(end).level  = level;
                        res(end).Tn     = Tn;
                    end
                end
            end
            disp(D_CCT(D_ind))
        end
    end
    res(1)=[];
    
    time_taken=toc;
    
    save('results.mat','res','time_taken')
end

%% Visualisation

% Reproduce figure 2

% TO DO:
% - check out the weird thing at the start (low CCT) of the third component
% - add second level pcas
% - add plot lines
% - go back and add multiple images
% - get legends in the right place
% - add titles

figure, hold on
ylb={'1st Component Coefficients','2nd Component Coefficients','3rd Component Coefficients','4th Component Coefficients'};

for j=1:4
    subplot(4,2,j*2-1), hold on
    plot([0,D_CCT(end)],[0,0],'k:')
    for i=1:length(res)
        if (min(size(res(i).P_coeff) == [4,4])) && (res(i).level == 1)
            h1 = scatter(res(i).CCT,res(i).P_coeff(1,j),'k','filled',                'MarkerEdgeColor',[0,0,0]);
            h2 = scatter(res(i).CCT,res(i).P_coeff(2,j),'ks','filled',               'MarkerEdgeColor',[0,0,0]);        
            h3 = scatter(res(i).CCT,res(i).P_coeff(3,j),'k^','filled',               'MarkerEdgeColor',[0,0,0]);              
            h4 = scatter(res(i).CCT,res(i).P_coeff(4,j),'MarkerFaceColor',[1,1,1],   'MarkerEdgeColor',[0,0,0]);
        end
    end
    ylim([-1,1])
    ylabel(ylb(1,j))    
end
xlabel('Illuminant CCT (K)')

for j=1:3
    subplot(4,2,j*2+2), hold on
    plot([0,D_CCT(end)],[0,0],'k:')
    for i=1:length(res)
        if (min(size(res(i).P_coeff) == [3,3])) && (res(i).level == 2)
            h5 = scatter(res(i).CCT,res(i).P_coeff(1,j),'k','filled',                'MarkerEdgeColor',[0,0,0]);
            h6 = scatter(res(i).CCT,res(i).P_coeff(2,j),'k^','filled',               'MarkerEdgeColor',[0,0,0]);             
            h7 = scatter(res(i).CCT,res(i).P_coeff(3,j),'MarkerFaceColor',[1,1,1],   'MarkerEdgeColor',[0,0,0]);
        end
    end
    ylim([-1,1])
    ylabel(ylb(1,j))    
end
xlabel('Illuminant CCT (K)')

subplot(4,2,1)
title('A: First Level Analysis')
legend([h1 h2 h3 h4],{'L','M','S','R'})


subplot(4,2,4)
title('B: Second Level Analysis')
legend([h5 h6 h7],{'L/(L+M)','S/(L+M)','R/(L+M)'})



% for i=1:length(res)
%     if (min(size(res(i).P_coeff) == [3,3])) && (res(i).level == 1)
%         imshow((res(i).P_coeff+1)/2,'InitialMagnification', 8000)
%         drawnow
%         title(res(i).CCT)
%         pause(0.3)
%     end
% end


%%

% Compare with table 5 of original pub
% It looks as though the third component might have the wrong signs, hmmm
% otherwise everything else matches fairly well

% from pub, for comparison
table5 = [0.49, 0.48, 0.38, 0.45, 0.43;...
    -0.40 -0.38, 0.80, -0.04, 0.20;...
    0.59, -0.08, 0.39, -0.48, -0.48;...
    -0.45, 0.64 0.21, 0.15, -0.54;...
    0.18, -0.45, 0.03, 0.73, -0.48];

% format bank
% P_coeff'-table5
% format

% figure, imshow(abs(P_coeff'-table5),'InitialMagnification', 8000)

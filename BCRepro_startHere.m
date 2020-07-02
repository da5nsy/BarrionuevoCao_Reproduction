clc, clear, close all

%% Load Images

ims = BCRepro_LoadImages; % Loads images, and prints a summary of the memory being used

%% Load Illuminants

% 21 D ills 3600:25000, no mention of interval so assuming the interval
% which gives 21, though an interval of 1020 is weird, and I personally
% would think that a non-linear interval would make more sense.
% (paper shows [3940,5205,6677,24770] on figures)

D_CCT_range = 3600:1020:25000; 

% For readability I should generate the illums here, and then call the
% right one below.

%% PCA
% Currently takes ~25mins to run full set

loadPreviouslyGeneratedResults = 0;

res = struct(); %'res', short for 'results'

if loadPreviouslyGeneratedResults
    load([cd,'\results.mat'])
else
    tic
    for imn = 1:length(ims)
        im = ims(imn).reflectances;
        for D_CCT = D_CCT_range
            [im_LMSRI_c,im_lsri_c] = BCRepro_ComputeRetinalSignals(im,D_CCT);
            for level = [1,2]
                if level == 1
                    for Tn = [3,4,5] %LMS,LMSR,LMSRI
                        [res(end+1).P_coeff,~,~,~,res(end+1).P_explained] = pca(im_LMSRI_c(:,1:Tn));
                        res(end).imn    = imn;
                        res(end).CCT    = D_CCT;
                        res(end).level  = level;
                        res(end).Tn     = Tn;
                    end
                elseif level == 2
                    for Tn = [2,3,4] %ls,lsr,lsri
                        [res(end+1).P_coeff,~,~,~,res(end+1).P_explained] = pca(im_lsri_c(:,1:Tn));
                        res(end).imn    = imn;
                        res(end).CCT    = D_CCT;
                        res(end).level  = level;
                        res(end).Tn     = Tn;
                    end
                end
            end
            %progress indicators:
            disp(imn)
            disp(D_CCT)
        end
    end
    res(1)=[]; % gets rid of empty first entry
    
    time_taken=toc;
    
    save('results.mat','res','time_taken')
end

%% Visualisation

for imn=1:length(ims)
    [f2,f3] = BCRepro_figs(res, D_CCT_range,imn);
    saveas(f2,['figures/f2_im',num2str(imn),'_',datestr(now,'yymmddHHMMSS'),'.tiff'])    
    saveas(f3,['figures/f3_im',num2str(imn),'_',datestr(now,'yymmddHHMMSS'),'.tiff'])
end

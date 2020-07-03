clc, clear, close all

% Currently takes ~15mins to run full set

%% Load Images

ims = BCRepro_LoadImages; % Loads images, and prints a summary of the memory being used

%% Load Illuminants

% 21 D ills 3600:25000, no mention of interval so assuming the interval
% which gives 21, though an interval of 1020 is weird, and I personally
% would think that a non-linear interval would make more sense.
% (paper shows [3940,5205,6677,24770] on figures)

D_CCT_range = 3600:1020:25000; 

load B_cieday B_cieday S_cieday % from PsychToolbox

daylight_spd = zeros(S_cieday(3),length(D_CCT_range));
for i = 1:length(D_CCT_range)
    daylight_spd(:,i) = GenerateCIEDay(D_CCT_range(i),B_cieday);
    daylight_spd(:,i) = daylight_spd(:,i)/max(daylight_spd(:,i));
    %caution: these appear to be linearly upsampled from 10nm intervals
end

%% PCA

loadPreviouslyGeneratedResults = 0;

res = struct(); %'res', short for 'results'

if loadPreviouslyGeneratedResults
    load([cd,'\results.mat'])
else
    tic
    for imn = 1:length(ims)
        im = ims(imn).reflectances;
        for D_CCTi = 1:length(D_CCT_range)
            [im_LMSRI_c,im_lsri_c] = BCRepro_ComputeRetinalSignals(im,daylight_spd(:,D_CCTi),S_cieday);
            for level = [1,2]
                if level == 1
                    for Tn = [3,4,5] %LMS,LMSR,LMSRI
                        [res(end+1).P_coeff,~,~,~,res(end+1).P_explained] = pca(im_LMSRI_c(:,1:Tn));
                        res(end).imn    = imn;
                        res(end).CCT    = D_CCT_range(D_CCTi);
                        res(end).level  = level;
                        res(end).Tn     = Tn;
                    end
                elseif level == 2
                    for Tn = [2,3,4] %ls,lsr,lsri
                        [res(end+1).P_coeff,~,~,~,res(end+1).P_explained] = pca(im_lsri_c(:,1:Tn));
                        res(end).imn    = imn;
                        res(end).CCT    = D_CCT_range(D_CCTi);
                        res(end).level  = level;
                        res(end).Tn     = Tn;
                    end
                end
            end
            %progress indicators:
            disp(imn)
            disp(D_CCT_range(D_CCTi))
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

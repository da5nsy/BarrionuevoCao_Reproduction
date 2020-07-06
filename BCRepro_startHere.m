clc, clear, close all

% Currently takes ~15mins to run full set

loadPreviouslyGeneratedResults = 1;
plt_figuresForIndividualImages = 0; % if not selected only plots data for means (as in original paper)

%% Load Images

ims = BCRepro_LoadImages; % Loads images, and prints a summary of the memory being used

%% Load Illuminants

% 21 D ills, from:
% Linhares, J.M.M. and Nascimento, S.M.C., 2012. A chromatic diversity index based on complex scenes. Journal of the Optical Society of America A, 29(2), p.A174.
% for unclear reasons

D_CCT_range = 3600:1190.3:25000; 

load B_cieday B_cieday S_cieday % from PsychToolbox

daylight_spd = zeros(S_cieday(3),length(D_CCT_range));
for i = 1:length(D_CCT_range)
    daylight_spd(:,i) = GenerateCIEDay(D_CCT_range(i),B_cieday);
    daylight_spd(:,i) = daylight_spd(:,i)/max(daylight_spd(:,i));
    %caution: these appear to be linearly upsampled from 10nm intervals
end

%% PCA

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

%% Results extraction - reproduce the tables

% Table 1

table_inds = [1,3; 2,2; 1,4; 2,3; 1,5; 2,4;];

for i = 1:size(table_inds,1)
    level = table_inds(i,1);
    Tn    = table_inds(i,2); 
    res_t = res([res.level] == level & [res.Tn] == Tn); % results temp. Sub-select data where the above conditions are met
    clear res_t2
    for j = 1:length(res_t)
        res_t2(:,:,j) = res_t(j).P_coeff;
    end
    tables{i} = [mean(res_t2,3)',mean([res_t.P_explained],2)];
    disp(table(tables{i}))
end



%% Visualisation

% WIP!
% [f2,f3] = BCRepro_figs(res_mean, D_CCT_range,1); %imn == 1? Or do we want to handle this in a different way?
% saveas(f2,['figures/f2_',datestr(now,'yymmddHHMMSS'),'.tiff'])
% saveas(f3,['figures/f3_',datestr(now,'yymmddHHMMSS'),'.tiff'])

if plt_figuresForIndividualImages
    for imn=1:length(ims)
        [f2,f3] = BCRepro_figs(res, D_CCT_range,imn);
        saveas(f2,['figures/individualImages/f2_im',num2str(imn),'_',datestr(now,'yymmddHHMMSS'),'.tiff'])
        saveas(f3,['figures/individualImages/f3_im',num2str(imn),'_',datestr(now,'yymmddHHMMSS'),'.tiff'])
    end
end

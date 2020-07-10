clc, clear, close all

% Currently takes ~15mins to run full set

loadPreviouslyGeneratedResults = 1;
plt_figuresForIndividualImages = 0; % if not selected only plots data for means (as in original paper)

%% Load Images

ims = BCRepro_LoadImages; % Loads images, and prints a summary of the memory being used

%% Load Illuminants

% 21 D ills, from:
% Linhares, J.M.M. and Nascimento, S.M.C., 2012. A chromatic diversity index based on complex scenes. Journal of the Optical Society of America A, 29(2), p.A174.
% reason for this specific range is unclear

D_CCT_range = 3600:1190.3:25000;

load B_cieday B_cieday S_cieday % from PsychToolbox

daylight_spd = zeros(S_cieday(3),length(D_CCT_range));
for i = 1:length(D_CCT_range)
    daylight_spd(:,i) = GenerateCIEDay(D_CCT_range(i),B_cieday);
    daylight_spd(:,i) = daylight_spd(:,i)/max(daylight_spd(:,i));
    %caution: these appear to be linearly upsampled from 10nm intervals
end

%% PCA

res = struct(); % Results
im_c = cell(size(ims));

if loadPreviouslyGeneratedResults
    load([cd,'\results.mat'])
else
    tic
    for imn = [1:length(ims),-1] % -1 is the flag for the concatenated image
        if imn ~= -1
            im = ims(imn).reflectances; % pick each image in turn
            im = reshape(im,size(im,1)*size(im,2),size(im,3)); %reshape image - 2D structure is unimportant currently, so reshaping for easier concatenation
            if ismember(imn,[5,6,7,8,9])
                im_t = im(:,2:32); % get rid of un-common spectra (image Temp)
            else
                im_t = im;
            end
            im_c{imn} = im_t;
        else
            im = cell2mat(im_c');
        end
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
            disp(['Image number: ', num2str(imn)])
            fprintf('CCT: %0.1fK\n',D_CCT_range(D_CCTi))
        end
    end
    res(1)=[]; % gets rid of empty first entry
    
    time_taken = toc;
    
    save('results.mat','res','time_taken')
end

%% Results extraction - reproduce the tables

table_inds = [1,3; 2,2; 1,4; 2,3; 1,5; 2,4;];

for i = 1:size(table_inds,1)
    level = table_inds(i,1);
    Tn    = table_inds(i,2);
    res_t = res([res.level] == level & [res.Tn] == Tn & [res.imn] > 0); % results temp. Sub-select data where the above conditions are met, and are for individual images
    res_t2 = zeros([size(res_t(1).P_coeff),size(res_t,2)]);
    for j = 1:length(res_t)
        res_t2(:,:,j) = res_t(j).P_coeff;
    end
    tables{i} = [mean(res_t2,3)',mean([res_t.P_explained],2)];
    %disp(table(tables{i}))
end

% Concatenated image
for i = 1:size(table_inds,1)
    level = table_inds(i,1);
    Tn    = table_inds(i,2);
    res_t = res([res.level] == level & [res.Tn] == Tn & [res.imn] < 0); % results temp. Sub-select data where the above conditions are met, only for the concatenated image
    res_t2 = zeros([size(res_t(1).P_coeff),size(res_t,2)]);
    for j = 1:length(res_t)
        res_t2(:,:,j) = res_t(j).P_coeff;
    end
    tablesc{i} = [mean(res_t2,3)',mean([res_t.P_explained],2)]; %tables for Concatenated image
    %disp(table(tablesc{i}))
end

C = cellfun(@minus,tables,tablesc,'Un',0); % test difference between two methods

%% Visualisation

% For all individual images
if plt_figuresForIndividualImages
    for imn = 1:length(ims)
        [f2,f3] = BCRepro_figs(res, D_CCT_range,imn);
        saveas(f2,['figures/individualImages/f2_im',num2str(imn),'_',datestr(now,'yymmddHHMMSS'),'.tiff'])
        saveas(f3,['figures/individualImages/f3_im',num2str(imn),'_',datestr(now,'yymmddHHMMSS'),'.tiff'])
    end
end

% For the data computed from the concatendated image
[f2,f3] = BCRepro_figs(res, D_CCT_range,length(ims)+1); % 'length(ims)+1' is where the results
saveas(f2,['figures/f2_',datestr(now,'yymmddHHMMSS'),'.tiff'])
saveas(f3,['figures/f3_',datestr(now,'yymmddHHMMSS'),'.tiff'])

% For the average results

% WIP

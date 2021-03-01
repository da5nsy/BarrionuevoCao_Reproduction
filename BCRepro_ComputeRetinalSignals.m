function [im_LMSRI_c,im_lsri_c] = BCRepro_ComputeRetinalSignals(im,daylight_spd,S_cieday)

%% Data

% Set sampling interval metadata
if size(im,ndims(im)) == 31 %2002 images
    S_im = [410,10,31]; 
elseif size(im,ndims(im)) == 33 %2004 images #1:4  
    S_im = [400,10,33];
elseif size(im,ndims(im)) == 32 %2004 image #5   
    S_im = [400,10,32];
else
    error('S_im error')
end

% Observer

% Smith-Pokorny
load([PsychtoolboxRoot, filesep, 'PsychColorimetricData', filesep, 'PsychColorimetricMatFiles', filesep, 'T_cones_sp.mat']) % from PsychToolbox

% Rods
load([PsychtoolboxRoot, filesep, 'PsychColorimetricData', filesep, 'PsychColorimetricMatFiles', filesep, 'T_rods.mat']) % from PsychToolbox

% Melanopsin
% Psychtoolbox's melanopsin function is neither the same as the Lucas+ 2014
% data, which it claims to be in the docs, or the Enezi data which should
% peak at 484. (PsychT = 488nm, Lucas = 490nm)
% And so for simplicity, for now, I'll use psychtoolbox, but remember that
% if the results come out slightly diff, this could be a contributor.
load([PsychtoolboxRoot, filesep, 'PsychColorimetricData', filesep, 'PsychColorimetricMatFiles', filesep, 'T_melanopsin.mat']) % from PsychToolbox

% figure, hold on
% plot(SToWls(S_cones_sp),T_cones_sp)
% plot(SToWls(S_rods),T_rods)
% plot(SToWls(S_melanopsin),T_melanopsin)

% Pull them all together (`SplineCmf` is from PsychToolbox)
T_LMSRI = [(SplineCmf(S_cones_sp,T_cones_sp,S_im));...
    (SplineCmf(S_rods,T_rods,S_im));...
    (SplineCmf(S_melanopsin,T_melanopsin,S_im))];

S_LMSRI = S_im;

% figure, plot(SToWls(S_LMSRI),T_LMSRI)

%% Normalisation

% This code impliments this:

% "The spectral-sensitivity functions of the photopigments
% were normalized [Fig. 1(b)] such that for an equal-energyspectrum
% light at 1 Td, the L-, M-, and S-cone opsins, rhodopsin,
% and melanopsin excitations would be 0.667 (L), 0.333 (M), 1 (S),
% 1 (R), and 1 (I) Td, respectively, (so L + M = 1Td)."

% I think that the primary importance is so that luminance is calculated
% correctly. [ref?] 
% [Probably: Smith, V.C., Pokorny, J., 1975. Spectral sensitivity of the foveal cone photopigments between 400 and 500 nm. Vision Research 15, 161–171. https://doi.org/10.1016/0042-6989(75)90203-5]

% sum(T_LMSRI')
% figure, plot(T_LMSRI')

T_LMSRI = T_LMSRI./sum(T_LMSRI,2); % Normalise so that they are equal

% sum(T_LMSRI')
% figure, plot(T_LMSRI')

T_LMSRI(1,:) = T_LMSRI(1,:)*(2/3); % Knock L down to 2/3
T_LMSRI(2,:) = T_LMSRI(2,:)*(1/3); % Knock M down to 1/3

% sum(T_LMSRI')
% figure, plot(T_LMSRI')

%% Convert to radiance

spd_i = SplineSpd(S_cieday,daylight_spd,S_im,1); %interpolate to match range and interval of Foster images

% figure, hold on, %check interpolation
% scatter(SToWls(S_cieday), daylight_spd, 'DisplayName', 'Original Data')
% scatter(SToWls(S_im), spd_i, 'DisplayName', 'Interpolated Data');
% legend('Location', 'best')

im_r = zeros(size(im));
for i = 1:size(im,2)
    im_r(:,i) = im(:,i) * spd_i(i); %image radiance
end

%im_r = im .* permute(repmat(spd_i,1,748,820),[2,3,1]); % slightly quicker, but less readable

% for i=1:31
%     imshow(im_r(:,:,i))
%     drawnow
%     pause(0.5)
% end

%% Calculate LMSRI and lsri for each pixel

% https://personalpages.manchester.ac.uk/staff/david.foster/Tutorial_HSI2RGB/Tutorial_HSI2RGB.html

im_LMSRI = (T_LMSRI*im_r')';                                         %First level
im_lsri  = im_LMSRI(:,[1,3,4,5]) ./ (im_LMSRI(:,1) + im_LMSRI(:,2)); %Second level 

%% Correction (eq 1)

plt_process     = 0;
plt_correction  = 0;

if plt_process
    
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1:5
        subplot(3,5,i)
        hist(im_LMSRI(:,i),500)
        xlim([0 20])
        ylim([0 25000])
        if i == 1
            ylabel('count')
        end
        xlabel('raw values')
    end
    
    for i = 1:5
        subplot(3,5,5+i)
        hist(log(im_LMSRI(:,i)),500)
        xlim([-3 3])
        ylim([0 6000])
        if i == 1
            ylabel('count')
        end
        xlabel('log')
    end
    
    for i = 1:5
        subplot(3,5,10+i)
        hist(log(im_LMSRI(:,i))-mean(log(im_LMSRI(:,i))),500)
        xlim([-3 3])
        ylim([0 6000])
        if i == 1
            ylabel('count')
        end
        xlabel('log -mean(log)')
        hold on
        plot([0,0],ylim,'k')
    end
    
end

% Equation 1

log_im_LMSRI = log(im_LMSRI); % doing this bit first because in the next section we need to exclude infinite entries (which happen when you get log(0))
log_im_lsri  = log(im_lsri);

if any(any(~isfinite(log_im_LMSRI)))
log_im_LMSRI(~isfinite(log_im_LMSRI)) = min(log_im_LMSRI(isfinite(log_im_LMSRI))); % replace infinite values with minimum finite values
warning('Replacing values of ''-inf'' in log_im_LMSRI with the smallest finite value')
end

if any(any(~isfinite(log_im_lsri)))
log_im_lsri(~isfinite(log_im_lsri)) = min(log_im_lsri(isfinite(log_im_lsri))); % replace infinite values with minimum finite values
warning('Replacing values of ''-inf'' in log_im_lsri with the smallest finite value')
end


% im_LMSRI_c = log(im_LMSRI) - mean(log_im_LMSRI(isfinite(log_im_LMSRI))); %'c' = 'corrected'
% im_lsri_c  = log(im_lsri)  - mean(log_im_lsri(isfinite(log_im_lsri)));   %'c' = 'corrected'

im_LMSRI_c = log_im_LMSRI - mean(log_im_LMSRI);  %'c' = 'corrected'
im_lsri_c  = log_im_lsri  - mean(log_im_lsri);   %'c' = 'corrected'

if plt_correction
    figure,
    hist(im_LMSRI_c,50)
    xlim([-(max(xlim)) max(xlim)]) %smmetrical x-axis
    legend({'L','M','S','R','I'})
end

end


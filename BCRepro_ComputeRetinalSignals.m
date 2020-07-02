function [im_LMSRI_c,im_lsri_c] = BCRepro_ComputeRetinalSignals(im,D_CCT)

%% Data

% Set sampling interval metadata
if size(im,3) == 31 %2002 images
    S_im = [410,10,31]; 
elseif size(im,3) == 33 %2004 images #1:4  
    S_im = [400,10,33];
elseif size(im,3) == 32 %2004 image #5   
    S_im = [400,10,32];
end

% Illuminants

load B_cieday % from PsychToolbox
daylight_spd = GenerateCIEDay(D_CCT,[B_cieday]); 
daylight_spd = daylight_spd/max(daylight_spd);
%caution: these appear to be linearly upsampled from 10nm intervals

% Observer(s)

% Smith-Pokorny
load T_cones_sp % from PsychToolbox

% Rods
load T_rods % from PsychToolbox

% Melanopsin
% Psychtoolbox's melanopsin function is neither the same as the Lucas+ 2014
% data, which it claims to be in the docs, or the Enezi data which should
% peak at 484. (PsychT = 488nm, Lucas = 490nm)
% And so for simplicity, for now, I'll use psychtoolbox, but remember that
% if the results come out slightly diff, this could be a contributor.
load T_melanopsin % from PsychToolbox

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

%% Funky normalisation in original paper

% I don't think this section is required due to a later normalisation, but
% I'll put this here just in case I'm wrong so that it's here to come back
% to if I need to.

%% Convert to radiance

spd_i = SplineSpd(S_cieday,daylight_spd,S_im,1); %interpolate to match range and interval of Foster images

% figure, hold on, %check interpolation
% scatter(SToWls(S_cieday),  spd)
% scatter(SToWls(S_im),      spd_i);

for i = 1:size(im,3)
    im_r(:,:,i) = im(:,:,i)*spd_i(i); %image radiance
end

% for i=1:31
%     imshow(im_r(:,:,i))
%     drawnow
%     pause(0.5)
% end

%% Calculate LMSRI and lsri for each pixel

% https://personalpages.manchester.ac.uk/staff/david.foster/Tutorial_HSI2RGB/Tutorial_HSI2RGB.html

[r,c,w] = size(im_r);
im_rr = reshape(im_r, r*c, w); %Image radiance reshaped

im_LMSRI = (T_LMSRI*im_rr')';                                 %First level
im_lsri=im_LMSRI(:,[1,3,4,5])./(im_LMSRI(:,1)+im_LMSRI(:,2)); %Second level

% If one wanted it reshaped back to the shape of the actual image
% im_LMSRI_shape = reshape(im_LMSRI, r, c, 5); 

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

im_LMSRI_c = log(im_LMSRI)-mean(log(im_LMSRI)); %'c' = 'corrected'
im_lsri_c  = log(im_lsri)-mean(log(im_lsri));   %'c' = 'corrected'

if plt_correction
    figure,
    hist(im_LMSRI_c,50)
    xlim([-(max(xlim)) max(xlim)]) %smmetrical x-axis
    legend({'L','M','S','R','I'})
end

end


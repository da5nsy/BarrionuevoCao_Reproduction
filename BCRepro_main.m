% -WORK IN PROGRESS-
%
% Code to reproduce analysis from:
%
% P. A. Barrionuevo and D. Cao,
% “Contributions of rhodopsin, cone opsins, and melanopsin to
% postreceptoral pathways inferred from natural image statistics,”
% Journal of the Optical Society of America A, vol. 31, no. 4,
% p. A131, Apr. 2014.

% Requires:
% Psychtoolbox (could probs be done without, but it makes it easy)
% Version: 3.0.14 - Flavor: beta - Corresponds to SVN Revision 8424

% TO DO list
% - Second level pca
% - pca not including rods/melanopsin
% - Do I need to do that initial normalisation?
% - Multiple light sources
% - Multiple images
% - Think more about whether the sign inverted row is actually important?
% (Can you just sign invert and it means nothing?)
% - Find a way to programmatically crop out the zeros 
% (re-download data and check whether it is still dodgy)

%%

function [P_coeff,P_explained] = BCRepro_main(im,D_ind,level,Tn)
% im = image
% D_ind = an index for which illuminant to use 
%   (from a series of CCT defined D series illuminants)
% level = which level do you want to do this at? 
%   (1 = LMSRI, 2 = lsri (with luminance removed before analysis)
% Tn = number of sensitivities (T in psychtoolbox terminology)
%   (3/4/5 = LMS/LMSR/LMSRI or 2/3/4 = ls/lsr/lsri)    


%% Load
if ~exist('D_ind','var') %hacky way to clear everything during testing
    clc, clear, close all
end

% Imagery

if ~exist('im','var') %if this script isn't being used as a function...
    
    % default = 2002/scene3
    load('C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Foster Lab Images\2002\scene3.mat')
    im = reflectances; clear reflectances
    disp('using default image')
        
    % Manual cropping, would be good to replace with auto 
    % / find images that don't need cropping
    im = im(1:750,:,:); % (2002/scene3)
    
%     for i=1:31
%         imshow(im(:,:,i))
%         drawnow
%         pause(0.5)
%     end
end
S_im=[410,10,31];


% Illuminants

% 21 D ills 3600:25000, no mention of interval so assuming the interval
% which gives 21, though an interval of 1020 is weird, and I personally
% would think that a non-linear interval would make more sense.
% (paper shows [3940,5205,6677,24770] on figures)
D_CCT=3600:1020:25000; 
load B_cieday
daylight_spd = GenerateCIEDay(D_CCT,[B_cieday]); %caution: these appear to be linearly upsampled from 10nm intervals
for i=1:size(daylight_spd,2) %Normalise. Sure there's a more efficient way to do this with matrix division but I am tired.
    daylight_spd(:,i)=daylight_spd(:,i)/max(daylight_spd(:,i));
end


% Observer(s)

% Smith-Pokorny from CVRL
T_sp = csvread('C:\Users\cege-user\Dropbox\UCL\Data\Colour standards\CVRL cone fundamentals\sp.csv');
T_sp(:,2:4)=(10.^(T_sp(:,2:4)))./max(10.^(T_sp(:,2:4))); %Make non-log, and normalise to peak 1
S_sp=[T_sp(1,1),T_sp(2,1)-T_sp(1,1),length(T_sp)]; %Get wavlength range, and put in psychtoolbox format
T_sp=T_sp(:,2:4)'; %Remove wavelength range
%plot(SToWls(S_sp),T_sp)

% Psychtoolbox version
% % Not using because of 0s at low and high ends.
% % See note on http://docs.psychtoolbox.org/PsychColorimetricMatFiles
% load T_cones_sp
% plot(SToWls(S_cones_sp),T_cones_sp,'o')

% Rods
load T_rods

% Melanopsin
% Psychtoolbox's melanopsin function is neither the same as the Lucas+ 2014
% data, which it claims to be in the docs, or the Enezi data which should
% peak at 484. (PsychT = 488nm, Lucas = 490nm)
% And so for simplicity, for now, I'll use psychtoolbox, but remember that
% if the results come out slightly diff, this could be a contributor.
load T_melanopsin

% figure, hold on
% plot(SToWls(S_sp),T_sp)
% plot(SToWls(S_rods),T_rods)
% plot(SToWls(S_melanopsin),T_melanopsin)

% Pull them all together
T_LMSRI=[(SplineCmf(S_sp,T_sp,S_im));...
    (SplineCmf(S_rods,T_rods,S_im));...
    (SplineCmf(S_melanopsin,T_melanopsin,S_im))];

S_LMSRI=S_im;

% figure, plot(SToWls(S_LMSRI),T_LMSRI)

%% Funky normalisation

% I don't think this section is required due to a later normalisation, but
% I'll put this here just in case I'm wrong so that it's here to come back
% to if I need to.

%% Convert to radiance

if exist('D_ind','var') %if this script is being used as a function, and D_ind has been specified
    spd=daylight_spd(:,D_ind);
else
    spd=daylight_spd(:,4); % default = daylight_spd(:,4) (CCT=6600)
    disp('using default CCT')
end    
spd_i=SplineSpd(S_cieday,spd,S_im,1); %interpolate to match range and interval of Foster images

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

im_LMSRI = im_LMSRI/max(im_LMSRI(:));

% If one wanted it reshaped back to the shape of the actual image
% im_LMSRI_shape = reshape(im_LMSRI, r, c, 5); 

%% Correction (eq 1)

plt_process     = 0;
plt_correction  = 0;

if plt_process
    
    figure,
    for i=1:5
        subplot(3,5,i)
        hist(im_LMSRI(:,i),500)
        xlim([0 1])
        ylim([0 25000])
        if i==1
            ylabel('raw values')
        end
    end
    
    for i=1:5
        subplot(3,5,5+i)
        hist(log(im_LMSRI(:,i)),500)
        xlim([-5 0])
        ylim([0 6000])
        if i==1
            ylabel('log')
        end
    end
    
    for i=1:5
        subplot(3,5,10+i)
        hist(log(im_LMSRI(:,i))-mean(log(im_LMSRI(:,i))),500)
        xlim([-3 3])
        ylim([0 6000])
        if i==1
            ylabel('log -mean(log)')
        end
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

%% PCA

if ~exist('level','var')
    level = 1; %set level, unless we're inside a function
    Tn = 5;
end

if level == 1
    [P_coeff,P_score,P_latent,P_tsquared,P_explained] = pca(im_LMSRI_c(:,1:Tn));
elseif level == 2    
    [P_coeff,P_score,P_latent,P_tsquared,P_explained] = pca(im_lsri_c(:,1:Tn));
end

    
    
    
    
    
    
end
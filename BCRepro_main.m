% Code to reproduce analysis from:
%
% P. A. Barrionuevo and D. Cao, 
% “Contributions of rhodopsin, cone opsins, and melanopsin to 
% postreceptoral pathways inferred from natural image statistics,” 
% Journal of the Optical Society of America A, vol. 31, no. 4, 
% p. A131, Apr. 2014.

%%
clc, clear, close all

% % Load

% Imagery
% Initial version loads only one image, future versions would load multiple
% (original ref uses 9 images)
% chosen this one since the first set has less sidecar (presumably
% calibration files) to deal with)
load('C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Foster Lab Images\2002\scene1.mat')
im = reflectances; clear reflectances

% Illuminants
% 21 D ills 3600:25000, no mention of interval so assuming the interval
% which gives 21, though an interval of 1020 is weird, and I personally 
% would think that a non-linear interval would make more sense.
D_CCT=3600:1020:25000; %but including [3940,5205,6677,24770]
load B_cieday
daylight_spd = GenerateCIEDay(D_CCT,[B_cieday]);
for i=1:size(daylight_spd,2) %Normalise. Sure there's a more efficient way to do this with matrix division but I am tired.
    daylight_spd(:,i)=daylight_spd(:,i)/max(daylight_spd(:,i));
end

% Observer(s)

% Smith-Pokorny from CVRL
T_sp = csvread('C:\Users\cege-user\Dropbox\UCL\Data\Colour standards\CVRL cone fundamentals\sp.csv');
T_sp(:,2:4)=(10.^(T_sp(:,2:4)))./max(10.^(T_sp(:,2:4))); %Make non-log, and normalise to peak 1
%Special normalization !!!!!!!!!!!!
S_sp=[T_sp(1,1),T_sp(2,1)-T_sp(1,1),length(T_sp)]; %Get wavlength range, and put in psychtoolbox format
T_sp=T_sp(:,2:4); %Remove wavelength range
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

%% Calculate LMSRI for each pixel

% https://personalpages.manchester.ac.uk/staff/david.foster/Tutorial_HSI2RGB/Tutorial_HSI2RGB.html

% Correction (eq 1)
% E=log(E0) - mean(log(E0))

%% PCA
%% Stats





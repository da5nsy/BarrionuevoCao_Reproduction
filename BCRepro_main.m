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
D_CCT=3600:1020:25000;
load B_cieday
daylight_spd = GenerateCIEDay(D_CCT,[B_cieday]);
for i=1:size(daylight_spd,2) %Normalise. Sure there's a more efficient way to do this with matrix division but I am tired.
    daylight_spd(:,i)=daylight_spd(:,i)/max(daylight_spd(:,i));
end

% Observer(s)
% Smith Pokorny from CVRL
T_sp = csvread('C:\Users\cege-user\Dropbox\UCL\Data\Colour standards\CVRL cone fundamentals\sp.csv');
T_sp(:,2:4)=(10.^(T_sp(:,2:4)))./max(10.^(T_sp(:,2:4))); %Make non-log, and normalise to peak 1
%Special normalization !!!!!!!!!!!!
S_sp=[T_sp(1,1),T_sp(2,1)-T_sp(1,1),length(T_sp)];
T_sp=T_sp(:,2:4);
%plot(SToWls(S_sp),T_sp)

% Psychtoolbox version
% % Not using because of curtailment at low and high ends.
% % See note on http://docs.psychtoolbox.org/PsychColorimetricMatFiles
% load T_cones_sp
% plot(SToWls(S_cones_sp),T_cones_sp,'o')

%% Calculate LMSRI for each pixel

% https://personalpages.manchester.ac.uk/staff/david.foster/Tutorial_HSI2RGB/Tutorial_HSI2RGB.html

%% PCA
%% Stats





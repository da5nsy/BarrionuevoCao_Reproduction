clc, clear, close all
% BCRepro_caller calls BCRepro_main

load('C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Foster Lab Images\2002\scene3.mat')
im = reflectances; clear reflectances

im = im(1:750,:,:);
% for i=1:31
%     imshow(im(:,:,i))
%     drawnow
%     pause(0.5)
% end

%Reminder:
D_CCT=3600:1020:25000;
%D_ind=4; %Choose the D_CCT

for D_ind=1:length(D_CCT)
    coeff(:,:,D_ind) = BCRepro_main(im, D_ind)';
    disp(D_CCT(D_ind))
end

%%

% format bank
% P_coeff'
% format

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

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


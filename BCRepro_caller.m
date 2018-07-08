% BCRepro_caller calls BCRepro_main

load('C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Foster Lab Images\2002\scene3.mat')
im = reflectances; clear reflectances

% Urghhhh, so there's some weird banding artefacts with the images. Not sure
% what's going on. For now I just crop the zeros out.
im = im(1:750,:,:);
% for i=1:31
%     imshow(im(:,:,i))
%     drawnow
%     pause(0.5)
% end

%Reminder: D_CCT=3600:1020:25000;
D_ind=4; %Choose the D_CCT 

coeff = BCRepro_main(im, D_ind)' 


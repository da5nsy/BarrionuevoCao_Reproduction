clc, clear, close all
% Calls BCRepro_main with appropriate range of inputs

% Load images
load('C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Foster Lab Images\2002\scene3.mat')
im = reflectances; clear reflectances

im = im(1:750,:,:);
% for i=1:31
%     imshow(im(:,:,i))
%     drawnow
%     pause(0.5)
% end

D_CCT=3600:1020:25000; 

% Reminder: [P_coeff,P_explained] = BCRepro_main(im,D_ind,level,Tn)

% prints out everything
%   haven't worked out the best way to store these differently shaped
%   variables yet

res=struct(); %res=results

tic
for imn = 1 %!!!!!!!!!!!!!
    for D_ind = 1:21 %!!!!!!!!!!!!
        for level = [1,2]
            if level == 1
                for Tn = [3,4,5] %LMS,LMSR,LMSRI
                    [res(end+1).P_coeff,res(end+1).P_explained] = BCRepro_main(im,D_ind,level,Tn);
                    res(end).imn     = imn;
                    res(end).D_ind  = D_ind;
                    res(end).CCT    = D_CCT(D_ind);
                    res(end).level  = level;
                    res(end).Tn     = Tn;
                end
            elseif level == 2
                for Tn = [2,3,4] %ls,lsr,lsri
                    [res(end+1).P_coeff,res(end+1).P_explained] = BCRepro_main(im,D_ind,level,Tn);
                    res(end).imn     = imn;
                    res(end).D_ind  = D_ind;
                    res(end).CCT    = D_CCT(D_ind);
                    res(end).level  = level;
                    res(end).Tn     = Tn;
                end
            end            
        end
        %disp(D_CCT(D_ind))
    end
end

res(1)=[];
%end
time_taken=toc;

save('res.mat','res')


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

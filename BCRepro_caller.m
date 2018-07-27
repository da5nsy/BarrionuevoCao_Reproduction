% Calls BCRepro_main with appropriate range of inputs, 
% and visualizes results

clc, clear, close all

show_ims = 0; %choose whether to show visuals of images

% Load images
base = 'C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Foster Images\';
for i=1:4 %2002 images
    ims(i)=load([base, '2002\scene',num2str(i),'.mat']); %imageS
end
%2004 images
ims(5)=load([base,'2004\scene1\ref_crown3bb_reg1.mat']);
ims(6)=load([base,'2004\scene2\ref_ruivaes1bb_reg1.mat']);
ims(7)=load([base,'2004\scene3\ref_mosteiro4bb_reg1.mat']);
ims(8)=load([base,'2004\scene4\ref_cyflower1bb_reg1.mat']);
ims(9)=load([base,'2004\scene5\ref_cbrufefields1bb_reg1.mat']);
% for i=1:9
%     figure,imagesc(im(i).reflectances(:,:,17)); colormap('gray'); brighten(0.5);
% end
memory %check how much memory is being used

% if show_ims
%     for i=1:9
%         figure,imagesc(ims(i).reflectances(:,:,17)); colormap('gray'); brighten(0.5);
%     end
% end

% 21 D ills 3600:25000, no mention of interval so assuming the interval
% which gives 21, though an interval of 1020 is weird, and I personally
% would think that a non-linear interval would make more sense.
% (paper shows [3940,5205,6677,24770] on figures)
D_CCT_range=3600:1020:25000; 

%% Call function

% Currently takes ~25mins to run full set
% Top tip: make sure all the figures are turned off in the main script.
%   MATLAB does not enoy opening 1134 figures simultaneously.

res=struct(); %'res', short for 'results'

try load('C:\Users\cege-user\Dropbox\Documents\MATLAB\BarrionuevoCao_Reproduction\results.mat')
catch
    tic
    for imn = 1:length(ims)
        im=ims(imn).reflectances;
        for D_CCT = D_CCT_range
            for level = [1,2]
                if level == 1
                    for Tn = [3,4,5] %LMS,LMSR,LMSRI
                        [res(end+1).P_coeff,res(end+1).P_explained] = BCRepro_main(im,D_CCT,level,Tn);
                        res(end).imn    = imn;
                        res(end).CCT    = D_CCT;
                        res(end).level  = level;
                        res(end).Tn     = Tn;
                    end
                elseif level == 2
                    for Tn = [2,3,4] %ls,lsr,lsri
                        [res(end+1).P_coeff,res(end+1).P_explained] = BCRepro_main(im,D_CCT,level,Tn);
                        res(end).imn    = imn;
                        res(end).CCT    = D_CCT;
                        res(end).level  = level;
                        res(end).Tn     = Tn;
                    end
                end
            end
            %progress indicators:
            disp(imn)
            disp(D_CCT)
        end
    end
    res(1)=[];
    
    time_taken=toc;
    
    save('results.mat','res','time_taken')
end

%% Visualisation

for imn=1:length(ims)
    [f2,f3] = BCRepro_figs(res, D_CCT_range,imn);
    saveas(f2,['f2_im',num2str(imn),'_',datestr(now,'yymmddHHMMSS'),'.tiff'])    
    saveas(f3,['f3_im',num2str(imn),'_',datestr(now,'yymmddHHMMSS'),'.tiff'])
end

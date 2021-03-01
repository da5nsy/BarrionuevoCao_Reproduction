function ims = BCRepro_LoadImages
  
  % Load the images.
  % Originally written in MATLAB - see comments about things that work in MATLAB but have been commented out for Octave compatibility.

show_ims = 0; %choose whether to show visuals of images

% Load images

% base = uigetdir(cd,'Select Image Data Folder'); %works in MATLAB but there is an Octave bug (on Windows) that means it doesn't currently work (https://savannah.gnu.org/bugs/?58521)
base = fullfile('C:','Users','cege-user','Dropbox','UCL','Data','Reference Data','Foster Images');

for i = 1:4 %2002 images
    ims(i) = load([base, filesep, '2002', filesep, 'scene', num2str(i), '.mat']); %imageS
end
%2004 images
ims(5) = load(fullfile(base,'2004','scene1','ref_crown3bb_reg1.mat'));
ims(6) = load(fullfile(base,'2004','scene2','ref_ruivaes1bb_reg1.mat'));
ims(7) = load(fullfile(base,'2004','scene3','ref_mosteiro4bb_reg1.mat'));
ims(8) = load(fullfile(base,'2004','scene4','ref_cyflower1bb_reg1.mat'));
ims(9) = load(fullfile(base,'2004','scene5','ref_cbrufefields1bb_reg1.mat'));

% memory %check how much memory is being used %commented out because this function is not currently implemented in Octave

if show_ims
    for i = 1:9
        figure,
        imagesc(ims(i).reflectances(:,:,17)); 
        colormap('gray'); 
        brighten(0.5);
    end
end

end
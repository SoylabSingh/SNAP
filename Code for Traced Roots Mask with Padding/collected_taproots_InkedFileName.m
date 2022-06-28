clear all
clc
% filelist with extension *.jpg
filelist=dir('Traced Roots/*.jpg');
% create output directory
output_directory = 'traced_tap_binary_padded';
mkdir(output_directory);

patchsize = 256;
for i=1:length(filelist)
    if endsWith(filelist(i).name,'LI.jpg')
        Im=imread(fullfile(filelist(i).folder,filelist(i).name));
        size(Im)
        filenamea=erase(filelist(i).name,'_LI.jpg');
        filenameb=erase(filenamea,'Inked');
        % identifying tap root
        [BWa,~]=createMask_tap(Im);
        % add padding
        [h1,w1]=size(BWa);
        pad_r = ceil(h1/patchsize)*patchsize-h1;
        pad_c = ceil(w1/patchsize)*patchsize-w1;
        BW = padarray(BWa,[pad_r pad_c],0,'post');
        % save image
        imwrite(BW,fullfile(output_directory,strcat(filenameb,'.png')));
    end
end
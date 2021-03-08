% This script takes detected nodule spatial information on the image and 
% binary image of the tap root as input, perform some image processing on 
% tap root images and identify the nodules near or on the tap root and 
% store the information in a csv file.

clearvars
clc
addpath('../sample_outputs/nodules')
filelist=dir('../sample_outputs/tap_roots/*.png');

if ~exist('../sample_outputs/counts','dir')
    mkdir('../sample_outputs/counts');
end

if ~exist('../sample_outputs/nodules_on_tap_root','dir')
    mkdir('../sample_outputs/nodules_on_tap_root');
end


tap_nod_count=[];
total_nod_count=[];
imagename_list={};

for i=1:length(filelist)
    % read tap root
    Im=imread(fullfile(filelist(i).folder,filelist(i).name));
    BW = imbinarize(Im);
    filenamea=erase(filelist(i).name,'.png');
    % collect detected nodules info
    imagename_list{end+1}=strcat(filenamea,'.JPG');
    detected_data = strcat(filenamea,'.csv');
    nodule_data=importfile_read(detected_data,1);
    nod_cor=[uint16(nodule_data.xc),uint16(nodule_data.yc)];
    nod_area = [uint16(nodule_data.area)];
    total_nod_count(end+1)=size(nod_area,1);
 
    % tap root analysis
    
    % dilate tap root
    se = strel('disk',20);
    BWa = imdilate(BW,se);
    [rows,cols] = find(BWa);
    rootseg=[cols,rows];
    % Find how many nodule center matches with the co-ordinate
    [C,ia,ib] = intersect(rootseg,nod_cor,'rows');
    C_area = nod_area(ib);
    
    if (C_area>0)
        % visualization
        figure(1);
        imshow(Im);
        title(strcat(filenamea,': all nodules (red) nodules on tap root (green box)'),'FontSize',8)
        hold on;
        scatter(uint16(nodule_data.xc),uint16(nodule_data.yc),'*r');
        scatter(C(:,1),C(:,2),'sg');
        saveas(gcf,fullfile('../sample_outputs/nodules_on_tap_root/',strcat(filenamea,'.png')));
        tap_nod_count(end+1)=size(ib,1);
        hold off;  
        else
        % visualization
        figure(1);
        imshow(Im);
        title(strcat(filenamea,': all nodules (red) nodules on tap root (green box)'),'FontSize',8)
        hold on;
        scatter(uint16(nodule_data.xc),uint16(nodule_data.yc),'*r');
        saveas(gcf,fullfile('../sample_outputs/nodules_on_tap_root/',strcat(filenamea,'.png')));
        tap_nod_count(end+1)=size(ib,1);
        hold off;  
    end
end
close all;
T = table(imagename_list',total_nod_count',tap_nod_count','VariableNames', {'imagename', 'total','on_tap_root'});
writetable(T,'../sample_outputs/counts/nodules_distribution.csv')    

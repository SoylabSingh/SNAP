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

% original image directory
original = '../sample_images/';

tap_nod_count=[];
total_nod_count=[];
tap_length =[];
imagename_list={};

N = length(filelist);
all_data = cell(1,N);
    
for i=1:length(filelist)
    % read tap root
    Im=imread(fullfile(filelist(i).folder,filelist(i).name));
    if ~isa(Im,'logical')
        BW = imbinarize(Im);
    else
        BW=Im;
    end
    % remove other root segments and reconstruct missing part of taproot 
    BW = remove_reconstruction(BW);
    filenamea=erase(filelist(i).name,'.png');
    % get reconstructed taproot length(skeltonization and total pixel count)
    % collect detected nodules info
    tap_len= measure_tap_root_length(BW);
    
    imagename_list{end+1}=strcat(filenamea,'.JPG');
    detected_data = strcat(filenamea,'.csv');
    nodule_data=importfile_read(detected_data,1);
    nod_cor=[uint16(nodule_data.xc),uint16(nodule_data.yc)];
    nod_area = [uint16(nodule_data.area)];
    total_nod_count(end+1)=size(nod_area,1);
    
    imagenames ={};
    % preparing for merging all csvs including tap root info
    for k =1:size(nod_cor,1)
        imagenames{end+1}=strcat(filenamea,'.JPG');
    end
    
    % tap root analysis
    tap_root_id = zeros(size(nod_cor,1),1);
    % dilate tap root
    se = strel('disk',20);
    BWa = imdilate(BW,se);
    [rows,cols] = find(BWa);
    rootseg=[cols,rows];
    % find how many nodule center matches with the co-ordinate
    [C,ia,ib] = intersect(rootseg,nod_cor,'rows');
    C_area = nod_area(ib);
    tap_root_id(ib)=1;
    
    nodule_data.tap_root_id = tap_root_id;
    nodule_data.imagename = imagenames';
    %nodule_data.VarName1=[]
    all_data{i} = nodule_data;
    
    if (size(C_area,1)>0)
        % visualization
        % read original image
        I_ori=imread(strcat(original,filenamea,'.JPG'));
        BW_ori = BW(1:size(I_ori,1),1:1:size(I_ori,2));
        figure(1);
        %imshow(BW)
        imshow(I_ori+uint8(255*repmat(BW_ori,[1 1 3])));
        title(strcat(filenamea,': all nodules (red) nodules on tap root (green box)'),'FontSize',8)
        hold on;
        scatter(uint16(nodule_data.xc),uint16(nodule_data.yc),'*r');
        scatter(C(:,1),C(:,2),'sg');
        saveas(gcf,fullfile('../sample_outputs/nodules_on_tap_root/',strcat(filenamea,'.png')));
        tap_nod_count(end+1)=size(ib,1);
        tap_length(end+1)=tap_len;
        hold off;  
        else
        % visualization
        figure(1);
        I_ori=imread(strcat(original,filenamea,'.JPG'));
        BW_ori = BW(1:size(I_ori,1),1:1:size(I_ori,2));
        figure(1);
        %imshow(BW)
        imshow(I_ori+uint8(255*repmat(BW_ori,[1 1 3])));
        title(strcat(filenamea,': all nodules (red) nodules on tap root (green box)'),'FontSize',8)
        hold on;
        scatter(uint16(nodule_data.xc),uint16(nodule_data.yc),'*r');
        saveas(gcf,fullfile('../sample_outputs/nodules_on_tap_root/',strcat(filenamea,'.png')));
        tap_nod_count(end+1)=size(ib,1);
        tap_length(end+1)=tap_len;
        hold off;  
    end
end
close all;
T = table(imagename_list',total_nod_count',tap_nod_count',tap_length','VariableNames', {'imagename', 'total','on_tap_root','tap_length'});
writetable(T,'../sample_outputs/counts/nodules_distribution_summary.csv') 

T_all = vertcat(all_data{:});
writetable(T_all,'../sample_outputs/counts/nodules_distribution.csv') 

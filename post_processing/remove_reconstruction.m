function [BWr] = remove_reconstruction(BW)
%This function take detected tap root as input and removes the roots other
%than tap root and reconstruct missing part of the tap root using spanning

% identify median of the column values of the largest connected compononets
% skeletonize and remove root part which centroid is two std away from the median valu
%I = imread('Sample8.png');
%BW = imbinarize(I);
%skeBW = bwmorph(BW,'skel','inf');
CC = bwconncomp(BW,8); %locates all connected components

numPixels = cellfun(@numel,CC.PixelIdxList);
numPixels_s = sort(numPixels,'descend');
Tap1 = zeros(size(BW ));idx = numPixels == numPixels_s(1);Tap1(CC.PixelIdxList{idx}) = 1;
[y,x]=find(Tap1);
cmean = mean(x);
cstd =  std(x);

% % skeletonize and remove root part which centroid is two std away from the median value
BW2= BW;
% other components expect biggest middle part
BW2(CC.PixelIdxList{idx})=0;
CC = bwconncomp(BW2,8); %locates all connected components
S = regionprops(CC,'Centroid');


% components within cetrain distance from the largest one
cmax = max(x);
cmin = min(x);
th = 100;

for i=1:size(S)
    if abs(S(i).Centroid(:,1)-cmean)>cstd
        BW2(CC.PixelIdxList{i}) = 0;
    end
    
    dummy = zeros(size(BW2 ));
    dummy(CC.PixelIdxList{i}) = 1;
    [yd,xd]=find(dummy);
    cmaxd = max(xd);
    cmind = min(xd);
    
    if ((abs(cmaxd-cmax)<th) ||(abs(cmind-cmax)<th) ||(abs(cmaxd-cmin)<th)||(abs(cmind-cmin)<th))
        BW2(CC.PixelIdxList{i}) = 1;
    end
end    

BW2=BW2+Tap1;

imshowpair(BW,BW2,'montage');

skeBW3 = bwmorph(BW2,'skel','inf');
skeBW3 = bwmorph(skeBW3,'clean');
% creating a synthetic case
%skeBW3(1500:2000,:)=0;
%imshowpair(skeBW2,skeBW3);

% identify connected components and endpoints
% create a distance matrix among the endpoints
    % set distance between endpoints of the same connected components to 1(very low)
  
% prune spur segments to remove artificial endpoints
skeBW4=bwmorph(skeBW3,'spur',20);
% find the number of connect components
CC = bwconncomp(skeBW4,8);

if CC.NumObjects>1
    %disp('reconstruction is required')
    %CC.NumObjects;
sizes = [];%number of endpoints per segments

for i = 1:CC.NumObjects
    S_dummy=zeros(size(skeBW4));
    S_dummy(CC.PixelIdxList{i}) = 1;
    %figure;imshow(S_dummy);
    BP=bwmorph(S_dummy,'endpoints');
    % figure;imshow(BP);
    [yball,xball]=find(BP);
    %figure;imshow(S_dummy);hold on; plot(xball,yball,'*g');
    A = [yball,xball];
    sizes(end+1)=size(yball,1);
    if i ==1
    Aall = A;
    else
    Aall =vertcat(Aall,A);
    end
end

% create the distance matrix
D1 = pdist(Aall);
Z = squareform(D1);Zold=Z;

% force the points in the same connected components small value

% force the points in the same connected components small value
c_sizes = cumsum(sizes)
for k=1:size(sizes,2)
    % for endpoints of first connected components
   if k==1
   Z(1:c_sizes(1) ,1:c_sizes(1))=1;
   end
    
   if ((k<size(sizes,2)-1)&&(k~=1))
       Z(c_sizes(k-1)+1:c_sizes(k) ,c_sizes(k-1)+1:c_sizes(k))=1;
   end
   % for endpoints of last connected components
   if k==size(sizes,2)
      Z(c_sizes(k-1)+1:end,c_sizes(k-1)+1:end)=1;
   end
   
end


% make sure the diagoal is zero
for i=1:size(Z,1)
Z(i,i)=0;
end
% convert back to the linear form
D = squareform(Z);

% D stores values of the lower triangle of the Z
X =[];
Y=[];
% create points and array (lower triangle matrix
for k = 1:size(Z,1)-1
    for kk = k+1:size(Z,1)
        X(end+1)=kk;
        Y(end+1)=k;
    end
end

% create graph and find minimum spanning tree
G = graph(X,Y,D);
%p = plot(G,'EdgeLabel',G.Edges.Weight);
[T,~] = minspantree(G);

% find the edges that connect two root segments (with value higher than 1 Edges weight) 
S = table2array(T.Edges);
S1 = find(S(:,3)>1);
%skeBW5=skeBW4;
skeBW5 = zeros(size(BW2 ));
% bresenham algorithm to join to points 
% loop through all the possible joints
for i=1:size(S1,1)
    node1=Aall(S(S1(i),1),:);
    node2=Aall(S(S1(i),2),:);
    [px,py]=bresenham(node1(1),node1(2),node2(1),node2(2));
    for j = 1:size(px,1)
    skeBW5(px(j),py(j))=1;
    end
end

%imshowpair(skeBW4,skeBW5)
% merge the dilated image with the 
se = strel('disk',20);
extended = imdilate(skeBW5,se);
%BWr = imdilate(skeBW5,se);
BWr = BW2 + extended;
%imshowpair(BW,BWr,'montage')
%pause;
else
    %disp('no reconstruction is needed')
    %se = strel('disk',20);
    %BWr = imdilate(skeBW3,se);
    BWr = BW2;
    %imshowpair(BW,BWr,'montage')
    %pause;
end
end


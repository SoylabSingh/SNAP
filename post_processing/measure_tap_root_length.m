function [tap_len] = measure_tap_root_length(BW)
%skeletontize input image, remove spurious branches, then calculate length
skel=bwmorph(BW,'skel','inf');
B = bwmorph(skel, 'branchpoints');
E = bwmorph(skel, 'endpoints');
[y,x] = find(E);
B_loc = find(B);
Dmask = false(size(skel));
for k = 1:numel(x)
    D = bwdistgeodesic(skel,x(k),y(k));
    distanceToBranchPt = min(D(B_loc));
    Dmask(D < distanceToBranchPt) =true;
end
skelD = skel - Dmask;
figure(10);
imshow(BW);
hold on;
[y,x] = find(skelD); scatter(x,y,5,'r*');
hold off;
tap_len = bwarea(skelD);
end


%% Read In a File 
I_cam = imread('C:\Users\Carlos\Google Drive\MASTER\MASTER\Semestre 2\Percepcion\Plantilla\plantilla_sudoku.png');
imshow(I_cam);
I_cam = imresize(I_cam,2);

%% Crop the Image (1) 
hold on
h_g = plot(90+[0 460 460 0 0],5+[0 0 460 460 0],'g');
hold off

%% Crop the Image (2) 

I = I_cam(5+(1:460),90+(1:460));
imshow(I);

%% Convert to Black and White 
makebw = @(I) im2bw(I.data,median(double(I.data(:)))/1.2/255);
I = ~blockproc(I,[92 92],makebw);

imshow(I);

%% Remove Noise
I = bwareaopen(I,30);
imshow(I);
%% Clear the border 
I = imclearborder(I);
imshow(I);

%% Find the largest box 
hold on;
R = regionprops(I,'Area','BoundingBox','PixelList');
NR = numel(R);

maxArea = 0;
for k = 1:NR
    A(k) = prod(R(k).BoundingBox(3:4));
    if R(k).Area > maxArea
        maxArea = R(k).Area;
        kmax = k;
    end
end

BBmax = R(kmax).BoundingBox;
DIAG1 = sum(R(kmax).PixelList,2);
DIAG2 = diff(R(kmax).PixelList,[],2);

[m,dUL] = min(DIAG1);    [m,dDR] = max(DIAG1);
[m,dDL] = min(DIAG2);    [m,dUR] = max(DIAG2);

pts = R(kmax).PixelList([dUL dDL dDR dUR dUL],:);
h_pts = plot(pts(:,1),pts(:,2),'m','linewidth',3);

XYLIMS = [BBmax(1) + [0 BBmax(3)] BBmax(2) + [0 BBmax(4)]];

%% Identify objects inside the box 
A_tmin = 30; % Bounds for the digit pixel area
A_tmax = 1000;
digitbox_minarea = 20; % Bounds for the digit bounding box area
digitbox_maxarea = 25^2;

kgood = zeros(1,NR);
Pnew = zeros(NR,2);
        for k = 1:NR
            if R(k).Area < A_tmax && A(k) > digitbox_minarea && A(k) < digitbox_maxarea ...
                    && R(k).BoundingBox(3) < 40 && R(k).BoundingBox(4) < 40 ...
                    && R(k).BoundingBox(3) > 1 && R(k).BoundingBox(4) > 1
                
                Pnew(k,:) = [R(k).BoundingBox(1)+R(k).BoundingBox(3)/2 R(k).BoundingBox(2)+R(k).BoundingBox(4)/2];
                
                
                if inpolygon(Pnew(k,1),Pnew(k,2),pts(:,1),pts(:,2))
                    h_digitcircles(k) = plot(Pnew(k,1),Pnew(k,2),'ro','markersize',24);
                end
                
            end
        end


%% Draw the grid based on the corners

T = cp2tform(pts(1:4,:),0.5 + [0 0; 9 0; 9 9; 0 9],'projective');
for n = 0.5 + 0:9, [x,y] = tforminv(T,[n n],[0.5 9.5]); plot(x,y,'g'); end
for n = 0.5 + 0:9, [x,y] = tforminv(T,[0.5 9.5],[n n]); plot(x,y,'g'); end
%% Only keep elements in the boxes 
T = cp2tform(pts(1:4,:),[0.5 0.5; 9.5 0.5; 9.5 9.5; 0.5 9.5],'projective');
Plocal = (tformfwd(T,Pnew));
Plocal = round(2*Plocal)/2;

del = find(sum(Plocal - floor(Plocal) > 0 |  Plocal < 1 | Plocal > 9,2)) ;
Pnew(del,:) = [];


%% Show the coordinate transforms 
figure;
T = cp2tform(pts(1:4,:),500*[0 0; 1 0; 1 1; 0 1],'projective');
NT = imtransform(double(I),T);
imshow(NT);
%% Show the template data 
figure;

for n = 1:9
    subplot(3,3,n),imagesc(NT{n});
end
colormap gray;
%% Calculate the Solution 


Plocal = identifynumbers_fun(pts,Pnew,NT,I);
M = zeros(9);
for k = 1:size(Plocal,1)
    M(Plocal(k,2),Plocal(k,1)) = Plocal(k,3);
end
M_sol = drawgraph(M);

%% Generate an image from the solution 
I = solution2image(M,M_sol);
figure; imshow(I);
%% Overlay the solution on the original image

figure(1); 
clf;

T = cp2tform([1 1; 200 1; 200 200; 1 200],[pts(1:4,1),pts(1:4,2)],'projective');
I = imtransform(~I,T,'XData',[1 460], 'YData',[1 460],'XYscale',1);

Imask = zeros(480,640);
Imask(10 + (1:460), 90+(1:460)) = I;
Imask = I_cam .* uint8(~Imask);

h = imshow(cat(3,I_cam,Imask,I_cam));
set(h,'Cdatamapping','direct');

hold on;
plot(90 + pts(:,1), 10 + pts(:,2),'m')
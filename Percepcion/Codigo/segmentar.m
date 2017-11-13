function I = segmentar(I)
%% Convertir a blanco y negro
makebw = @(I) im2bw(I.data,median(double(I.data(:)))/1.2/255);
I = ~blockproc(I,[100 100],makebw);
%% Eliminar el ruido
I = bwareaopen(I,30);
%% Eliminar bordes
I = imclearborder(I);

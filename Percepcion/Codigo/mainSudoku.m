 % Funcion principal de ejecucion del sudoku
clear 
close all
clc
imaqreset

%% CREACION DEL VIDEO
vid = videoinput('winvideo', 1 ,'YUY2_640x480');
set(vid,'ReturnedColorSpace','rgb');
set(vid,'TriggerRepeat',Inf);
set(vid,'FramesPerTrigger',1);
vidRes = vid.VideoResolution; 
start(vid)

%% Variables
enunciado = zeros(9,9);
validez = zeros(9,9);
contador = 0;
global solucionEncontrada 
solucionEncontrada = 0;
FIABLE = 1;
AJUSTE = 1.4;
% Dimensiones de la region de deteccion
resolx = vidRes(1)-20;
resoly = vidRes(2)-20;
posx = (vidRes(1)-resolx)/2;
posy =  (vidRes(2)-resoly)/2;
% Cargar plantillas
plantillas = cargarPlantillas;
    
% Boton para reset
btn = uicontrol('Style', 'pushbutton', 'String', 'Reset',...
        'Position', [20 20 50 20],...
        'Callback', @pushbutton1_Callback); 
    
%% Estudio de los frames
while islogging(vid)   
    tic;
    hold off;

    %% Capturar frame
    imagen = getsnapshot(vid);
    
    %% Segmentar frame
    tiempoFrame = tic;
    % Recortar imagen
    imRegion = imagen(posy+(1:resoly),posx+(1:resolx),1);
    % Eliminar cache de cam
    flushdata(vid);
    % Convertir a blanco y negro
    makebw = @(imRegion) im2bw(imRegion.data,...
        median(double(imRegion.data(:)))/AJUSTE/255);
    imSegmentada = ~blockproc(imRegion,[92 92],makebw);
    % Eliminar el ruido
    imSegmentada = bwareaopen(imSegmentada,30);
    % Eliminar bordes
    imSegmentada = imclearborder(imSegmentada);

    tiempoFrame = toc(tiempoFrame);
    
    %% Se comprueba si existe un sudoku que analizar
    tiempoHaySudoku = tic;
    [verticesOriginales,existeSudoku] = haySudoku(imSegmentada);
    
    tiempoHaySudoku = toc(tiempoHaySudoku);
    
    %% Si hay sudoku se intenta resolver
    if existeSudoku && ~solucionEncontrada && ...
            polyarea(verticesOriginales(1:4,1),verticesOriginales(1:4,2))
        %% Se extrae el enunciado
        enunciadoAnterior = enunciado;
        enunciado = prepararEnunciado(plantillas,imSegmentada,verticesOriginales);
        
        % Se valida cada celda individualmente 
        % - Se buscan los valores estables en la correlacion 
        %   --> (correlacion ==1)
        % - Se suma uno a dicho valor estable en la matriz de validez 
        %   hasta maximo de 3
        correlacion = enunciado==enunciadoAnterior;
        validez(correlacion == 1 & validez ==0) = 1;
%         validez(correlacion == 1 & validez ==1) = 2;
%         validez(correlacion == 1 & validez ==2) = 3;
         
%         validez(correlacion == 0 & validez ==2) = 1;
%         validez(correlacion == 0 & validez ==3) = 2;
        
        if min(min(validez))==1 && max(max(enunciado))~=0
            contador = 1;
        else
            contador = 0;
        end
        
        %% Si la repetitbilidad llega a un minimo se resuelve el sudoku
        if contador >= FIABLE
            solucion = sudoku_solver(enunciado);
            
            %% Si hay solucion se crea la imagen sintetica asociada
            if ~isempty(solucion)
                [imSintetica,verticesSinteticos] = crearImagenSintetica(solucion,enunciado);
                solucionEncontrada = 1;
            end
        end
    end
    
    %% Finalmente se muestra la solucion
    if solucionEncontrada && existeSudoku
        % 1. Se genera la transformacion del sudoku a la imagen captada haciendo
        % coincidir directamente las esquinas del sudoku_solucion con las de la
        % imagen del sudoku_enunciado. De esta forma la superposición es directa.
        for i=1:4
            verticesOriginalesCorregidos(i,1) = verticesOriginales(i,1)+posx;
            verticesOriginalesCorregidos(i,2) = verticesOriginales(i,2)+posy;
        end
        T_sintetic2original = cp2tform(verticesSinteticos,verticesOriginalesCorregidos,'projective');
        imSinteticaTrans = imtransform(~imSintetica,T_sintetic2original,'XData',[1 size(imagen,2)], 'YData',[1 size(imagen,1)]);
        
        % 2. Se crea la plantilla para la realidad aumentada
        imYCbCr = rgb2ycbcr(imagen);
        imSinteticaTrans = uint8(~imSinteticaTrans);
        imYCbCr(:,:,1) = imYCbCr(:,:,1) .* imSinteticaTrans;
        imFinal = cat(3,imYCbCr(:,:,1),imYCbCr(:,:,2),imYCbCr(:,:,3));
        imFinal = ycbcr2rgb(imFinal);
        
        % 3. Se muestra la RA
        image(imFinal);
    else
        % 4. Si no hay sudoku resuelto se muestra la imagen normal
        image(imagen); 
    end
    axis image off
    hold on;
    plot(posx + [0 resolx resolx 0 0],posy + [0 0 resoly resoly 0],...
        'g','Linewidth',1);
    if ~isempty(verticesOriginales)
        puntos = verticesOriginales;
        puntos = [puntos;puntos(1,:)];
        plot(puntos(:,1)+posx,puntos(:,2)+posy,'k','LineWidth',2);
        drawnow;
    end
    FPS = 1/toc;
    strx = cat(2,'Existe Sudoku: ',num2str(existeSudoku));
    stry = cat(2,'Contador: ',num2str(contador));
    xlabel(strx);
    ylabel(stry)
    title(FPS)
    drawnow;
end
 
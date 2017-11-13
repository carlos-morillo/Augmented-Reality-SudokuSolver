%% Reset
close all
clc
clear

%% Modo de ejecución
MOSTRAR = 1;
pausa = 5;

%% Cargar plantillas
plantillas = cargarPlantillas;

%% Lectura de la plantilla
im = imread('C:\Users\Carlos Morillo\Google Drive\MASTER\MASTER\Semestre 2\Percepcion\Plantilla\sudoku3.jpg');

if MOSTRAR
    imshow(im);pause(pausa)
end

%% Pintar recorte
resol = size(im,1)-20;
posx = (size(im,2)-resol)/2-20;
posy =  (size(im,1)-resol)/2;
if MOSTRAR
    hold on
    recuadro = plot(posx+[0 resol resol 0 0],posy+[0 0 resol resol 0],...
        'g-','LineWidth',5);
    hold off
    pause(pausa)
end
%% Recortar imagen
I = im(posy+(1:resol),posx+(1:resol),:);

if MOSTRAR
    imshow(I);pause(pausa)
end

%% Convertir a blanco y negro
makebw = @(I) im2bw(I.data,median(double(I.data(:)))/1.2/255);
imBin1 = ~blockproc(I,[20 20],makebw);

if MOSTRAR
    imshow(imBin1);pause(pausa)
end

%% Eliminar el ruido
imBin2 = bwareaopen(imBin1,30);

if MOSTRAR
    imshow(imBin2);pause(pausa)
end

%% Eliminar bordes
imBin3 = imclearborder(imBin2);

if MOSTRAR
    imshow(imBin3);pause(pausa)
end
%% Determinar el perímetro del enunciado
% 1. Se detectan los objetos de la escena
objetosOriginales = regionprops(imBin3,'FilledArea','PixelList');
% 2. Se detectan las esquinas del enunciado
verticesOriginales = detectarPerimetroSudoku(objetosOriginales);

if MOSTRAR
    hold on;
    plot(verticesOriginales(:,1),verticesOriginales(:,2),'r+','Linewidth',15)
    pause(pausa)
end

%% Transoformación del enunciado a vista ortogonal
% 0. Se ajusta la calidad de la imagen
res = 500;
% 1. Se establece la relación de transformación
T_original2ortogonal = fitgeotrans(verticesOriginales,res*[0 0;0 1;1 1;1 0],'projective');
% 2. Se transforma la imagen anterior
imOrtogonal = imwarp(imBin3,T_original2ortogonal);

if MOSTRAR
%     figure
    imshow(imOrtogonal);pause(pausa)
end
%% Determinar el perímetro del sudoku ortogonal
objetosOrtogonal = regionprops(imOrtogonal,'FilledArea','PixelList',...
    'Centroid','BoundingBox','EulerNumber');
[verticesOrtogonal,iAreaMax] = detectarPerimetroSudoku(objetosOrtogonal);

if MOSTRAR
    hold on
    plot(verticesOrtogonal(:,1),verticesOrtogonal(:,2),'r+','Linewidth',15)
    pause(pausa)
end

%% Seleccionar objetos dentro del sudoku ortogonal
% 1. Se desestima el objeto del perímetro en sí
objetosOrtogonal(iAreaMax) = [];
% 2. Se estudia si cada objeto está dentro del perímetro del sudoku
num_objetos = numel(objetosOrtogonal);
for i=num_objetos:-1:1
    % 2.1. Si el objeto está fuera del perimetro:
    if ~inpolygon(objetosOrtogonal(i).Centroid(1),...
            objetosOrtogonal(i).Centroid(2),verticesOrtogonal(:,1),...
            verticesOrtogonal(:,2))
        objetosOrtogonal(i) = [];
    end
end
% 3. Se recalcula la cantidad de objetos dado que se han eliminado algunos
num_objetos = numel(objetosOrtogonal);

if MOSTRAR
    for i=numel(objetosOrtogonal):-1:1
        rectangle('Position',objetosOrtogonal(i).BoundingBox,'EdgeColor','green')
    end
end

%% Calcular la malla
% 1. Se crea la relacion de proyeccion de vista ortogonal al sudoku 9x9
T_ortogonal29x9 = fitgeotrans(verticesOrtogonal,[0 0; 0 9; 9 9; 9 0],'projective');
% 1.1. Se crean las columnas y filas
if MOSTRAR
    columnas = zeros(2,2,10);
    filas = zeros(2,2,10);
    for i=0:9
        % 1.1.1. Se aplica la transformacion a cada columna
        [x,y] = transformPointsInverse(T_ortogonal29x9,[i i],[0 9]);
        % 1.1.2. Se almacena cada columna (los extremos)
        columnas(:,:,i+1)=[x',y'];
        % 1.1.3. Se aplica la transformacion a cada fila
        [x,y] = transformPointsInverse(T_ortogonal29x9,[0 9],[i i]);
        % 1.1.4. Se almacena cada fila (los extremos)
        filas(:,:,i+1)=[x',y'];
        
        plot(columnas(:,1,i+1),columnas(:,2,i+1),'g');
        plot(filas(:,1,i+1),filas(:,2,i+1),'g');
    end
    pause(pausa)
end


%% Ubicar cada objeto en la malla del sudoku
if MOSTRAR
    figure
    rectangle('Position',[0 0 9 9])
    hold on
    grid on
    axis image
end

for i=num_objetos:-1:1
    % 1. Se transforman los centroides al sudoku 9x9 virtual
    [x,y]=transformPointsForward(T_ortogonal29x9...
        ,objetosOrtogonal(i).Centroid(1),objetosOrtogonal(i).Centroid(2));
    % 2. Se establecen las columnas y filas adyacentes al objeto
    LIM_INF = fix([x y]);
    LIM_SUP = 1 + LIM_INF;
    UMBRAL = 0.1;
    % 3. Se evalúa si el objeto está centrado en su casilla
    if x-LIM_INF(1) <= UMBRAL || LIM_SUP(1)-x <= UMBRAL ||...
            y-LIM_INF(2) <= UMBRAL || LIM_SUP(2)-y <= UMBRAL
        % 3.1. Si está muy cerca de los limetes se elimina
        objetosOrtogonal(i) = [];
    else
        % 3.2. Si el objeto está centrado se asigna la casilla que ocupa
        objetosOrtogonal(i).Casilla = LIM_SUP;
        
        if MOSTRAR
            OBJETO(:,:,i) = [x y];
            plot(OBJETO(:,1,i),OBJETO(:,2,i),'m+')
        end
    end
end
if MOSTRAR
    pause(pausa)
end

%% Detectar el valor de cada numero
SE = strel('square',1);
num_objetos = numel(objetosOrtogonal);
for i=num_objetos:-1:1
    % 1. Se recorta cada numero en funcion del BoundingBox
    imNumero = imcrop(imOrtogonal,objetosOrtogonal(i).BoundingBox);
    % 2. Se reescala para que coincida con la plantilla
    imNumero = imresize(imNumero,[40 22]);
    % 3. Se añade un marco al numero
    imNumero = padarray(imNumero,[1 1]);
    imNumero = imerode(imNumero,SE);
    
    objetosOrtogonal(i).Valor = comprobarValor(imNumero,...
        objetosOrtogonal(i).EulerNumber,plantillas);
    if MOSTRAR
        subplot(4,10,i)
        imshow(imNumero)
        title(objetosOrtogonal(i).Valor)
        pause(0.2)
    end
end

% if MOSTRAR
%     figure
%     for i=1:9
%         subplot(3,3,i)
%         imshow(plantillas(:,:,i))
%     end
% end

%% Crear el enunciado numérico del sudoku
% 1. Se crea la matriz vacía
enunciado = zeros(9,9);
% 2. Se rellenan las casillas con su valor numerico
for i=1:num_objetos
    m = objetosOrtogonal(i).Casilla(1);
    n = objetosOrtogonal(i).Casilla(2);
    enunciado(m,n) = objetosOrtogonal(i).Valor;
end

% Resolver el sudoku
solucion = sudoku_solver(enunciado)

if ~isempty(solucion)
    %% Convertir la solucion a imagen
    % 1. Se obtiene la matriz sin los numeros del enunciado
    solucion_gap = solucion - enunciado
    % 2. Se crea la nueva imagen
    figura = figure;
    set(figura,'Visible','off')
    if MOSTRAR
        set(figura,'Visible','on')
    end
    axis ([0 9 -9 0])
    set(gcf,'PaperPositionMode','auto')
    axis square off
    hold on
    grid off
    for i=1:9
        for j=1:9
            % El eje y está invertido con respecto a las casillas => posY = -j
            posX = i-0.6;
            posY = -j+0.5;
            % 2.2. Si el valor NO es cero se escribe
            hold on
            if solucion_gap(i,j)
                text(posX,posY,num2str(solucion_gap(i,j)),'FontSize',20,...
                    'FontWeight','bold');
                if MOSTRAR
                    pause(0.2)
                end
                % 2.3. Si el valor SI es cero no se escribe
            else
                text(posX,posY,' ','FontSize',20,...
                    'FontWeight','bold');
            end
        end
    end
    % 2.1. Se crea un recuadro que se usará como referencia para la posición
    rectangle('Position',[0 -9 9 9])
    plot([0 9 9 0 0],[0 0 -9 -9 0])
    % 3. Se salva la figura como imagen
    saveas(figura,'solucion_sudoku.tif');
    imSintetica = im2bw(imread('solucion_sudoku.tif'));
    close (figura)
    
    if MOSTRAR
        figure
        imshow(imSintetica);pause(pausa)
    end
    
    %% Se recorta la imagen para que ajuste en el sudoku
    % 1. Determinar el perímetro del sudoku ortogonal
    objetosSinteticos = regionprops(~imSintetica,'FilledArea','PixelList');
    [verticesSinteticos,~] = detectarPerimetroSudoku(objetosSinteticos);
    % 2. Recortar la imagen para que ajuste al perimetro del sudoku
    imSintetica = imcrop(imSintetica,[verticesSinteticos(1,1),verticesSinteticos(1,2),...
        -verticesSinteticos(1,1)+verticesSinteticos(3,1),...
        -verticesSinteticos(1,2)+verticesSinteticos(3,2)]);
    
    if MOSTRAR
        hold on
        plot(verticesSinteticos(:,1),verticesSinteticos(:,2),'r+','Linewidth',15)
        pause(pausa)
        figure
        imshow(imSintetica);
        pause(pausa)
    end
    %% Superponer la solución en la imagen real
    % 1. Se detecta el nuevo perímetro del sudoku, que ha sido recortado
    objetosSinteticos = regionprops(~imSintetica,'FilledArea','PixelList');
    [verticesSinteticos,~] = detectarPerimetroSudoku(objetosSinteticos);
    % 2. Se genera la transformacion del sudoku a la imagen captada haciendo
    % coincidir directamente las esquinas del sudoku_solucion con las de la
    % imagen del sudoku_enunciado. De esta forma la superposición es directa.
    for i=1:4
        verticesOriginales(i,1) = verticesOriginales(i,1)+posx;
        verticesOriginales(i,2) = verticesOriginales(i,2)+posy;
    end
    T_sintetic2original = cp2tform(verticesSinteticos,verticesOriginales,'projective');
    imSintetica = imtransform(~imSintetica,T_sintetic2original,'XData',[1 size(im,2)], 'YData',[1 size(im,1)]);
    
    imYCbCr = rgb2ycbcr(im);
    imSintetica = uint8(~imSintetica);
    imYCbCr(:,:,2) = imYCbCr(:,:,2) .* imSintetica;
    imFinal = cat(3,imYCbCr(:,:,1),imYCbCr(:,:,2),imYCbCr(:,:,3));
    imFinal = ycbcr2rgb(imFinal);
    
    figure
    imshow(imFinal)
    title('sintetica')
    
end

























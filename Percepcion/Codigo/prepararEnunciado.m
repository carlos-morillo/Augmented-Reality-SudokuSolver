function enunciado = prepararEnunciado(plantillas,I,verticesOriginales)
%% Transoformación del enunciado a vista ortogonal
% 0. Se ajusta la calidad de la imagen
res = 500;
% 1. Se establece la relación de transformación
T_original2ortogonal = fitgeotrans(verticesOriginales,res*[0 0;0 1;1 1;1 0],'projective');
% 2. Se transforma la imagen anterior
imOrtogonal = imwarp(I,T_original2ortogonal);


%% Determinar el perímetro del sudoku ortogonal
objetosOrtogonal = regionprops(imOrtogonal,'FilledArea','PixelList',...
    'Centroid','BoundingBox','EulerNumber');
[verticesOrtogonal,iAreaMax] = detectarPerimetroSudoku(objetosOrtogonal);

% hold on
% plot(verticesOrtogonal(:,1),verticesOrtogonal(:,2),'r+','Linewidth',15)
% hold off

%% Seleccionar objetos dentro del sudoku ortogonal
% 1. Se desestima el objeto del perímetro en sí
objetosOrtogonal(iAreaMax) = [];
% 2. Se estudia si cada objeto está dentro del perímetro del sudoku
num_objetos = numel(objetosOrtogonal);
for i=num_objetos:-1:1
    % 2.1. Si el objeto está fuera del perimetro o es demasiado grande es
    % demasiado pequeño
    if ~inpolygon(objetosOrtogonal(i).Centroid(1),...
            objetosOrtogonal(i).Centroid(2),...
            verticesOrtogonal(:,1),...
            verticesOrtogonal(:,2)) ||...
            objetosOrtogonal(i).FilledArea < 100 ||...
            objetosOrtogonal(i).FilledArea > 450
        objetosOrtogonal(i) = [];
    end
end
% 3. Se recalcula la cantidad de objetos dado que se han eliminado algunos
num_objetos = numel(objetosOrtogonal);

% for i=numel(objetosOrtogonal):-1:1
%     rectangle('Position',objetosOrtogonal(i).BoundingBox,'EdgeColor','green')
% end
% drawnow;hold off;

%% Calcular la malla
% 1. Se crea la relacion de proyeccion de vista ortogonal al sudoku 9x9
T_ortogonal29x9 = fitgeotrans(verticesOrtogonal,[0 0; 0 9; 9 9; 9 0],'projective');

%% Ubicar cada objeto en la malla del sudoku
 
%     figure(9)
%     rectangle('Position',[0 0 9 9])
%     hold on
%     grid on
%     axis image



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
    end
%    OBJETO(:,:,i) = [x y];
%    plot(OBJETO(:,1,i),OBJETO(:,2,i),'m+')
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

    
%     objetosOrtogonal(i).im=imNumero;
%     
end
% figure
% for i=1:num_objetos
%     subplot(5,8,i)
%     imshow(objetosOrtogonal(i).im)
%     title(objetosOrtogonal(i).Valor);
% end
% drawnow;
% figure(1)
%% Crear el enunciado numérico del sudoku
% 1. Se crea la matriz vacía
enunciado = zeros(9,9);
% 2. Se rellenan las casillas con su valor numerico
for i=1:num_objetos
    m = objetosOrtogonal(i).Casilla(1);
    n = objetosOrtogonal(i).Casilla(2);
    enunciado(m,n) = objetosOrtogonal(i).Valor;
end

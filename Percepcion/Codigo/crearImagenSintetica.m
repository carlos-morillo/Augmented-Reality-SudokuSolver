function [imSintetica,verticesSinteticos] = crearImagenSintetica(solucion,enunciado)
%% Convertir la solucion a imagen
% 1. Se obtiene la matriz sin los numeros del enunciado
solucion_gap = solucion - enunciado;
% 2. Se crea la nueva imagen
figura = figure;
set(figura,'Visible','off')
axis ([0 9 -9 0])
set(gcf,'PaperPositionMode','auto')
axis square off
hold on
grid off
% 2.1. Se rellena con los valores
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
saveas(figura,'C:\Users\Carlos Morillo\Google Drive\MASTER\MASTER\Semestre 2\Percepcion\solucion_sudoku.tif');
imSintetica = im2bw(imread('C:\Users\Carlos Morillo\Google Drive\MASTER\MASTER\Semestre 2\Percepcion\solucion_sudoku.tif'));
close (figura)

% figure(10)
% imshow(imSintetica)
% figure(1)
%% Se recorta la imagen para que ajuste en el sudoku
% 1. Determinar el perímetro del sudoku ortogonal
objetosSinteticos = regionprops(~imSintetica,'FilledArea','PixelList');
[verticesSinteticos,~] = detectarPerimetroSudoku(objetosSinteticos);
% 2. Recortar la imagen para que ajuste al perimetro del sudoku
imSintetica = imcrop(imSintetica,[verticesSinteticos(1,1),verticesSinteticos(1,2),...
    -verticesSinteticos(1,1)+verticesSinteticos(3,1),...
    -verticesSinteticos(1,2)+verticesSinteticos(3,2)]);

%% Se analizan las esquinas nuevas para el sudoku recortado
objetosSinteticos = regionprops(~imSintetica,'FilledArea','PixelList');
[verticesSinteticos,~] = detectarPerimetroSudoku(objetosSinteticos);

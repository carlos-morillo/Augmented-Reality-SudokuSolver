function [verticesOriginales,existe] = haySudoku(I)
%% Determinar el perímetro del enunciado
% 0. Se detectan los objetos de la escena
objetosOriginales = regionprops(I,'FilledArea','PixelList','Area');
% 1. Se busca el objeto de mayor area
num_objetos = numel(objetosOriginales);
maxArea = 0;
for i = 1:num_objetos
    if objetosOriginales(i).FilledArea > maxArea
        maxArea = objetosOriginales(i).FilledArea;
        iAreaMax = i;
    end
end
if ~isempty(objetosOriginales)
    % 2. Se desechan los objetos que no sean recuadro de sudoku
    if objetosOriginales(iAreaMax).FilledArea < 200*200 || ...
            objetosOriginales(iAreaMax).Area > 14000
        existe = 0;
        verticesOriginales = [];
        return
    end
% 3. Se detectan las esquinas del enunciado
[verticesOriginales,~] = detectarPerimetroSudoku(objetosOriginales);
existe = 1;
return
end
existe = 0;
verticesOriginales = [];

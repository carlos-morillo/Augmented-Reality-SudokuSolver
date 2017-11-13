function [verticesOriginales,existe] = haySodoku(I)
%% Determinar el perímetro del enunciado
% 1. Se detectan los objetos de la escena
objetosOriginales = regionprops(I,'FilledArea','PixelList');
% 2. Se detectan las esquinas del enunciado
verticesOriginales = detectarPerimetroSudoku(objetosOriginales);
% 3. Se desechan los objetos pequeños
if norm(verticesOriginales(1,:)-verticesOriginales(3,:)) < 300
    existe = 0;
    verticesOriginales = [];
end
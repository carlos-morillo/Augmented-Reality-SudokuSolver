function [vertices,iAreaMax] = detectarPerimetroSudoku(objetos)
%% Determinar el períemtro
% 1. Se busca el objeto de mayor area
num_objetos = numel(objetos);
maxArea = 0;
for i = 1:num_objetos
    if objetos(i).FilledArea > maxArea
        maxArea = objetos(i).FilledArea;
        iAreaMax = i;
    end
end
% 2. Se extraen las esquinas 
    % 2.1. Se extraen las diagonales
    objPerimetro = objetos(iAreaMax);
    diagonal1 = sum(objPerimetro.PixelList,2);
    diagonal2 = diff(objPerimetro.PixelList,[],2);
    % 2.2. Se extraen los puntos esquina de las diagonales
        % 2.2.1. Esquina superior izquierda
        [~,iSupIz] = min(diagonal1);
        % 2.2.2. Esquina inferior derecha
        [~,iInfDer] = max(diagonal1);
        % 2.2.3. Esquina superior derecha
        [~,iSupDer] = max(diagonal2);
        % 2.2.4. Esquina inferior izquierda
        [~,iInfIz] = min(diagonal2);
    
vertices = [objPerimetro.PixelList(iSupIz,:);...
    objPerimetro.PixelList(iSupDer,:);...
    objPerimetro.PixelList(iInfDer,:);...
    objPerimetro.PixelList(iInfIz,:)];

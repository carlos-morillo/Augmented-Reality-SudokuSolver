% Variables entrada:
% imNumero --> imagen rescortada y escalada
% O --> numero de euler del numero de la imagen
% plantillas --> plantillas de los numeros

function valor = comprobarValor (imNumero,O,plantillas)
corrMax = 0; 
valor = 0;

switch O
    case 1
        for i=1:9
            if i == 4 || i == 6 || i == 8 || i == 9
                continue;
            end
            n = corr2(imNumero,plantillas(:,:,i));
            if n > corrMax
                corrMax = n;
                valor = i;
            end
        end
    case 0
        for i=1:9
            if i ~= 4 && i ~= 6  && i ~= 9
                continue;
            end
            n = corr2(imNumero,plantillas(:,:,i));
            if n > corrMax
                corrMax = n;
                valor = i;
            end
        end
    case -1
        valor = 8;
    otherwise
        for i=1:9
            n = corr2(imNumero,plantillas(:,:,i));
            if n > corrMax
                corrMax = n;
                valor = i;
            end
        end
end
% 
% 
% 
for i=1:9
    n = corr2(imNumero,plantillas(:,:,i));
    if n > corrMax 
        corrMax = n;
        valor = i;
    end
end
% 
% 


if valor == 1
   if O <= 0
       valor = 4;
   end
end
if valor == 9 || valor == 6 || valor == 3
    if O < 0
        valor = 8;
    end
end
if valor == 5
    if O <= 0
        valor = 5;
    end
end
if valor == 6
    if O > 0
        valor = 5;
    end
end



% %     imshow(imNumero)
%     
%     sumMax =0;
%     valor = 0;
% 
%     for i=1:9
%         m = imNumero .* plantillas(:,:,i);
%         m2 = sum(sum(m));
%         if m2 > sumMax 
%             sumMax = m2;
%             valor = i;
%         end
%     end
%% PLANTILLAS DE NUMEROS
function creadorPlantillas()
%%
for i=1:9
    switch i
        case 1
            fich = 'UNO';
            fich2 = 'Puno.png';
        case 2
            fich = 'DOS';
            fich2 = 'Pdos.png';
        case 3
            fich = 'TRES';
            fich2 = 'Ptres.png';
        case 4
            fich = 'CUATRO';
            fich2 = 'Pcuatro.png';
        case 5
            fich = 'CINCO';
            fich2 = 'Pcinco.png';
        case 6
            fich = 'SEIS';
            fich2 = 'Pseis.png';
        case 7
            fich = 'SIETE';
            fich2 = 'Psiete.png';
        case 8
            fich = 'OCHO';
            fich2 = 'Pocho.png';
        case 9
            fich = 'NUEVE';
            fich2 = 'Pnueve.png';
    end
    fichero = cat(2,'C:\Users\Carlos\Google Drive\MASTER\MASTER\Semestre 2\Percepcion\Plantilla\',fich,'.png');
    I=imread(fichero);
    imshow(I) ;pause(0.5)
    %%
    I=im2bw(I);
    imshow(I);pause(0.5)
    %%
    I=~I;
    imshow(I);pause(0.5)
    %%
    objetos = regionprops(I);
    i=1;
    objetos(i).BoundingBox(1) = objetos(i).BoundingBox(1)- 1;
    objetos(i).BoundingBox(2) = objetos(i).BoundingBox(2)- 1;
    objetos(i).BoundingBox(3) = objetos(i).BoundingBox(3)+ 1;
    objetos(i).BoundingBox(4) = objetos(i).BoundingBox(4)+ 1;
    im_numero = imcrop(I,objetos(i).BoundingBox);
    imshow(im_numero);pause(0.5)
    size(im_numero)
    %%
    im_numero = imresize(im_numero,[42 24]);
    imshow(im_numero);pause(0.5)
    %%
    imwrite(im_numero,fich2);
end
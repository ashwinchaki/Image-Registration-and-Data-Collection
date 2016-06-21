clc
disp('Creating Images / Figures - Outputting to Current Directory')
disp('.')
disp('.')
disp('.')
d=dir('*.mat'); % <- retrieve all names: file(s) and folder(s)
d=d(~[d.isdir]); % <- keep file name(s), only
d={d.name}.'; % <- file name(s)
nf=numel(d);
for i=1:nf
    disp(sprintf('working on %5d/%5d: %s',i,nf,d{i}));
    filename = d{i};    
    load(filename);
    figure
    imshow(PCAparams.stdProjection)
    image(PCAparams.stdProjection)
    axis off;
    imagefile = strrep(filename,'.mat','');
    export_fig(imagefile,i);
end

close all
sortandregister;


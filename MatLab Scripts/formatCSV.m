function formatCSV(foldername)
workingarray = csvread('Transformation_Points.csv');
delete('Transformation_Points.csv');
transformpoints = struct;
files = dir('*.png'); % <- retrieve all names: file(s) and folder(s)
files = files(~[files.isdir]); % <- keep file name(s), only
files = {files.name}.'; % <- file name(s)
nf = numel(files);
for a=2:nf

    currentfile = files{a,1};
    indexof = strfind(currentfile, '.');
    currentfile = currentfile(1,indexof-1);
    
    for b = 1:3
    
        newarray(1,:) = workingarray(b,:);
        newarray(2,:) = workingarray(b+1,:);
        newarray(3,:) = workingarray(b+2,:);
    
    end
    transformpoints.(currentfile) = newarray;
end
%mousefile = strcat(mousename,'.mat');
fname  = sprintf('Mouse-%s',foldername);
save(fname,'transformpoints');
end


        
        

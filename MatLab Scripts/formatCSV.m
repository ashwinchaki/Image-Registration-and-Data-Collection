function formatCSV(foldername)
    workingarray = csvread('Transformation_Points.csv');
    delete('Transformation_Points.csv');
    Transformations = struct;
    files = dir('*.png'); % <- retrieve all names: file(s) and folder(s)
    files = files(~[files.isdir]); % <- keep file name(s), only
    files = {files.name}.'; % <- file name(s)
    nf = numel(files);
    for a=2:nf

%         currentfile = files{a,1};
%         indexof = strfind(currentfile, '.');
%         currentfile = currentfile(1:(indexof-1));

        for b = 1:3

            newarray(b,:) = workingarray((3*(a-2))+b,:);

        end
        Transformations.files{a-1}.filenames = [files{a-1,1};files{a,1}];
        Transformations.files{a-1}.transformpoints = newarray;
    end
    %mousefile = strcat(mousename,'.mat');
     fname  = sprintf('Mouse-%s',foldername);
    save(fname,'Transformations');
end


        
        

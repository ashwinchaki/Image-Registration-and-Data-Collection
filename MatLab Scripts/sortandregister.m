% function sortandregister
d=dir('*.png'); % <- retrieve all names: file(s) and folder(s)
d=d(~[d.isdir]); % <- keep file name(s), only
d={d.name}.'; % <- file name(s)
nf=numel(d);
for i=1:nf
    filename = d{i};
    indexof = strfind(filename,'_');
    if size(indexof) == 0;
            break;
        else
            foldername = filename(1:indexof-1);
            %folderdir = strcat('\',foldername)
            if (exist(foldername)== 0)
                mkdir(foldername); 
                movefile(filename,foldername);
            elseif (exist(foldername)== 7)
                movefile(filename,foldername);
            end
        end
end

javaaddpath 'C:\Program Files\MATLAB\R2015a\java\jar\mij.jar'
javaaddpath 'C:\Program Files\MATLAB\R2015a\java\jar\ij.jar'
% Get a list of all files and folders in this folder.
files = dir();
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags);
% Print folder names to command window.
for i = 3 : length(subFolders)
    subFolders = {subFolders.name}.'
	foldername = subFolders{i};
    currentpath = pwd;
    inpath = strcat(currentpath, '\', foldername, '\');
    cd(inpath);
    firstImage = dir('*.png');
    firstImage = firstImage(~[firstImage.isdir]);
    firstImage = {firstImage.name}.';
    firstImage = firstImage{1};
    inpath = strcat(inpath, firstImage);
    args = inpath;
    macro_path='C:\Users\Ashwin Chakicherla\Desktop\ImageJ\macros\StackRegMacro.ijm';
    MIJ.start('C:\Users\Ashwin Chakicherla\Desktop\ImageJ')
    IJ = ij.IJ();
    IJ.runMacroFile(java.lang.String(macro_path),java.lang.String(args));
    IJ.run(java.lang.String('Quit'));
    cd(currentpath);
end
mousename = foldername;
%formatCSV;
% end
    
    
    

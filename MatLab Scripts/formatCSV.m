function formatCSV(mousename)
{
    workingarr = csvread('Transformation_Points.csv');
    delete('Transformation_Points.csv');
    numberOfFiles = size(workingarr,2)/3;
    (mousename) = struct;
    inputNumber = size(images);
    d=dir('*.png'); % <- retrieve all names: file(s) and folder(s)
    d=d(~[d.isdir]); % <- keep file name(s), only
    d={d.name}.'; % <- file name(s)
    nf=numel(d);
    for i=2:nf
    {
        currentfile = d{i};
        

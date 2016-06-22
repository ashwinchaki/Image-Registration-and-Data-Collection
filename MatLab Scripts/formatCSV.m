workingarr = csvread('Transformation_Points.csv');
delete('Transformation_Points.csv');
transformpoints = struct;
d=dir('*.png'); % <- retrieve all names: file(s) and folder(s)
d=d(~[d.isdir]); % <- keep file name(s), only
d={d.name}.'; % <- file name(s)
nf=numel(d);
for a=2:nf
{
    currentfile = d(a);
    for b = 1:3
    {
        newarray(1,:) = workingarray(i,:);
        newarray(2,:) = workingarray(i+1,:);
        newarray(3,:) = workingarray(i+2,:);
    }

    transformpoints.(currentfile) = newarray;
    end
end
delete('Transformation_Points.csv');
save(mousename,transformationpoints);


        
        

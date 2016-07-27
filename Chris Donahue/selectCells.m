% selectCells.m
% This script will run the ICA algorithm on the PCA .mat file (created with createPCAfile.m).
% The user can select cells with the GUI (ICA_GUI) and all the output is saved into the
% struct IC. 
clear variables;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT PROCESSING PARAMETERS:                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input paramters for ICA image segmentation and selection:
ICAparams.mu = .5; % weight of temporal info for ICA (check references)
ICAparams.nIC = 100; % number of ICs to find
ICAparams.smwidth = 3; % std of Gaussian kernel for image segmentation
ICAparams.thresh = 3; % threshold for spatial filters (std) for image segmentation
ICAparams.arealims = [50 1e6]; % minimum and maximum size for image segmentation


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD PCA FILE: (from CellsortPCA.m):                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[PCAfile,PathName] = uigetfile('*','Load PCA file:');
load([PathName,PCAfile]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WARNING IF PCA VARIANCE IS TOO LOW:                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PCAparams.percentvar<90
    warning(['Explained PCA variance low: ',num2str(PCAparams.percentvar,'%1.1f'),...
        '%. Redo motion correction?']);
end
    
% CAN CHECK FOR EXISTENCE OF FILE HERE:



% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROCESSING STARTS HERE:                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Future version may make this an option. It can help you reduce the
% dimensionality to get rid of obvious artifacts, but I think cropping
% before PCA is probably the best option and will likely make this
% unnecessary (CHD). 
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% % SELECT SUBSET OF PCs:  %
% %%%%%%%%%%%%%%%%%%%%%%%%%%

% [PCuse] = CellsortChoosePCs(fn, mixedfilters); % was PCAparams.tiffFile->fn
% PCAparams.PCrange = PCuse;
PCuse = 1:PCAparams.nPCs; % 



%%%%%%%%%%%%%%%%%%%%%%%%%%
% PERFORM ICA:           %
%%%%%%%%%%%%%%%%%%%%%%%%%%
ica_A_guess = randn(length(PCuse), ICAparams.nIC);
termtol = 1e-6;
maxrounds = 300;
[ica_sig, ica_filters, ica_A, numiter, warnFlag] = CellsortICA(mixedsig, ...
    mixedfilters, CovEvals, PCuse, ICAparams.mu, ICAparams.nIC, ica_A_guess, termtol,...
    maxrounds);
if warnFlag==1
    error('ICA failed to converge, please try again! If problem persists you can change maxrounds, termtol, or PCuse');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMAGE SEGMENTATION AND GUI   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ica_segments, segLabels, segCentroids] = ...
    CellsortSegmentation(ica_filters, ICAparams.smwidth, ICAparams.thresh, ICAparams.arealims, 0);
[pathstr,fname,ext] = fileparts(PCAparams.tiffFile);
fn = strcat(fname,ext);
ICchosenData = testGUI2(fn,segLabels,ica_segments,ica_sig,segCentroids,ica_filters);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE IC DATA:                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% all ICs:
IC.all.traces = ica_sig;
IC.all.filters = ica_filters;
IC.all.segments = ica_segments;
IC.all.centroids = segCentroids; % Centroid for each segment
IC.all.segLabels = segLabels;    % cellID for each segment
IC.all.unmixingMatrix = ica_A;  % Can be used to test for replication
IC.all.peakInfo = ICchosenData.ICpeaks; % data{cellID}[Location PeakValue]

% selected ICs:
IC_selected = find(ICchosenData.saveCell==1);
segIdx = ismember(segLabels,IC_selected);
IC.selected.traces = ica_sig(IC_selected,:);
IC.selected.filters = ica_filters(IC_selected,:,:);
% IC.selected.segments = ica_segments(IC_selected,:,:); % INCORRECT
% INDEXING
IC.selected.cellID = IC_selected;
IC.selected.centroids = segCentroids(find(segIdx==1),:);
IC.selected.segLabels = segLabels(find(segIdx==1),:);
for i = 1:length(IC_selected)
    IC.selected.peakInfo{i} = ICchosenData.ICpeaks{IC_selected(i)};
end

% AUTOMATE THIS AFTER FIXING PCA NAMING CONVENTION
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% save File:
[FileName,PathName] = uiputfile('*','Save ICA processed file:');
fSaveName = strcat(PathName,FileName);
save(fSaveName,'IC'); 
    
   
   
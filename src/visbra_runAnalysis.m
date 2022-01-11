% (C) Copyright 2019 Remi Gau

clear;
clc;

warning('off');
addpath(genpath('C:\Users\filip\Documents\MATLAB\spm12')); % genpath = subfolders
addpath(genpath('C:\Users\filip\Documents\MATLAB\NIfTI_tools'));

% Sets up the environment for the analysis and add libraries to the path
% initEnv();

%% Set options
opt = visbra_getOption_stats();

checkDependencies(opt);

%% Run batches
reportBIDS(opt);
bidsCopyInputFolder(opt);

% In case you just want to run segmentation and skull stripping
% Skull stripping is also included in 'bidsSpatialPrepro'
% bidsSegmentSkullStrip(opt);

% bidsSTC(opt);
% 
% bidsSpatialPrepro(opt);
% 
% % The following do not run on octave for now (because of spmup)
% anatomicalQA(opt);
% bidsResliceTpmToFunc(opt);
% % functionalQA(opt);
% 
% % Smoothing to apply
FWHM = 2;
bidsSmoothing(opt);

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);
bidsResults(opt);

bidsRFX('smoothContrasts', opt);
bidsRFX('RFX', opt);

% WIP: group level results
% bidsResults(opt);

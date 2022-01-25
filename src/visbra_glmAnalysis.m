% (C) Copyright 2019 Remi Gau

clear;
clc;

warning('off');
addpath(genpath('C:\Users\filip\Documents\MATLAB\spm12')); % genpath = subfolders
addpath(genpath('C:\Users\filip\Documents\MATLAB\NIfTI_tools'));

% Sets up the environment for the analysis and add libraries to the path
% initEnv();

%% Set options
opt = visbra_getOption_stats_loca();

checkDependencies(opt);

%% Run batches
reportBIDS(opt);
bidsCopyInputFolder(opt);

% Smoothing to apply: change parameteres if you go for mvpa-rsa
if strcmp (opt.taskName, 'visualEventRelated')

    opt.fwhm.func = 2;
    opt.fwhm.contrast = 2;  
end

bidsSmoothing(opt);

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);
bidsResults(opt);

%% Group analysis

bidsRFX('smoothContrasts', opt);
bidsRFX('RFX', opt);

% WIP: group level results
% bidsResults(opt);

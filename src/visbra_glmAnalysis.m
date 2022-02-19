% (C) Copyright 2019 Remi Gau

clear;
clc;

warning('off');
addpath(genpath('C:\Users\filip\Documents\MATLAB\spm12')); % genpath = subfolders
addpath(genpath('C:\Users\filip\Documents\MATLAB\NIfTI_tools'));

% Sets up the environment for the analysis and add libraries to the path
% initEnv();

%% Set options
% Comment the one you're not using

% opt = stats_getOption_localizer();
opt = stats_getOption_evrel();


%% Run batches

% Smoothing to apply: change parameteres if you go for mvpa-rsa
if strcmp (opt.taskName, 'visualEventRelated')
    opt.funcFWHM = 2;
else
    funcFWHM = 6;
end

% bidsFFX('specifyAndEstimate', opt, opt.funcFWHM);


% return

bidsFFX('contrasts', opt, opt.funcFWHM);
bidsResults(opt, opt.funcFWHM);

return
%% Group analysis

bidsRFX('smoothContrasts', opt);
bidsRFX('RFX', opt);

% WIP: group level results
% bidsResults(opt);

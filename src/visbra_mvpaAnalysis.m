%% MVPA Analysis scirpt for VISual BRAille study.
%
%   Coming from CerenB\rhythmBlock_mvpa scripts on github
%   And Fede's scripts

clear;
clc;

%% Load options

% options come from event related design, the one set up to do mvpa
opt = visbra_getOption_mvpa();

% add cpp repo
run ../lib/CPP_SPM/initCppSpm.m;

warning('off');

%% Run batches
reportBIDS(opt);
bidsCopyInputFolder(opt);

% slice time correction
bidsSTC(opt);

% spatial preprocessing
bidsSpatialPrepro(opt);

% Quality control
% anatomicalQA(opt);
% bidsResliceTpmToFunc(opt);
% functionalQA(opt);

% smoothing first level
opt.fwhm.func = 6;
opt.fwhm.contrast = 6;  

bidsSmoothing(opt);

% subject level univariate
bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);

% visualise the results
bidsResults(opt);

% group level univariate
% conFWHM = 8;
% bidsRFX('smoothContrasts', opt,funcFWHM, conFWHM);
% bidsRFX('RFX', opt, funcFWHM, conFWHM);
% WIP: group level results
% bidsResults(opt, FWHM);


%% MVPA

% SMOOTHING OF 0
opt.fwhm.func = 0;
opt.fwhm.contrast = 0;  
    
bidsSmoothing(opt);

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);

bidsResults(opt);
% % prep for mvpa

bidsConcatBetaTmaps(opt, 0, 0);

% SMOOTHING OF 2
opt.fwhm.func = 2;
opt.fwhm.contrast = 2;  

bidsSmoothing(opt);

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);

bidsResults(opt);

bidsConcatBetaTmaps(opt, 0, 0);


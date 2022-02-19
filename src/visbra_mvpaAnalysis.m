%% MVPA Analysis scirpt for VISual BRAille study.
%
%   Coming from CerenB\rhythmBlock_mvpa scripts on github
%   + Fede's and Iqra's scripts

clear;
clc;

%% Load options
% 

% options come from event related design, the one set up to do mvpa
opt = mvpa_getOption();

% add cpp repo
run ../lib/CPP_SPM/initCppSpm.m;

warning('off');

%% Run batches
% SMOOTHING OF 2
funcFWHM = 2; 

% bidsSmoothing(funcFWHM, opt);

bidsFFX('specifyAndEstimate', opt, funcFWHM);
bidsFFX('contrasts', opt, funcFWHM);

% bidsResults(opt, funcFWHM);

bidsConcatBetaTmaps(opt, funcFWHM, 0, 0);


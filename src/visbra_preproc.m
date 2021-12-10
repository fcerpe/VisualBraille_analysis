% This script will download the dataset from the FIL for the block design SPM tutorial
% and will run the basic preprocessing.
%
% (C) Copyright 2019 Remi Gau

clear; 
clc;

warning('off');
addpath(genpath('C:\Users\filip\Documents\MATLAB\spm12'));
addpath(genpath('C:\Users\filip\Documents\MATLAB\NIfTI_tools'));

try
run ../lib/CPP_SPM/initCppSpm.m;
catch
end

opt = visbra_getOption();

% reportBIDS(opt);

bidsCopyInputFolder(opt);

% In case you just want to run segmentation and skull stripping
% NOTE: skull stripping is also included in 'bidsSpatialPrepro'
% bidsSegmentSkullStrip(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

anatomicalQA(opt);

bidsResliceTpmToFunc(opt);

% DOES NOT WORK
% functionalQA(opt);

% create a whole brain functional mean image mask
% so the mask will be in the same resolution/space as the functional images
% one may not need it if they are running bidsFFX
% since it creates a mask.nii by default
% NEEDS DEBUGGING
% opt.skullstrip.mean = 1;
% mask = bidsWholeBrainFuncMask(opt);

bidsSmoothing(opt);

%% Create ROIs based on peak coordinates from thesingle subjects
%
% Script from Iqra: tmpCreateROIs and marsbar_create_ROIs merged together
%
% Steps:
% 1 - open bspmview Manually get the peak coordinates in each subject for each ROI
% 2 - load sub-XXX_contrast_spmT.nii
% 3 - go near your ROI and right-click to "nearest peak"
% 3B- for LOC1 and 2, applied masks from Kastner's probabilistic maps and
%     chose the highest peak
% 4 - save coordinates below
% 5 - run section-by-section
%
% sub-001
% vwfa L [-46.8, -70.4, -12.8]
% LO1 L  [-39,   -86,   -7.6]
% LO2 L  [-41.6, -80.8, -7.6]
% LO1 R  [46.8,  -80.8, -7.6]
% LO2 R  [44.2,  -75.6, -10.2]
%
% sub-002
% vwfa L [-49.4, -57.4, -12.8]
% LO1 L  [-36.4, -88.6, -10.2]
% LO2 L  [-46.8, -80.8, -2.4]
% LO1 R  [46.8,  -75.6, 0.2]
% LO2 R  [46.8,  -73,   -5]
%
% sub-003
% vwfa L [-49.4, -60,   -20.6]
% LO1 L  [-44.2, -75.6, 13.2]
% LO2 L  [-41.6, -78.2, -2.4]
% LO1 R  [44.2,  -80.8, -5]
% LO2 R  [44.2,  -70.4, -2.4]
%
% mni{sub_number}(contrast number, coordinates)
% mni{1}= [-46 64 4]

%% clear
clear;
clc;
%% visual Localizer
% LO1 and LO2 come from: Larsson and Heeger, 2006 (jneurosci)
%                        Sayres and Grill-Spector, 2008 (jnp)
%
% SUB-001
mni{1}(1,1:3)= [-4.680000e+01, -7.040000e+01, -1.280000e+01];   % VWFA
mni{1}(2,1:3)= [-3.900000e+01, -8.600000e+01, -0.760000e+01];   % LO1 LEFT
mni{1}(3,1:3)= [-4.160000e+01, -8.080000e+01, -0.760000e+01];   % LO2 LEFT
mni{1}(4,1:3)= [4.680000e+01, -8.080000e+01, -0.760000e+01];   % LO1 RIGHT
mni{1}(5,1:3)= [4.420000e+01, -7.560000e+01, -1.020000e+01];   % LO2 RIGHT

% SUB-002
mni{2}(1,1:3)= [-4.940000e+01, -5.740000e+01, -1.280000e+01];   % VWFA
mni{2}(2,1:3)= [-3.640000e+01, -8.860000e+01, -1.020000e+01];   % LO1 LEFT
mni{2}(3,1:3)= [-4.680000e+01, -8.080000e+01, -0.240000e+01];   % LO2 LEFT
mni{2}(4,1:3)= [4.680000e+01, -7.560000e+01, 0.020000e+01];   % LO1 RIGHT
mni{2}(5,1:3)= [4.680000e+01, -7.300000e+01, -0.500000e+01];   % LO2 RIGHT

% SUB-003
mni{3}(1,1:3)= [-4.940000e+01, -6.000000e+01, -2.060000e+01];   % VWFA
mni{3}(2,1:3)= [-4.420000e+01, -7.560000e+01,  1.320000e+01];   % LO1 LEFT
mni{3}(3,1:3)= [-4.160000e+01, -7.820000e+01, -0.240000e+01];   % LO2 LEFT
mni{3}(4,1:3)= [4.420000e+01, -8.080000e+01, -0.500000e+01];   % LO1 RIGHT
mni{3}(5,1:3)= [4.420000e+01, -7.040000e+01, -0.240000e+01];   % LO2 RIGHT


ROI_name_list = {'VWFA-Left','LO1-Left','LO2-Left','LO1-Right','LO2-Right'};

save('visROI_mni_coordinates.mat','ROI_name_list','mni')

%% MarsBar
% warning('off');
% addpath(genpath('/Users/battal/Documents/MATLAB/spm12'));
% bspm fmri
% addpath(genpath('/Users/shahzad/Documents/MATLAB/bspmview'));


% add cpp repo
run ../../lib/CPP_SPM/initCppSpm.m;

% Radius of the sphere around the peak
radius = 10; % mm, to confirm with Hans e Oli

% Another manual step, apparently it does not work well code-wise
% In casewe want to give it a shot, run these:
% MARS.OPTIONS.spacebase.fname =  fullfile(pwd,'template.nii');
% MARS.OPTIONS.spacebase.fname =  t-contrast image

marsbar('on')

%% Get the ROIs (actually just the spheres)

for iSub = 1:length(mni)
    
    % Get subject name, in our single ROI is the row with the coordinates
    subName = ['sub-00',num2str(iSub)];
    
    % If there is actually something there
    if ~isnan(mni{iSub})
        
        for iReg = 1:size(mni{iSub},1) % for each region this subject has
            % Get the center
            ROI_center = mni{iSub}(iReg,:);
            
            regionName = ROI_name_list{iReg};
            
            % Set up bids-like name
            ROI_save_name = [subName,'_', regionName,'_',num2str(radius),'mm'];
            %             ROI_name = [SubName,'_','space-MNI','_','tac','hemi-' region_name,'_', SubName,'_',num2str(radius),'mm'];
            
            % create the sphere with marsbar and save it
            params = struct('centre', ROI_center , 'radius', radius);
            roi = maroi_sphere(params);
            saveroi(roi, [ROI_save_name,'.mat']);
            mars_rois2img([ROI_save_name,'.mat'],[ROI_save_name,'.nii'])
            
            % Delete .mat files, not necessary
            delete([ROI_save_name,'_labels.mat']);
            delete([ROI_save_name,'.mat'])
            
        end
    end
    
end
% end

%sub-01_space-individual_hemi-L_label-V1d_desc-wang_mask.nii



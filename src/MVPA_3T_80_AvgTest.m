%%% Script to run MVPA on fMRI data using cosmoMVPA %%%
% by Ineke Pillet, May 2020
% adapted for 3T dataset by Roxane Philips May 2021
% adapted again for use on the 7T dataset by Ineke Pillet, May 2021

%%% Make sure cosmoMVPA folder is in your matlab path
%addpath('C:\Program Files\MATLAB\R2020a\toolbox\CoSMoMVPA-master\mvpa')
%addpath('C:\Program Files\MATLAB\R2020a\toolbox\CoSMoMVPA-master\external\NIfTI_20140122')
opt = mvpa_getOption();

funcFWHM = opt.funcFWHM;

% choose masks to be used
opt = chooseMask(opt);

% set output folder/name
savefileMat = fullfile(opt.pathOutput, ...
    [opt.taskName, '_', 'HansTrick', '_s', num2str(opt.funcFWHM), '_ratio', num2str(156), '.mat']);

savefileCsv = fullfile(opt.pathOutput, ...
    [opt.taskName, '_', 'HansTrick', '_s', num2str(opt.funcFWHM), '_ratio', num2str(156), '.csv']);

nconditions = 16; % Including long fixation condition
nruns = 8;
%     allsubjectsrsm=[];

% NEXT: LOOP SUBJECTS
iSub = 1;
       
    % NEXT: LOOP ROIS
    
    % get FFX path
    iSub = opt.subjects{iSub};
    ffxDir = getFFXdir(iSub, funcFWHM, opt);
    
    % get subject folder name
    subFolder = ['sub-', iSub];
    
        subMasks = opt.maskName(startsWith(opt.maskName,strcat('sub-00',num2str(iSub))));
        
        iMask = 1;
        mask = fullfile(opt.maskPath, subFolder, 'sub-001_hemi-L_space-MNI_label-VWFA_radius-10mm_mask.nii');
        
        % Load and prepare dataset (betas or tstats)
        
        imageName = ['4D_', opt.mvpa.map4D{1}, '_', num2str(funcFWHM), '.nii'];
        image = fullfile(ffxDir, imageName);
                
        ds=cosmo_fmri_dataset(image, 'mask', mask);
        ds=cosmo_remove_useless_data(ds);
        
        ds.sa.targets = repmat((1:nconditions)',nruns,1); % Define targets
        
%         % Getting rid off zeros
%         zeroMask = all(ds.samples == 0, 1);
%         ds = cosmo_slice(ds, ~zeroMask, 2);
%         
%         condLabelNb = 1:16;
%         condLabelName = getConditionNames(); % sweep the mess under the rug
%         decodingCondition = {'words'}; % just to hide the huge amount of conditions
%         
%         nbRun = opt.mvpa.nbRun;
%         betasPerCondition = opt.mvpa.nbTrialRepetition; % trial is given by trial_type
%         
%         % chunk (runs), target (condition), labels (condition names)
%         conditionPerRun = length(condLabelNb);
%         betasPerRun = betasPerCondition * conditionPerRun;
%         
%         chunks = repmat((1:nbRun)', 1, betasPerRun);
%         chunks = chunks(:);
%         
%         targets = repmat(condLabelNb', 1, nbRun)';
%         targets = targets(:);
%         targets = repmat(targets, betasPerCondition, 1);
%         
%         condLabelName = repmat(condLabelName', 1, nbRun)';
%         condLabelName = condLabelName(:);
%         condLabelName = repmat(condLabelName, betasPerCondition, 1);
        
        % assign our 4D image design into cosmo ds git
%         ds.sa.targets = targets;
%         ds.sa.chunks = chunks;
%         ds.sa.labels = condLabelName;

        % Define an argument structure for decoding
        args = struct();
        args.classifier = @cosmo_classify_lda;
        args.max_feature_count=10000;
        classif='lda';
               
        % clear args.partitions
        % Dafaq is cons??
        cons = nchoosek(1:(81),2); % 120 = (16*16 - 16) /2, just does half of the rdm
     %%   
        for c = 1:length(cons)
            
            % get current contrast
            currentC = cons(c,:);
            
            % get which targets are involved
            cur_msk = cosmo_match(ds.sa.targets, currentC); % Set 1 for the locations where this contrast is located
            
            % slice the dataset to only include them 
            ds_cur = cosmo_slice(ds, cur_msk); % Slice a dataset by samples, this case the conditions we want to compare
            
            n_points = 3; % how many test examplars we average over
            args.partitions = cosmo_nchoosek_partitioner(ds_cur,n_points); % Take-one-chunk out partitioning
            %args.normalization = 'demean';
            
            % average 2 examplars of each pair-member in test condition
            args_ts= args.partitions.test_indices;
            args_tr= args.partitions.train_indices;
            ds_curr = ds_cur;
            for i=1:length(args_ts)
                arg_ts = args_ts{i}; % test  indexes
                arg_tr = args_tr{i}; % train indexes
                
                samp_cur = ds_cur.samples;
                
                
                % calculate mean for each stimulus out of the pair
                mu1=mean(samp_cur(arg_ts(1:2:n_points*2),:),1);
                mu2=mean(samp_cur(arg_ts(2:2:n_points*2),:),1);
                %                 mu2=mean([samp_cur(arg_ts(2),:); samp_cur(arg_ts(4),:)],1);
                
                % put them back into the current sample
                samp_cur(arg_ts(1:2:n_points*2),:) = repmat(mu1,n_points,1);
                samp_cur(arg_ts(2:2:n_points*2),:) = repmat(mu2,n_points,1);
                
                %                 samp_cur(arg_ts(1),:) = mu1;
                %                 samp_cur(arg_ts(3),:) = mu1;
                %                 samp_cur(arg_ts(2),:) = mu2;
                %                 samp_cur(arg_ts(4),:) = mu2;
                ds_curr.samples(:,:,i) = samp_cur;
            end
            
            rs = cosmo_crossvalidation_measure_avgTest_AP(ds_curr,args);
            
        end
        
        
        % calculate mean across all pairwise comparisons
        rsm_tmp = rsm(2:end,3:end);
        mnz = mean(nonzeros(rsm_tmp));
        
        
        
        %     clear data_path mask_path ds fixcond ds_wofix args classif cons rsm cur cur_msk ds_cur rs...
        %         filename Variables Variables2 Variable Variable2 filename1...
        %         res_decoding targets_animacy anim_msk ds_anim rs_anim targets_living living_msk...
        %         ds_living rs_living
    
    matname = [subjects{iSub} '_LDA_Avg_' num2str(n_points) '_' ROIs{currentROI} '.mat'];
    
    
    %%
%     close all
%     [arsm,brsm]=size(rsm);
%     figure;
%     imagesc(rsm);
%     colorbar
%     set(gca,'xtick',1:arsm,'xticklabel',Variables)
%     set(gca,'ytick',1:arsm,'yticklabel',Variables)
%     xtickangle(45)
%     title('LDA classifier: 80 ai','FontSize',16)
%     % print -dtiff -r300 80_ai_PPA_LDA
%     
%     
%     % FFA-means
%     rsmf1=rsm(42:61,62:end);
%     rsmf2=rsm(2:41,42:61);
%     ffa_face = mean([rsmf1(:);rsmf2(:)])
%     
%     rsmn = rsm;
%     rsmn(42:61,62:end)=0;
%     rsmn(2:41,42:61)=0;
%     rsmn = [rsmn(:)];
%     ffa_noface = mean(rsmn(abs(rsmn)>0))
%     
%     % LO-means
%     rsmo1=rsm(2:21,22:end);
%     rsmo1 = rsmo1(:);
%     lo_obj = mean(rsmo1)
%     rsmno = rsm;
%     rsmno(2:21,22:end)=0;
%     rsmno = rsmno(:);
%     lo_noobj = mean(rsmno(abs(rsmno)>0))
%     
%     % PPA-means
%     rsmp1=rsm(22:41,42:end);
%     rsmp2=rsm(2:21,22:41);
%     ppa_place = mean([rsmp1(:);rsmp2(:)])


function ds = setCosmoStructure(opt, ds, condLabelNb, condLabelName)
% sets up the target, chunk, labels by stimuli condition labels, runs,
% number labels.

% Modified to include different analyses and chunks.
% Works for decoding of single words (16 betas per run)
% not (yet) for single betas (64 per run)

% switch condition 
%     
%     case 'words' % each single word v. all the others (pair-wise)
%         betasPerCondition = opt.mvpa.nbTrialRepetition;
%         conditionPerRun = length(condLabelNb);
%         betasPerRun = betasPerCondition * conditionPerRun;
%         
%         chunks = repmat((1:nbRun)', 1, betasPerRun);
%         chunks = chunks(:);
%         
%         targets = repmat(condLabelNb', 1, nbRun)';
%         targets = targets(:);
%         targets = repmat(targets, betasPerCondition, 1);
%         
%         condLabelName = repmat(condLabelName', 1, nbRun)';
%         condLabelName = condLabelName(:);
%         condLabelName = repmat(condLabelName, betasPerCondition, 1);
% 
% 
%     case 'semantics' % living v. non-living
%         
%         
%         
%         
%     case 'phonology' % -on v. -et
%         
%     case 'format' % french v. braille
% 
% end
% design info from opt
nbRun = opt.mvpa.nbRun;
betasPerCondition = opt.mvpa.nbTrialRepetition; % trial is given by trial_type

% chunk (runs), target (condition), labels (condition names)
conditionPerRun = length(condLabelNb);
betasPerRun = betasPerCondition * conditionPerRun;

chunks = repmat((1:nbRun)', 1, betasPerRun);
chunks = chunks(:);

targets = repmat(condLabelNb', 1, nbRun)';
targets = targets(:);
targets = repmat(targets, betasPerCondition, 1);

condLabelName = repmat(condLabelName', 1, nbRun)';
condLabelName = condLabelName(:);
condLabelName = repmat(condLabelName, betasPerCondition, 1);

% assign our 4D image design into cosmo ds git
ds.sa.targets = targets;
ds.sa.chunks = chunks;
ds.sa.labels = condLabelName;

% figure; imagesc(ds.sa.chunks);

end



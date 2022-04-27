function accu = calculateMvpaWithinModality(opt, condition)

% main function which loops through masks and subjects to calculate the
% decoding accuracies for given conditions.
% dependant on SPM + CPP_SPM and CosMoMvpa toolboxes
% the output is compatible for R visualisation, it gives .csv file as well
% as .mat file

% get the smoothing parameter for 4D map
funcFWHM = opt.funcFWHM;

% choose masks to be used
opt = chooseMask(opt);

% fn = getSavename(condition); 

% set output folder/name
savefileMat = fullfile(opt.pathOutput, ...
    [opt.taskName, '_', char(condition), '_s', num2str(opt.funcFWHM), '_ratio', num2str(opt.mvpa.ratioToKeep), '.mat']);

savefileCsv = fullfile(opt.pathOutput, ...
    [opt.taskName, '_', char(condition), '_s', num2str(opt.funcFWHM), '_ratio', num2str(opt.mvpa.ratioToKeep), '.csv']);

%% MVPA options

% set cosmo mvpa structure
condLabelNb = getConditionIDs(opt, condition);
condLabelName = getConditionNames('all_betas'); % sweep the mess under the rug

decodingCondition = getConditionList(); % just to hide the huge amount of conditions


%% let's get going!

% set structure array for keeping the results
accu = struct('subID', [],       'mask', [], ...
    'accuracy', [],    'prediction', [], ...
    'maskVoxNb', [],   'choosenVoxNb', [], ...
    'image', [],       'ffxSmooth', [], ...
    'roiSource', [],   'decodingCondition', [], ...
    'permutation', [], 'imagePath', []);

count = 1;

for iSub = 1:numel(opt.subjects)
    
    % get FFX path
    subID = opt.subjects{iSub};
    ffxDir = getFFXdir(subID, funcFWHM, opt);
    
    % get subject folder name
    subFolder = ['sub-', subID];
    
    for iImage = 1:length(opt.mvpa.map4D)
        
        subMasks = opt.maskName(startsWith(opt.maskName,strcat('sub-00',num2str(iSub))));
        
        for iMask = 1:length(subMasks)
            
            decID = 1;
                        
            % choose the mask
            mask = fullfile(opt.maskPath, subFolder, subMasks{iMask});
            
            % display the used mask
            disp(subMasks{iMask});
            
            % 4D image
            imageName = ['4D_', opt.mvpa.map4D{iImage}, '_', num2str(funcFWHM), '.nii'];
            image = fullfile(ffxDir, imageName);
            
            % Start decoding: 16 words and pairwise decoding
            % Giga-loop: every word against all the others
            % 256 loops
            for iCon = 1:length(condLabelNb) % loop once to get which is #1
                for iDec = 1:length(condLabelNb) % loop again for #2
                    
                    % avoid self-decoding and empty decodings (in the case
                    % of a single script
                    if condLabelNb(iCon) == condLabelNb(iDec) || condLabelNb(iCon) == 0 || condLabelNb(iDec) == 0
                        continue;
                    end
                   
                    % load cosmo input
                    ds = cosmo_fmri_dataset(image, 'mask', mask);
                    
                    % Getting rid off zeros
                    zeroMask = all(ds.samples == 0, 1);
                    ds = cosmo_slice(ds, ~zeroMask, 2);
                    
                    % set cosmo structure
                    ds = setCosmoStructure(opt, ds, condLabelNb, condLabelName);
                    
                    % slice the ds according to your targers (choose your
                    % train-test conditions)
                    if strcmp(condition, 'words') || strcmp(condition, 'br_words')
                        % we are doing deconding on a single word
                        ds = cosmo_slice(ds, ds.sa.targets == condLabelNb(iCon) | ds.sa.targets == condLabelNb(iDec));
                        
                    else % other conditions (phono, sem) with a single decoding
                        ds = cosmo_slice(ds, ds.sa.targets == 1 | ds.sa.targets == 2);
                    end
                    
                    % remove constant features
                    ds = cosmo_remove_useless_data(ds);
                    
                    % calculate the mask size
                    maskVoxel = size(ds.samples, 2);
                    
                    % partitioning, for test and training : cross validation
                    partitions = cosmo_nfold_partitioner(ds);
                    
                    % define the voxel number for feature selection
                    % set ratio to keep depending on the ROI dimension
                    
                    % use the ratios, instead of the voxel number:
                    opt.mvpa.feature_selection_ratio_to_keep = opt.mvpa.ratioToKeep;
                    
                    % ROI mvpa analysis
                    [pred, accuracy] = cosmo_crossvalidate(ds, ...
                                       @cosmo_classify_meta_feature_selection, ...
                                       partitions, opt.mvpa);
                    
                    
                    %% store output
                    accu(count).subID = subID;
                    accu(count).mask = opt.maskLabel{iMask};
                    accu(count).maskVoxNb = maskVoxel;
                    accu(count).choosenVoxNb = opt.mvpa.feature_selection_ratio_to_keep;
                    % accu(count).choosenVoxNb = round(maskVoxel * maxRatio);
                    % accu(count).maxRatio = maxRatio;
                    accu(count).image = opt.mvpa.map4D{iImage};
                    accu(count).ffxSmooth = funcFWHM;
                    accu(count).accuracy = accuracy;
                    accu(count).prediction = pred;
                    accu(count).imagePath = image;
                    %         accu(count).roiSource = roiSource;
                    accu(count).decodingCondition = decodingCondition{1};
                    
                    %% PERMUTATION PART
                    if opt.mvpa.permutate  == 1
                        % number of iterations
                        nbIter = 100;
                        
                        % allocate space for permuted accuracies
                        acc0 = zeros(nbIter, 1);
                        
                        % make a copy of the dataset
                        ds0 = ds;
                        
                        % for _niter_ iterations, reshuffle the labels and compute accuracy
                        % Use the helper function cosmo_randomize_targets
                        for k = 1:nbIter
                            ds0.sa.targets = cosmo_randomize_targets(ds);
                            [~, acc0(k)] = cosmo_crossvalidate(ds0, ...
                                @cosmo_meta_feature_selection_classifier, ...
                                partitions, opt.mvpa);
                        end
                        
                        p = sum(accuracy < acc0) / nbIter;
                        fprintf('%d permutations: accuracy=%.3f, p=%.4f\n', nbIter, accuracy, p);
                        
                        % save permuted accuracies
                        accu(count).permutation = acc0';
                    end
                    
                    % increase the counter and allons y!
                    count = count + 1;
                    decID = decID + 1;
                    
                    fprintf(['Sub'  subID ' - area: ' opt.maskLabel{iMask} ...
                        ', accuracy: ' num2str(accuracy) '\n\n\n']);
                    
                    
                end
            end
        end
    end
end
%% save output

% mat file
save(savefileMat, 'accu');

% csv but with important info for plotting
csvAccu = rmfield(accu, 'permutation');
csvAccu = rmfield(csvAccu, 'prediction');
csvAccu = rmfield(csvAccu, 'imagePath');
writetable(struct2table(csvAccu), savefileCsv);

end

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

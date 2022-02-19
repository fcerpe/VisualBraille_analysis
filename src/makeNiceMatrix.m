%% Decoding data vis
%
% I get a 1x7200 matrix
%
% 7200 = 240 decodings * 3 subs * 5 masks * 2 maps (betas and t)
%
% 1. dividi table in struct

mvpa = struct;
% sub-001
mvpa.raw.sub001.vwfa = struct;  mvpa.raw.sub001.locL = struct;  mvpa.raw.sub001.pfsL = struct;
mvpa.raw.sub001.locR = struct;  mvpa.raw.sub001.pfsR = struct;
% sub-002
mvpa.raw.sub002.vwfa = struct;  mvpa.raw.sub002.locL = struct;  mvpa.raw.sub002.pfsL = struct;
mvpa.raw.sub002.locR = struct;  mvpa.raw.sub002.pfsR = struct;
%sub-003
mvpa.raw.sub003.vwfa = struct;  mvpa.raw.sub003.locL = struct;  mvpa.raw.sub003.pfsL = struct;
mvpa.raw.sub003.locR = struct;  mvpa.raw.sub003.pfsR = struct;

% loop through the matrix and save each chunk in the corresponding file
% (for now)
% Order: sub, image, mask
% Then: 
% sub-001: 1-2400
%   betas: 1-1200
%       locL: 1-240; locR: 241-480; pfsL: 481-720 pfsR: 721-960 vwfa: 961-1200; 
%   tmaps: 1201-2400
%       locL: 1201-1440; locR: 1441-1680; pfsL: 1681-1920 pfsR: 1921-2160 vwfa: 2161-2400;
%
% sub-002: 2401-4800
%   betas: 2401-3600
%       locL: 2401-2640; locR: 2641-2880; pfsL: 2881-3120 pfsR: 3121-3360 vwfa: 3361-3600; 
%   tmaps: 3601-4800
%       locL: 3601-3840; locR: 3841-4080; pfsL: 4081-4320 pfsR: 4321-4560 vwfa: 4561-4800;
%
% sub-003: 4801-7200
%   betas: 4801-6000
%       locL: 4801-5040; locR: 5041-5280; pfsL: 5281-5520 pfsR: 5521-5760 vwfa: 5761-6000; 
%   tmaps: 6001-7200
%       locL: 6001-6240; locR: 6241-6480; pfsL: 6481-6720 pfsR: 6721-6960 vwfa: 6961-7200;

%%
for i = 1:240:7200
    % get chunk
    thisDec = accu(i:i+239);
    
    % save original in corresponding variable
    pathString = "mvpa.raw.";
    
    % mvpa.sub00?
    switch str2double(accu(i).subID)
        case 1, pathString = pathString + "sub001.";
        case 2, pathString = pathString + "sub002.";
        case 3, pathString = pathString + "sub003.";
    end
    
    % mvpa.sub.area?
    switch accu(i).mask
        case 'VWFA-Left',   pathString = pathString + "vwfa";
        case 'LOC-Left',    pathString = pathString + "locL";
        case 'PFS-Left',    pathString = pathString + "pfsL";
        case 'LOC-Right',   pathString = pathString + "locR";
        case 'PFS-Right',   pathString = pathString + "pfsR";
    end
    
    %save chunk in the right struct place
    eval([char(pathString) '.' accu(i).image '.raw = thisDec;']);
            
    % But also, make them into a matrix
    
    % Adjust pathString: from raw to mat
    pathString{1}(6:8) = 'mat';
    % Place every accuracy from struct to 16x16 matrix: every 16 add a NaN
    %%
    iDec = 0; % skip index
    iAcc = 1; % accuracy index
    accuMat = nan(16);
    for iMat = 1:256 % for each place in the matrix
        % every 17, skip one (leaves the diagonal empty)
        if mod(iDec,17) == 0
            iDec = iDec +1;
            continue;
        end
        
        % get this accuracy and put it in the matrix place
        thisAccu = thisDec(iAcc).accuracy;
        accuMat(iMat) = thisAccu;
        iDec = iDec +1;
        iAcc = iAcc +1;
    end
    
    eval([char(pathString) '.' accu(i).image ' = accuMat;']);
    
    % show figure as heatmap
    lab_mvpa = {'fr-balcon', 'fr-vallon', 'fr-cochon', 'fr-faucon', ...
                'fr-chalet', 'fr-sommet', 'fr-poulet', 'fr-roquet', ...
                'br-balcon', 'br-vallon', 'br-cochon', 'br-faucon', ...
                'br-chalet', 'br-sommet', 'br-poulet', 'br-roquet'};
    name = pathString{1}([10 15]) + "_" + pathString{1}(17:20) + "_" + string(accu(i).image(1)) + "_htmp";
    figure;
    eval(['mvpa.' char(name) ' = heatmap(lab_mvpa,lab_mvpa,accuMat,''CellLabelColor'',''none'',''Colormap'',parula);']);
    title = pathString{1}([10 15]) + "-" + pathString{1}(17:20) + "-" + string(accu(i).image(1));
    eval(['mvpa.' char(name) '.Title = ''' char(title) ''';']);
end
































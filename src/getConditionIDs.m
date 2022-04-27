%% Get ID list based on the decoding analysis we're running

function outList = getConditionIDs(opt,condition)

switch condition
    
    case 'words'
        if strcmp(opt.desc,'Mvpa_singleWords')
            outList = 1:16; % one beta per word
        else
            outList = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 ...
                        9 9 9 9 10 10 10 10 11 11 11 11 12 12 12 12 13 13 13 13 ...
                        14 14 14 14 15 15 15 15 16 16 16 16]; % one beta per stimulus
        end
    
    case 'fr_semantics' % living = 1; non-living = 2;
        outList = [2 2 1 1 2 2 1 1 0 0 0 0 0 0 0 0];
        
    case 'fr_phonology' % on = 1; et = 2
        outList = [1 1 1 1 2 2 2 2 0 0 0 0 0 0 0 0];
        
    case 'br_semantics' % living = 1; non-living = 2;
        outList = [0 0 0 0 0 0 0 0 2 2 1 1 2 2 1 1];
        
    case 'br_phonology' % on = 1; et = 2
        outList = [0 0 0 0 0 0 0 0 1 1 1 1 2 2 2 2];
        
    case 'fr_words' % single words within french
        outList = [1 2 3 4 5 6 7 8 0 0 0 0 0 0 0 0];
        
    case 'br_words' % single words within braille
        outList = [0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8];
        
        
end
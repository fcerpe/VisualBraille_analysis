function outString = getSavename(condition)

switch condition
    
    case 'words'
        if strcmp(opt.desc,'Mvpa_singleWords')
            outString = 'Fr-v-Br_singleWords';        
        else
            outString = 'Fr-v-Br_singleBetas';     % one beta per stimulus
        end
    
    case 'fr_semantics' % living = 1; non-living = 2;
        outString = 'Fr_semantics';    
        
    case 'fr_phonology' % on = 1; et = 2
        outString = 'Fr_phonology';
        
    case 'br_semantics' % living = 1; non-living = 2;
        outString = 'Br_semantics';    
        
    case 'br_phonology' % on = 1; et = 2
        outString = 'Br_phonology';
        
    case 'format' % just french vs. braille
        outString = 'French_v_Braille';    
        
end


end
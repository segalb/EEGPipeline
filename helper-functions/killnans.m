function [cellarray] = killnans(cellarray)

for cidx=1:size(cellarray,1)
    
    for ridx=1:size(cellarray,2)
        
        if cell2mat(cellfun(@(x)any(isnan(x)), cellarray(cidx, ridx), 'UniformOutput', false))
            
            cellarray(cidx, ridx) = {[]};
            
        end
    end
end
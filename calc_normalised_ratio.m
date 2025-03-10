%this function calculates the normalised ratio (Fm) 


%Calculate fmax/min normalised ratio (f-Fmin/Fmax)
%where      
    %Fmin = avg of lowest 5% of values in the trace
    %Fmax = avg of highest 5% of values in the trace
%the full trace, baseline start (bstart) to movie end (mend) is used to
%calculate the top and bottom 5% of traces


function [norm_ratios] = calc_normalised_ratio(ratios, bstart, mend)
   
    % Sort all values in ratios from baseline start to end of movie in ascending order
        %check if movie is long enough to reach movie end frame, if not,
        %take last frame available
    if length(ratios)<mend
        sortedratios = sort(ratios(bstart:end));

    else

         sortedratios = sort(ratios(bstart:mend));
    end
        
        
       
    
    % Remove NaN values 
    sortedratios = sortedratios(~isnan(sortedratios));
    
    % Calculate how many frames represent 5% of total frames
    p5 = round(length(sortedratios) * 0.05);
    
    % Compute Fmin and Fmax using the lowest/highest 5% of values
    Fmin = mean(sortedratios(1:p5), 'omitnan');  
    Fmax = mean(sortedratios(end-p5+1:end), 'omitnan'); 
    
    % Prevent division by zero in case Fmax == F0
    if Fmax == Fmin
        warning('Fmax and F0 are equal. Normalization may fail.');
        norm_ratios = NaN(size(ratios)); % Assign NaN to avoid errors
    else
        norm_ratios = (ratios - Fmin) / Fmax;
    end



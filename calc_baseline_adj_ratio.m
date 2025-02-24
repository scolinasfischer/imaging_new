%This function calculates the baseline-adjusted ratio 
%Baseline-adjusted ratio is (R - R0 / R0)
    %where 
    % R = green/red ratio at each timepoint
    % R0 = average ratio during baseline period (bstart - bend)



function [badjratio] = calc_baseline_adj_ratio(ratios, bstart, bend)

 R0 = mean(ratios(bstart:bend),'omitnan'); % R0
 badjratio = ((ratios - R0)/R0); %baseline adjusted ratio
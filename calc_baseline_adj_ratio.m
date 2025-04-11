
    %{
Calculates baseline-adjusted fluorescence ratio (R - R0) / R0).
R0 is the average ratio during  the baseline window. 

Inputs:
- ratios: raw or corrected G/R ratio vector
- moviepars: defines bstart and bend

Output:
- badjratio: baseline-adjusted vector
%}


function [badjratio] = calc_baseline_adj_ratio(ratios, moviepars)

bstart = moviepars.bstart;
bend   = moviepars.bend;

 R0 = mean(ratios(bstart:bend),'omitnan'); % R0
 badjratio = ((ratios - R0)/R0); %baseline adjusted ratio
# imaging_new
## New and improved code for analysing Ca2+ imaging data

The script "main_analysis" coordinates parameter input and calling of all other functions to conduct processing and analysis of calcium imaging data. 

Options include whether to carry out bleach-correction, plot baseline-adjusted and/or minmax normalised ratios.
There is also the option to carry out type 1 type 2 analysis as developed for AIY, as well as ON/OFF categorisation as developed for RIM and AIB. 

Important notes: 


- ON/OFF categorisation	(AIB/RIM) analysis: things that are missing that could be added:
    - Option to set what time period using for R0, currently using baseline for everything but should be able to plot version using e.g. 10secs prior to odour off or 10 secs prior to odour on. 
    - Cumulative proportion plot
    - Maximum response calculation, save to excel +  plot

- Bleach-correction:
    - Could consider adding the option to bleach-correct depending on R2 value after fitting exponential. Currently this is not the case, bleach-correction is done for all neurons, regardless of R2 value. The problem with only correcting some neurons     though, is that , then, the ratio of neurons that have been bleach-corrected will have values that are much smaller in magnitude than those that have not been bleach corrected , so we would need to come up with a work
around for this.  





Further thoughts: 
  - Timings:
    - Currently the analysis assumes that the frame rate is constant during the entire video, however, this is not the case. The frame rate is set manually to 10, but in reality it fluctuates around 9.9. 
    - This causes error to accumulate, because the frames are not timestamped: we assume that frame 792 corresponds to second  80, and that frame 2079 corresponds to frame 210 (assuming frame rate of               9.9). The final frame corresponds to second 220,          however, because the frame rate is variable, the total frame number is variable:
        - For movies of 220 seconds, which ideally would have 2200 frames, in reality only 2181-2187 frames. 
        - Average frame rate is therefore 2184/2200 = 0,992727273. 
    - I think the best thing to do is to record short videos to reduce the time over which the error can accumulate. 
    - If want to try to correct for this error, I would use an approach along the lines of script “test_timeresampling4” (but haven’t thought it through fully or executed it so make sure to check and think     if there is a better option).


  - Input parameters:
    - It would probably be more reliable to have set input parameters for each neuron, saved as a .mat file, and load it at the beggnining of the analysis, rather than inputting them manually in the script (especially for the infomration in the             structure "moviepars" . 


Attached is doc with Diagram of analysis flow and general overview of all functions. 

[imaging_new Analysis Pipeline Documentation.docx](https://github.com/user-attachments/files/19708155/imaging_new.Analysis.Pipeline.Documentation.docx)


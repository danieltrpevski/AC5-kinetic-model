# AC5-kinetic-model
This repository contains the kinetic models for the adenylyl cyclase 5 signal transduction network studied in [1].
The model is built in MATLAB's Simbiology, and this repository contains the following files:

## 1. Simbiology project file:
- AC5small.sbproj - this is the project file containing the kinetic models used in [1].

## 2. Scripts for generating some of the figures in [1]. 
These scripts can also be used to explore the models.
- single_run_ABS.m and single_run_SBS.m - provide output of running the ABS and SBS versions of the kinetic model, as in Fig. 3.
- cAMP_ABS.m and cAMP_SBS.m - provide the cAMP production that would be achieved with the ABS and the SBS versions of the kinetic model
- scans_SBS.m - parameter scans as in Fig. 4.
- detection_window.m - calculates the detection window in Fig. 3G

## 3. Scripts for auxiliary functions:
ach_square_dip.m
ach_square_dips.m
da_square_pulse.m
da_square_pulses.m
relaxsys_for_smallAC5.m
set_Gi_dips.m
set_Gs_pulses.m
set_Gi_production_rule.m
set_Gs_production_rule.m

## 4. Text files
These contain the reactions and parameter values for the ABS and SBS versions of the kinetic model:
- reactions-ABS.txt
- reactions-SBS.txt
- parameters-ABS.txt
- parameters-SBS.txt


[1] DOI to come

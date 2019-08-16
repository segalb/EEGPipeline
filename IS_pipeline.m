%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interaction Study Preprocessing Pipeline  %
% AUTHOR: Jeremy C. Simon                   %
% VERSION DATE: 29 May 2019                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%run these first
clear
clc
format compact
hold off; close all

%--INSTRUCTIONS--%
%--This script is in two pieces:
%Set options: set your options regardless of what analysis you are running:
%What do you want to call the analysis (this name will be given to the
%folder holding all your files)? Do you want individual data or dyadic
%data, or both? Which particiapnts do you want? Do you want to exclude any?
%More options are available in the anlaysis_options file

%Run pipeline: thirteen scripts that can be called in the pipeline:
% 1. RidTTL_loop gets rid of the extra TTLs in our data
% 2. Make_eeg_lab_data takes the BrainVision files and makes eeglab files,
%it also splits the dyadic data into separate files for each participant
%and downsamples everything to 250 Hz
% 3. Segmentation creates a separate file for every TTL. It defaults to
%doing all of the ones in your data, but you can select which you want
%below.
% 4. Pre_ICA_clumping puts together some small segments so that ICA can run
% 5. Filtering filters the data
% 6. IS_ICA runs ICA and saves the weights
% 7. Artifact_Removal removes artifactual components. It can deal with eye
%components, muscle components, or "Other" components
% 8. de-clumping splits the combined data sets back into their individual
%segments
% 9. Epoch-Removal removes messy epochs and re-references
% 10. Power_Extraction does spectral decomposition for each electrode
% 11. Topograhic_Maps creates .fig files of the topoographic distribution of
%averaged extracted power
% 12. save_as saves the .fig files as images
% 13. Auditor goes through the folders created by the pipeline and tells you
%what participants and segments are missing

%Simply comment out (%) any steps that you don't want to run. Each step
%only needs to be run once.

%--What you need to run this
% 1. a folder called "raw" containing the three BrainVision export files
% for every subject you want to run (.eeg, .vmrk, and .vhdr)
% 2. analysis_options.m
% 3. a folder called "script-functions" that contains the scripts below
% 4. a folder called "helper-functions" that contains additional scripts
% 5. an instance of eeglab. If that folder is not called eeglab14_1_2b or
% if you are not Jennifer Gutsell, you should edit either the folder name
% or the analysis_options script so that it can find the electrode location
% info for our caps

%--TTL warning
%RidTTL_loop only works with .xlsx files as inputs. 
%Where there are extra TTLs, "Missing_and_additional_TTLs.txt" will tell
%you, and there will be segments named for them. The script deals with some
%but not all cases...updates pending.


%--SET OPTIONS--%
%--job name
config_options.job_name = 'Full_Run_No_Images_5.24';

%--analysis type
config_options.analysis_type = 'Indiv'; % 'Dyad' | 'Indiv' | 'Both'

%--select participants
%%if commented out, will use all files%%
%config_options.Dyads = [14]; % set this to the Dyad files you want (dyad #, not indiv #!)
config_options.Indivs = [1002]; %set this to the Individual files you want

%--set exclusions
config_options.exclusions = [6]; %set exclusions here.
%Otherwise, defaults are in analysis_options, but they are not gospel.

%--filter options
config_options.highpass = 1; %set this where you want it
config_options.lowpass = 30;
config_options.laplacian = 'on'; % 'on' | 'off'

%--amplitude-based epoch rejection
config_options.uV_threshold = 100;

%--artifact thresholds
config_options.blink_threshold = .85;
config_options.emg_removal = 'on'; % 'on' | 'off'
config_options.emg_threshold = .85;
config_options.other_removal = 'on'; % 'on' | 'off'
config_options.other_threshold = .85;
config_options.brain_threshold = .75; %this is for ICA mu extraction

%--ICA options
config_options.icatype = 'sobi'; % 'sobi' |'extended'
config_options.save_img = 'off'; % 'on' | 'off
% affects both artifact and mu components

%--ICA extraction options
% if on, will ignore decomposition
config_options.ICA_power = 'off'; % 'on' | 'off' 
config_options.ica_electrodes = {'C3' 'Cz' 'C4'};
config_options.ica_electrode_flag = 'Mu'; %whatever you want your power to be called

%--spectral decomposition options
%this won't run if ICA_power is 'on'
config_options.decomp = 'wavelet'; % 'wavelet' | 'Spectopo'
config_options.pfreq_low = 8; %Mu is 8-13 Hz
config_options.pfreq_high = 13;
%wavelet and Spectopo output is logged

%--electrode set-up
%config_options.electrode_template = []; %don't change this

%--set ttls to segment here (defaults to all)
%config_options.dyad_ttls.names =  {':_Action_Coordination_dual'};
config_options.indiv_ttls.names = {'!_Action_Coordination_indiv' }
% config_options.indiv_ttls.names = {
%   ':_black_hand_1', ...
%     ':_black_hand_2', ...
%     ':_black_hand_3', ...
%     ':_white_hand_1', ...
%     ':_white_hand_2', ...
%     ':_white_hand_3', ...
%     ':_white_noise_black_hand_1', ...
%     ':_white_noise_black_hand_2', ...
%     ':_white_noise_black_hand_3', ...
%     ':_white_noise_white_hand_1', ...
%     ':_white_noise_white_hand_2', ...
%     ':_white_noise_white_hand_3', ...
%     ':_white_noise_ball_roll_1', ...
%     ':_white_noise_ball_roll_2', ...
%     ':_white_noise_ball_roll_3', ...
%     ':_white_noise_ball_roll_4', ...
%     ':_white_noise_ball_roll_5', ...
%     ':_white_noise_ball_roll_6', ...
%     ':_white_noise_ball_roll_7', ...
%     ':_white_noise_ball_roll_8', ...
%     ':_ball_roll_1', ...
%     ':_ball_roll_2', ...
%     ':_ball_roll_3', ...
%     ':_ball_roll_4', ...
%     ':_ball_roll_5', ...
%     ':_ball_roll_6', ...
%     ':_ball_roll_7', ...
%     ':_ball_roll_8', ...
%     ':_Action_Coordination_indiv', ...
%     ':_eyes_open_baseline', ...
%     ':_80s_white_noise_baseline'};
% REMEMBER TO KEEP CLUMPS TOGETHER

options = analysis_options(config_options);
eeglab; close

%--RUN PIPELINE--%

%--Pre-Processing
RidTTL_loop(options); %Needs to have the .xlsx files set up already
make_eeg_lab_data(options); %separates participants in dyad and creates indiv files. Also downsamples to 250 Hz

segmentation(options); %deals with some but not all extra ttls

%%This doesnot even work because our TTl is nothere
%%TODO: to fix this and add our TTL if we want to preclump
Pre_ICA_clumping(options); %puts together shorter segments to keep ICA viable
filtering(options); %filters and epochs data

%--ICA
%%fix the ICA it's not ready yet
IS_ICA(options);

Artifact_Removal(options); %can also remove EMG and/or Other artifacts (set above)
de_clumping(options);
Epoch_Removal(options); %removes bad epochs and rereferences

%--Power Extraction

%power_extraction(options);

%--Topographic Mapping

%Topographic_Maps(options);
%save_figures_as(options);  %can save as as any extension saveas() supports

%--Audit files created in pipeline
Auditor(options);

%--save options for future reference
cd(options.save_dir);
save(strcat(options.job_name, '_options.mat'),  'options')
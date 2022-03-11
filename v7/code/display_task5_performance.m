% Purpose:  Analyze behavioral performance for task 5 for version 6.
% By:       Michael Jigo
%

function display_task5_performance(subj,varargin)
   %% Parse optional inputs
      optionalIn  = {'spatial_profile' 'model_variant' 'show_fit'};
      optionalVal = {'center_surround2DG' 'response_gain' 1};
      model       = parseOptionalInputs(optionalIn,optionalVal,varargin);
   
   %% Load subject's behavior
      data        = load_subj_data(subj,'task5');


   %% Check if subject's data have been fit, if yes plot it
      fitFile     = sprintf('../data/fitted_parameters/task5/%s/%s/%s.mat',model.model_variant,model.spatial_profile,subj);
      if exist(fitFile,'file') && model.show_fit
         load(fitFile);
         model.dprime= out.fineModel;
         model.ecc   = out.data.fineEcc;
      else
         model.dprime= [];
         model.ecc   = [];
      end

   %% Plot
      % Fixation vs Saccade Target
         create_fix_saccadeTarget_plot(data,model,subj)

      % Fixation vs Saccade
         create_fix_saccade_plot(data,model,subj)

      % Fixation vs Valid
         %create_fix_valid_plot(data,model,subj)


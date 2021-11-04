% Purpose:  This function will call all requisite functions to fit imAmodel (IMage-computable Attention model)
%           to the behavioral data collected from thresholding/training session (task 1) for individual subjects.
%        
%           To simulate behavior in the detection task:
%              - two images will be passed to the model (one with a target patch, another without)
%              - four model parameters will be adjusted for individual subjects:
%                 1. cg_max
%                 2. cg_slope
%                 3. freq_max
%                 4. freq_slope
%                 5. bw_max
%                 6. criterion
%              - model discriminability between images will be matched to behavior using Maximum Likelihood Estimation
%
% By:       Michael Jigo

function fit_task1_likelihood(subj)
   % add paths
   addpath(genpath('../../../modelCPD'));
   addpath(genpath('~/apps'));
   addpath(genpath('./helperfun'));

   % specify attention condition
   attnType = 'neutral'; % only neutral condition will be analyzed here

   %% Set indices for loaded data matrix
      % matrix columns
      % 1   block number
      % 2   bandwidth                  (orientation bandwidth)
      % 3   size                       (target patch size)
      % 4   background orientation     (-45 or 45)
      % 5   patch orientation          (-45 or 45)
      % 6   cue ecc                    (0)
      % 7   cue absolute ecc           (0)
      % 8   target ecc                 (+-)
      % 9   target absolute ecc        (+)
      % 10  response cue ecc           (+-)
      % 11  response cue absolute ecc  (+)
      % 12  response                   (0=absent; 1=present)
      % 13  accuracy                   (0=incorrect; 1=correct)
      idx_targecc    = 9;
      idx_respcue    = 11;
      idx_resp       = 12;
      idx_size       = 3;


   %% Load data
      % load subject data
         subjdata = sprintf('../data/raw/%s_Task1_resMat.mat',subj);
         load(subjdata);
         tmp = resMat;

      % parse data into necessary experiment variables
         data.subj               = subj;
         data.trials.response    = tmp(:,idx_resp);
         data.trials.ecc         = tmp(:,idx_respcue);
         data.trials.size        = tmp(:,idx_size);
         data.trials.presence    = tmp(:,idx_targecc);
         data.ecc                = unique(data.trials.ecc);
         data.size               = unique(data.trials.size);

         % make 'presence' binary (1=present; 0=absent)
            data.trials.presence(~isnan(data.trials.presence)) = 1;
            data.trials.presence(isnan(data.trials.presence))  = 0;

      % add in calculated dprime
         dprimedir = '../data/dprime/';
         load(sprintf('%s%s.mat',dprimedir,subj));
         data.dprime = dprime;

   


   %% Create stimuli
      % image parameters
         linesize    = [0.1 0.3];
         pxperdeg    = 32;
         imsize      = [5 8];
         sizes       = data.size;
         spacing_row = 0.3;
         spacing_col = 0.3;
         

      % generate textures
         for d = 1:numel(sizes)
            [stim(d).target stim(d).notarg stim(d).texture_params] = make_texture(...
               'line_size',linesize,...
               'px_per_deg',pxperdeg,...
               'im_size',imsize,...
               'line_spacing_row',spacing_row,...
               'line_spacing_col',spacing_col,...
               'targ_array_size',[sizes(d) sizes(d)]);

         % clamp images to vary between 0 and 1
            stim(d).target(stim(d).target>1) = 1;
            stim(d).notarg(stim(d).notarg>1) = 1;
         end

   
      % decompose images
         for d = 1:numel(sizes)
            [~,stim(d).energy.targ]    = imAmodel(stim(d).target,'px_per_deg',pxperdeg,'im_size',imsize,'decompose_only',1,'preprocess_image',1);
            [~,stim(d).energy.notarg]  = imAmodel(stim(d).notarg,'px_per_deg',pxperdeg,'im_size',imsize,'decompose_only',1,'preprocess_image',1);
         end
         keyboard



   %% Create parameter configuration matrix
      config = create_configuration_matrix_likelihood(data,'spatial_profile',attnType,'model_variant','main_model');


   %% Initialize model parameters
      [stimdrive supdrive attn observer config] = format_unformat_params_likelihood(config);


   %% Perform optimization
      objective = @(params)fit_task1_objective(stimdrive,supdrive,attn,observer,data,stim,config,params);

      % fitting options
         options = bads('defaults');
         options.MaxIter = 1e2;

      % BADS
         [fit_params fit_err] = bads(objective,config.paramvals',config.bnds(:,1)',config.bnds(:,2)',config.plausbnds(:,1)',config.plausbnds(:,2)',[],options); 



   %% Evaluate model to generate best-fitting values at finely-spaced eccentricities
      % evaluate to get model response at tested eccentricities, as well as cost and likelihood
         [~, model, sse]   = fit_task1_objective(stimdrive,supdrive,attn,observer,data,stim,config,fit_params);
      % evaluate at finely spaced eccentricities
         data.fineEcc      = min(data.ecc):0.1:max(data.ecc);
         fineModel         = fit_task1_objective_fineSpacing(stimdrive,supdrive,attn,observer,data,stim,config,fit_params);
      % put best-fitting parameters in proper format
         [stimdrive supdrive attn observer config] = format_unformat_params_likelihood(config,fit_params',stimdrive,supdrive,attn,observer);


   %% Put variables in a handy structure
      out.negLL      = fit_err;
      out.sse        = sse;
      out.observer   = observer;
      out.stimdrive  = stimdrive;
      out.supdrive   = supdrive;
      out.attn       = attn;
      out.config     = config;
      out.data       = data;
      out.model      = model;
      out.fineModel  = fineModel;


   %% Save file
   savedir = '../data/fitted_parameters/task1/';
   if ~exist(savedir,'dir')
      mkdir(savedir);
   end
   save(sprintf('%s%s.mat',savedir,subj),'out');

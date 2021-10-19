% Purpose:  This function will call all requisite functions to simulate performance on the thresholding task.
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

%%%%% DID NOT WRITE THIS YET %%%

function simulate_task1(subj)
   attnType = 'neutral';
   % matrix columns
   % 1   block number
   % 2   bandwidth                  (orientation bandwidth)
   % 3   density                    (texture density)
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
      idx_block      = 1;
      idx_targecc    = 9;
      idx_respcue    = 11;
      idx_resp       = 12;
      idx_density    = 3;
      idx_bw         = 2;



   %% Load data, initialize stimuli
      % load subject data
         subjdata = sprintf('../data/raw/%s_Task1_resMat.mat',subj);
         load(subjdata);
         tmp = resMat;

      % parse data into necessary experiment variables
         data.subj             = subj;
         data.trials.response  = tmp(:,idx_resp);
         data.trials.ecc       = tmp(:,idx_respcue);
         data.trials.density   = tmp(:,idx_density);
         data.trials.presence  = tmp(:,idx_targecc);
         data.ecc              = unique(data.trials.ecc);
         data.density          = unique(data.trials.density);

         % make 'presence' variable binary (1=present; 0=absent)
            data.trials.presence(~isnan(data.trials.presence)) = 1;
            data.trials.presence(isnan(data.trials.presence))  = 0;

      % add in calculated dprime
         dprimedir = '../data/dprime/';
         load(sprintf('%s%s.mat',dprimedir,subj));
         data.dprime = dprime;

   
      % create texture images for each tested density
         % image parameters
         linesize    = [0.0312 0.2];
         pxperdeg    = 32;
         imsize      = [5 5];
         densities   = unique(data.density);
         %densities   = densities(1); % DEBUG

         % generate textures
         for d = 1:numel(densities)
            line_spacing_row = densities(d);
            line_spacing_col = densities(d);
            [stim(d).target stim(d).notarg stim(d).texture_params] = make_texture(...
               'line_size',linesize,...
               'px_per_deg',pxperdeg,...
               'im_size',imsize,...
               'line_spacing_row',densities(d),...
               'line_spacing_col',densities(d),...
               'bg_color','gray',...
               'targ_array_size',[1 1]);

            % clamp images to vary between 0 and 1
               stim(d).target(stim(d).target>1) = 1;
               stim(d).notarg(stim(d).notarg>1) = 1;
         end

   
         % decompose images
            for d = 1:numel(densities)
               [~,stim(d).energy.targ] = imAmodel(stim(d).target,'px_per_deg',pxperdeg,'im_size',imsize,'decompose_only',1,'preprocess_image',1);
               [~,stim(d).energy.notarg] = imAmodel(stim(d).notarg,'px_per_deg',pxperdeg,'im_size',imsize,'decompose_only',1,'preprocess_image',1);
            end


   %% Create parameter configuration matrix
      config = create_configuration_matrix_likelihood(data,'spatial_profile',attnType,'model_variant','main_model');


   %% Initialize model parameters
      [stimdrive supdrive attn observer config] = format_unformat_params_likelihood(config);


   %% Evaluate model to generate best-fitting values
      fit_params = config.paramvals';
      [~, model, sse] = fit_task1_objective(stimdrive,supdrive,attn,observer,data,stim,config,fit_params);
      [stimdrive supdrive attn observer config] = format_unformat_params_likelihood(config,fit_params',stimdrive,supdrive,attn,observer);
      keyboard


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


   %% Save file
   savedir = '../data/fitted_parameters/task1/';
   if ~exist(savedir,'dir')
      mkdir(savedir);
   end
   save(sprintf('%s%s.mat',savedir,subj),'out');


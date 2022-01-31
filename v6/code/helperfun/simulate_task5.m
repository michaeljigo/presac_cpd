% Purpose:  Just a simple simulation function for attention effects.
% By:       Michael Jigo

function simulate_task5
   %% Add paths
      addpath(genpath('../../../modelCPD'));
      addpath(genpath('~/apps'));
      addpath(genpath('./helperfun'));


   %% Load the desired subject's parameters
      subj              = 'NH';
      spatial_profile   = 'center_surround2DG';
      model_variant     = 'response_gain';
      filepath          = sprintf('../data/fitted_parameters/task5/%s/%s/%s.mat',model_variant,spatial_profile,subj);
      load(filepath);
      data              = out.data;
      observer          = out.observer;
      stimdrive         = out.stimdrive;
      supdrive          = out.supdrive;
      attn              = out.attn;
      config            = out.config;
      

   %% Create stimuli
      % image parameters
         linesize    = [0.1 0.3];
         pxperdeg    = 32;
         imsize      = [5 22];
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
            [~,stim(d).energy.targ]    = imAmodel(stim(d).target,'px_per_deg',pxperdeg,'im_size',imsize,'decompose_only',1,'preprocess_image',0);
            [~,stim(d).energy.notarg]  = imAmodel(stim(d).notarg,'px_per_deg',pxperdeg,'im_size',imsize,'decompose_only',1,'preprocess_image',0);
         end



   %% Evaluate model to generate best-fitting values at finely-spaced eccentricities
      % evaluate at finely spaced eccentricities
      tic
         data.fineEcc      = linspace(min(data.ecc),max(data.ecc),15);
         fineModel         = fit_task5_objective_fineSpacing(stimdrive,supdrive,attn,observer,data,stim,config,config.paramvals,0);
         toc
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
      out.fineModel  = fineModel;


   %% Save file
   savedir = sprintf('../data/fitted_parameters/task5/%s/%s/',p.model_variant,p.spatial_profile);
   if ~exist(savedir,'dir')
      mkdir(savedir);
   end
   save(sprintf('%s%s.mat',savedir,subj),'out');

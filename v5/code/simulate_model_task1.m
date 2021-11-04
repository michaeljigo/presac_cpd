% Purpose:  Simulate model output for a range of texture sizes for a given subject's best-fitting parameters.
% By:       Michael Jigo

function simulate_model_task1(subj,sizes)

   %% Load subject's best-fitting parameters
      file = sprintf('../data/fitted_parameters/task1/%s.mat',subj);
      load(file);

   %% Generate stimuli for model simulation
      % image parameters
         linesize    = [0.1 0.3];
         pxperdeg    = 32;
         imsize      = [8 8];
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


   %% Generate model responses
      stimdrive         = out.stimdrive;
      supdrive          = out.supdrive;
      attn              = out.attn;
      ecc               = linspace(0,12,30);

      % evaluate moel on all sizes and eccentricities 
         for d = 1:numel(sizes)
            targresp    = imAmodel(stim(d).target,'energy',stim(d).energy.targ.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',ecc);
            notargresp  = imAmodel(stim(d).notarg,'energy',stim(d).energy.notarg.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',ecc);
   
            % compute dprime
               dprime(d,:) = sqrt(sum((targresp(:,:)-notargresp(:,:)).^2,2,'omitnan')); 
         end 
         keyboard

% Purpose:  Evaluates the model at finely-spaced eccentricities for visualization purposes. 
%           The code is based on the objective function, thus the name.
% By:       Michael Jigo

function model = fit_task5_objective_fineSpacing(stimdrive,supdrive,attn,observer,data,stim,config,params,rescale)
   if ~exist('rescale','var')
      rescale = 1;
   end

   if rescale
   %% Re-scale parameters
      [stimdrive supdrive attn observer config] = format_unformat_params(config,params',stimdrive,supdrive,attn,observer);
   end


   %% Evaluate model on all cueing conditions
      spatial_profile = config.paraminfo.spatial_profile;
      model_variant   = config.paraminfo.model_variant;
      % Fixation 
         targresp    = imAmodel(stim.target,'energy',stim.energy.targ.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',data.fineEcc,'model_variant',model_variant);
         notargresp  = imAmodel(stim.notarg,'energy',stim.energy.notarg.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',data.fineEcc,'model_variant',model_variant);
         % compute dprime
            fixation = sqrt(sum((targresp(:,:)-notargresp(:,:)).^2,2,'omitnan')); 

      % Saccade targets
         for st = 1:numel(data.saccadeTarg) % parfor
            saccade_target = data.saccadeTarg(st);
            targresp    = imAmodel(stim.target,'energy',stim.energy.targ.energy,'use_attn',1,'stimdrive',stimdrive,'supdrive',supdrive,'attn',attn,'ecc',data.fineEcc,'attended_ecc',saccade_target,...
               'spatial_profile',spatial_profile,'model_variant',model_variant);
            notargresp  = imAmodel(stim.notarg,'energy',stim.energy.notarg.energy,'use_attn',1,'stimdrive',stimdrive,'supdrive',supdrive,'attn',attn,'ecc',data.fineEcc,'attended_ecc',saccade_target,...
               'spatial_profile',spatial_profile,'model_variant',model_variant);
            % compute dprime
               saccade(st,:) = sqrt(sum((targresp(:,:)-notargresp(:,:)).^2,2,'omitnan')); 
         end 


   %% Get observed performance
      observed       = data.dprime.fix_sacTarg.perf;


   %% Scale FIXATION and SACCADE dprime by internal noise to match OBSERVED dprime
      modelFixation  = mean(fixation(:));
      obsFixation    = mean(observed(1,:));
      scalar         = obsFixation/modelFixation;
      % scale
         fixation    = fixation*scalar;
         saccade     = saccade*scalar;


   %% Format model predictions to match observed dprime
      model(1,:,:)   = repmat(shiftdim(fixation,-1),[numel(data.saccadeTarg) 1]);
      model(2,:,:)   = saccade;

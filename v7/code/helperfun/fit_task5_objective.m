% Purpose:  Objective function for fitting behavioral performance from Task 5.
% By:       Michael Jigo

function [cost model sse] = fit_task5_objective(stimdrive,supdrive,attn,observer,data,stim,config,params)

   %% Re-scale parameters
      [stimdrive supdrive attn observer config] = format_unformat_params(config,params',stimdrive,supdrive,attn,observer);


   %% Evaluate model on all cueing conditions
      spatial_profile = config.paraminfo.spatial_profile;
      model_variant   = config.paraminfo.model_variant;
      % Fixation 
         targresp    = imAmodel(stim.target,'energy',stim.energy.targ.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',data.ecc,'model_variant',model_variant);
         notargresp  = imAmodel(stim.notarg,'energy',stim.energy.notarg.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',data.ecc,'model_variant',model_variant);
         % compute dprime
            fixation = sqrt(sum((targresp(:,:)-notargresp(:,:)).^2,2,'omitnan')); 

      % Saccade targets
         parfor st = 1:numel(data.saccadeTarg) % parfor
            saccade_target = data.saccadeTarg(st);
            targresp    = imAmodel(stim.target,'energy',stim.energy.targ.energy,'use_attn',1,'stimdrive',stimdrive,'supdrive',supdrive,'attn',attn,'ecc',data.ecc,'attended_ecc',saccade_target,...
               'spatial_profile',spatial_profile,'model_variant',model_variant);
            notargresp  = imAmodel(stim.notarg,'energy',stim.energy.notarg.energy,'use_attn',1,'stimdrive',stimdrive,'supdrive',supdrive,'attn',attn,'ecc',data.ecc,'attended_ecc',saccade_target,...
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

      % compute SSE
         sse       = nansum((model(:)-observed(:)).^2);

      
   %% Compute likelihood
      sacEcc = unique(data.trials.sacEcc);
      for f = 1:size(observed,1)       % fixation or saccade
         for st = 1:size(observed,2)   % saccade targets
            for e = 1:size(observed,3) % response-cued ecc
               % extract hits and false alarms for this condition
                  % (adding +0.5 and +1 implements Hautas correction)
                  hits     = sum(data.trials.presence==1 & data.trials.response==1 & data.trials.ecc==data.ecc(e) & data.trials.sacEcc==sacEcc(st) & data.trials.fixSac==(f-1))+0.5; % # hits
                  fa       = sum(data.trials.presence==0 & data.trials.response==1 & data.trials.ecc==data.ecc(e) & data.trials.sacEcc==sacEcc(st) & data.trials.fixSac==(f-1))+0.5; % # false alarms
                  pres     = sum(data.trials.presence==1 & data.trials.ecc==data.ecc(e) & data.trials.sacEcc==sacEcc(st) & data.trials.fixSac==(f-1))+1; % # target present trials
                  abse     = sum(data.trials.presence==0 & data.trials.ecc==data.ecc(e) & data.trials.sacEcc==sacEcc(st) & data.trials.fixSac==(f-1))+1; % # target absent trials

               % compute hit rate and false alarm rate, based on model-derived dprime
                  modelHit = normcdf(model(f,st,e)/2-observer.criterion);
                  modelFA  = normcdf(-model(f,st,e)/2-observer.criterion);
   
               % compute, then add, negative log-likelihood of hit and false alarm rate
                  negLHit  = -computeLL(modelHit,hits,pres);
                  negLFA   = -computeLL(modelFA,fa,abse);
                  negLL(f,st,e) = negLHit+negLFA;
            end
         end
      end
      % sum negative log-likelihood across conditions
         cost = sum(negLL(:));


   %% save interim fit parameters
      out.stimdrive     = stimdrive;
      out.supdrive      = supdrive;
      out.attn          = attn;
      out.observer      = observer;
      out.config        = config;
      out.data          = data;
      out.model         = model;
      out.fixation      = fixation;
      out.saccade       = saccade;
      out.cost          = cost;
      out.sse           = sse;
      savedir = sprintf('../data/running_parameters/task5/%s/%s/',config.paraminfo.model_variant,config.paraminfo.spatial_profile);
      if ~exist(savedir,'dir')
         mkdir(savedir);
      end
      save(sprintf('%s%s.mat',savedir,data.subj),'out');

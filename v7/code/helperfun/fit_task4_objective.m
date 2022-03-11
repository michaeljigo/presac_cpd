% Purpose:  Objective function for fitting behavioral performance from Task 4.
% By:       Michael Jigo

function [cost dprime sse] = fit_task4_objective(stimdrive,supdrive,attn,observer,data,stim,config,params)

   %% Re-scale parameters
      [stimdrive supdrive attn observer config] = format_unformat_params(config,params',stimdrive,supdrive,attn,observer);


   %% Evaluate moel on all sizes and eccentricities 
      for d = 1:numel(data.size)
         targresp    = imAmodel(stim(d).target,'energy',stim(d).energy.targ.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',data.ecc);
         notargresp  = imAmodel(stim(d).notarg,'energy',stim(d).energy.notarg.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',data.ecc);

         % compute dprime
            dprime(d,:) = sqrt(sum((targresp(:,:)-notargresp(:,:)).^2,2,'omitnan')); 
      end 

   %% Scale dprime to match overall dprime (i.e., not sizes interactions)
      %modelOverall = mean(dprime(:));
      %scalar       = data.dprime.overall./modelOverall;
      %dprime       = dprime*scalar;

   %% Scale separately for each size x ecc combination
      scalar         = mean(data.dprime.perf,2)./mean(dprime,2);
      dprime         = dprime.*scalar;

      % compute SSE
         sse       = nansum((dprime(:)-data.dprime.perf(:)).^2);

      
   %% Compute likelihood
      sizes = unique(data.size);
      ecc   = unique(data.ecc); 
      for d = 1:numel(sizes)
         for e = 1:numel(ecc)
            % extract hits and false alarms for this condition
               % (adding +0.5 and +1 implements Hautas correction)
               hits     = sum(data.trials.presence==1 & data.trials.response==1 & data.trials.size==sizes(d) & data.trials.ecc==ecc(e))+0.5; % # hits
               fa       = sum(data.trials.presence==0 & data.trials.response==1 & data.trials.size==sizes(d) & data.trials.ecc==ecc(e))+0.5; % # false alarms
               pres     = sum(data.trials.presence==1 & data.trials.size==sizes(d) & data.trials.ecc==ecc(e))+1;                             % # target present trials
               abse     = sum(data.trials.presence==0 & data.trials.size==sizes(d) & data.trials.ecc==ecc(e))+1;                             % # target absent trials

            % compute hit rate and false alarm rate, based on model-derived dprime
               modelHit = normcdf(dprime(d,e)/2-observer.criterion);
               modelFA  = normcdf(-dprime(d,e)/2-observer.criterion);

            % compute, then add, negative log-likelihood of hit and false alarm rate
               negLHit  = -computeLL(modelHit,hits,pres);
               negLFA   = -computeLL(modelFA,fa,abse);
               negLL(d,e) = negLHit+negLFA;
         end
      end
      % sum negative log-likelihood across conditions
         cost = sum(negLL(:));


   %% Save interim fit parameters
      out.stimdrive     = stimdrive;
      out.supdrive      = supdrive;
      out.attn          = attn;
      out.observer      = observer;
      out.config        = config;
      out.data          = data;
      out.model         = dprime;
      out.cost          = cost;
      out.sse           = sse;
      savedir = sprintf('../data/running_parameters/task4/');
      if ~exist(savedir,'dir')
         mkdir(savedir);
      end
      save(sprintf('%s%s.mat',savedir,data.subj),'out');

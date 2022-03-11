% Purpose:  Evaluates the model at finely-spaced eccentricities for visualization purposes. 
%           The code is based on the objective function, thus the name.
% By:       Michael Jigo

function dprime = fit_task4_objective_fineSpacing(stimdrive,supdrive,attn,observer,data,stim,config,params)

   %% re-scale parameters
      [stimdrive supdrive attn observer config] = format_unformat_params(config,params',stimdrive,supdrive,attn,observer);


   %% evaluate moel on all sizes and eccentricities 
      for d = 1:numel(data.size)
         targresp    = imAmodel(stim(d).target,'energy',stim(d).energy.targ.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',data.fineEcc);
         notargresp  = imAmodel(stim(d).notarg,'energy',stim(d).energy.notarg.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',data.fineEcc);

         % compute dprime
            dprime(d,:) = sqrt(sum((targresp(:,:)-notargresp(:,:)).^2,2,'omitnan')); 
      end 


   %% scale dprime to match overall dprime (i.e., not sizes interactions)
      %modelOverall = mean(dprime(:));
      %scalar       = data.dprime.overall./modelOverall;
      %dprime       = dprime*scalar;

   %% scale separately for each size x ecc combination
      scalar         = mean(data.dprime.perf,2)./mean(dprime,2);
      dprime         = dprime.*scalar;


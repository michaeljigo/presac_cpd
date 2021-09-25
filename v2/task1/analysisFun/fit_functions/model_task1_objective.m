% Purpose:  Objective function for fitting behavioral performance from Task 1.
% By:       Michael Jigo
%           04.23.21

function [cost dprime] = model_task1_objective(stimdrive,supdrive,subjdata,energy,params,freeparams,compute_cost)

   if ~exist('compute_cost','var')
      compute_cost = 1;
   end

   % re-scale and restructure parameters
      % re-scale
      freeparams = freeparams.*(params.bnds(2,:)-params.bnds(1,:))+params.bnds(1,:);

      % restructure parameters
      for p = 1:numel(params.list)
         stimdrive.(params.list{p}) = freeparams(p);
      end


   % compute model response to each density level
   imsize = size(energy(1).targ.energy.im); imsize = nan(imsize(3:4));
   parfor d = 1:numel(subjdata.densityvals)
      targresp = imAmodel(imsize,'energy',energy(d).targ.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',subjdata.eccvals);
      notargresp = imAmodel(imsize,'energy',energy(d).notarg.energy,'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',subjdata.eccvals);

      % compute dprime
      dprime(d,:) = sqrt(sum((targresp(:,:)-notargresp(:,:)).^2,2,'omitnan')); 
      scalar(d,:) = repmat(mean(subjdata.dprime.density_targecc.perf(d,:))./mean(dprime(d,:)),1,numel(subjdata.eccvals));
   end

   % scale dprime
   dprime = dprime./mean(dprime(:)).*mean(subjdata.dprime.density_targecc.perf(:));
   %dprime = dprime.*scalar;

   % compute SSE
   if compute_cost
      obsdata = subjdata.dprime.density_targecc.perf(:);
      cost = sum((dprime(:)-obsdata(:)).^2);
   else
      cost = nan;
   end

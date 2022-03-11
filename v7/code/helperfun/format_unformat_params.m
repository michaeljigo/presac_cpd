% Purpose:  Format vector of parameter values into structures for the excitatory drive (i.e., stimulus drive) and attentional gain.
%           If only config is input, initialize parameter vector and structures.
%           If config, fittedparams, exc, inh and attn are inputs, then format the fitted parameters into the structures.
%
% By:       Michael Jigo
%
% Input:    config         structure containing information of parameter configuration (see load_subj_stim)
%           fittedparams   vector of best-fitting parameters
%           exc            stimulus drive parameter structure
%           inh            suppressive drive parameter structure
%           attn           attentional gain parameter structure
%
% Output:   exc            same as above

function [stimdrive supdrive attn observer config] = format_unformat_params(config,fittedparams,stimdrive,supdrive,attn,observer)
rng('shuffle');

%% Initialize parameters
if nargin==1
   % Initialize parameters for each subject
   for s = 1:size(config.paramidx,1)
      [stimdrive(s), supdrive(s), attn(s), observer(s)] = init_parameters(); 

      % fix parameters for specified spatial proflie
         if strcmp(config.paraminfo.spatial_profile,'center_surround')
            % fix baseline at 1 (i.e., only tuned suppression)
               fixThis = {'attn_baseline'};
               fixVal  = 1;
               for f = 1:numel(fixThis)
                  attn(s).(fixThis{f})             = fixVal(f);
                  attn(s).bnd.(fixThis{f})         = repmat(fixVal(f),[1 2]); 
                  attn(s).plaus_bnd.(fixThis{f})   = repmat(fixVal(f),[1 2]); 
               end
         elseif strcmp(config.paraminfo.spatial_profile,'center_surround2DG')
            % fix sup_amp and sup_spread at 0 (only uniform, non-tuned suppression)
               fixThis = {'attn_sup_amp' 'attn_sup_spread' 'attn_baseline'};
               fixVal  = [0 0 1];
               for f = 1:numel(fixThis)
                  attn(s).(fixThis{f})             = fixVal(f);
                  attn(s).bnd.(fixThis{f})         = repmat(fixVal(f),[1 2]); 
                  attn(s).plaus_bnd.(fixThis{f})   = repmat(fixVal(f),[1 2]); 
               end
         else
            % fix sup_amp and sup_spread at 0 (only uniform, non-tuned suppression)
               fixThis = {'attn_sup_amp' 'attn_sup_spread' 'attn_baseline'};
               fixVal  = [0 0 1];
               for f = 1:numel(fixThis)
                  attn(s).(fixThis{f})             = fixVal(f);
                  attn(s).bnd.(fixThis{f})         = repmat(fixVal(f),[1 2]); 
                  attn(s).plaus_bnd.(fixThis{f})   = repmat(fixVal(f),[1 2]); 
               end
         end

      % set parameters that will be fixed among subjects to NaN
      for param = config.paraminfo.param_list
         param = char(param);
         if ~isequal(s,config.paramidx(s,ismember(config.paraminfo.param_list,param))) % checks if parameter should follow a different experiment
            switch param
               case {'cg_max' 'cg_slope' 'freq_max' 'freq_slope' 'bw_max'}
                  stimdrive(s).(param) = nan;
               case {'attn_freq_max' 'attn_freq_slope' 'attn_bw' 'attn_amp_max' 'attn_spread' ...
                     'attn_baseline' 'attn_sup_amp' 'attn_sup_spread'}
                  attn(s).(param) = nan;
               case {'criterion'}
                  observer(s).(param) = nan;
               case {'sup_space' 'sup_freq' 'sup_ori'}
                  supdrive(s).(param) = nan;
            end
         end

         % put all parameters in a matrix matching the index matrix
         switch param
            case {'cg_max' 'cg_slope' 'freq_max' 'freq_slope' 'bw_max'}
               paramvals(s,ismember(config.paraminfo.param_list,param)) = stimdrive(s).(param);
               param_lo_bnd(s,ismember(config.paraminfo.param_list,param)) = min(stimdrive(s).bnd.(param));
               param_hi_bnd(s,ismember(config.paraminfo.param_list,param)) = max(stimdrive(s).bnd.(param));

               param_plaus_lo(s,ismember(config.paraminfo.param_list,param)) = min(stimdrive(s).plaus_bnd.(param));
               param_plaus_hi(s,ismember(config.paraminfo.param_list,param)) = max(stimdrive(s).plaus_bnd.(param));
            case {'attn_freq_max' 'attn_freq_slope' 'attn_bw' 'attn_amp_max' 'attn_spread' ...
                  'attn_baseline' 'attn_sup_amp' 'attn_sup_spread'}
               paramvals(s,ismember(config.paraminfo.param_list,param)) = attn(s).(param);
               param_lo_bnd(s,ismember(config.paraminfo.param_list,param)) = min(attn(s).bnd.(param));
               param_hi_bnd(s,ismember(config.paraminfo.param_list,param)) = max(attn(s).bnd.(param));
               
               param_plaus_lo(s,ismember(config.paraminfo.param_list,param)) = min(attn(s).plaus_bnd.(param));
               param_plaus_hi(s,ismember(config.paraminfo.param_list,param)) = max(attn(s).plaus_bnd.(param));
            case {'criterion'}
               paramvals(s,ismember(config.paraminfo.param_list,param))    = observer(s).(param);
               param_lo_bnd(s,ismember(config.paraminfo.param_list,param)) = min(observer(s).bnd.(param));
               param_hi_bnd(s,ismember(config.paraminfo.param_list,param)) = max(observer(s).bnd.(param));
               
               param_plaus_lo(s,ismember(config.paraminfo.param_list,param)) = min(observer(s).plaus_bnd.(param));
               param_plaus_hi(s,ismember(config.paraminfo.param_list,param)) = max(observer(s).plaus_bnd.(param));
            case {'sup_space' 'sup_freq' 'sup_ori'}
               paramvals(s,ismember(config.paraminfo.param_list,param))    = supdrive(s).(param);
               param_lo_bnd(s,ismember(config.paraminfo.param_list,param)) = min(supdrive(s).bnd.(param));
               param_hi_bnd(s,ismember(config.paraminfo.param_list,param)) = max(supdrive(s).bnd.(param));
               
               param_plaus_lo(s,ismember(config.paraminfo.param_list,param)) = min(supdrive(s).plaus_bnd.(param));
               param_plaus_hi(s,ismember(config.paraminfo.param_list,param)) = max(supdrive(s).plaus_bnd.(param));
         end
      end
   end

   %% collapse all parameters into a vector, then keep track of nan locations
   % collapse
   config.paramvals = paramvals(:);
   param_lo_bnd = param_lo_bnd(:);
   param_hi_bnd = param_hi_bnd(:);
   param_plaus_lo = param_plaus_lo(:);
   param_plaus_hi = param_plaus_hi(:);
   
   % remove fixed (i.e., nans)
   config.fixedidx = isnan(paramvals);
   config.paramvals(config.fixedidx) = [];
   param_lo_bnd(config.fixedidx) = [];
   param_hi_bnd(config.fixedidx) = [];
   param_plaus_lo(config.fixedidx) = [];
   param_plaus_hi(config.fixedidx) = [];
   config.bnds = [param_lo_bnd param_hi_bnd];
   config.plausbnds = [param_plaus_lo param_plaus_hi];

   %% scale parameters and bounds to range from 0-1, based on bounds
   % store unscaled values
   config.unscaled.paramvals = config.paramvals;
   config.unscaled.bnds = config.bnds;
   config.unscaled.plausbnds = config.plausbnds; 

   % scale parameter values 
   config.paramvals = (config.paramvals-config.bnds(:,1))./(config.bnds(:,2)-config.bnds(:,1));

   % scale plausible bounds
   for col = 1:size(config.plausbnds,2)
      config.plausbnds(:,col) = (config.plausbnds(:,col)-config.bnds(:,1))./(config.bnds(:,2)-config.bnds(:,1));
   end

   % scale hard bounds
   config.bnds = repmat([0 1],size(config.bnds,1),1);
else
   %% Un-format parameters
   % re-scale the parameters
   fittedparams = fittedparams.*(config.unscaled.bnds(:,2)-config.unscaled.bnds(:,1))+config.unscaled.bnds(:,1);
   config.paramvals = fittedparams;

   % un-format paramater values and recreate full matrix of parameters
   paramvals = nan(size(config.paramidx));
   paramvals = paramvals(:);
   paramvals(~config.fixedidx(:)) = fittedparams;
   paramvals = reshape(paramvals,size(config.paramidx));

   for s = 1:size(config.paramidx)
      for ii = 1:numel(config.paraminfo.param_list)
         switch config.paraminfo.param_list{ii}
            case {'cg_max' 'cg_slope' 'freq_max' 'freq_slope' 'bw_max'}
               if ~isnan(paramvals(s,ii))
                  stimdrive(s).(config.paraminfo.param_list{ii}) = paramvals(s,ii);
               else
                  stimdrive(s).(config.paraminfo.param_list{ii}) = paramvals(config.paramidx(s,ii),ii);
               end 
            case {'attn_freq_max' 'attn_freq_slope' 'attn_bw' 'attn_amp_max' 'attn_spread' ...
                  'attn_baseline' 'attn_sup_amp' 'attn_sup_spread'}
               if ~isnan(paramvals(s,ii))
                  attn(s).(config.paraminfo.param_list{ii}) = paramvals(s,ii);
               else
                  attn(s).(config.paraminfo.param_list{ii}) = paramvals(config.paramidx(s,ii),ii);
               end 
            case {'criterion'}
               if ~isnan(paramvals(s,ii))
                  observer(s).(config.paraminfo.param_list{ii}) = paramvals(s,ii);
               else
                  observer(s).(config.paraminfo.param_list{ii}) = paramvals(config.paramidx(s,ii),ii);
               end 
            case {'sup_space' 'sup_freq' 'sup_ori'}
               if ~isnan(paramvals(s,ii))
                  supdrive(s).(config.paraminfo.param_list{ii}) = paramvals(s,ii);
               else
                  supdrive(s).(config.paraminfo.param_list{ii}) = paramvals(config.paramidx(s,ii),ii);
               end 
         end
      end
   end
end

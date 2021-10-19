% Purpose:  Create a parameter configuration matrix specifying which parameters remain free or are fixed among subjects.
% By:       Michael Jigo

function config = create_configuration_matrix(data,varargin)

%% Paramter information
in = ...
   {'spatial_profile' ... % 'center', 'center_surround2DG', or 'neutral'
    'model_variant' ...   % 'main_model', 'minus_context', 'minus_sum'
   };        
val = ...
   {'center' ...
    'main_model' ...
   };
p = parseOptionalInputs(in,val,varargin);


%% Choose parameters based on desired spatial spread
switch p.spatial_profile
   case 'center'
      p.param_list = {'cg_max' 'cg_slope' 'freq_max' 'freq_slope' 'bw_max' 'attn_freq_max' 'attn_freq_slope' 'attn_bw' 'attn_amp_max' 'attn_spread' 'attn_baseline' 'criterion'};
      p.free_fixed = ones(1,numel(p.param_list)); % 1=fixed; 0=free

      % free up some parameters
         p.free_param_names = [];

         if ~isempty(p.free_param_names)
            p.free_fixed(ismember(p.param_list,p.free_param_names)) = 0;
         end

   case 'center_surround2DG'
      p.param_list = {'cg_max' 'cg_slope' 'freq_max' 'freq_slope' 'bw_max' 'attn_freq_max' 'attn_freq_slope' 'attn_bw' 'attn_amp_max' 'attn_spread' 'attn_baseline' 'criterion'};
      p.free_fixed = ones(1,numel(p.param_list)); % 1=fixed; 0=free

      % free up some parameters
         p.free_param_names = [];

         if ~isempty(p.free_param_names)
            p.free_fixed(ismember(p.param_list,p.free_param_names)) = 0;
         end

      
   case 'center_surround'
      p.param_list = {'cg_max' 'cg_slope' 'freq_max' 'freq_slope' 'bw_max' 'attn_freq_max' 'attn_freq_slope' 'attn_bw' 'attn_amp_max' 'attn_spread' 'attn_sup_amp' 'attn_sup_spread' 'criterion'};
      p.free_fixed = ones(1,numel(p.param_list)); % 1=fixed; 0=free

      % free up some parameters
         %p.free_param_names = {'cg_slope'};
         p.free_param_names = [];

         if ~isempty(p.free_param_names)
            p.free_fixed(ismember(p.param_list,p.free_param_names)) = 0;
         end

   case 'neutral'
      p.param_list = {'cg_max' 'cg_slope' 'freq_max' 'freq_slope' 'bw_max' 'criterion'};
      p.free_fixed = ones(1,numel(p.param_list)); % 1=fixed; 0=free

      % free up some parameters
         %p.free_param_names = {'cg_slope'};
         p.free_param_names = [];

         if ~isempty(p.free_param_names)
            p.free_fixed(ismember(p.param_list,p.free_param_names)) = 0;
         end
end


%% Generate configuration matrix
config.paramidx = []; numsubj = 0;
for s = 1:numel(data);
   numsubj = numsubj+1; 
   for param = 1:numel(p.param_list)
      if p.free_fixed(param)
         val = 1;
      else
         val = numsubj;
      end
      config.paramidx(numsubj,param) = val;
   end
end
config.paraminfo = p;

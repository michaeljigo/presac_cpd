% Purpose:  Generate predicted CPDs from assumed effects of presaccadic attention at the saccadic landing position.
%           Predictions will use fitted parameters to the Neutral (i.e., no saccade) condition as a foundation.
%           
%           Predictions will be made by the combination of the following factors:
%           1. Attention modulation type (NMA, response gain, contrast gain)
%           2. SF preference (higher-SF, lower-SF, uniform)
%
% By:       Michael Jigo
%           05.06.21

function display_valid_predictions(subj)
   tic

   % set simulation parameters
      % eccentricities
      eccvals = 0:1:10;
      

   % load subject parameters and create/decompose texture images
      % subject parameters
      paramfile = sprintf('../../data/bestfit_params/%s.mat',subj);
      params = load(paramfile);

      % subject texture info
      texdir = '../../data/dprime/';
      texfilename = sprintf('%s%s.mat',texdir,subj);
      subjdata = load(texfilename);
   
      % create texture images for each tested density
         % image parameters
         linesize = [0.1 0.4];
         pxperdeg = 32;%31.4426;
         imsize = [5 5];
         densities = subjdata.densityvals;

         % generate textures
         line_spacing_row = densities;
         line_spacing_col = densities;
         [target notarg texture_params] = create_texture(...
            'line_size',linesize,...
            'px_per_deg',pxperdeg,...
            'im_size',imsize,...
            'line_spacing_row',densities,...
            'line_spacing_col',densities,...
            'bkgrnd_color','gray');

      % decompose images
      [~,energy.targ] = imAmodel(target,'px_per_deg',pxperdeg,'im_size',imsize,'decompose_only',1,'preprocess_image',1);
      [~,energy.notarg] = imAmodel(notarg,'px_per_deg',pxperdeg,'im_size',imsize,'decompose_only',1,'preprocess_image',1);


   % generate neutral CPD
      % evaluate model
      targresp = imAmodel(target,'energy',energy.targ.energy,'use_attn',0,'stimdrive',params.stimdrive,'supdrive',params.supdrive,'ecc',eccvals);
      notargresp = imAmodel(notarg,'energy',energy.notarg.energy,'use_attn',0,'stimdrive',params.stimdrive,'supdrive',params.supdrive,'ecc',eccvals);

      % compute dprime
      dprime_nosac = sqrt(sum((targresp(:,:)-notargresp(:,:)).^2,2,'omitnan')); 
      scalar = repmat(mean(subjdata.dprime.targecc.perf)./mean(dprime_nosac),1,numel(eccvals));
      dprime_nosac = dprime_nosac.*scalar;

   
   % set attention prediction parameters
      % model factors
      modeltype = {'main_model' 'response_gain' 'contrast_gain'};
      sfpref = {'high' 'low' 'uniform'};
            
      % define attention parameters for SF preferences
         % shift in attentional preference
         deltapref = 0.5; % in octaves
         
         % SF bandwidth
         bw = 3; % in octaves

         % change in slope
         slopescalar = 1.5;

      % initialize attention parameters for imAmodel
      [~,~,attn] = init_parameters;
      fixedparams = {'attn_freq_slope' 
                     'attn_amp_max' 
                     'attn_spread'};
      fixedvals   = [params.stimdrive.freq_slope./slopescalar;
                     2
                     3];
      for p = 1:numel(fixedparams)
         attn.(fixedparams{p}) = fixedvals(p);
      end

      
   % create predictions for each combination of model factors
      for m = 1:numel(modeltype)
         switch modeltype{m}
            case {'response_gain' 'contrast_gain'}
               attn.attn_amp_max = attn.attn_amp_max./10;
         end
         
         for f = 1:numel(sfpref)
            % adjust SF preferences
            switch sfpref{f}
               case 'high'
                  attnSF = 2.^(log2(params.stimdrive.freq_max)+deltapref);
                  attn.attn_freq_max = attnSF;
                  attn.attn_bw = bw;
               case 'low'
                  attnSF = 2.^(log2(params.stimdrive.freq_max)-deltapref);
                  attn.attn_freq_max = attnSF;
                  attn.attn_bw = bw;
               case 'uniform'
                  attnSF = 2.^(log2(params.stimdrive.freq_max)-0);
                  attn.attn_freq_max = attnSF;
                  attn.attn_bw = 1e6;
               end


               % evaluate the model with specified parameters
               targresp = imAmodel(target,'energy',energy.targ.energy,'stimdrive',params.stimdrive,'supdrive',params.supdrive,'ecc',eccvals, ...
                                   'use_attn',1,'attn',attn,'model_variant',modeltype{m});
               notargresp = imAmodel(notarg,'energy',energy.notarg.energy,'stimdrive',params.stimdrive,'supdrive',params.supdrive,'ecc',eccvals, ...
                                   'use_attn',1,'attn',attn,'model_variant',modeltype{m});

               % compute dprime
               dprime_sac(:,m,f) = sqrt(sum((targresp(:,:)-notargresp(:,:)).^2,2,'omitnan')).*scalar'; 
         end
      end

   
      toc
   % plot the predictions (models on rows, sfpref on columns)
   ylim = [0 4]; ytick = 0:10;
   xlim = [0 10]; xtick = 0:2:10;
   figure('name',sprintf('%s predictions',subj),'position',[360 48 796 570]);
   for m = 1:numel(modeltype)
      for f = 1:numel(sfpref)
         subplot(numel(modeltype),numel(sfpref),(m-1)*numel(sfpref)+f);

         % no-saccade
         plot(eccvals,dprime_nosac,'k-','linewidth',3); hold on

         % saccade
         plot(eccvals,dprime_sac(:,m,f),'b-','linewidth',3); hold on

         
         % pretty it up
         set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'xlim',xlim,'xtick',xtick,'fontname','arial','fontsize',8,'ytick',ytick);

         % labels
            % model names on each row
            if f==1
               ylabel({modeltype{m};'d-prime'},'fontname','arial','fontsize',10,'interpreter','none');
            end

            % sf pref labels on each column
            if m==1
               title(sfpref{f},'fontname','arial','fontsize',10);
            end
            
            % xlabel on bottom-left plot
            if f==1 && m==numel(modeltype) 
               xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
            end
      end
   end
      
   
   % save the figure
   savedir = '../../figures/task3/valid_predictions/';
   if ~exist(savedir,'dir')
      mkdir(savedir)
   end
   filename = sprintf('%s%s.png',savedir,subj);
   saveas(gcf,filename);

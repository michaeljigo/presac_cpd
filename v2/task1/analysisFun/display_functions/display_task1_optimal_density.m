% Purpose:  Using the best-fitting parameters to behavioral performance in Task 1, extrapolate the optimal density (i.e., spacing) for each observer.
%           The optimal spacing can be flexibly chosen at any desired eccentricity.
%           Current eccentricity target = 7.5 deg
%
% By:       Michael Jigo
%           04.24.21

function display_task1_optimal_density(subj)

   % load subject's best-fitting parameters
      % load
      datadir = '../../data/bestfit_params/';
      filename = sprintf('%s%s.mat',datadir,subj);
      load(filename);

      % initialize parameter structure
         % initialize structures
         [stimdrive supdrive] = init_parameters;

         % re-scale parameters to original scale
         fitparams = fitparams.*(params.bnds(2,:)-params.bnds(1,:))+params.bnds(1,:);

         % restructure parameters
         for p = 1:numel(params.list)
            stimdrive.(params.list{p}) = fitparams(p);
         end

   
   % create finely-sampled texture densities
      % image parameters
      linesize = [0.1 0.4];
      pxperdeg = 32;%31.4426;
      imsize = [5 5];
      densityvals = linspace(min(subjdata.densityvals),max(subjdata.densityvals),30);

      % generate textures
      for d = 1:numel(densityvals)
         line_spacing_row = densityvals(d);
         line_spacing_col = densityvals(d);
         [target(:,:,d) notarg(:,:,d) texture_params] = create_texture(...
            'line_size',linesize,...
            'px_per_deg',pxperdeg,...
            'im_size',imsize,...
            'line_spacing_row',densityvals(d),...
            'line_spacing_col',densityvals(d),...
            'bkgrnd_color','gray');

      end

   
   
   % run textures through the image
      clear dprime
      for d = 1:numel(densityvals)
         targresp = imAmodel(target(:,:,d),'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',subjdata.eccvals,'preprocess_image',1);
         notargresp = imAmodel(notarg(:,:,d),'use_attn',0,'stimdrive',stimdrive,'supdrive',supdrive,'ecc',subjdata.eccvals,'preprocess_image',1);

         % compute d-prime
         dprime(d,:) = sqrt(sum((targresp(:,:)-notargresp(:,:)).^2,2,'omitnan')); 
      end
   
      % scale dprime
         dprime = dprime./mean(dprime(:)).*mean(subjdata.dprime.density_targecc.perf(:));

   
   % compute preferred density at each eccentricity
      % simply find the density associated with maximum performance at each eccentricity
      [maxdprime,prefidx] = max(dprime,[],1);
      densitypref = densityvals(prefidx);

   
   % display observed and model-derived density-tuning functions
      ylim = [0 3.5]; ytick = 0:4; 
      xlim = [0.25 1]; xtick = 0.25:0.25:1;
      ecclabels = cellfun(@num2str, num2cell(subjdata.eccvals),'uniformoutput',0); 
      figure('name',sprintf('%s | density x target eccentricity',subj),'position',[185 435 865 167]);
      for e = 1:numel(subjdata.eccvals)
         subplot(1,numel(subjdata.eccvals),e);

         % model-derived function
         plot(densityvals,dprime(:,e),'k-','linewidth',3); hold on
            % plot line for preferred density
            line([densitypref(e) densitypref(e)],[0 maxdprime(e)],'color',[0.5 0.5 0.5],'linewidth',1.5)

         % observed data
         plot(subjdata.densityvals,squeeze(subjdata.dprime.targecc_density.perf(e,:,:)),'ko','markersize',4); hold on

         % pretty up figure
         set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'xlim',xlim,'xtick',xtick,'fontname','arial','fontsize',8,'ytick',ytick);
         title(sprintf('ecc=%s; pref=%.2f',ecclabels{e},densitypref(e)),'fontname','arial','fontsize',7);
      
         if e==1
            xlabel('Spacing (deg btwn lines)','fontname','arial','fontsize',8);
            ylabel('Prop. correct','fontname','arial','fontsize',8);
         end
      end
      
      
      % save the figure
      savedir = '../../figures/task1/optimal_density/';
      if ~exist(savedir,'dir')
         mkdir(savedir)
      end
      filename = sprintf('%s%s.png',savedir,subj);
      saveas(gcf,filename);

% Purpose:  This function will call all requisite functions to fit imAmodel (IMage-computable Attention model)
%           to the behavioral data collected from task 3 for individual subjects.
%        
%           To simulate behavior in the detection task:
%              - two images will be passed to the model (one with a target patch, another without)
%              - four model parameters will be adjusted for individual subjects:
%                 1. cg_max
%                 2. cg_slope
%                 3. freq_max
%                 4. bw_max
%              - model discriminability between images will be matched to behavior using SSE
%
% By:       Michael Jigo
%           05.06.21

function model_task3(subj)

   % load subject data
   datadir = '../../data/dprime/';
   filename = sprintf('%s%s.mat',datadir,subj);
   subjdata = load(filename);

   
   % create texture images for each tested density
      % image parameters
      linesize = [0.1 0.4];
      pxperdeg = 32;%31.4426;
      imsize = [5 5];
      densities = subjdata.densityvals;

      % generate textures
      for d = 1:numel(densities)
         line_spacing_row = densities(d);
         line_spacing_col = densities(d);
         [target(:,:,d) notarg(:,:,d) texture_params] = create_texture(...
            'line_size',linesize,...
            'px_per_deg',pxperdeg,...
            'im_size',imsize,...
            'line_spacing_row',densities(d),...
            'line_spacing_col',densities(d),...
            'bkgrnd_color','gray');
      end

   
   % decompose images
      % pass through imAmodel to get image energy
      for d = 1:numel(densities)
         [~,energy(d).targ] = imAmodel(target(:,:,d),'px_per_deg',pxperdeg,'im_size',imsize,'decompose_only',1,'preprocess_image',1);
         [~,energy(d).notarg] = imAmodel(notarg(:,:,d),'px_per_deg',pxperdeg,'im_size',imsize,'decompose_only',1,'preprocess_image',1);
      end

   
   % initialize model parameters
      % set parameters which will be optimized
      params.list = {'cg_max' 'cg_slope' 'freq_max' 'freq_slope' 'bw_max'}; 

      % create random starting points for model
      [stimdrive supdrive] = init_parameters;

      % vectorize and scale the free parameters
         % collect the random starting points
         for p = 1:numel(params.list)
            params.free(p) = stimdrive.(params.list{p});
            params.bnds(:,p) = stimdrive.bnd.(params.list{p});
            params.plaus_bnds(:,p) = stimdrive.plaus_bnd.(params.list{p});
         end

         % scale parameters to range between 0-1
         params.scaled.free = (params.free-params.bnds(1,:))./(params.bnds(2,:)-params.bnds(1,:));
         params.scaled.bnds = [zeros(1,numel(params.list)); ones(1,numel(params.list))];
         params.scaled.plaus_bnds(1,:) = (params.plaus_bnds(1,:)-params.bnds(1,:))./(params.bnds(2,:)-params.bnds(1,:));
         params.scaled.plaus_bnds(2,:) = (params.plaus_bnds(2,:)-params.bnds(1,:))./(params.bnds(2,:)-params.bnds(1,:));

   
   % optimize using BADS
      % set optimization options
      options = bads('defaults');
      options.MaxIter = 10;

      % run optimization
      objective = @(freeparams)model_task3_objective(stimdrive,supdrive,subjdata,energy,params,freeparams);
      [fitparams fiterr] = bads(objective,params.scaled.free,params.scaled.bnds(1,:),params.scaled.bnds(2,:),params.scaled.plaus_bnds(1,:),params.scaled.plaus_bnds(2,:),[],options); % BADS

   
   
   % evaluate best-fitting parameters
      % finely-sample eccentricity
      finesample = subjdata;
      finesample.eccvals = linspace(min(finesample.eccvals),max(finesample.eccvals),16);

      % evaluate model
      [~,dprime] = model_task3_objective(stimdrive,supdrive,finesample,energy,params,fitparams,0);



   % save parameters and best-fit
      % re-scale parameters
      freeparams = fitparams.*(params.bnds(2,:)-params.bnds(1,:))+params.bnds(1,:);

      % restructure parameters
      for p = 1:numel(params.list)
         stimdrive.(params.list{p}) = freeparams(p);
      end

      % generate save directory
      savedir = '../../data/bestfit_params/';
      if ~exist(savedir)
         mkdir(savedir)
      end
      filename = sprintf('%s%s.mat',savedir,subj);

      % save
      save(filename,'fitparams','fiterr','params','dprime','subjdata','stimdrive','supdrive');



   % plot best-fitting dprime along with observer data
      % plotting parameters
      ylim = [-1 3]; ytick = -4:4;
      xlim = [0 10]; xtick = 0:2:10;
      densitylabels = cellfun(@num2str, num2cell(subjdata.densityvals),'uniformoutput',0);
  
      % actual plotting
      figure('name',sprintf('%s | target eccentricity',subj),'position',[109 290 238 326]);
      for d = 1:numel(subjdata.densityvals)
         subplot(1,numel(subjdata.densityvals),d);

         % line at 0
         line(xlim,[0 0],'color',[0.5 0.5 0.5],'linewidth',1.5);
         
         % observer data
         plot(subjdata.eccvals,subjdata.dprime.targecc.perf(d,:),'k.','markersize',20); hold on

         % model-data
         plot(finesample.eccvals,dprime(d,:),'k-','linewidth',3); hold on

         set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'xlim',xlim,'fontname','arial','fontsize',8,'ytick',ytick);
         title(sprintf('d=%s',densitylabels{d}),'fontname','arial','fontsize',7);
      
         if d==1
            xlabel('Eccentricity (deg)','fontname','arial','fontsize',8);
            ylabel('d^{\prime}','fontname','arial','fontsize',10);
         end
      end

      % save the figure
      savedir = '../../figures/task3/model_fit/';
      if ~exist(savedir,'dir')
         mkdir(savedir)
      end
      filename = sprintf('%s%s.png',savedir,subj);
      saveas(gcf,filename);

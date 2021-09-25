% Purpose:  Analyze behavioral performance for task 1.
% By:       Michael Jigo
%
%
%% Notes

function display_task1_performance(subj)
   % matrix columns
   % 1   block number
   % 2   bandwidth                  (orientation bandwidth)
   % 3   density                    (texture density)
   % 4   background orientation     (-45 or 45)
   % 5   patch orientation          (-45 or 45)
   % 6   cue ecc                    (0)
   % 7   cue absolute ecc           (0)
   % 8   target ecc                 (+-)
   % 9   target absolute ecc        (+)
   % 10  response cue ecc           (+-)
   % 11  response cue absolute ecc  (+)
   % 12  response                   (0=absent; 1=present)
   % 13  accuracy                   (0=incorrect; 1=correct)
      idx_block      = 1;
      idx_targecc    = 9;
      idx_respcue    = 11;
      idx_resp       = 12;
      idx_density    = 3;
      idx_bw         = 2;

      
   
   % load subject files
   if ischar(subj), subj={subj}; end
   for s = 1:numel(subj)
      subjdata = sprintf('../data/raw/%s_Task1_resMat.mat',subj{s});
      load(subjdata);
      data = resMat;

      % remove some blocks from analysis
         %data(data(:,idx_block)<=3,:) = [];

      % create trial labels for target presence (0=absent; 1=present)
         tmp_presence = data(:,idx_targecc);
         tmp_presence(~isnan(tmp_presence)) = 1;
         tmp_presence(isnan(tmp_presence)) = 0;
      
      
      % get actual values for eccentricity 
         eccvals     = unique(data(:,idx_respcue));
         ecclabels   = cellfun(@num2str, num2cell(eccvals),'uniformoutput',0);
      

      % create condition labels
         % response-cued location
            respcue.val = data(:,idx_respcue); 
            respcue.label = cellfun(@num2str,num2cell(unique(respcue.val)),'UniformOutput',0);  
         
         % target presence (0=absent; 1=present)
            presence.val = tmp_presence;
            presence.label = {'absent' 'present'};

         % create trial labels for target response (0=left, 1=right hemifield)
            trialresp = data(:,idx_resp);

     
      % use condParser to compute behavioral metrics
         % overall
            dprime(s).overall          = condParser(trialresp,presence);
            dprime(s).overall          = diff(norminv(dprime(s).overall.perf),[],2);


         % eccentricity 
            dprime(s).subj             = subj{s};
            dprime(s).targecc          = condParser(trialresp,presence,respcue); 
            criterion(s).targecc       = dprime(s).targecc;
            criterion(s).targecc.perf  = -0.5*(sum(norminv(dprime(s).targecc.perf),1));
            dprime(s).targecc          = hautas_adjustment(dprime(s).targecc); % adjust for extreme probabilities


         % density
            density.val                = data(:,idx_density);
            density.label              = cellfun(@num2str,num2cell(unique(density.val)),'un',0);
            dprime(s).density          = condParser(trialresp,presence,density);
            dprime(s).density          = hautas_adjustment(dprime(s).density);


         % density x eccentricity
            dprime(s).density_ecc      = condParser(trialresp,presence,density,respcue);
            dprime(s).density_ecc      = hautas_adjustment(dprime(s).density_ecc);


         % bandwidth
            bw.val                     = data(:,idx_bw);
            bw.label                   = cellfun(@num2str,num2cell(unique(bw.val)),'un',0);
            dprime(s).bw               = condParser(trialresp,presence,bw);
            dprime(s).bw               = hautas_adjustment(dprime(s).bw);

         
      % save subject performance
         savedir = '../../data/dprime/';
         if ~exist(savedir,'dir')
            mkdir(savedir)
         end
         filename = sprintf('%s%s.mat',savedir,subj{s});
         save(filename,'dprime','criterion');
   end

   % draw rough plots of the main effects
   ylim           = [-1 3];
   ytick          = -10:1:10;
   xlim           = [-1 11];
   xtick          = 0:2:11;
   sizePerTrial   = 7;
   colors         = linspecer(numel(dprime),'qualitative');
      % figure 1. eccentricity
         figure('name','eccentricity','position',[109 395 232 221]);
         for s = 1:numel(dprime)
            line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on
            legendlines(s) = plot(eccvals,dprime(s).targecc.perf,'-','linewidth',2,'color',colors(s,:)); hold on
            % plot individual data points at corresponding size
               for e = 1:numel(eccvals)
                  plot(eccvals(e),dprime(s).targecc.perf(e),'o','markersize',sizePerTrial*(dprime(s).targecc.numtrials(e)./max(dprime(s).targecc.numtrials)),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
               end
            figureDefaults;
            set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
            xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
            ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
            if s==numel(dprime)
               legend(legendlines,subj,'location','southeast');
            end
         end

         % save figure
            figdir = '../figures/behavior/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%seccentricity.png',figdir);
            saveas(gcf,filename);
      
      
      % figure 2. criterion
         figure('name','criterion','position',[109 395 232 221]);
         for s = 1:numel(dprime)
            ylim = [-2 2];
            ytick = -10:1:10;
            line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on
            legendlines(s) = plot(eccvals,criterion(s).targecc.perf,'-','linewidth',2,'color',colors(s,:));
            % plot individual data points at corresponding size
               for e = 1:numel(eccvals)
                  plot(eccvals(e),criterion(s).targecc.perf(e),'o','markersize',sizePerTrial*(dprime(s).targecc.numtrials(e)./max(dprime(s).targecc.numtrials)),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
               end
            figureDefaults
            set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
            xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
            ylabel('criterion','fontname','arial','fontsize',10);
            if s==numel(dprime)
               legend(legendlines,subj,'location','southeast');
            end
         end
         % save figure
            figdir = '../figures/behavior/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%scriterion.png',figdir);
            saveas(gcf,filename);


      % figure 3. bandwidth
         xlim  = [80 120];
         xtick = 0:10:200;
         ylim  = [0 3];
         ytick = 0:5;

         figure('name','bandwidth','position',[109 395 232 221]);
         for s = 1:numel(dprime)
            bwvals = dprime(s).bw.factorVals.factor2;
            line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on
            legendlines(s) = plot(bwvals,dprime(s).bw.perf,'-','linewidth',2,'color',colors(s,:));
            % plot individual data points at corresponding size
               for b = 1:numel(bwvals)
                  plot(bwvals(b),dprime(s).bw.perf(b),'o','markersize',sizePerTrial*(dprime(s).bw.numtrials(b)./max(dprime(s).bw.numtrials)) ,'markerFaceColor',colors(s,:),'markerEdgeColor','w');
               end
            figureDefaults
            set(gca,'xlim',xlim,'ylim',ylim,'xtick',xtick,'ytick',ytick);
            xlabel('Bandwidth (^o)','fontname','arial','fontsize',10);
            ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
            if s==numel(dprime)
               legend(legendlines,subj,'location','southeast');
            end
         end
         % save figure
            figdir = '../figures/behavior/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%sbw.png',figdir);
            saveas(gcf,filename);
      

      % figure 4. density x eccentricity (ecc subplots)
         densityvals = unique(density.val);
         xlim  = [0 1];
         xtick = 0:0.2:1;
         ylim  = [-0.5 5];
         ytick = 0:8;
         figure('name','density_eccentricity','position',[109 403 742 213]);
         for e = 1:numel(eccvals)
            subplot(1,numel(eccvals),e);
            for s = 1:numel(dprime)
               legendlines(s) = plot(densityvals,dprime(s).density_ecc.perf(:,e),'-','linewidth',2,'color',colors(s,:)); hold on
               % plot individual data points at corresponding size
                  for d = 1:numel(densityvals)
                     plot(densityvals(d),dprime(s).density_ecc.perf(d,e),'o','markersize',sizePerTrial*(dprime(s).density_ecc.numtrials(d,e)./max(dprime(s).density_ecc.numtrials(:,e))),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
                  end
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               if s==1 && e==1
                  xlabel('Density (line-to-line distance)','fontname','arial','fontsize',10);
                  ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
               end

               if s==numel(dprime) && e==1
                  legend(legendlines,subj,'location','northwest');
               end
            end
            title(sprintf('%i deg',eccvals(e)),'fontname','arial','fontsize',10);
         end

         % save figure
            figdir = '../figures/behavior/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%sdensity_ecc.png',figdir);
            saveas(gcf,filename);



      % figure 5. eccentricity x density (density subplots)
         densityvals = unique(density.val);
         xlim  = [0 10];
         xtick = 0:2:10;
         ylim  = [-0.5 5];
         ytick = 0:8;
         figure('name','density_eccentricity','position',[113 1408 1650 200]);
         for d = 1:numel(densityvals)
            subplot(1,numel(densityvals),d);
            for s = 1:numel(dprime)
               legendlines(s) = plot(eccvals,dprime(s).density_ecc.perf(d,:),'-','linewidth',2,'color',colors(s,:)); hold on
               % plot individual data points at corresponding size
                  for e = 1:numel(eccvals)
                     plot(eccvals(e),dprime(s).density_ecc.perf(d,e),'o','markersize',sizePerTrial*(dprime(s).density_ecc.numtrials(d,e)./max(dprime(s).density_ecc.numtrials(d,:))),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
                  end
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               if s==1 && d==1
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
               end

               if s==numel(dprime) && d==1
                  legend(legendlines,subj,'location','northwest');
               end
            end
            title(sprintf('density = %.2f',densityvals(d)),'fontname','arial','fontsize',10);
         end

         % save figure
            figdir = '../figures/behavior/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%secc_density.png',figdir);
            saveas(gcf,filename);

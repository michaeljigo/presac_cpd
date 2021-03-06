% Purpose:  Create plote showing fixation vs valid saccade  performance from task 5.
% By:       Michael Jigo

function create_fix_valid_plot(data,subj)

   %% Get subject data
      dprime      = data.dprime.fix_valid;
      criterion   = data.criterion.fix_valid;


   %% Check if model fit has to be displayed
      dispFit = 0;
      if ~isempty(model.dprime)
         dispFit = 1;

         % average across all saccade targets for this plot
            model.dprime = squeeze(mean(model.dprime,2));
      end


   %% Plotting
      % visualization parameters
         ylim           = [-0.5 3];
         ytick          = -10:1:10;
         xlim           = [-1 13];
         xtick          = 0:4:20;
         sizePerTrial   = 7;
         colors         = [0 0 0; 202 0 32; 5 113 176]./255; 
         linewidth      = 2;

      % create figures
         figure('name','Fixation vs Valid','position',[1 1 782 427]);
         subplot(1,2,1);

         % Sensitivity
            for s = 1:size(dprime.perf,1)
               % draw horizontal line at 0
                  line(xlim,[0 0],'linewidth',1.5,'color',colors(1,:)); hold on
   
               % plot discriminability
                  leg(s) = plot(data.ecc,squeeze(dprime.perf(s,:)),'-','linewidth',linewidth,'color',colors(s,:)); hold on
                  % plot individual data points at corresponding size
                     for e = 1:numel(data.ecc)
                        if isnan(dprime.numtrials(s,e)) || dprime.numtrials(s,e)<=0
                           continue
                        end
                        plot(data.ecc(e),dprime.perf(s,e),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(s,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
                     end
   
               % pretty up figure
                  figureDefaults;
                  set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
                  title(sprintf('Discriminability'),'fontname','arial','fontsize',10);
            end
            legend(leg,{'fixation' 'invalid' 'valid'},'fontname','arial','fontsize',8,'linewidth',0.0001,'location','southwest');


         % Criterion
            ylim           = [-2 2];
            ytick          = -10:1:10;
            subplot(1,2,2);
            for s = 1:size(criterion.perf,1)
               % draw horizontal line at 0
                  line(xlim,[0 0],'linewidth',1.5,'color',colors(1,:)); hold on
   
               % plot discriminability
                  plot(data.ecc,squeeze(criterion.perf(s,:)),'-','linewidth',linewidth,'color',colors(s,:)); hold on
                  % plot individual data points at corresponding size
                     for e = 1:numel(data.ecc)
                        if isnan(dprime.numtrials(s,e)) || dprime.numtrials(s,e)<=0
                           continue
                        end
                        plot(data.ecc(e),criterion.perf(s,e),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(s,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
                     end
   
               % pretty up figure
                  figureDefaults;
                  set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Criterion','fontname','arial','fontsize',10);
                  title(sprintf('Criterion'),'fontname','arial','fontsize',10);
            end
            % save figure
               figdir = sprintf('../figures/behavior/task5/%s/',subj);
               if ~exist(figdir,'dir')
                  mkdir(figdir)
               end
               filename = sprintf('%sfixation_vs_valid.png',figdir);
               saveas(gcf,filename);

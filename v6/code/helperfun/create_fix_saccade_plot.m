% Purpose:  Create plote showing fixation vs saccade performance from task 5.
% By:       Michael Jigo

function create_fix_saccade_plot(data,model,subj)

   %% Get subject data
      dprime      = data.dprime.fix_saccade;
      criterion   = data.criterion.fix_saccade;


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
         sizePerTrial   = 12;
         colors         = [0 0 0; brewermap(numel(data.saccadeTarg)+4,'*Blues')]; 
         linewidth      = 2;
         txtPosY        = [0.5 0.2];

      % create figures
         figure('name','Fixation vs Saccade','position',[1 1 1597 373]);
         subplot(1,3,1);

         % Sensitivity
            for s = 1:size(dprime.perf,1)
               % draw horizontal line at 0
                  line(xlim,[0 0],'linewidth',1.5,'color',colors(1,:)); hold on
   
               % plot discriminability
                  if dispFit
                     leg(s) = plot(model.ecc,squeeze(model.dprime(s,:)),'-','linewidth',linewidth,'color',colors(s,:)); hold on
   
                     % add in line at peak eccentricity
                        [peakD,peakEcc]   = max(model.dprime(s,:));
                        peakEcc           = model.ecc(peakEcc); 
                        line([peakEcc peakEcc],[0 peakD],'linewidth',linewidth/2,'color',colors(s,:));
   
                     % add text specifying the peak eccentricity
                        txt = text(peakEcc,txtPosY(s),sprintf('%s^o',num2str(peakEcc)));
                        txt.FontSize            = 8; 
                        txt.FontWeight          = 'bold';
                        txt.Color               = colors(s,:);
                        txt.FontName            = 'arial';
                        txt.BackgroundColor     = [1 1 1 0.8];
                        txt.HorizontalAlignment = 'center';
                  else
                     leg(s) = plot(data.ecc,squeeze(dprime.perf(s,:)),'-','linewidth',linewidth,'color',colors(s,:)); hold on
                  end

               % plot individual data points at corresponding size
                  for e = 1:numel(data.ecc)
                     plot(data.ecc(e),dprime.perf(s,e),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(s,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
                  end
   
               % pretty up figure
                  figureDefaults;
                  set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
                  title(sprintf('Discriminability'),'fontname','arial','fontsize',10);
            end
            legend(leg,{'fixation' 'saccade'},'fontname','arial','fontsize',8,'linewidth',0.0001,'location','southwest');



         % Saccadic effect
            ylim  = [-1 1];
            ytick = -1:0.5:1;

            subplot(1,3,2);
            % draw horizontal line at 0
               line(xlim,[0 0],'linewidth',1.5,'color',colors(1,:)); hold on
   
            % plot effect
               if dispFit
                  leg(s) = plot(model.ecc,squeeze(diff(model.dprime,[],1)),'-','linewidth',linewidth,'color',colors(2,:)); hold on
               else
                  leg(s) = plot(data.ecc,squeeze(diff(dprime.perf,[],1)),'-','linewidth',linewidth,'color',colors(2,:)); hold on
               end

            % plot individual data points at corresponding size
               for e = 1:numel(data.ecc)
                  plot(data.ecc(e),diff(dprime.perf(:,e),[],1),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(1,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
               end
   
            % pretty up figure
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
               ylabel('Saccadic effect (\Deltad^{\prime})','fontname','arial','fontsize',10);
               title(sprintf('Saccadic effect'),'fontname','arial','fontsize',10);



         % Criterion
            ylim           = [-2 2];
            ytick          = -10:1:10;
            subplot(1,3,3);
            for s = 1:size(criterion.perf,1)
               % draw horizontal line at 0
                  line(xlim,[0 0],'linewidth',1.5,'color',colors(1,:)); hold on
   
               % plot discriminability
                  plot(data.ecc,squeeze(criterion.perf(s,:)),'-','linewidth',linewidth,'color',colors(s,:)); hold on
                  % plot individual data points at corresponding size
                     for e = 1:numel(data.ecc)
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
               if dispFit
                  figdir = sprintf('../figures/model/task5/%s/%s/%s/',model.model_variant,model.spatial_profile,subj);
               else
                  figdir = sprintf('../figures/behavior/task5/no_fit/%s/',subj);
               end
               if ~exist(figdir,'dir')
                  mkdir(figdir)
               end
               filename = sprintf('%sfixation_vs_saccade.png',figdir);
               saveas(gcf,filename);

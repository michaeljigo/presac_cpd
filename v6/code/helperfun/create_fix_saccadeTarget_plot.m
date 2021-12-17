% Purpose:  Create plote showing fixation vs saccade target performance from task 5.
% By:       Michael Jigo

function create_fix_saccadeTarget_plot(data,subj)

   %% Get subject data
      dprime      = data.dprime.fix_sacTarg;
      criterion   = data.criterion.fix_sacTarg;


   %% Plotting
      % visualization parameters
         ylim           = [-0.5 3.5];
         ytick          = -10:1:10;
         xlim           = [-1 13];
         xtick          = 0:4:20;
         sizePerTrial   = 7;
         colors         = [0 0 0; 202 0 32; 5 113 176]./255; 
         linewidth      = 2;
         subplotIdx     = [1 2 3 4];

      % create figures
         figure('name','Fixation vs Saccade Target','position',[1 1 1597 746]);

         % Sensitivity
         for t = 1:numel(data.saccadeTarg)
            subplot(2,numel(data.saccadeTarg),subplotIdx(t));

            for c = 1:size(dprime.perf,1)
               % draw horizontal line at 0
                  line(xlim,[0 0],'linewidth',1.5,'color',colors(1,:)); hold on

               % add in FIXATION discriminability after averaging across all saccade target locations
                  %if c==1
                     %plot(data.ecc,data.dprime.fix_saccade.perf(1,:),'-','linewidth',4,'color',[colors(c,:) 0.2]); hold on
                  %end

               % plot discriminability
                  leg(c) = plot(data.ecc,squeeze(dprime.perf(c,t,:)),'-','linewidth',linewidth,'color',colors(c,:));

                  % plot individual data points at corresponding size
                     for e = 1:numel(data.ecc)
                        if isnan(dprime.numtrials(c,t,e)) || dprime.numtrials(c,t,e)<=0
                           continue
                        end
                        if c==2 && data.ecc(e)==data.saccadeTarg(t)
                           plot(data.ecc(e),dprime.perf(c,t,e),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(c,t,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(3,:),'markerEdgeColor','w'); % Valid cueing
                        else
                           plot(data.ecc(e),dprime.perf(c,t,e),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(c,t,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w'); % Invalid cueing
                        end
                     end
            end
            % pretty up figure
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               title(sprintf('saccade=%.1f',data.saccadeTarg(t)),'fontname','arial','fontsize',10);
               if t==1
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
                  legend(leg,{'fixation' 'saccade'},'fontname','arial','fontsize',8,'linewidth',0.0001,'location','northeast');
               end
         end


         % Criterion
            ylim           = [-2 2];
            ytick          = -10:1:10;
            subplotIdx     = [5 6 7 8];

         for t = 1:numel(data.saccadeTarg)
            subplot(2,numel(data.saccadeTarg),subplotIdx(t));

            for c = 1:size(criterion.perf,1)
               % draw horizontal line at 0
                  line(xlim,[0 0],'linewidth',1.5,'color',colors(1,:)); hold on
   
               % plot criterion
                  leg(c) = plot(data.ecc,squeeze(criterion.perf(c,t,:)),'-','linewidth',linewidth,'color',colors(c,:)); hold on

                  % plot individual data points at corresponding size
                     for e = 1:numel(data.ecc)
                        if isnan(dprime.numtrials(c,t,e)) || dprime.numtrials(c,t,e)<=0
                           continue
                        end
                        if c==2 && data.ecc(e)==data.saccadeTarg(t)
                           plot(data.ecc(e),criterion.perf(c,t,e),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(c,t,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(3,:),'markerEdgeColor','w'); % Valid cueing
                        else
                           plot(data.ecc(e),criterion.perf(c,t,e),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(c,t,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w'); % Invalid cueing
                        end
                     end
            end
            % pretty up figure
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               if t==1
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Criterion','fontname','arial','fontsize',10);
                  legend(leg,{'fixation' 'saccade'},'fontname','arial','fontsize',8,'linewidth',0.0001,'location','northeast');
               end
         end

         % save figure
            figdir = sprintf('../figures/behavior/task5/%s/',subj);
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%sfixation_vs_saccadeTarget.png',figdir);
            saveas(gcf,filename);

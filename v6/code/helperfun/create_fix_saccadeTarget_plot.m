% Purpose:  Create plote showing fixation vs saccade target performance from task 5.
% By:       Michael Jigo

function create_fix_saccadeTarget_plot(data,model,subj)

   %% Get subject data
      dprime      = data.dprime.fix_sacTarg;
      criterion   = data.criterion.fix_sacTarg;

   %% Check if model fit has to be displayed
      dispFit = 0;
      if ~isempty(model.dprime)
         dispFit = 1;
      end


   %% Plotting
      % visualization parameters
         ylim           = [-0.5 3.5];
         ytick          = -10:1:10;
         xlim           = [-1 13];
         xtick          = 0:4:20;
         sizePerTrial   = 12;
         colors         = [0 0 0; 202 0 32; 5 113 176]./255; 
         linewidth      = 2;
         subplotIdx     = [1 2 3 4];
         txtPosY        = [0.5 0.2];

      % create figures
         figure('name','Fixation vs Saccade Target','position',[1 1 1597 746]);

         % Sensitivity
         for t = 1:numel(data.saccadeTarg)
            subplot(2,numel(data.saccadeTarg),subplotIdx(t));

            for c = 1:size(dprime.perf,1)
               % draw horizontal line at 0
                  line(xlim,[0 0],'linewidth',1.5,'color',colors(1,:)); hold on

               % plot discriminability
                  if dispFit
                     leg(c) = plot(model.ecc,squeeze(model.dprime(c,t,:)),'-','linewidth',linewidth,'color',colors(c,:)); hold on
   
                     % add in line at peak eccentricity
                        [peakD,peakEcc]   = max(model.dprime(c,t,:));
                        peakEcc           = model.ecc(peakEcc); 
                        line([peakEcc peakEcc],[0 peakD],'linewidth',linewidth/2,'color',colors(c,:));
   
                     % add text specifying the peak eccentricity
                        txt = text(peakEcc,txtPosY(c),sprintf('%s^o',num2str(peakEcc)));
                        txt.FontSize            = 8; 
                        txt.FontWeight          = 'bold';
                        txt.Color               = colors(c,:);
                        txt.FontName            = 'arial';
                        txt.BackgroundColor     = [1 1 1 0.8];
                        txt.HorizontalAlignment = 'center';
                  else
                     leg(c) = plot(data.ecc,squeeze(dprime.perf(c,t,:)),'-','linewidth',linewidth,'color',colors(c,:));
                  end

               % plot individual data points at corresponding size
                   for e = 1:numel(data.ecc)
                     if isnan(dprime.numtrials(c,t,e)) || dprime.numtrials(c,t,e)<=0
                        continue
                     end
                     if c==2 && data.ecc(e)==data.saccadeTarg(t)
                        leg(3) = plot(data.ecc(e),dprime.perf(c,t,e),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(c,t,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(3,:),'markerEdgeColor','w'); % Valid cueing
                     else
                        plot(data.ecc(e),dprime.perf(c,t,e),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(c,t,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w'); % Invalid cueing
                     end
                  end
            end
            % pretty up figure
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               title(sprintf('saccade=%.1f^o',data.saccadeTarg(t)),'fontname','arial','fontsize',10);
               if t==1
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
                  legend(leg,{'fixation' 'saccade' 'valid'},'fontname','arial','fontsize',6,'linewidth',0.0001,'location','northeast');
               end
         end


         % Saccadic effect
         ylim           = [-2 2];
         ytick          = -10:1:10;
         subplotIdx     = [5 6 7 8];
         linewidth      = 3;

         for t = 1:numel(data.saccadeTarg)
            subplot(2,numel(data.saccadeTarg),subplotIdx(t));

            % draw horizontal line at 0
               line(xlim,[0 0],'linewidth',1.5,'color',colors(1,:)); hold on

            % plot discriminability
               if dispFit
                  leg(c) = plot(model.ecc,squeeze(diff(model.dprime(:,t,:),[],1)),'-','linewidth',linewidth,'color',colors(2,:)); hold on
               else
                  leg(c) = plot(data.ecc,squeeze(diff(dprime.perf(:,t,:),[],1)),'-','linewidth',linewidth,'color',colors(2,:));
               end

            % plot individual data points at corresponding size
                  for e = 1:numel(data.ecc)
                     if any(isnan(dprime.numtrials(:,t,e))) || squeeze(nansum(dprime.numtrials(:,t,e),1))<=0
                        continue
                     end
                     if data.ecc(e)==data.saccadeTarg(t)
                        plot(data.ecc(e),diff(dprime.perf(:,t,e),[],1),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(1,t,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(3,:),'markerEdgeColor','w'); % Valid cueing
                     else
                        plot(data.ecc(e),diff(dprime.perf(:,t,e),[],1),'o','markersize',sizePerTrial*(squeeze(dprime.numtrials(1,t,e))./max(dprime.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w'); % Invalid cueing
                     end
               end

            % pretty up figure
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               title(sprintf('effect=%.1f^o',data.saccadeTarg(t)),'fontname','arial','fontsize',10);
               if t==1
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Saccadic effect (\Deltad^{\prime})','fontname','arial','fontsize',10);
               end
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
            filename = sprintf('%sfixation_vs_saccadeTarget.png',figdir);
            saveas(gcf,filename);



         % Criterion
            figure('name','Fixation vs Saccade Target','position',[1 1 1597 373]);
            ylim           = [-2 2];
            ytick          = -10:1:10;
            subplotIdx     = [1 2 3 4];

         for t = 1:numel(data.saccadeTarg)
            subplot(1,numel(data.saccadeTarg),subplotIdx(t));

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
               title(sprintf('saccade=%.1f^o',data.saccadeTarg(t)),'fontname','arial','fontsize',10);
               if t==1
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Criterion','fontname','arial','fontsize',10);
                  legend(leg,{'fixation' 'saccade'},'fontname','arial','fontsize',8,'linewidth',0.0001,'location','northeast');
               end
         end
         % save figure
            figdir = sprintf('../figures/behavior/task5/no_fit/%s/',subj);
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%scriterion.png',figdir);
            saveas(gcf,filename);

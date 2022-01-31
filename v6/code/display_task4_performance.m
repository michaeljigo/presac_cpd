% Purpose:  Analyze behavioral performance for task 4 for version 6, but only analyze Fixation trials to assess for peak shifts.
% By:       Michael Jigo
%
% Only analyzes a single subject at a time, unlike Task1.
%

function display_task4_performance(subj)
   
   %% Load subject's behavior
      data        = load_subj_data(subj,'task4');
      dprime      = data.dprime;
      criterion   = data.criterion;

   %% Check if subject's data have been fit, if yes plot it
      fitFile     = sprintf('../data/fitted_parameters/task4/%s.mat',subj);
      if exist(fitFile,'file')
         load(fitFile);
         model.dprime= out.fineModel;
         model.ecc   = out.data.fineEcc;
         dispFit     = 1;
      else
         dispFit     = 0;
      end


   %% Plot
      % Performance (each size in separate subplots)
         ylim           = [-0.5 3];
         ytick          = -10:1:10;
         xlim           = [-1 14];
         xtick          = 0:4:20;
         sizePerTrial   = 7;
         colors         = [0 0 0; 0 0 0];
         linewidth      = 2;

         figure('name','Sensitivity','position',[1 1 651 310]);
         for s = 1:size(dprime.perf,1)
            subplot(1,size(dprime.perf,1),s)

            % draw horizontal line at 0
               line(xlim,[0 0],'linewidth',1.5,'color',colors(s,:)); hold on

            % plot Neutral condition only
               if dispFit
                  plot(model.ecc,model.dprime(s,:),'-','linewidth',linewidth,'color',colors(s,:)); hold on

                  % add in line at peak eccentricity
                     [peakD,peakEcc]   = max(model.dprime(s,:));
                     peakEcc           = model.ecc(peakEcc); 
                     line([peakEcc peakEcc],[0 peakD],'linewidth',linewidth/2,'color',colors(s,:));

                  % add text specifying the peak eccentricity
                     txt = text(peakEcc,0.5,sprintf('%s^o',num2str(peakEcc)));
                     txt.FontSize            = 8; 
                     txt.FontWeight          = 'bold';
                     txt.Color               = colors(s,:);
                     txt.FontName            = 'arial';
                     txt.BackgroundColor     = 'w';
                     txt.HorizontalAlignment = 'center';
               else
                  plot(data.ecc,squeeze(dprime.perf(s,:)),'-','linewidth',linewidth,'color',colors(s,:)); hold on
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
               title(sprintf('size = %i',data.size(s)),'fontname','arial','fontsize',10);
         end
         % save figure
            figdir = sprintf('../figures/behavior/task4/%s/',subj);
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%sdprime.png',figdir);
            saveas(gcf,filename);





      % Criterion (each size in separate subplots)
         ylim           = [-2 2];
         ytick          = -10:1:10;
         xlim           = [-1 14];
         xtick          = 0:3:20;
         sizePerTrial   = 7;
         colors         = [0 0 0; 0 0 0];
         linewidth      = 2;

         figure('name','Criterion','position',[1 1 421 214]);
         for s = 1:size(criterion.perf,1)
            subplot(1,size(criterion.perf,1),s)

            % draw horizontal line at 0
               line(xlim,[0 0],'linewidth',1.5,'color',colors(s,:)); hold on

            % plot Neutral condition only
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
               title(sprintf('size = %i',data.size(s)),'fontname','arial','fontsize',10);
         end
         % save figure
            figdir = sprintf('../figures/behavior/task4/%s/',subj);
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%scriterion.png',figdir);
            saveas(gcf,filename);

% Purpose:  Display fits to individual observer data.
% By:       Michael Jigo

function display_model_fits(subj)

   %% Load fitted parameters and associated data
      dataDir = sprintf('../data/fitted_parameters/task1/%s.mat',subj);
      load(dataDir);

   %% Display each size in the same plot
      colors = [5 113 176; 202 0 32]./255;
      figure('name','Size fits','position',[680 1308 413 390]);
      for s = 1:numel(out.data.size)
         % display fit
            leg(s) = plot(out.data.fineEcc,out.fineModel(s,:),'-','linewidth',3,'color',colors(s,:)); hold on
         % display observed data
            plot(out.data.ecc,out.data.dprime.size_ecc.perf(s,:),'o','markersize',7,'color','w');
            plot(out.data.ecc,out.data.dprime.size_ecc.perf(s,:),'o','markersize',6,'markerFaceColor',colors(s,:),'markerEdgeColor','none');
      end
      % pretty up figure
         figureDefaults
         xlim  = [-1 14];
         xtick = 0:2:20;
         ylim  = [0 4.5];
         ytick = -10:1:10;
         set(gca,'xlim',xlim,'ylim',ylim,'xtick',xtick,'ytick',ytick);
         xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
         ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
         legend(leg,cellfun(@(x) ['size = ',num2str(x)],num2cell(out.data.size),'un',0));
         title(sprintf('%s',subj),'fontname','arial','fontsize',10);

   %% Save figure
      saveDir = '../figures/model/';
      if ~exist(saveDir,'dir')
         mkdir(saveDir);
      end
      saveas(gcf,[saveDir,subj,'.png']);

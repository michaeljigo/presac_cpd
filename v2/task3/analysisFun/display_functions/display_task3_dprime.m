% Purpose:  Analyze behavioral performance for task 3.
% By:       Michael Jigo
%           05.04.21
%
%
%% Notes

function display_task3_performance(subj)
   % matrix columns
   % 1   block number
   % 2   bandwidth                  (orientation bandwidth)
   % 3   density                    (fixed)
   % 4   background orientation     (fixed)
   % 5   patch orientation          (fixed)
   % 6   cue ecc                    (neutral only)
   % 7   cue absolute ecc           (neutral only)
   % 8   target ecc                 (present=-10:2.5:10; absent=NaN)
   % 9   target absolute ecc        (present=0:2.5:10; absent=NaN)
   % 10  response cue ecc           (-10:2.5:10)
   % 11  response cue absolute ecc  (0:2.5:10)
   % 12  response                   (0=absent; 1=present)
   % 13  accuracy                   (0=incorrect; 1=correct)
      idx_targecc    = 9;
      idx_respcue    = 11;
      idx_resp       = 12;
      idx_density    = 3;

      
   
   % load subject files
   if ischar(subj), subj={subj}; end
   for s = 1:numel(subj)
      subjdata = sprintf('../../data/raw/%s_Task3_resMat.mat',subj{s});
      load(subjdata);
      data = resMat;

      % save density value for subject
         densityvals = unique(data(:,idx_density));


      % create trial labels for target presence (0=absent; 1=present)
         tmp_presence = data(:,idx_targecc);
         tmp_presence(~isnan(tmp_presence)) = 1;
         tmp_presence(isnan(tmp_presence)) = 0;
      
      
      % get actual values for eccentricity 
         eccvals = unique(data(:,idx_respcue));
         ecclabels = cellfun(@num2str, num2cell(eccvals),'uniformoutput',0);
      


      % create condition labels
         % response-cued location
            respcue.val = data(:,idx_respcue); 
            respcue.label = cellfun(@num2str,num2cell(unique(respcue.val)),'UniformOutput',0);  
         
         % target presence (0=absent; 1=present)
            presence.val = tmp_presence;
            presence.label = {'absent' 'present'};

         % create trial labels for target response (0=left, 1=right hemifield)
            trialresp = data(:,idx_resp);

     
      % compute d-prime (using condParser)
         % parse discriminability across eccentricity
            dprime.targecc = condParser(trialresp,presence,respcue); 

            % compute criterion
            criterion.targecc = dprime.targecc;
            criterion.targecc.perf = -0.5*(sum(norminv(dprime.targecc.perf),1));

            % adjust dprime for extreme values
            dprime.targecc = hautas_adjustment(dprime.targecc); 

         
      % concatenate across subjects
         perf.targecc(:,s) = dprime.targecc.perf;
         crit.targecc(:,s) = criterion.targecc.perf;
   
     
      % save subject performance
         savedir = '../../data/dprime/';
         if ~exist(savedir,'dir')
            mkdir(savedir)
         end
         filename = sprintf('%s%s.mat',savedir,subj{s});
         save(filename,'dprime','eccvals','densityvals');
   end

   % rename structure that holds performance
   fields = {'targecc'};
   for f = 1:numel(fields)
      dprime.(fields{f}).perf = perf.(fields{f});
      criterion.(fields{f}).perf = crit.(fields{f});
   end


   % draw rough plots of the main effects
   ylim = [-1 3];
   ytick = -10:1:10;
   xlim = [-1 11];
   xtick = 0:2:11;
      % figure 1. sensitivity
      figure('name',sprintf('[ %s ] sensitivity',subj{:}),'position',[109 290 238 326]);
      line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on
      legendlines = plot(eccvals,dprime.targecc.perf,'.-','linewidth',2,'markersize',20);
      set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
      xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
      ylabel('d^{\prime}','fontname','arial','fontsize',10);
      if s>1
         legend(legendlines,subj,'location','northwest');
      end

      % save figure
      figdir = '../../figures/';
      if ~exist(figdir,'dir')
         mkdir(figdir)
      end
      subjstr = sprintf('%s_',subj{:});
      filename = sprintf('%s%scpd.png',figdir,subjstr);
      saveas(gcf,filename);
      
      
      % figure 2. criterion
      ylim = [-2 2];
      ytick = -10:0.5:10;
      figure('name',sprintf('[ %s ] criterion',subj{:}),'position',[109 290 238 326]);
      line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on
      legendlines = plot(eccvals,criterion.targecc.perf,'.-','linewidth',2,'markersize',20);
      set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
      xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
      ylabel('criterion','fontname','arial','fontsize',10);
      if s>1
         legend(legendlines,subj,'location','southwest');
      end

      % save figure
      figdir = '../../figures/';
      if ~exist(figdir,'dir')
         mkdir(figdir)
      end
      subjstr = sprintf('%s_',subj{:});
      filename = sprintf('%s%scriterion.png',figdir,subjstr);
      saveas(gcf,filename);

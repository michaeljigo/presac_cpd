% Purpose:  Analyze behavioral performance for task 3.
% By:       Michael Jigo
%           05.04.21
%
%
%% Notes
   %% USE MODEL TO FIND DENSITY AT FOVEA USING DATA AND PARAMETERS IN TASK 1

function dprime = display_task4_dprime(subj)
   % matrix columns
   % 1   block number
   % 2   bandwidth                     (orientation bandwidth)
   % 3   density                       (fixed)
   % 4   background orientation        (fixed)
   % 5   patch orientation             (fixed)
   % 6   cue ecc                       (-10:2.5:10)
   % 7   cue absolute ecc              (0:2.5:10)
   % 8   target ecc                    (present=-10:2.5:10; absent=NaN)
   % 9   target absolute ecc           (present=0:2.5:10; absent=NaN)
   % 10  response cue ecc              (-10:2.5:10)
   % 11  response cue absolute ecc     (0:2.5:10)
   % 12  response                      (0=absent; 1=present)
   % 13  accuracy                      (0=incorrect; 1=correct)
   % 14  closest saccade pos           (-10:2.5:10)
   % 15  closest saccade abs pos       (0:2.5:10)
   % 16  sacc distance from respcue 
   % 17  sacc landing from precue      (0=outside 2 deg; 1=inside)
   % 18  abs sacc landing from precue  (0=outside 2 deg; 1=inside)
   % 19  sacc landing from precue      (x deg)
      idx_targecc    = 9;
      idx_respcue    = 11;
      idx_resp       = 12;
      idx_density    = 3;
      idx_cue        = 7;
      idx_sac        = 15;
      idx_distsac    = 19;

      
      sacthresh      = 1.75; % maximum allowable distance from landing position from precue
   
   % load subject files
   if ischar(subj), subj={subj}; end
   for s = 1:numel(subj)
      subjdata = sprintf('../../data/raw/%s_Task4_resMat.mat',subj{s});
      load(subjdata);
      data = resMat;

      % save density value for subject
         densityvals = unique(data(:,idx_density));


      % create trial labels for target presence (0=absent; 1=present)
         tmp_presence = data(:,idx_targecc);
         tmp_presence(~isnan(tmp_presence)) = 1;
         tmp_presence(isnan(tmp_presence)) = 0;

      % create trial labels for valid, invalid and neutral
         validity = nan(size(data,1),1);
         validity(data(:,idx_cue)==data(:,idx_respcue)) = 1; % valid
         validity(data(:,idx_cue)~=data(:,idx_respcue)) = -1; % invalid
         validity(data(:,idx_cue)==0) = 0; % neutral

      
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

         % cue location
            cue.val = data(:,idx_cue);
            cue.label = cellfun(@num2str,num2cell(unique(cue.val)),'UniformOutput',0);  

         % saccade landing position
            sacland.val = data(:,idx_sac);
            sacland.label = cellfun(@num2str,num2cell(unique(sacland.val)),'UniformOutput',0);  

         % validity
            cueval.val = validity;
            cueval.label = {'invalid' 'neutral' 'valid'};
         
         % create trial labels for target response (0=left, 1=right hemifield)
            trialresp = data(:,idx_resp);
     
      
      % compute d-prime (using condParser)
         % validity
            dprime.validity = condParser(trialresp,presence,cueval,respcue); dprime.validity = hautas_adjustment(dprime.validity);

         % cue location
            dprime.cue = condParser(trialresp,presence,cue,respcue); dprime.cue = hautas_adjustment(dprime.cue);
         
         % saccade landing position
            dprime.sac = condParser(trialresp,presence,sacland,respcue); dprime.sac = hautas_adjustment(dprime.sac);
         
         % cue, but only close saccades
            trialresp_close = trialresp;
            trialresp_close(data(:,idx_distsac)>sacthresh & validity~=0) = nan;  trialresp_close(isnan(data(:,idx_distsac)) & validity~=0) = nan;
            dprime.cue_closesac = condParser(trialresp_close,presence,cue,respcue); dprime.cue_closesac = hautas_adjustment(dprime.cue_closesac);

         % eccentricity
            dprime.ecc = condParser(trialresp_close,presence,cue); dprime.ecc = hautas_adjustment(dprime.ecc);

         
      % concatenate across subjects
         fields = {'cue' 'sac' 'cue_closesac' 'validity'};
         for f = 1:numel(fields)
            perf.(fields{f})(:,:,s) = dprime.(fields{f}).perf;
         end
   
     
      % save subject performance
         savedir = '../../data/dprime/';
         if ~exist(savedir,'dir')
            mkdir(savedir)
         end
         filename = sprintf('%s%s.mat',savedir,subj{s});
         save(filename,'dprime','eccvals','densityvals');
   end

   % rename structure that holds performance
   for f = 1:numel(fields)
      dprime.(fields{f}).perf = perf.(fields{f});
   end


   % draw rough plots of the main effects
   ylim = [-1 3];
   ytick = -10:1:10;
   xlim = [-1 11];
   xtick = 0:2.5:10;
      % figure 1. validity
      figure('name','validity','position',[109 290 238 326]);
      line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on
      cuecolors = [208 28 139; 0 0 0; 77 172 38]./255;
      for c = 1:size(dprime.validity.perf,1)
         leg(c) = plot(eccvals,dprime.validity.perf(c,:),'.-','linewidth',2,'markersize',20,'color',cuecolors(c,:));
      end
      set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
      xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
      ylabel('d^{\prime}','fontname','arial','fontsize',10);
      legend(leg,cueval.label,'location','southeast');

      % save figure
      figdir = '../../figures/';
      if ~exist(figdir,'dir')
         mkdir(figdir)
      end
      subjstr = sprintf('%s_',subj{:});
      filename = sprintf('%s%svalidity.png',figdir,subjstr);
      saveas(gcf,filename);
      
      
      % figure 2. split by cued location
      figure('name','precued location','position',[109 423 1011 193]);
      line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on

      for c = 1:size(dprime.cue.perf,1)
         subplot(1,size(dprime.cue.perf,1),c);
         
         % draw line at 0
         line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on

         % always include neutral (i.e., cue at 0)
         plot(eccvals,dprime.cue.perf(1,:),'k.-','linewidth',2,'markersize',20);

         % then draw the current cue position
         plot(eccvals,dprime.cue.perf(c,:),'.-','linewidth',2,'markersize',20);

         % pretty it up
         set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
         xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
         ylabel('d^{\prime}','fontname','arial','fontsize',10);
         title(cue.label{c},'fontname','arial','fontsize',10);
      end

      % save figure
      figdir = '../../figures/';
      if ~exist(figdir,'dir')
         mkdir(figdir)
      end
      subjstr = sprintf('%s_',subj{:});
      filename = sprintf('%s%sprecue.png',figdir,subjstr);
      saveas(gcf,filename);
      
      
      
      % figure 3. split by saccade landing location
      figure('name','saccade landing location','position',[109 423 1011 193]);
      line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on

      for c = 1:size(dprime.sac.perf,1)
         subplot(1,size(dprime.sac.perf,1),c);
         
         % draw line at 0
         line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on

         % always include neutral (i.e., cue at 0)
         plot(eccvals,dprime.sac.perf(1,:),'k.-','linewidth',2,'markersize',20);

         % then draw the current cue position
         plot(eccvals,dprime.sac.perf(c,:),'.-','linewidth',2,'markersize',20);

         % pretty it up
         set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
         xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
         ylabel('d^{\prime}','fontname','arial','fontsize',10);
         title(sacland.label{c},'fontname','arial','fontsize',10);
      end

      % save figure
      figdir = '../../figures/';
      if ~exist(figdir,'dir')
         mkdir(figdir)
      end
      subjstr = sprintf('%s_',subj{:});
      filename = sprintf('%s%ssaccade_landing.png',figdir,subjstr);
      saveas(gcf,filename);
      
      
      % figure 4. split by saccade landing location
      figure('name','CLOSE saccade landing location','position',[109 423 1011 193]);
      line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on

      for c = 1:size(dprime.cue_closesac.perf,1)
         subplot(1,size(dprime.cue_closesac.perf,1),c);
         
         % draw line at 0
         line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on

         % always include neutral (i.e., cue at 0)
         plot(eccvals,dprime.cue_closesac.perf(1,:),'k.-','linewidth',2,'markersize',20);

         % then draw the current cue position
         plot(eccvals,dprime.cue_closesac.perf(c,:),'.-','linewidth',2,'markersize',20);

         % pretty it up
         set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
         xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
         ylabel('d^{\prime}','fontname','arial','fontsize',10);
         title(sacland.label{c},'fontname','arial','fontsize',10);
      end

      % save figure
      figdir = '../../figures/';
      if ~exist(figdir,'dir')
         mkdir(figdir)
      end
      subjstr = sprintf('%s_',subj{:});
      filename = sprintf('%s%sclose_saccade_landing.png',figdir,subjstr);
      saveas(gcf,filename);

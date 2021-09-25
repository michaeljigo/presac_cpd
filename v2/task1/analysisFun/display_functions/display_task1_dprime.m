% Purpose:  Analyze behavioral performance for task 1.
% By:       Michael Jigo
%           04.10.21
%
%
%% Notes

function display_task1_performance(subj)
   % matrix columns
   % 1   block number
   % 2   block bandwidth            (orientation bandwidth)
   % 3   cue eccentricity           (always 0)
   % 4   target eccentricity        (-10:2.5:10)
   % 5   density                    (0.3:0.1:0.9)
   % 6   L/R response               (1=left, 2=right)
   % 7   Correct-incorrect response (1=correct, 0=incorrect)
      idx_targecc = 4;
      idx_density = 5;
      idx_resp    = 6;

      
      
   
   % load subject files
   if ischar(subj), subj={subj}; end
   for s = 1:numel(subj)
      subjdata = sprintf('../../data/raw/%s_Task1_resMat2.mat',subj{s});
      load(subjdata);
      data = resMat2;
   
      % get actual values for eccentricity and density
      eccvals = unique(abs(data(:,idx_targecc)));
      densityvals = unique(data(:,idx_density));
      ecclabels = cellfun(@num2str, num2cell(eccvals),'uniformoutput',0);
      densitylabels = cellfun(@num2str, num2cell(densityvals),'uniformoutput',0);
      

   
      % create condition labels
         targecc.val = abs(data(:,idx_targecc)); 
         targecc.label = cellfun(@num2str,num2cell(unique(targecc.val)),'UniformOutput',0);  
         
         density.val = data(:,idx_density);  
         density.label = cellfun(@num2str,num2cell(unique(data(:,idx_density))),'UniformOutput',0);  
      
         % create trial labels for target location (0=left, 1=right hemifield) 
         targloc.val = data(:,idx_targecc);
         targloc.val(data(:,idx_targecc)<0) = 0; targloc.val(data(:,idx_targecc)>0) = 1;
         targloc.label = {'left hemi' 'right hemi'};

         % create trial labels for target response (0=left, 1=right hemifield)
         trialresp = data(:,idx_resp);
         trialresp(data(:,idx_resp)==1) = 0;
         trialresp(data(:,idx_resp)==2) = 1;

      % compute d-prime (using condParser)
         % parse main effects: targecc + density
         dprime.targecc = condParser(trialresp,targloc,targecc); dprime.targecc = hautas_adjustment(dprime.targecc);
         dprime.density = condParser(trialresp,targloc,density); dprime.density = hautas_adjustment(dprime.density);
         keyboard
         
         % parse interaction: targecc:density
         dprime.targecc_density = condParser(trialresp,targloc,targecc,density); dprime.targecc_density = hautas_adjustment(dprime.targecc_density);
         dprime.density_targecc = condParser(trialresp,targloc,density,targecc); dprime.density_targecc = hautas_adjustment(dprime.density_targecc);

      % concatenate across subjects
         perf.targecc(:,s) = dprime.targecc.perf;
         perf.density(:,s) = dprime.density.perf;
         perf.targecc_density(:,:,s) = squeeze(dprime.targecc_density.perf);
         perf.density_targecc(:,:,s) = squeeze(dprime.density_targecc.perf);
   
         % save subject performance
         savedir = '../../data/dprime/';
         filename = sprintf('%s%s.mat',savedir,subj{s});
         save(filename,'dprime','densityvals','eccvals');
   end

   % rename structure that holds performance
   fields = {'targecc' 'density' 'targecc_density' 'density_targecc'};
   for f = 1:numel(fields)
      dprime.(fields{f}).perf = perf.(fields{f});
   end



  

   % draw rough plots of the main effects
   ylim = [0 4];
   ytick = 0:1:4;
      % figure 1. target eccentricity
      figure('name',sprintf('[ %s ] target eccentricity',subj{:}),'position',[109 290 238 326]);
      plot(eccvals,dprime.targecc.perf,'.-','linewidth',2,'markersize',20);
      set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'fontname','arial','fontsize',8);
      title('CPD','fontname','arial','fontsize',8);
      xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
      ylabel('d^{\prime}','fontname','arial','fontsize',10);
      if s>1
         legend(subj);
      end

      % figure 2. density
      figure('name',sprintf('%s | density',subj{:}),'position',[109 290 238 326]);
      plot(densityvals,dprime.density.perf,'.-','linewidth',2,'markersize',20);
      set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'fontname','arial','fontsize',8);
      title('Density tuning','fontname','arial','fontsize',8);
      xlabel('Density (deg/row)','fontname','arial','fontsize',10);
      ylabel('d^{\prime}','fontname','arial','fontsize',10);
      if s>1
         legend(subj);
      end
      
      % figure 3. density x target eccentricity
         % density are separate lines across eccentricity
         figure('name',sprintf('%s | density x target eccentricity',subj{:}),'position',[-6 413 1284 173]);
         for d = 1:numel(densityvals)
            subplot(1,numel(densityvals),d);
            plot(eccvals,squeeze(dprime.density_targecc.perf(d,:,:)),'.-','linewidth',2,'markersize',20); hold on
            line([2.25 10.25],[0.5 0.5],'color','k','linewidth',1.5);
            set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'xlim',[2.25 10.25],'fontname','arial','fontsize',8,'ytick',ytick);
            title(sprintf('d=%s',densitylabels{d}),'fontname','arial','fontsize',7);
         
            if d==1
               xlabel('Eccentricity (deg)','fontname','arial','fontsize',8);
               ylabel('d^{\prime}','fontname','arial','fontsize',10);
               
               if s>1
                  legend(subj);
               end
            end
         end
         
         
         % eccentricity are separate lines across density
         figure('name',sprintf('%s | density x target eccentricity',subj{:}),'position',[-6 413 1284 173]);
         for e = 1:numel(eccvals)
            subplot(1,numel(eccvals),e);
            plot(densityvals,squeeze(dprime.targecc_density.perf(e,:,:)),'.-','linewidth',2,'markersize',20); hold on
            line([0 1.25],[0.5 0.5],'color','k','linewidth',1.5);
            set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',ylim,'xlim',[0 1.25],'fontname','arial','fontsize',8,'ytick',ytick);
            title(sprintf('ecc=%s',ecclabels{e}),'fontname','arial','fontsize',7);
         
            if e==1
               xlabel('Spacing (deg btwn lines)','fontname','arial','fontsize',8);
               ylabel('Prop. correct','fontname','arial','fontsize',8);

               if s>1
                  legend(subj);
               end
            end
         end

% Purpose:  Analyze behavioral performance for task 1.
% By:       Michael Jigo
%           04.10.21
%
%
%% Notes

function display_task1_performance(subj)
   % matrix columns
   % 1   block number
   % 2   cue eccentricity (always 0)
   % 3   target eccentricity (2.5:2.5:10)
   % 4   density (0.25:0.15:1.15)
   % 5   response (1=correct, 0=false)
      idx_targecc = 3;
      idx_density = 4;
      idx_resp    = 5;
      
   
   % load subject files
   if ischar(subj), subj={subj}; end
   for s = 1:numel(subj)
      subjdata = sprintf('../../data/raw/%s_Task1_resMat.mat',subj{s});
      load(subjdata);
      data = resMat;
      
      % get actual values for eccentricity and density
      eccvals = unique(abs(data(:,idx_targecc)));
      densityvals = unique(data(:,idx_density));
      ecclabels = cellfun(@num2str, num2cell(eccvals),'uniformoutput',0);
      densitylabels = cellfun(@num2str, num2cell(densityvals),'uniformoutput',0);
   
      % compute proportion correct (using condParser)
         % create condition labels
         targecc.val = data(:,idx_targecc);  
         targecc.label = cellfun(@num2str,num2cell(unique(data(:,idx_targecc))),'UniformOutput',0);  
         
         density.val = data(:,idx_density);  
         density.label = cellfun(@num2str,num2cell(unique(data(:,idx_density))),'UniformOutput',0);  
   
         % parse main effects: targecc + density
         pcorr.targecc = condParser(data(:,idx_resp),targecc); perf.targecc(:,s) = pcorr.targecc.perf;
         pcorr.density = condParser(data(:,idx_resp),density); perf.density(:,s) = pcorr.density.perf;
   
         % parse interaction: targecc:density
         pcorr.targecc_density = condParser(data(:,idx_resp),targecc,density);   perf.targecc_density(:,:,s) = pcorr.targecc_density.perf;
         pcorr.density_targecc = condParser(data(:,idx_resp),density,targecc);   perf.density_targecc(:,:,s) = pcorr.density_targecc.perf;
         

         % do simple conversion to d-prime
         fields = {'targecc' 'density' 'targecc_density' 'density_targecc'};
         for f = 1:numel(fields)
           dprime.(fields{f}) = pcorr.(fields{f}); 
           dprime.(fields{f}).perf(dprime.(fields{f}).perf==1) = 0.99;
           dprime.(fields{f}).perf = norminv(dprime.(fields{f}).perf)*sqrt(2);
         end

         % save subject performance
         savedir = '../../data/dprime/';
         filename = sprintf('%s%s.mat',savedir,subj{s});
         save(filename,'dprime','densityvals','eccvals');
   end

   % extract useful fields only
   fields = {'targecc' 'density' 'targecc_density' 'density_targecc'};
   for f = 1:numel(fields)
      pcorr.(fields{f}).perf = perf.(fields{f});
   end
  

   % draw rough plots of the main effects
      % figure 1. target eccentricity
      figure('name',sprintf('[ %s ] target eccentricity',subj{:}),'position',[109 290 238 326]);
      plot(unique(data(:,idx_targecc)),pcorr.targecc.perf,'.-','linewidth',2,'markersize',20);
      set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',[0.5 1],'fontname','arial','fontsize',8);
      title('CPD','fontname','arial','fontsize',8);
      xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
      ylabel('Proportion correct','fontname','arial','fontsize',10);
      if s>1
         legend(subj);
      end

      % figure 2. density
      figure('name',sprintf('%s | density',subj{:}),'position',[109 290 238 326]);
      plot(unique(data(:,idx_density)),pcorr.density.perf,'.-','linewidth',2,'markersize',20);
      set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',[0.5 1],'fontname','arial','fontsize',8);
      title('Density tuning','fontname','arial','fontsize',8);
      xlabel('Density (deg/row)','fontname','arial','fontsize',10);
      ylabel('Proportion correct','fontname','arial','fontsize',10);
      if s>1
         legend(subj);
      end
      
      % figure 3. density x target eccentricity
         % density are separate lines across eccentricity
         figure('name',sprintf('%s | density x target eccentricity',subj{:}),'position',[-6 413 1284 173]);
         for d = 1:numel(pcorr.density.condLabel)
            subplot(1,numel(pcorr.density.condLabel),d);
            plot(unique(data(:,idx_targecc)),squeeze(pcorr.density_targecc.perf(d,:,:)),'.-','linewidth',2,'markersize',20); hold on
            line([2.25 10.25],[0.5 0.5],'color','k','linewidth',1.5);
            set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',[0.45 1.05],'xlim',[2.25 10.25],'fontname','arial','fontsize',8,'ytick',0.5:0.25:1);
            title(sprintf('d=%s',pcorr.density.condLabel{d}),'fontname','arial','fontsize',7);
         
            if d==1
               xlabel('Eccentricity (deg)','fontname','arial','fontsize',8);
               ylabel('Prop. correct','fontname','arial','fontsize',8);
               
               if s>1
                  legend(subj);
               end
            end
         end
         
         
         % eccentricity are separate lines across density
         figure('name',sprintf('%s | density x target eccentricity',subj{:}),'position',[-6 413 1284 173]);
         for e = 1:numel(pcorr.targecc.condLabel)
            subplot(1,numel(pcorr.targecc.condLabel),e);
            plot(unique(data(:,idx_density)),squeeze(pcorr.targecc_density.perf(e,:,:)),'.-','linewidth',2,'markersize',20); hold on
            line([0 1.25],[0.5 0.5],'color','k','linewidth',1.5);
            set(gca,'box','off','tickdir','out','linewidth',1.5,'plotboxaspectratio',[1 1 1],'ylim',[0.45 1.05],'xlim',[0 1.25],'fontname','arial','fontsize',8,'ytick',0.5:0.25:1);
            title(sprintf('ecc=%s',pcorr.targecc.condLabel{e}),'fontname','arial','fontsize',7);
         
            if e==1
               xlabel('Spacing (deg btwn lines)','fontname','arial','fontsize',8);
               ylabel('Prop. correct','fontname','arial','fontsize',8);

               if s>1
                  legend(subj);
               end
            end
         end

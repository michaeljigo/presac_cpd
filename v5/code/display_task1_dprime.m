% Purpose:  Analyze behavioral performance for task 1 for version 5.
% By:       Michael Jigo
%
%
%% Notes

function display_task1_dprime(subj)
   % matrix columns
   % 1   block number
   % 2   bandwidth                  (orientation bandwidth)
   % 3   size                       (target patch size)
   % 4   background orientation     (-45 or 45)
   % 5   patch orientation          (-45 or 45)
   % 6   cue ecc                    (0)
   % 7   cue absolute ecc           (0)
   % 8   target ecc                 (+-)
   % 9   target absolute ecc        (+)
   % 10  response cue ecc           (+-)
   % 11  response cue absolute ecc  (+)
   % 12  response                   (0=absent; 1=present)
   % 13  accuracy                   (0=incorrect; 1=correct)
      idx_block      = 1;
      idx_targecc    = 9;
      idx_respcue    = 11;
      idx_resp       = 12;
      idx_size       = 3;
      idx_bw         = 2;

      
   
   %% Load subject files
   if ischar(subj), subj={subj}; end
   for s = 1:numel(subj)
      subjdata = sprintf('../data/raw/%s_Task1_resMat.mat',subj{s});
      load(subjdata);
      data = resMat;

      % remove some blocks from analysis
         data(data(:,idx_block)<=1,:) = [];

      % create trial labels for target presence (0=absent; 1=present)
         tmp_presence = data(:,idx_targecc);
         tmp_presence(~isnan(tmp_presence)) = 1;
         tmp_presence(isnan(tmp_presence)) = 0;
      
      
      % get actual values for eccentricity 
         eccvals     = round(unique(data(:,idx_respcue))*1e2)./1e2;
         ecclabels   = cellfun(@num2str, num2cell(eccvals),'uniformoutput',0);
      


      %% Create condition labels
         % response-cued location
            respcue.val    = data(:,idx_respcue); 
            respcue.label  = cellfun(@num2str,num2cell(unique(respcue.val)),'UniformOutput',0);  
         
         % target presence (0=absent; 1=present)
            presence.val   = tmp_presence;
            presence.label = {'absent' 'present'};

         % create trial labels for target response (0=left, 1=right hemifield)
            trialresp      = data(:,idx_resp);

         % size
            sz.val                        = data(:,idx_size);
            sz.label                      = cellfun(@num2str,num2cell(unique(sz.val)),'un',0);

     

      %% Use condParser to compute behavioral metrics
         % overall
            allDPrime(s).overall          = condParser(trialresp,presence);
            allCrit(s).overall            = -0.5*(sum(norminv(allDPrime(s).overall.perf)));
            allDPrime(s).overall          = diff(norminv(allDPrime(s).overall.perf),[],2);


         % eccentricity 
            allDPrime(s).subj             = subj{s};
            allDPrime(s).targecc          = condParser(trialresp,presence,respcue); 
            % criterion
               allCrit(s).targecc         = allDPrime(s).targecc;
               allCrit(s).targecc.perf    = -0.5*(sum(norminv(allDPrime(s).targecc.perf),1));
            % adjusted dprime
               allDPrime(s).targecc       = hautas_adjustment(allDPrime(s).targecc); % adjust for extreme probabilities

         % size
            allDPrime(s).size             = condParser(trialresp,presence,sz);
            allDPrime(s).size             = hautas_adjustment(allDPrime(s).size);

         % size x eccentricity
            allDPrime(s).size_ecc         = condParser(trialresp,presence,sz,respcue);
            % criterion
               allCrit(s).size_ecc        = allDPrime(s).size_ecc;
               allCrit(s).size_ecc.perf   = squeeze(-0.5*(sum(norminv(allDPrime(s).size_ecc.perf),1)));
            % adjusted dprime
               allDPrime(s).size_ecc      = hautas_adjustment(allDPrime(s).size_ecc);


         % bandwidth
            bw.val                        = data(:,idx_bw);
            bw.label                      = cellfun(@num2str,num2cell(unique(bw.val)),'un',0);
            allDPrime(s).bw               = condParser(trialresp,presence,bw);
            allDPrime(s).bw               = hautas_adjustment(allDPrime(s).bw);

         % bandwidth x size
            allDPrime(s).bw_size          = condParser(trialresp,presence,bw,sz);
            allDPrime(s).bw_size          = hautas_adjustment(allDPrime(s).bw_size);

         % bandwidth x ecc
            allDPrime(s).bw_ecc           = condParser(trialresp,presence,bw,respcue); 
            allDPrime(s).bw_ecc           = hautas_adjustment(allDPrime(s).bw_ecc);

         % bandwidth x ecc x size
            allDPrime(s).bw_ecc_size      = condParser(trialresp,presence,bw,respcue,sz); 
            allDPrime(s).bw_ecc_size      = hautas_adjustment(allDPrime(s).bw_ecc_size);


         
      % save subject performance
         dprime      = allDPrime(s);
         criterion   = allCrit(s);
         savedir = '../data/dprime/';
         if ~exist(savedir,'dir')
            mkdir(savedir)
         end
         filename = sprintf('%s%s.mat',savedir,subj{s});
         save(filename,'dprime','criterion');
   end

   %% Average across subjects, if multiple were entered
      % leave observers concatenated
         dprime    = allDPrime;
         criterion = allCrit;

      % add in group-average of dprime
         if numel(subj)>1
            dprimeFields = fieldnames(dprime(1));
            dprimeFields = setdiff(dprimeFields,{'subj'});
            for f = 1:numel(dprimeFields)
               if strcmp(dprimeFields{f},'overall')
                  dprime(numel(subj)+1).(dprimeFields{f})            = nanmean(arrayfun(@(x) reshape(x.(dprimeFields{f}),[1 size(x.(dprimeFields{f}))]),allDPrime,'un',1));  
               else
                  dprime(numel(subj)+1).(dprimeFields{f}).perf       = squeeze(nanmean(squeeze(cell2mat(arrayfun(@(x) reshape(x.(dprimeFields{f}).perf,[1 1 size(x.(dprimeFields{f}).perf)]),allDPrime,'un',0))),1));  
                  dprime(numel(subj)+1).(dprimeFields{f}).numtrials  = squeeze(nanmean(squeeze(cell2mat(arrayfun(@(x) reshape(x.(dprimeFields{f}).numtrials,[1 1 size(x.(dprimeFields{f}).numtrials)]),allDPrime,'un',0))),1));  
               end
            end
         end

      % add in group-average of criterion
         if numel(subj)>1
            critFields = fieldnames(criterion(1));
            critFields = setdiff(critFields,{'subj'});
            for f = 1:numel(critFields)
               if strcmp(critFields{f},'overall')
                  criterion(numel(subj)+1).(critFields{f})           = nanmean(arrayfun(@(x) reshape(x.(critFields{f}),[1 size(x.(critFields{f}))]),allCrit,'un',1));  
               else
                  criterion(numel(subj)+1).(critFields{f}).perf      = squeeze(nanmean(squeeze(cell2mat(arrayfun(@(x) reshape(x.(critFields{f}).perf,[1 1 size(x.(critFields{f}).perf)]),allCrit,'un',0))),1));  
               end
            end
            subj{numel(subj)+1} = 'average';
         end



   %% Plot
      ylim           = [0 4];
      ytick          = -10:1:10;
      xlim           = [-1 14];
      xtick          = 0:2:20;
      sizePerTrial   = 7;
      colors         = linspecer(numel(dprime),'qualitative'); 
      linewidth      = repmat(2,1,numel(subj));
      alphas         = ones(1,numel(subj));
      if numel(subj)>1
         colors(end,:)  = [0 0 0];
         alphas(end)    = 0.5;
         linewidth(end) = 4;
      end
      % figure 1. eccentricity
         figure('name','eccentricity','position',[109 395 232 221]);
         for s = 1:numel(dprime)
            line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on
            legendlines(s) = plot(eccvals,dprime(s).targecc.perf,'-','linewidth',linewidth(s),'color',[colors(s,:) alphas(s)]); hold on
            % plot individual data points at corresponding size
               if ~strcmp(subj{s},'average')
                  for e = 1:numel(eccvals)
                     plot(eccvals(e),dprime(s).targecc.perf(e),'o','markersize',sizePerTrial*(dprime(s).targecc.numtrials(e)./max(dprime(s).targecc.numtrials)),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
                  end
               end
            figureDefaults;
            set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
            xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
            ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
            if s==numel(dprime)
               legend(legendlines,subj,'location','northeast');
            end
         end
         % save figure
            figdir = '../figures/behavior/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%seccentricity.png',figdir);
            saveas(gcf,filename);
      
      
      % figure 2. criterion
         figure('name','criterion','position',[109 395 232 221]);
         for s = 1:numel(dprime)
            ylim = [-2 2];
            ytick = -10:1:10;
            line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on
            legendlines(s) = plot(eccvals,criterion(s).targecc.perf,'-','linewidth',linewidth(s),'color',[colors(s,:) alphas(s)]);
            % plot individual data points at corresponding size
               if ~strcmp(subj{s},'average')
                  for e = 1:numel(eccvals)
                     plot(eccvals(e),criterion(s).targecc.perf(e),'o','markersize',sizePerTrial*(dprime(s).targecc.numtrials(e)./max(dprime(s).targecc.numtrials)),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
                  end
               end
            figureDefaults
            set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
            xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
            ylabel('criterion','fontname','arial','fontsize',10);
            if s==numel(dprime)
               legend(legendlines,subj,'location','southeast');
            end
         end
         % save figure
            figdir = '../figures/behavior/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%scriterion.png',figdir);
            saveas(gcf,filename);



      % figure 3. eccentricity x size (size subplots)
         xlim  = [-1 14];
         xtick = 0:2:20;
         ylim  = [0 3];
         ytick = 0:8;
         sizes = unique(sz.val);
         figure('name','size_eccentricity','position',[103 633 636 296]);
         for d = 1:numel(sizes)
            subplot(1,numel(sizes),d);
            for s = 1:numel(dprime)
               legendlines(s) = plot(eccvals,dprime(s).size_ecc.perf(d,:),'-','linewidth',linewidth(s),'color',[colors(s,:) alphas(s)]); hold on
               % plot individual data points at corresponding size
                  if ~strcmp(subj{s},'average')
                     for e = 1:numel(eccvals)
                        plot(eccvals(e),dprime(s).size_ecc.perf(d,e),'o','markersize',sizePerTrial*(dprime(s).size_ecc.numtrials(d,e)./max(dprime(s).size_ecc.numtrials(d,:))),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
                     end
                  end
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               if s==1 && d==1
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
               end
               if s==numel(dprime) && d==1
                  legend(legendlines,subj,'location','northwest','numColumns',2);
               end
            end
            title(sprintf('size = %i',sizes(d)),'fontname','arial','fontsize',10);
         end
         % save figure
            figdir = '../figures/behavior/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%secc_size.png',figdir);
            saveas(gcf,filename);


            return
      % figure 4. bandwidth x size (size subplots)
         xlim     = [60 150];
         xtick    = 0:30:210;
         ylim     = [0 2.5];
         ytick    = 0:8;
         bwvals   = unique(bw.val);
         figure('name','bandwidth_size','position',[360 344 611 274]);
         for d = 1:numel(sizes)
            subplot(1,numel(sizes),d);
            for s = 1:numel(dprime)
               if strcmp(subj{s},'average')
                  continue
               end
               legendlines(s) = plot(bwvals,dprime(s).bw_size.perf(:,d),'-','linewidth',linewidth(s),'color',[colors(s,:) alphas(s)]); hold on
               % plot indidividual data points at corresponding size
               for b = 1:numel(bwvals)
                  if dprime(s).bw_size.numtrials(b,d)>0
                     plot(bwvals(b),dprime(s).bw_size.perf(b,d),'o','markersize',sizePerTrial*(dprime(s).bw_size.numtrials(b,d)./max(dprime(s).bw_size.numtrials(:,d))),'markerFaceColor',colors(s,:),'markerEdgeColor','w');
                  end
               end
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               if s==1 && d==1
                  xlabel('Bandwidth (deg)','fontname','arial','fontsize',10);
                  ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
               end
               if s==numel(dprime) && d==1
                  legend(legendlines,subj,'location','northwest','numColumns',2);
               end
            end
            title(sprintf('size = %i',sizes(d)),'fontname','arial','fontsize',10);
         end
         % save figure
            figdir = '../figures/behavior/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%sbandwidth_size.png',figdir);
            saveas(gcf,filename);



      % figure 5. bandwidth x ecc x size (size subplots; separate figures for each subject)
         xlim  = [-1 14];
         xtick = 0:2:20;
         ylim  = [-0.5 4];
         ytick = 0:8;
         colors= linspecer(numel(bwvals),'qualitative'); 
         for s = 1:numel(dprime)
            if strcmp(subj{s},'average')
               continue
            end
            figure('name',sprintf('%s: bandwidth_size_ecc',subj{s}),'position',[360 250 833 368]);
            for d = 1:numel(sizes)
               subplot(1,numel(sizes),d);
               % plot each bandwidth performance separately
               for b = 1:numel(bwvals)
                  legendlines(b) = plot(eccvals,dprime(s).bw_ecc_size.perf(b,:,d),'-','linewidth',linewidth(s),'color',[colors(b,:) alphas(s)]); hold on
               end
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               if s==1 && d==1
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
               end
               legend(legendlines,cellfun(@num2str,num2cell(bwvals),'un',0),'location','northwest','numColumns',3);
               title(sprintf('size = %i',sizes(d)),'fontname','arial','fontsize',10);
            end
            % save figure
               figdir = '../figures/behavior/';
               if ~exist(figdir,'dir')
                  mkdir(figdir)
               end
               filename = sprintf('%s%s_bandwidth_size_ecc.png',figdir,subj{s});
               saveas(gcf,filename);
            end

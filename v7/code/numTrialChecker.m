function numTrialChecker(subj,nboot)
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


   %% Set # of trials to simulate
      numTrials   = 5:60;
      nboot       = 1e4;
      
   
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

         % size
            sz.val                        = data(:,idx_size);
            sz.label                      = cellfun(@num2str,num2cell(unique(sz.val)),'un',0);

         % create trial labels for target response (0=left, 1=right hemifield)
            trialresp      = data(:,idx_resp);

     

      %% Use condParser to compute behavioral metrics
      % size x eccentricity
         org   = condParser(trialresp,presence,sz,respcue);
         orgD  = hautas_adjustment(org);
         
      % store average number of trials in original dataset
         orgTrials(s) = mean(orgD.numtrials(:));

      % do simluations with subsets of trials
      tic
         for n = 1:numel(numTrials)
            for b = 1:nboot
               % resample some subset of trials per condition to find the minimum number of trials to still get reasonable data
                  boot     = org;
                  boot.raw = cellfun(@(x) x(randi(numel(x),1,numTrials(n))),org.raw,'un',0);
                  % compute dprime with subsampled dataset
                     boot   = hautas_adjustment(boot);
                  % store dprime from this iteration
                     bootD(:,:,s,n,b)  = boot.perf; 
                  % compute R2 for this iteration
                     r2(s,n,b)         = calcR2(boot.perf,orgD.perf);
            end
         end
         toc
   end


   %% Plot results of the simulations
      % scale up numTrials by factor of 2 to reflect total # of trials per condition (collapsed across present/absent conditions)
         numTrials = numTrials*2; 

      % create figure and set figure parameters
         figure('name','Min. # of trials','position',[680 1267 430 431]);
         colors = linspecer(numel(subj),'qualitative');
         xlim   = [min(numTrials) max(numTrials)];
         ylim   = [0 1];
         xtick  = 0:10:500;
         ytick  = 0:0.1:1;


      % get confidence interval for each subject and number of trials
         ci = quantile(r2,[0.025 1-0.025],3); 

      % display
      for s = 1:numel(subj)
         % confidence interval
            x = [numTrials, fliplr(numTrials)];
            y = [squeeze(ci(s,:,1)) fliplr(squeeze(ci(s,:,2)))];
            f = fill(x,y,colors(s,:));
            set(f,'facecolor',colors(s,:),'facealpha',0.25,'edgecolor','none'); hold on
         % median
            leg(s) = plot(numTrials,squeeze(median(r2(s,:,:),3)),'-','linewidth',2,'color',colors(s,:));
      end

      % add in lines for R2=0.8 and R2=0.9
         line(xlim,[0.8 0.8],'color',[0.5 0.5 0.5],'linewidth',1.5);
         line(xlim,[0.9 0.9],'color',[0.5 0.5 0.5],'linewidth',1.5);
         line([mean(orgTrials) mean(orgTrials)],ylim,'color',[0.5 0.5 0.5],'linewidth',1.5);
      
      % pretty up figure
         figureDefaults
         set(gca,'xlim',xlim,'ylim',ylim,'xtick',xtick,'ytick',ytick);
         xlabel('Trials/Size_x_Ecc','fontname','arial','fontsize',10,'interpreter','none');
         ylabel('R^2','fontname','arial','fontsize',10);
         legend(leg,subj,'location','southeast');

      % save figure
         saveDir  = '../figures/numTrialChecker/';
         if ~exist(saveDir,'dir')
            mkdir(saveDir);
         end
         saveas(gcf,[saveDir,'numTrialCheck.png']);

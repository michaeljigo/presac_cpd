% Purpose:  Analyze behavioral performance for task 1 for version 5.
% By:       Michael Jigo
%
% Only analyzes a single subject at a time, unlike Task1.
%

function display_task4_dprime(subj)
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
   % 14  sacEndPos_col              saccade endpoint (pix re ft)
   % 15  sacEndREft_deg_col         saccade endpoint (deg re ft)
   % 16  sacEnd_PosCue_col          closest saccade target (re sac endpoint); 0,0.75,1.25,1.5
   % 17  sacEnd_PosTst_col          closest test location (re sac endpoint); 0:1.5:2*pref_ecc
      idx_block      = 1;
      idx_targEcc    = 9;
      idx_respCue    = 11;
      idx_resp       = 12;
      idx_size       = 3;
      idx_bw         = 2;
      idx_sacCue     = 7;
      idx_testAtSac  = 17;

   
   %% Load subject files
      subjdata = sprintf('../data/raw/task4/%s_Task4_resMat.mat',subj);
      load(subjdata);
      data = resMat;

      % remove some blocks from analysis
         data(data(:,idx_block)<=1,:) = [];

      % create a new column in the matrix that re-codes fixation trials in terms of the saccade cue shown on that block
         newData  = data;
         newData(:,size(data,2)+1) = data(:,idx_sacCue);
         blocks   = unique(data(:,idx_block));
         for b = 1:numel(blocks)
            % get block index
               blockIdx  = data(:,idx_block)==blocks(b);
            % get which saccade cue was shown in this block
               whichSac = unique(data(blockIdx,idx_sacCue));
               whichSac = whichSac(whichSac>0);
            % replace fixation index (0) with -saccade cue
               newFix   = -whichSac;
               newData(blockIdx & data(:,idx_sacCue)==0,size(data,2)+1) = newFix;
         end
         data = newData;


   %% Extract important variables
      % create trial labels for target presence (0=absent; 1=present)
         tmp_presence = data(:,idx_targEcc);
         tmp_presence(~isnan(tmp_presence)) = 1;
         tmp_presence(isnan(tmp_presence)) = 0;
      
      % get actual values for eccentricity 
         eccVals     = round(unique(data(:,idx_respCue))*1e2)./1e2;
         ecclabels   = cellfun(@num2str, num2cell(eccVals),'uniformoutput',0);

      % get bandwidth values used
         bwVals      = unique(data(:,idx_bw));

      % get saccade cue eccentricities
         sacCueVals  = unique(data(:,idx_sacCue));
      


      %% Create condition labels
         % response-cued location
            respCue.val       = data(:,idx_respCue); 
            respCue.label     = cellfun(@num2str,num2cell(unique(respCue.val)),'UniformOutput',0);  
         
         % target presence (0=absent; 1=present)
            presence.val      = tmp_presence;
            presence.label    = {'absent' 'present'};

         % create trial labels for target response (0=left, 1=right hemifield)
            trialresp         = data(:,idx_resp);

         % cue eccentricity
            preCue.val        = data(:,idx_sacCue);
            preCue.label      = cellfun(@num2str,num2cell(unique(preCue.val)),'un',0);
            preCue.label{1}   = 'fixation';

         % valid vs invalid
            valVec         = data(:,idx_sacCue);
            valVec(valVec==0) = nan;
            valInval.val      = double(valVec==data(:,idx_respCue));
            valInval.val(isnan(valVec)) = -1; % fixation trials set to -1
            valInval.label    = {'fixation' 'invalid' 'valid'};

         % cue eccentricity (fixation trials separated by saccade target in given block)
            preCue_sepFix.val    = data(:,end);
            preCue_sepFix.label  = cellfun(@num2str,num2cell(unique(preCue_sepFix.val)),'un',0); % negative values correspond to fixation in a given saccade target condition

         % saccade vs fixation (all saccade eccentricities are collapsed to a single eccentricity)
            sacFix.val        = data(:,idx_sacCue);
            sacFix.val(sacFix.val>0) = 1;
            sacFix.label      = {'fixation' 'saccade'};

         % performance split by closest saccade landing position (conceptually consistent with valid cueing effects)
            sacLand.val       = data(:,idx_testAtSac);
            sacLand.removeIdx = isnan(sacLand.val);
            sacLand.label     = cellfun(@num2str,num2cell(unique(sacLand.val(~sacLand.removeIdx))),'un',0); 
     

      %% Use condParser to compute behavioral metrics
         % overall
            dprime.overall             = condParser(trialresp,presence,preCue);
            criterion.overall          = -0.5*(sum(norminv(dprime.overall.perf)));
            dprime.overall             = diff(norminv(dprime.overall.perf),[],1);

         % eccentricity (collapsed across saccade magnitudes)
            dprime.sacFix              = condParser(trialresp,presence,sacFix,respCue);
            dprime.sacFix              = hautas_adjustment(dprime.sacFix);

         % saccade x eccentricity 
            dprime.targEcc             = condParser(trialresp,presence,preCue,respCue); 
            % criterion
               criterion.targEcc       = dprime.targEcc;
               criterion.targEcc.perf  = squeeze(-0.5*(sum(norminv(dprime.targEcc.perf),1)));
               criterion.targEcc.perf(isinf(criterion.targEcc.perf)) = nan;
            % adjusted dprime
               dprime.targEcc          = hautas_adjustment(dprime.targEcc); % adjust for extreme probabilities

         % saccade x eccentricity (separate Fixation for each saccade target)
            dprime.targEcc_sepFix      = condParser(trialresp,presence,preCue_sepFix,respCue);
            dprime.targEcc_sepFix      = hautas_adjustment(dprime.targEcc_sepFix);
            

         % saccadic prep effect
            sacEffect.targEcc          = dprime.targEcc.perf(2:end,:)-dprime.targEcc.perf(1,:); % difference between saccade cues and fixation cue
            sacEffect.sacFix           = diff(dprime.sacFix.perf,[],1);
            % create axis aligned to saccade target
               for c = 2:numel(sacCueVals)
                  sacEffect.alignedAx.targEcc(c-1,:) = eccVals-sacCueVals(c);
               end

         % saccadic prep effect (fixation cue separated by saccade target)
            preCue_sepFixVals = unique(preCue_sepFix.val);
            for ii = 1:numel(preCue_sepFixVals)
               if preCue_sepFixVals(ii)<0
                  sacCueIdx = find(abs(preCue_sepFixVals(ii))==preCue_sepFixVals);
                  sacEffect.targEcc_sepFix(sacCueIdx,:) = dprime.targEcc_sepFix.perf(sacCueIdx,:)-dprime.targEcc_sepFix.perf(ii,:);
               end
            end
            % removes rows with all zeros
               zeroRows = sum(sacEffect.targEcc_sepFix==0,2);
               zeroRows = zeroRows==numel(eccVals);
               sacEffect.targEcc_sepFix(zeroRows,:) = [];


         % Valid cueing performance
            dprime.neutVal    = condParser(trialresp,presence,valInval,respCue);
            dprime.neutVal    = hautas_adjustment(dprime.neutVal); 
            % remove invalid cueing effects
               dprime.neutVal.perf = dprime.neutVal.perf([1 3],:);


         % Performance split by where the saccade landed
            % remove NaNs (where there were no eye movements)
               tmpTrialResp   = trialresp;   tmpTrialResp(sacLand.removeIdx)     = [];
               tmpSacLand     = sacLand;     tmpSacLand.val(sacLand.removeIdx)   = [];
               tmpPresence    = presence;    tmpPresence.val(sacLand.removeIdx)  = [];
               tmpRespCue     = respCue;     tmpRespCue.val(sacLand.removeIdx)   = [];
            % compute performance
               dprime.sacLand = condParser(tmpTrialResp,tmpPresence,tmpSacLand,tmpRespCue);
               dprime.sacLand = hautas_adjustment(dprime.sacLand);
            % compute performance, split by valid vs. invalid
               tmpValid.val   = tmpSacLand.val==tmpRespCue.val;
               tmpValid.label = {'invalid' 'valid'};
               dprime.sacLand_validity = condParser(tmpTrialResp,tmpPresence,tmpValid,tmpRespCue);
               dprime.sacLand_validity = hautas_adjustment(dprime.sacLand_validity);
               keyboard




         
      % save subject performance
         savedir = '../data/dprime/task4/';
         if ~exist(savedir,'dir')
            mkdir(savedir)
         end
         filename = sprintf('%s%s.mat',savedir,subj);
         save(filename,'dprime','criterion');

   %% Plot
      ylim           = [0 3.5];
      ytick          = -10:1:10;
      xlim           = [-1 14];
      xtick          = 0:2:20;
      sizePerTrial   = 7;
      colors         = [0 0 0; linspecer(numel(sacCueVals(2:end)),'qualitative')]; 
      linewidth      = 2;

      % figure 1. eccentricity
         figure('name','Sensitivity','position',[128 77 868 875]);
         for c = 2:numel(sacCueVals)
            subplot(3,numel(sacCueVals)-1,c-1)

            % plot Neutral condition
               plot(eccVals,dprime.targEcc.perf(1,:),'-','linewidth',linewidth,'color',colors(1,:)); hold on
               % plot individual data points at corresponding size
                  for e = 1:numel(eccVals)
                     plot(eccVals(e),dprime.targEcc.perf(1,e),'o','markersize',sizePerTrial*(dprime.targEcc.numtrials(1,e)./max(dprime.targEcc.numtrials(:))),'markerFaceColor',colors(1,:),'markerEdgeColor','w');
                  end

            % plot Saccade condition
               plot(eccVals,dprime.targEcc.perf(c,:),'-','linewidth',linewidth,'color',colors(c,:)); hold on
               % plot individual data points at corresponding size
                  for e = 1:numel(eccVals)
                     plot(eccVals(e),dprime.targEcc.perf(c,e),'o','markersize',sizePerTrial*(dprime.targEcc.numtrials(c,e)./max(dprime.targEcc.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w');
                  end

            % draw vertical line at Saccade eccentricity
               legendlines(1) = line([sacCueVals(c) sacCueVals(c)],ylim,'linestyle','-','linewidth',3,'color',[colors(c,:) 0.25]);
            % draw vertical line at Neutral peak eccentricity
               [~,maxEcc]  = max(dprime.targEcc.perf,[],2);
               maxEcc      = eccVals(maxEcc(1));
               legendlines(2) = line([maxEcc maxEcc],ylim,'linestyle','-','linewidth',3,'color',[colors(1,:) 0.25]);

            % pretty up figure
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
               ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
               title(sprintf('saccade to %.1f deg',sacCueVals(c)),'fontname','arial','fontsize',10);
               if c==2
                  legend(legendlines,{'saccade ecc' 'peak ecc'},'location','southwest','linewidth',0.001,'fontname','arial','fontsize',6);
               end

               % add yyaxis for ylabel
               if c==numel(sacCueVals)
                  yyaxis right
                  set(gca,'ytick',[],'linewidth',0.0001);
                  ylabel('CPD','fontname','arial','fontsize',10,'color','k','fontWeight','bold');
               end
         end

         % Saccadic effects
            ylim  = [-1.5 1.5];
            ytick = [-2:0.5:2];
            for c = 2:numel(sacCueVals)
               subplot(3,numel(sacCueVals)-1,numel(sacCueVals)-1+c-1)
               % plot Saccade-Fixation
                  plot(eccVals,sacEffect.targEcc(c-1,:),'-','linewidth',linewidth,'color',colors(c,:)); hold on
               % plot individual data points at corresponding size
                  for e = 1:numel(eccVals)
                     plot(eccVals(e),sacEffect.targEcc(c-1,e),'o','markersize',sizePerTrial*(dprime.targEcc.numtrials(c,e)./max(dprime.targEcc.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w');
                  end

               % draw line at no cueing effect (i.e., 0)
                  line(xlim,[0 0],'linestyle','-','color',[0.5 0.5 0.5],'linewidth',linewidth);
               % draw vertical line at Saccade eccentricity
                  line([sacCueVals(c) sacCueVals(c)],ylim,'linestyle','-','linewidth',3,'color',[colors(c,:) 0.25]);
               % draw vertical line at Neutral peak eccentricity
                  [~,maxEcc]  = max(dprime.targEcc.perf,[],2);
                  maxEcc      = eccVals(maxEcc(1));
                  line([maxEcc maxEcc],ylim,'linestyle','-','linewidth',3,'color',[colors(1,:) 0.25]);

               % pretty up figure
                  figureDefaults
                  set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Saccadic effect (\Delta d^{\prime})','fontname','arial','fontsize',10);

               % add yyaxis for ylabel
               if c==numel(sacCueVals)
                  yyaxis right
                  set(gca,'ytick',[],'linewidth',0.0001);
                  ylabel('Saccade effect','fontname','arial','fontsize',10,'color','k','fontWeight','bold');
               end
            end


         % Saccadic effects aligned to saccade eccentricity
            ylim  = [-1.5 1.5];
            ytick = [-1.5:0.5:1.5];
            xlim  = [-9 9];
            xtick = -9:3:9;

            for c = 2:numel(sacCueVals)
               subplot(3,numel(sacCueVals)-1,2*(numel(sacCueVals)-1)+c-1)
               % plot Saccade-Fixation
                  plot(sacEffect.alignedAx.targEcc(c-1,:),sacEffect.targEcc(c-1,:),'-','linewidth',linewidth,'color',colors(c,:)); hold on
               % plot individual data points at corresponding size
                  for e = 1:numel(eccVals)
                     plot(sacEffect.alignedAx.targEcc(c-1,e),sacEffect.targEcc(c-1,e),'o','markersize',sizePerTrial*(dprime.targEcc.numtrials(c,e)./max(dprime.targEcc.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w');
                  end

               % draw line at no cueing effect (i.e., 0)
                  line(xlim,[0 0],'linestyle','-','color',[0 0 0],'linewidth',1.5);
               % draw vertical line at 0
                  line([0 0],ylim,'linestyle','-','linewidth',1.5,'color','k');

               % pretty up figure
                  figureDefaults
                  set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
                  xlabel('\Delta saccade ecc (deg)','fontname','arial','fontsize',10);
                  ylabel('Saccadic effect (\Delta d^{\prime})','fontname','arial','fontsize',10);

               % add yyaxis for ylabel
               if c==numel(sacCueVals)
                  yyaxis right
                  set(gca,'ytick',[],'linewidth',0.0001);
                  ylabel('Aligned to saccade targ.','fontname','arial','fontsize',10,'color','k','fontWeight','bold');
               end

            end
         % save figure
            figdir = '../figures/behavior/task4/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%ssensitivity_%s.png',figdir,subj);
            saveas(gcf,filename);
      


      % figure 2. Saccade vs Fixation
         xlim  = [-1 14];
         xtick = 0:2:20;
         ylim  = [0 3.5];
         ytick = -10:1:10;
         clear legendlines
         figure('name','saccade vs fixation','position',[158 345 895 426]);
            subplot(1,2,1);
            for c = 1:size(dprime.sacFix.perf,1)
               % plot performance on each condition
                  legendlines(c) = plot(eccVals,dprime.sacFix.perf(c,:),'-','linewidth',linewidth,'color',colors(c,:)); hold on
                  % plot individual data points at corresponding size
                     for e = 1:numel(eccVals)
                        plot(eccVals(e),dprime.sacFix.perf(c,e),'o','markersize',sizePerTrial*(dprime.sacFix.numtrials(c,e)./max(dprime.sacFix.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w');
                     end
               % draw vertical line at Neutral peak eccentricity
                  [~,maxEcc]  = max(dprime.targEcc.perf,[],2);
                  maxEcc      = eccVals(maxEcc(1));
                  line([maxEcc maxEcc],ylim,'linestyle','-','linewidth',3,'color',[colors(1,:) 0.25]);
            end
            % pretty up 
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
               ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
               legend(legendlines,{'Fixation' 'Saccade'},'fontname','arial','fontsize',6,'location','southwest');

            % Saccadic effects
               subplot(1,2,2);
               ylim  = [-1.5 1.5];
               ytick = -1.5:0.5:1.5;
               legendlines(c) = plot(eccVals,sacEffect.sacFix,'-','linewidth',linewidth,'color',colors(2,:)); hold on
               % plot individual data points at corresponding size
                  for e = 1:numel(eccVals)
                     plot(eccVals(e),sacEffect.sacFix(e),'o','markersize',sizePerTrial*(dprime.sacFix.numtrials(2,e)./max(dprime.sacFix.numtrials(:))),'markerFaceColor',colors(2,:),'markerEdgeColor','w');
                  end
               % draw line at no cueing effect (i.e., 0)
                  line(xlim,[0 0],'linestyle','-','color',[0.5 0.5 0.5],'linewidth',linewidth);
               % draw vertical line at Neutral peak eccentricity
                  [~,maxEcc]  = max(dprime.targEcc.perf,[],2);
                  maxEcc      = eccVals(maxEcc(1));
                  line([maxEcc maxEcc],ylim,'linestyle','-','linewidth',3,'color',[colors(1,:) 0.25]);
               % pretty up 
                  figureDefaults;
                  set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Saccadic effect (\Delta d^{\prime})','fontname','arial','fontsize',10);

         % save figure
            figdir = '../figures/behavior/task4/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%ssaccade_vs_fixation_%s.png',figdir,subj);
            saveas(gcf,filename);


      % figure 3. Saccade vs Fixation
         xlim  = [-1 14];
         xtick = 0:2:20;
         ylim  = [0 3.5];
         ytick = -10:1:10;
         clear legendlines
         figure('name','valid effect','position',[125 562 368 354]);
            for c = 1:size(dprime.neutVal.perf,1)
               % plot performance on each condition
                  legendlines(c) = plot(eccVals,dprime.neutVal.perf(c,:),'o-','linewidth',linewidth,'color',colors(c,:),'markersize',6,'markerfaceColor',colors(c,:),'markerEdgeColor','w'); hold on
            end
            % pretty up 
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
               ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
               legend(legendlines,{'Fixation' 'Valid'},'fontname','arial','fontsize',6,'location','southwest');
         % save figure
            figdir = '../figures/behavior/task4/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%svalid_%s.png',figdir,subj);
            saveas(gcf,filename);
      
      % figure 4. criterion
         xlim  = [-1 14];
         xtick = 0:2:20;
         ylim = [-1.5 1.5];
         ytick = -10:0.5:10;
         clear legendlines
         figure('name','criterion','position',[109 235 454 381]);
         for c = 1:numel(sacCueVals)
            line(xlim,[0 0],'color',[0 0 0]+0.5,'linewidth',1.5); hold on

            % plot line across eccentricity
               legendlines(c) = plot(eccVals,criterion.targEcc.perf(c,:),'-','linewidth',linewidth,'color',colors(c,:));

            % plot individual data points at corresponding size
               for e = 1:numel(eccVals)
                  plot(eccVals(e),criterion.targEcc.perf(c,e),'o','markersize',sizePerTrial*(dprime.targEcc.numtrials(c,e)./max(dprime.targEcc.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w');
               end

            % draw vertical line at Saccade eccentricity
               if c>1
                  line([sacCueVals(c) sacCueVals(c)],[ylim(1) min(criterion.targEcc.perf(c,:))],'linestyle','-','linewidth',3,'color',[colors(c,:) 0.25]);
               end
         end
         % pretty up figure
            figureDefaults
            set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
            xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
            ylabel('Criterion','fontname','arial','fontsize',10);
            legend(legendlines,preCue.label,'location','northwest','fontname','arial','fontsize',6,'linewidth',0.001);

         % save figure
            figdir = '../figures/behavior/task4/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%scriterion_%s.png',figdir,subj);
            saveas(gcf,filename);



      % figure 4. eccentricity
         ylim           = [0 3.5];
         ytick          = -10:1:10;
         xlim           = [-1 14];
         xtick          = 0:2:20;
         sizePerTrial   = 7;
         colors         = [0 0 0; linspecer(numel(sacCueVals(2:end)),'qualitative')]; 
         linewidth      = 2;
         figure('name','Sensitivity: Separated Fixation','position',[128 77 868 875]);
         for c = 2:numel(sacCueVals)
            subplot(3,numel(sacCueVals)-1,c-1)

            % plot Neutral condition
               thisNeutIdx = unique(preCue_sepFix.val)==-sacCueVals(c);
               plot(eccVals,dprime.targEcc_sepFix.perf(thisNeutIdx,:),'-','linewidth',linewidth,'color',colors(1,:)); hold on
               % plot individual data points at corresponding size
                  for e = 1:numel(eccVals)
                     plot(eccVals(e),dprime.targEcc_sepFix.perf(thisNeutIdx,e),'o','markersize',sizePerTrial*(dprime.targEcc_sepFix.numtrials(thisNeutIdx,e)./max(dprime.targEcc_sepFix.numtrials(:))),'markerFaceColor',colors(1,:),'markerEdgeColor','w');
                  end

            % plot Saccade condition
               plot(eccVals,dprime.targEcc.perf(c,:),'-','linewidth',linewidth,'color',colors(c,:)); hold on
               % plot individual data points at corresponding size
                  for e = 1:numel(eccVals)
                     plot(eccVals(e),dprime.targEcc.perf(c,e),'o','markersize',sizePerTrial*(dprime.targEcc.numtrials(c,e)./max(dprime.targEcc_sepFix.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w');
                  end

            % draw vertical line at Saccade eccentricity
               legendlines(1) = line([sacCueVals(c) sacCueVals(c)],ylim,'linestyle','-','linewidth',3,'color',[colors(c,:) 0.25]);
            % draw vertical line at Neutral peak eccentricity
               [~,maxEcc]  = max(dprime.targEcc.perf,[],2);
               maxEcc      = eccVals(maxEcc(1));
               legendlines(2) = line([maxEcc maxEcc],ylim,'linestyle','-','linewidth',3,'color',[colors(1,:) 0.25]);

            % pretty up figure
               figureDefaults;
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
               ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
               title(sprintf('saccade to %.1f deg',sacCueVals(c)),'fontname','arial','fontsize',10);
               if c==2
                  legend(legendlines,{'saccade ecc' 'peak ecc'},'location','southwest','linewidth',0.001,'fontname','arial','fontsize',6);
               end

               % add yyaxis for ylabel
               if c==numel(sacCueVals)
                  yyaxis right
                  set(gca,'ytick',[],'linewidth',0.0001);
                  ylabel('CPD','fontname','arial','fontsize',10,'color','k','fontWeight','bold');
               end
         end

         % Saccadic effects
            ylim  = [-1.5 1.5];
            ytick = [-2:0.5:2];
            for c = 2:numel(sacCueVals)
               subplot(3,numel(sacCueVals)-1,numel(sacCueVals)-1+c-1)
               % plot Saccade-Fixation
                  plot(eccVals,sacEffect.targEcc_sepFix(c-1,:),'-','linewidth',linewidth,'color',colors(c,:)); hold on
               % plot individual data points at corresponding size
                  for e = 1:numel(eccVals)
                     plot(eccVals(e),sacEffect.targEcc_sepFix(c-1,e),'o','markersize',sizePerTrial*(dprime.targEcc_sepFix.numtrials(c,e)./max(dprime.targEcc_sepFix.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w');
                  end

               % draw line at no cueing effect (i.e., 0)
                  line(xlim,[0 0],'linestyle','-','color',[0.5 0.5 0.5],'linewidth',linewidth);
               % draw vertical line at Saccade eccentricity
                  line([sacCueVals(c) sacCueVals(c)],ylim,'linestyle','-','linewidth',3,'color',[colors(c,:) 0.25]);
               % draw vertical line at Neutral peak eccentricity
                  [~,maxEcc]  = max(dprime.targEcc.perf,[],2);
                  maxEcc      = eccVals(maxEcc(1));
                  line([maxEcc maxEcc],ylim,'linestyle','-','linewidth',3,'color',[colors(1,:) 0.25]);

               % pretty up figure
                  figureDefaults
                  set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
                  xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
                  ylabel('Saccadic effect (\Delta d^{\prime})','fontname','arial','fontsize',10);

               % add yyaxis for ylabel
               if c==numel(sacCueVals)
                  yyaxis right
                  set(gca,'ytick',[],'linewidth',0.0001);
                  ylabel('Saccade effect','fontname','arial','fontsize',10,'color','k','fontWeight','bold');
               end
            end


         % Saccadic effects aligned to saccade eccentricity
            ylim  = [-1.5 1.5];
            ytick = [-1.5:0.5:1.5];
            xlim  = [-9 9];
            xtick = -9:3:9;

            for c = 2:numel(sacCueVals)
               subplot(3,numel(sacCueVals)-1,2*(numel(sacCueVals)-1)+c-1)
               % plot Saccade-Fixation
                  plot(sacEffect.alignedAx.targEcc(c-1,:),sacEffect.targEcc_sepFix(c-1,:),'-','linewidth',linewidth,'color',colors(c,:)); hold on
               % plot individual data points at corresponding size
                  for e = 1:numel(eccVals)
                     plot(sacEffect.alignedAx.targEcc(c-1,e),sacEffect.targEcc_sepFix(c-1,e),'o','markersize',sizePerTrial*(dprime.targEcc_sepFix.numtrials(c,e)./max(dprime.targEcc_sepFix.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w');
                  end

               % draw line at no cueing effect (i.e., 0)
                  line(xlim,[0 0],'linestyle','-','color',[0 0 0],'linewidth',1.5);
               % draw vertical line at 0
                  line([0 0],ylim,'linestyle','-','linewidth',1.5,'color','k');

               % pretty up figure
                  figureDefaults
                  set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
                  xlabel('\Delta saccade ecc (deg)','fontname','arial','fontsize',10);
                  ylabel('Saccadic effect (\Delta d^{\prime})','fontname','arial','fontsize',10);

               % add yyaxis for ylabel
               if c==numel(sacCueVals)
                  yyaxis right
                  set(gca,'ytick',[],'linewidth',0.0001);
                  ylabel('Aligned to saccade targ.','fontname','arial','fontsize',10,'color','k','fontWeight','bold');
               end

            end
         % save figure
            figdir = '../figures/behavior/task4/';
            if ~exist(figdir,'dir')
               mkdir(figdir)
            end
            filename = sprintf('%ssensitivity_separateFixation_%s.png',figdir,subj);
            saveas(gcf,filename);
      


         % Performance with saccades, based on closest saccade landing position
            ylim  = [0 3.5];
            ytick = 0:5;
            xlim  = [-1 14];
            xtick = 0:2:14;
            clear legendlines

            figure('name','Closest saccade landing','position',[109 235 454 381]);
            for c = 1:size(dprime.sacLand_validity.perf,1)
               if c==1
                  % plot Fixation performance
                     legendlines(c) = plot(eccVals,dprime.targEcc.perf(1,:),'-','linewidth',linewidth,'color',colors(c,:)); hold on
                  % plot individual data points at corresponding size
                     for e = 1:numel(eccVals)
                        plot(eccVals(e),dprime.targEcc.perf(1,e),'o','markersize',sizePerTrial*(dprime.targEcc.numtrials(1,e)./max(dprime.targEcc.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w');
                     end
               else
                  % plot performance when saccade landing and response cue overlapped
                     legendlines(c) = plot(eccVals,dprime.sacLand_validity.perf(c,:),'-','linewidth',linewidth,'color',colors(c,:)); hold on
                  % plot individual data points at corresponding size
                     for e = 1:numel(eccVals)
                        if dprime.sacLand_validity.numtrials(c,e)>0
                           plot(eccVals(e),dprime.sacLand_validity.perf(c,e),'o','markersize',sizePerTrial*(dprime.sacLand_validity.numtrials(c,e)./max(dprime.targEcc.numtrials(:))),'markerFaceColor',colors(c,:),'markerEdgeColor','w');
                        end
                     end
               end
            end
            % pretty up figure
               figureDefaults
               set(gca,'ylim',ylim,'ytick',ytick,'fontname','arial','fontsize',8,'xlim',xlim,'xtick',xtick);
               xlabel('Eccentricity (deg)','fontname','arial','fontsize',10);
               ylabel('Sensitivity (d^{\prime})','fontname','arial','fontsize',10);
               legend(legendlines,{'fixation' 'saccade+response cue overlap'},'fontname','arial','fontsize',8,'location','southwest');
            % save figure
               figdir = '../figures/behavior/task4/';
               if ~exist(figdir,'dir')
                  mkdir(figdir)
               end
               filename = sprintf('%ssensitivity_saccadeLanding_%s.png',figdir,subj);
               saveas(gcf,filename);
               close all

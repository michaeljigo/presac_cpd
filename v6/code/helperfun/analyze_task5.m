% Purpose:  Analyze behavior from task 5. Both fixation and saccade conditions will be analyzed.
% By:       Michael Jigo

function analyze_task5(subj)
   idx = parse_column_idx;

   
   %% Load subject's data
      dataDir  = '../data/raw/task5/';
      filename = sprintf('%s_Task5_resMat.mat',subj);
      load([dataDir filename],'resMat');
      data = resMat;


   %% Do some data preprocessing
   if size(data,2)<=idx.sacTargMarkerEcc
      % create a new column in the matrix that re-codes fixation trials in terms of the saccade cue shown on that block
         newData  = data;
         %newData(:,size(data,2)+1) = data(:,idx.sacEcc);
         newData(:,idx.sacTargMarkerEcc) = data(:,idx.sacEcc);
         blocks   = unique(data(:,idx.block));
         for b = 1:numel(blocks)
            % get block index
               blockIdx  = data(:,idx.block)==blocks(b);
            % get which saccade cue was shown in this block
               whichSac = unique(data(blockIdx,idx.sacEcc));
               whichSac = whichSac(whichSac>0);
            % replace fixation index (0) with saccade cue eccentricity
               newFix   = whichSac;
               newData(blockIdx & data(:,idx.sacEcc)==0,idx.sacTargMarkerEcc) = newFix;
         end
         % overwrite resMat with new matrix with newFixEcc
            resMat   = newData;
            save([dataDir,filename],'resMat');
         % update data matrix
            data     = newData;
   end

      % remove training (1st block) from analysis
         data(data(:,idx.block)<=1,:) = [];
         %data(data(:,idx.block)>=18,:) = [];



   %% Extract observer responses
      response          = data(:,idx.response);



   %% Create condition labels
      % response-cued location
         respEcc.val       = data(:,idx.respEcc); 
         respEcc.label     = cellfun(@num2str,num2cell(unique(respEcc.val)),'UniformOutput',0);  

      % target presence (0=absent; 1=present)
         % create trial labels for target presence (0=absent; 1=present)
            tmp_presence                        = data(:,idx.patchEcc);
            tmp_presence(~isnan(tmp_presence))  = 1;
            tmp_presence(isnan(tmp_presence))   = 0;
         presence.val      = tmp_presence;
         presence.label    = {'absent' 'present'};

      % fixation vs valid vs invalid
         valVec                        = data(:,idx.sacEcc);
         valVec(valVec==0)             = nan;
         valInval.val                  = double(valVec==data(:,idx.respEcc));
         valInval.val(isnan(valVec))   = -1; % fixation trials set to -1
         valInval.label                = {'fixation' 'invalid' 'valid'};

      % saccade vs fixation (all saccade eccentricities are collapsed to a single eccentricity)
         sacFix.val        = data(:,idx.sacEcc);
         sacFix.val(sacFix.val>0) = 1;
         sacFix.label      = {'fixation' 'saccade'};

      % saccade target eccentricity (i.e., eccentricity of small gray dots on a given block)
         sacTarg.val       = round(data(:,idx.sacTargMarkerEcc)*1e3)./1e3;
         sacTarg.label     = cellfun(@num2str,num2cell(unique(sacTarg.val)),'UniformOutput',0);  
     


   %% Use condParser to compute behavioral metrics
         %% fixation vs saccade
            dprime.fix_saccade    = condParser(response,presence,sacFix,respEcc); 
            % criterion
               criterion.fix_saccade                              = dprime.fix_saccade;
               criterion.fix_saccade.perf                         = squeeze(-0.5*(sum(norminv(dprime.fix_saccade.perf),1)));
               criterion.fix_saccade.perf(isinf(criterion.fix_saccade.perf))  = nan;
            % adjusted dprime
               dprime.fix_saccade = hautas_adjustment(dprime.fix_saccade);


         %% fixation vs valid
            dprime.fix_valid      = condParser(response,presence,valInval,respEcc);
            % criterion
               criterion.fix_valid                                = dprime.fix_valid;
               criterion.fix_valid.perf                           = squeeze(-0.5*(sum(norminv(dprime.fix_valid.perf),1)));
               criterion.fix_valid.perf(isinf(criterion.fix_valid.perf))    = nan;
            % adjusted dprime
               dprime.fix_valid   = hautas_adjustment(dprime.fix_valid);


         %% fixation vs saccade target (note, Fixation condition are split by the saccade target on a given block)
            dprime.fix_sacTarg  = condParser(response,presence,sacFix,sacTarg,respEcc);
            % criterion
               criterion.fix_sacTarg                                = dprime.fix_sacTarg;
               criterion.fix_sacTarg.perf                           = squeeze(-0.5*(sum(norminv(dprime.fix_sacTarg.perf),1)));
               criterion.fix_sacTarg.perf(isinf(criterion.fix_sacTarg.perf))    = nan;
            % adjusted dprime
               dprime.fix_sacTarg   = hautas_adjustment(dprime.fix_sacTarg);



      %% Create output structure
         behavior.dprime      = dprime;
         behavior.criterion   = criterion;
         behavior.ecc         = unique(respEcc.val);
         behavior.size        = unique(data(:,idx.size));
         behavior.saccadeTarg = unique(sacTarg.val);
         behavior.validity    = valInval.label;
         behavior.dataMat     = data;



      %% Create csv table # of trials
         csvDir = '../data/behavior/task5/numTrials/';
         if ~exist(csvDir,'dir')
            mkdir(csvDir);
         end
         ntrials     = dprime.fix_sacTarg.numtrials;
         trialType   = {'fix' 'sacc'};
         for ii = 1:size(ntrials,1)
            filename = [csvDir,subj,'_',trialType{ii},'.csv'];
            headers  = cellfun(@(x) ['ecc_',x],respEcc.label,'un',0);
            csvwrite_with_headers(filename,squeeze(ntrials(ii,:,:)),headers);
            fprintf('Saved table with # of trials per condition: %s\n',filename);
         end



      %% Save subject performance
         savedir = '../data/behavior/task5/';
         if ~exist(savedir,'dir')
            mkdir(savedir)
         end
         filename = sprintf('%s%s.mat',savedir,subj);
         save(filename,'behavior');
         fprintf('Saved analyzed behavior: %s\n',filename);

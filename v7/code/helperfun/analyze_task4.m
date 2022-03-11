% Purpose:  Analyze behavior from task 4. Only fixation condition will be analyzed.
% By:       Michael Jigo

function analyze_task4(subj)
   idx = parse_column_idx;

   %% Load subject's data
      dataDir  = '../data/raw/task4/';
      filename = sprintf('%s_Task4_resMat.mat',subj);
      load([dataDir filename],'resMat');
      data = resMat;


   %% Do some data preprocessing
      % remove training (1st block) from analysis
         data(data(:,idx.block)<=1,:) = [];

      % remove trials with saccades. We only care about Fixation trials in Task4
         fixTrials = data(:,idx.sacEcc)==0;
         data = data(fixTrials,:);


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
      % patch size
         sz.val         = data(:,idx.size);
         sz.label       = cellfun(@num2str,num2cell(unique(sz.val)),'un',0);
     


      %% Use condParser to compute behavioral metrics
         % size x patch ecc
            dprime            = condParser(response,presence,sz,respEcc); 
            % criterion
               criterion      = dprime;
               criterion.perf = squeeze(-0.5*(sum(norminv(dprime.perf),1)));
               criterion.perf(isinf(criterion.perf)) = nan;
            % adjusted dprime
               dprime         = hautas_adjustment(dprime); % adjust for extreme probabilities



      %% Create output structure
         behavior.dprime      = dprime;
         behavior.criterion   = criterion;
         behavior.ecc         = unique(respEcc.val);
         behavior.size        = unique(sz.val);
         behavior.dataMat     = data;


      %% Create csv table # of trials
         csvDir = '../data/behavior/task4/numTrials/';
         if ~exist(csvDir,'dir')
            mkdir(csvDir);
         end
         filename = [csvDir,subj,'.csv'];
         headers  = cellfun(@(x) ['ecc_',x],respEcc.label,'un',0);
         %csvwrite_with_headers(filename,dprime.numtrials',headers');
         %fprintf('Saved table with # of trials per condition: %s\n',filename);



      %% Save subject performance
         savedir = '../data/behavior/task4/';
         if ~exist(savedir,'dir')
            mkdir(savedir)
         end
         filename = sprintf('%s%s.mat',savedir,subj);
         save(filename,'behavior');
         fprintf('Saved analyzed behavior: %s\n',filename);

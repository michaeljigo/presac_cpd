% Purpose:  Load subject's data for the specified task.
% By:       Michael Jigo

function behavior = load_subj_data(subj,task,overwrite)
   if ~exist('overwrite','var')
      overwrite = 0;
   end

   switch task
      case 'task4'
         subjData = sprintf('../data/behavior/task4/%s.mat',subj);
         if ~exist(subjData,'file') || overwrite
            analyze_task4(subj);
         end
         load(subjData,'behavior');
      case 'task5'
         subjData = sprintf('../data/behavior/task5/%s.mat',subj);
         if ~exist(subjData,'file') || overwrite
            analyze_task5(subj);
         end
         load(subjData,'behavior');
   end

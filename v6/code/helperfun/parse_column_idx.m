% Purpose:  Contains the identity of individual columns in the data matrix saved in Nina Hanning's 'extract' file.
% By:       Michael Jiog

function idx = parse_columns

   % matrix columns
   % 1   block number
   % 2   bandwidth                  (orientation bandwidth)
   % 3   size                       (target patch size)
   % 4   background orientation     (-45 or 45)
   % 5   patch orientation          (-45 or 45)
   % 6   cue ecc                    
   % 7   cue absolute ecc           
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

      idx.block         = 1;
      idx.bw            = 2;
      idx.size          = 3;
      idx.sacEcc        = 7;
      idx.patchEcc      = 9;
      idx.respEcc       = 11;
      idx.response      = 12;
      idx.sacPatchEcc   = 17;

   

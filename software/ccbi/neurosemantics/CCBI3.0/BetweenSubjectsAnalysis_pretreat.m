% semantic space exp
% between subject analysis
% step1 - prepare and treat the data

%function []=step1(param_file)
function [] = BetweenSubjectsAnalysis_pretreat(param_file)
curr_dir = pwd;
eval(param_file);
disp('Pre-treating data...');
% load and standardize your data 
S={};
  for s=1:length(allsubjects) 
    if s == 1 %ADDED THIS IF BLOCK
        cd(sprintf('../%s',mDir));
        cd(allsubjects{s});
    else
        cd(sprintf('../%s',allsubjects{s}));
    end    
    S{s}=load(mFile);
    [C,Mpsc]=transformIDMtoMPSC(S{s});
    mm=mean(Mpsc,1);
    if any(isnan(mm)); 
      error('NAN in mpsc (quitting)')
    end

% Now Map to the new C matrix if provided.
 if ( exist ('newCMatFile' , 'var'))
 newC = load( newCMatFile, 'ascii');   %
 [Mpsc, C, ind_slctdtrls] = ccbiMaskAndMapMpscForClsfcn(Mpsc, C, newC);
  end



% reduce the data by averaging by presentation
% Assuming that the words appear exactly in the same order in each presentation
    n_pres = max(C(:,3));       % from 1 to 6
    n_cat =  max(C(:,1)) - 1 ;  % from 2 to 13
    n_word = max(C(:,2));       % from 1 to 5 (within category)
    S{s}.C = zeros(n_cat*n_word, 3);
    S{s}.Mpsc = zeros(n_cat*n_word, length(Mpsc(1,:)));
    i = 1;
    for c=2:n_cat+1
     for w = 1:n_word
       ind = find(C(:,1)==c & C(:,2)==w );
       S{s}.C(i,:)=C(ind(1),:);  
       S{s}.Mpsc(i,:)=mean(Mpsc(ind,:));
       i = i+1;
     end
    end
    S{s}.C(:,3) = s;
% get rid of unnecessary data - or is it too early?
    S{s}.info = [];
    S{s}.data = [];
%    S{s}.meta = [];
    S{s}.meta.ntrials = n_cat*n_word;
  end
  
% compute the common mask for all subjects (in terms of taliarch coordinates)
  common=S{1}.meta.colToCoord;
  commonMask=S{1}.meta.coordToCol>0;
  for s=2:length(allsubjects)
    isCommon=ismember(S{s}.meta.colToCoord,common,'rows');
    common=S{s}.meta.colToCoord(isCommon,:);
    commonMask=commonMask+(S{s}.meta.coordToCol>0);  % do i need this at all???
  end

% done with preparing the data
% form a single C,Mpsc from all subjects, including only the common voxels
%   Mpsc = zeros(n_cat*n_word*length(allsubjects), length(common(1,:)));
  Mpsc = [];
  C=[];
  for s=1:length(allsubjects)
   isCommon=ismember(S{s}.meta.colToCoord,common,'rows');
   Mpsc=[Mpsc; S{s}.Mpsc(:,isCommon)];
   C = [C; S{s}.C];
  end

%standardize the data - averaging across voxels
% I think the better way is to normalize by presentation - then it should be
% done before averaging across presentations... 
    Mpsc=Mpsc-(repmat(mean(Mpsc')',1,size(Mpsc,2)));
    Mpsc=Mpsc./(repmat(std(Mpsc')',1,size(Mpsc,2)));

 % Finally, save this in BetweenSubjects/groupname/groupname.mat
  allsubjects_saved =  allsubjects;
  outf = sprintf('%s/BetweenSubjects/%s/%s_pretreat.mat', ...
	      curr_dir, groupName, groupName);
  save (outf, 'C','Mpsc','common','allsubjects_saved');
cd(curr_dir);
return

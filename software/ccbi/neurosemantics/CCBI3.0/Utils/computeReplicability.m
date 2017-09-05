%$Header: /usr/cluster/projects2/cat_scripts/CVS/CCBI2.0/computeReplicability.m,v 1.7 2006/01/18 19:37:04 vlm Exp $
% Computes replicability for the full 
% derived from ns_replica.m
function [I,R]=computeReplicability(labels, presentations, Mpsc, measure, summary)

% MPSC = 84 X nvoxels
% labels = 84X1
%presentations =84X1 

% assumes no outlier dropping
%keyboard
u_pres=unique(presentations);
npres=length(u_pres);
[tpres,nvox]=size(Mpsc);
u_labels=unique(labels);
r=zeros((npres)*(npres-1)/2,nvox);
R=zeros(1,length(Mpsc(1,:)));
lgth=0;
if strcmp(measure,'Replica')
  for x=1:(npres-1)
    for y=(x+1):npres
      lgth=lgth+1;
      %sprintf('replica calculating for pres %d and %d',u_pres(x),u_pres(y))
      % subset by each presentation 
      % sort by labels within each presentation 
      
      % find indices where presentation matches
      presX=find(presentations==u_pres(x));
      presY=find(presentations==u_pres(y));
      
      %subset these so that you only have the words which exist in each
      existingLabels=intersect(labels(presX),labels(presY));
      fpx=presX(ismember(labels(presX),existingLabels));
      fpy=presY(ismember(labels(presY),existingLabels));
      % rest of code is unchanged
      MpscX=Mpsc(fpx,:);
      MpscY=Mpsc(fpy,:);
      %keyboard%
      [junk,slx]=sort(labels(fpx));
      [junk,sly]=sort(labels(fpy));
      X=MpscX(slx,:);
      Y=MpscY(sly,:);
      
      %
      % optimized standard deviation based on Francisco's code.  '
      %
      Sx=std(X,0,1);
      Sy=std(Y,0,1);
      %keyboard
      newX=X-repmat(mean(X,1),length(existingLabels),1);
      newY=Y-repmat(mean(Y,1),length(existingLabels),1);
      
      r(lgth,:)=sum(newX .* newY) ./ ((Sx .* Sy)*(length(existingLabels)-1));
            
      % for each voxel:
      % compute pairwise measure
      %for k=1:length(Mpsc(1,:))
%	rr=corrcoef(X(:,k),Y(:,k));
%	r(lgth,k)=rr(1,2);
 %     end
  %    keyboard
    end
  end
end

if strcmp(summary,'Mean')
  for k=1:length(Mpsc(1,:))
    R(k)=mean(r(:,k));
  end
elseif strcmp(summary,'Median')
  for k=1:length(Mpsc(1,:))
    R(k)=median(r(:,k));
  end
else
  sprintf('ERROR - Bad Argument');
  I=[];
  R=[];
end

% sort by it
[S,I]=sort(R);
%5figure;plot(sort(R));


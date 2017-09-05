function [newMpsc, newC, ind_slctdtrls] = ccbiMaskAndMapMpscForClsfcn(Mpsc, C, newC)
% function [newMpsc, newC, newWordLabels, newCategoryLabels] = ccbiMaskAndMapMpsc(Mpsc, C, wordLabels, categoryLabels, newC)
% mask out some trials ( if cond ==-1 in newC matrix) and map new wordLabels and categoryLabels 
% Input:  Mpsc -  trials by voxels matrix, 
%    C - trials X 3 columns columns corresponds to cond(starting from 2), exempler (1-5 in curent expts), presentations(1-6)
%    newC is same as C matrix but with -1 on cond column for the trials to be masked out and different cat and word numbering. see Detail 
%    for the rest of the trials it provides new label for category and word exemplers.
%    NOTE: transformIDMtoMPSC gives Mpsc and C from detrend file.   info.word  gives wordLabels. catLabels has to be mapped form info.cond
% 
%  Output: newMpsc - new Mpsc after applying newC
%          newC    - new C matrix.
%          ind_slctdtrls  - index to the trials selected for classification
%  Some detail about newC Matrix
%  should have 5 exampler in each categories.
%  condition should start from 2 and should be continuous 
%  (cond-2)*nofExempler + exempler should be continuous starting from 1.


%  ver 1.0
%  Nov 6 2008

% check if inputs are usable.


if( ~isequal(  size(C) ,size(newC) )) error('Error: size of C matrix mismatch'); 
end
if( size(Mpsc,1) ~= size(C,1)) error('Error: Mpsc and C matrix does not match');
end

% Now lets drop the trials with -1 in cond column of newC
ind_slctdtrls = find(newC(:,1) ~= -1);  
newC = newC(ind_slctdtrls,:);

% check newC  
% should have 5 exampler in each categories.
% condition should start from 2 and should be continuous 
% (cond-2)*nofExempler + exempler should be continuous starting from 1.

NewAllWordLables = (newC(:,1)-2)*length(unique(newC(:,2)))+newC(:,2);
if(~isequal(unique(NewAllWordLables), [1:length(unique(NewAllWordLables))]'))
error('Error: newC matrix is not valid');
end

newMpsc = Mpsc(ind_slctdtrls,:);

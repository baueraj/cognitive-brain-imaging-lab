function [Selected_Ind,XYZout] = ccbiMaskXYZ(XYZin, maskname , doMaskOut, pathToMaskDir)
%  maskIDM creates a subset of XYZin (voxel space [ 3.125, 3.125 , 6 mm voxel size]) coordinates using given mask.
%
%  function  [Selected_Ind,XYZout] = ccbiMaskXYZ(XYZin, maskXYZmatfile, doMaskOut, pathToMaskDir) 
%  
%  Input: 
%  XYZin is a #voxelsX3 matrix of XYZ coordiantes in voxels space 
%
%  maksXYZmatfile is a file with variable 'maskXYZ' which is a mask of voxels
  %      in  voxel space coordinate system. [ 3.125, 3.125 , 6 mm voxel size] 
%      maskXYZmatfiles for common lobes are availabe in LAB/software/ccbi/templates/mask336/mask 
%  doMaskOut [ default 0] is an optional parameter. If 1, result excludes voxels
%      in the given mask, else result includes voxels only from  the given mask.%  pathToMaskDir is optional directory where the masks are. If no masks from default directory are used. 
%
%  Output:
%  Selected_Ind is the index vecter of the voxels selected from original XYZin. 
%       It may be useful to map the voxels from resulting XYZ coordinates to the original XYZ coordinates.
%  XYZout,(optional) resulting subset of XYZin after mask operation.
%   
%  This function is supposed to be  used by WSA_scripts and BetweenSubjs Scripts to do 
%  lobewise classification.
% maskname - (currently) either of Fusiform Anterior Parietal
  
if nargin < 2
    error('At least two input arguments required.');
end
%keyboard
if(~exist('pathToMaskDir'))
maskXYZmatfile = ['../software/ccbi/templates/mask336/mask' maskname '.mat'];
   else
maskXYZmatfile = [pathToMaskDir '/mask' maskname '.mat'];
end 
if ~exist(maskXYZmatfile)
  error(sprintf('%s does not exist',maskXYZmatfile));
end

% maskout the unwanted voxels
load(maskXYZmatfile);
if(~exist('maskXYZ')| size(maskXYZ,2)~=3 )
error(sprintf('%s does not have variable named  maskXYZ or maskXYZ is not in NX3 format.',maskXYZmatfile));
end

maskedVoxels = ismember(XYZin,maskXYZ,'rows');
if (exist('doMaskOut','var') && doMaskOut ==1)
Selected_Ind = (find(~maskedVoxels))'; %'
else 
Selected_Ind = (find(maskedVoxels))'; %'
end 
if(nargout ==2)
XYZout =XYZin(Selected_Ind,:);
end

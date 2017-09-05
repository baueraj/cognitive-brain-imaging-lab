%%    Andrew Bauer
%     brainImagingLabSpring2014

%     modify ***ONLY*** the contents of this .m file
%     modifying ***any other files*** could result in your code not working




%% (1)Where are the voxels being selected from? Type in the ID number
%     directly after "voxelsID = " 
%
%     But first, determine which ID number goes with which set of voxels:

%     only frontal lobe ID = 1
%     only temporal lobe ID = 2
%     only parietal lobe ID = 3
%     only occipital lobe ID = 4
%     all lobes except occipital lobe ID = 5

%     NOTE: every lobe refers to both right and left lobes combined

voxelsID = 4




%% (2)How many voxels? Type the number in directly after "noVoxels = "

noVoxels = 70




%% (3)SAVE THIS FILE AFTER YOU CHOOSE (1) & (2) ABOVE! 
%     Now you are ready to run the classification analysis. Type (without
%     the quotes) "do_classify" into the MATLAB command prompt and then press
%     the enter key. Wait a little for it to run (it will display fold
%     accuracies/etc. on the screen); then, when it is done, your screen will
%     show the mean classification accuracies for all the object categories
%     individually and combined, as well as the parameters that you chose
%     (steps (1) & (2) above)

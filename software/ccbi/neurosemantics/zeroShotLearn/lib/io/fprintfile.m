% fprintfile(logfile, ttyAlso?, printCommand, remainingArguments)
%
% Just like fprintf, but output is appended to logfile.  If ttyAlso?=1,
% then output is also sent to terminal screen.  To send ONLY to the
% terminal screen, set logfile=1.  (not a string in this case).
%
% Example:  print message to both 'foo.txt' and terminal screen.
%  fprintfile('foo.txt',1,'the accuracy is either %d or %f\n', 100, 0)
%
% History - March 24, 2003 -tm - created
% May 5, 2005 - tm - added feature so you can set logfile=1 to avoid
%         writing to file.  (useful if you want to print to tty, but
%         toggle on and off the writing to files
%

function [] = fprintfile(varargin)
  l = length(varargin);
  if l < 3
    fprintf('syntax: fprintfile(logFile, ttyAlso?, printCommand, printArgs)\n');
    return;
  else
    logfile = varargin{1};
    ttyAlso = varargin{2};
    printCommand = varargin{3};
  end
  
  if ttyAlso 
    fprintf(printCommand, varargin{4:end});
  end
  if (logfile ~= 1)
    fid = fopen(logfile,'a');
    fprintf(fid,printCommand, varargin{4:end});
    fclose(fid);
  end
  

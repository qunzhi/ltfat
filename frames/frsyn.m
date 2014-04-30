function outsig=frsyn(F,insig);
%FRSYN  Frame synthesis operator
%   Usage: f=frsyn(F,c);
%
%   `f=frsyn(F,c)` constructs a signal *f* from the frame coefficients *c*
%   using the frame *F*. The frame object *F* must have been created using
%   |frame|.
%
%   See also: frame, frana, plotframe
  
complainif_notenoughargs(nargin,2,'FRSYN');
complainif_notvalidframeobj(F,'FRSYN');

L=framelengthcoef(F,size(insig,1));

F=frameaccel(F,L);

outsig=F.frsyn(insig);


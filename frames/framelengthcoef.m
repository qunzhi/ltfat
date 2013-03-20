function L=framelengthcoef(F,Ncoef);
%FRAMELENGTHCOEF  Frame length from coefficients
%   Usage: L=framelengthcoef(F,Ncoef);
%
%   `framelengthcoef(F,Ncoef)` returns the length of the frame *F*, such that
%   *F* is long enough to expand the coefficients of length *Ncoef*.
%
%   If instead a signal is given, call |framelength|.
%
%   See also: frame, framelength
  
if nargin<2
  error('%s: Too few input parameters.',upper(mfilename));
end;

if ~isscalar(Ncoef)
  error('%s: Ncoef must be a scalar.',upper(mfilename));
end;

switch(F.type)
  case 'dgt'
    L=Ncoef/F.M*F.a;
  case 'dgtreal'
    L=Ncoef/(floor(F.M/2)+1)*F.a;
  case {'filterbank','ufilterbank','ufilterbank','ufilterbankreal'}
    L=round(Ncoef/sum(1./F.a));
  case {'nsdgt','unsdgt','nsdgtreal','unsdgtreal'}
    L=sum(F.a);
  otherwise
    L=Ncoef/framered(F);
end;

% Verify the computed length
if ~(L==framelength(F,L))
  error(['%s: The coefficient number given does not correspond to a valid ' ...
         'set of coefficients for this type of frame.'],upper(mfilename));
    
end;
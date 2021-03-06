function g=pchirp(L,n)
%PCHIRP  Periodic chirp
%   Usage:  g=pchirp(L,n);
%
%   `pchirp(L,n)` returns a periodic, discrete chirp of length *L* that
%   revolves *n* times around the time-frequency plane in frequency. *n* must be
%   an integer number.
%
%   To get a chirp that revolves around the time-frequency plane in time,
%   use ::
%
%     dft(pchirp(L,N));  
%
%   The chirp is computed by:
%   
%   ..  g(l+1) = exp(pi*i*n*(l-ceil(L/2))^2*(L+1)/L) for l=0,...,L-1
%
%   .. math:: g\left(l+1\right)=e^{\pi in(l-\lceil L/2\rceil)^{2}(L+1)/L},\quad l=0,\ldots,L-1
%
%   The chirp has absolute value 1 everywhere. To get a chirp with unit
%   $l^2$-norm, divide the chirp by $\sqrt L$.
%
%   Examples:
%   ---------
%
%   A spectrogram on a linear scale of an even length chirp:::
%
%     sgram(pchirp(40,2),'lin');
%
%   The DFT of the same chirp, now revolving around in time:::
%
%     sgram(dft(pchirp(40,2)),'lin');
%
%   An odd-length chirp. Notice that the chirp starts at a frequency between
%   two sampling points:::
%
%     sgram(pchirp(41,2),'lin');
%   
%   See also: dft, expwave
%
%   References: feichtinger2008metaplectic

%   AUTHOR : Peter L. Søndergaard
%   TESTING: OK
%   REFERENCE: OK

error(nargchk(2,2,nargin));

if ~isnumeric(L) || ~isscalar(L)
  error('%s: L must be a scalar',upper(mfilename));
end;

if ~isnumeric(n) || ~isscalar(n)
  error('%s: n must be a scalar',upper(mfilename));
end;

if rem(L,1)~=0
  error('%s: L must be an integer',upper(mfilename));
end;

if rem(n,1)~=0
  error('%s: n must be an integer',upper(mfilename));
end;

g=comp_pchirp(L,n);

function demo_effects(source,varargin)
%DEMO_BLOCKPROC_PITCHSHIFT Pitch shift by Gabor coefficient bands shift
%   Usage: demo_blockproc_pitchshift('gspi.wav')
%
%   For additional help call |demo_blockproc_pitchshift| without arguments.
%
%   This script demonstrates a real-time Gabor coefficient manipulation.
%   Frequency bands are shifted up or down according to the slider
%   position.
%

if demo_blockproc_header(mfilename,nargin)
   return;
end



fobj = blockfigure();



% Common block setup
bufLen = 1024;


% Morphing params
Fmorph = frametight(framepair('dgtreal',{'hann',882},'dual',128,1024,'timeinv'));
Fmorph = blockframeaccel(Fmorph, bufLen,'segola');

ff = wavread('violin_m.wav');
%ff = 0.8*resample(ff,4,1);
ffblocks = reshape(postpad(ff,ceil(numel(ff)/bufLen)*bufLen),bufLen,[]);
cidx = 1;


% Plain analysis params
Fana = frame('dgtreal',{'hann',882},300,3000);
Fana = blockframeaccel(Fana, bufLen,'segola');

% Robotization params
Mrob = 2^12;
Frob = frametight(frame('dgtreal',{'hann',Mrob},Mrob/8,Mrob,'timeinv'));
Frob = blockframeaccel(Frob, bufLen,'segola');

% Whisperization params
Mwhis = 512;
Fwhis = frametight(frame('dgtreal',{'hann',512},128,Mwhis,'timeinv'));
Fwhis = blockframeaccel(Fwhis, bufLen,'segola');

% Pitch shift

% Window length in ms
M = 1024;
a = 128;
[F,Fdual] = framepair('dgtreal',{'hann',882},'dual',a,M);
[Fa,Fs] = blockframepairaccel(F,Fdual, bufLen,'segola');

Mhalf = floor(M/2) + 1;
scale = (0:Mhalf-1)/Mhalf;
scale = scale(:);

shiftRange = 12;

scaleTable = round(scale*2.^(-(1:shiftRange)/12)*Mhalf)+1;
scaleTable2 = round(scale*2.^((1:shiftRange)/12)*Mhalf)+1;
scaleTable2(scaleTable2>Mhalf) = Mhalf;
fola = 0;


% Basic Control pannel (Java object)
parg = {
        {'GdB','Gain',-20,20,0,21},...
        {'Eff','Effect',0,4,0,5},...
        {'Shi','Shift',-shiftRange,shiftRange,0,2*shiftRange+1}
       };

p = blockpanel(parg);

% Setup blocktream
fs=block(source,varargin{:},'loadind',p,'L',bufLen);

p.setVisibleParam('Shi',0);


oldEffect = 0;
flag = 1;
ffola = [];
%Loop until end of the stream (flag) and until panel is opened
while flag && p.flag
   gain = blockpanelget(p,'GdB');
   gain = 10.^(gain/20);
   effect = blockpanelget(p,'Eff');
   shift = fix(blockpanelget(p,'Shi'));
   
   effectChanged = 0;
   if oldEffect ~= effect
       effectChanged = 1;
   end
   oldEffect = effect;
       
   

   % Read block of data
   [f,flag] = blockread();

   % Apply gain
   f=f*gain;
   if effect ==0
       % Just plot spectrogram
       if effectChanged
          % Flush overlaps used in blockana and blocksyn
          block_interface('flushBuffers');
          p.setVisibleParam('Shi',0);
          % Now we can merrily continue
       end
       % Obtain DGT coefficients
       c = blockana(Fana, f);
       blockplot(fobj,Fana,c(:,1));
       
       fhat = f;
   elseif effect == 1
   % Robotization
   if effectChanged
       % Flush overlaps used in blockana and blocksyn
       block_interface('flushBuffers');
       p.setVisibleParam('Shi',0);
       % Now we can merrily continue
   end
   
   % Obtain DGT coefficients
   c = blockana(Frob, f);
   
   % Do the actual coefficient shift
   cc = Frob.coef2native(c,size(c));
   
   if(strcmpi(source,'playrec'))
      % Hum removal (aka low-pass filter)
      cc(1:2,:,:) = 0;
   end
   
   c = Frob.native2coef(cc);
   
   c = abs(c);
   
   % Plot the transposed coefficients
   blockplot(fobj,Frob,c(:,1));
   
   % Reconstruct from the modified coefficients
   fhat = blocksyn(Frob, c, size(f,1));
   
   elseif effect == 2
       % Whisperization
   if effectChanged
       % Flush overlaps used in blockana and blocksyn
       block_interface('flushBuffers');
       p.setVisibleParam('Shi',0);
       % Now we can merrily continue
   end

    c = blockana(Fwhis, f);
   
    % Do the actual coefficient shift
    cc = Fwhis.coef2native(c,size(c));
   
    if(strcmpi(source,'playrec'))
      % Hum removal (aka low-pass filter)
      cc(1:2,:,:) = 0;
    end
   
    c = Fwhis.native2coef(cc);
   
    c = abs(c).*exp(i*2*pi*randn(size(c)));
  
   
    % Plot the transposed coefficients
    blockplot(fobj,Fwhis,c(:,1));
   
    % Reconstruct from the modified coefficients
    fhat = blocksyn(Fwhis, c, size(f,1));
   elseif effect == 3
   if effectChanged
       % Flush overlaps used in blockana and blocksyn
       block_interface('flushBuffers');
       p.setVisibleParam('Shi',1);
       % Now we can merrily continue
   end
       

          % Obtain DGT coefficients
   c = blockana(Fa, f);
   
   % Do the actual coefficient shift
   cc = Fa.coef2native(c,size(c));
  
   

       cTmp = zeros(size(cc),class(c));
    if shift<0
       cTmp(scaleTable(:,-shift),:,:) =... 
       cc(1:numel(scaleTable(:,-shift)),:,:);
    elseif shift>0
       cTmp(scaleTable2(:,shift),:,:) =... 
       cc(1:numel(scaleTable2(:,shift)),:,:);
       %cc = [zeros(shift,size(cc,2),size(cc,3))];
    else
        cTmp = cc;
    end
   
   c = Fa.native2coef(cTmp);
 
   
   % Reconstruct from the modified coefficients
   fhat = blocksyn(Fs, c, size(f,1));
   
   [c2,fola] = blockana(Fa,fhat,fola);
   
   % Plot the transposed coefficients
   blockplot(fobj,Fa,c2(:,1));
   
   elseif effect == 4
       [cff,ffola] = blockana(Fmorph, ffblocks(:,cidx), ffola);
       cidx = mod(cidx+1,size(ffblocks,2)-10) + 1;
        % Obtain DGT coefficients
        c = blockana(Fmorph, f);
   
        if(strcmpi(source,'playrec'))
            cc = Fmorph.coef2native(c,size(c));
    
            % Hum removal (aka low-pass filter)
            cc(1:2,:,:) = 0;
   
            c = Fmorph.native2coef(cc);
        end
   

       c = (abs(c)).*exp(i*(angle(cff)+angle(c)));

   
        % Plot the transposed coefficients
        blockplot(fobj,Fmorph,c(:,1));
   
        % Reconstruct from the modified coefficients
        fhat = blocksyn(Fmorph, c, size(f,1)); 
   
   end

   % Enqueue to be played
   blockplay(fhat);
   blockwrite(fhat);
end
% Clear and close all
blockdone(p,fobj);

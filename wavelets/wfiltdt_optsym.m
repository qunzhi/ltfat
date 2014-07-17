function [h,g,a,info] = wfiltdt_optsym(N)
%WFILT_OPTSYM  Optimizatized Symmetric Self-Hilbertian Filters 
%
%   Usage: [h,g,a] = wfiltdt_optsym(N);
%
%   `[h,g,a]=wfilt_wfiltdt_optsym(N)` with *N\in {1,2,3}*. 
%
%   Examples:
%   ---------
%   :::
%     figure(1);
%     wfiltinfo('optsym3');
% 
%   References: dubase08
%

info.istight = 1;
a = [2;2];

switch(N)
 case 1
    hlp = [
        -0.0023380687
         0.0327804569
        -0.0025090221
        -0.1187657989
         0.2327030100
         0.7845762950
         0.5558782330
         0.0139812814
        -0.0766273710
        -0.0054654533
         0
         0         
    ];
case 2
    % 
    hlp = [
         0.0001598067
         0.0000007274
         0.0235678740
         0.0015148138
        -0.0931304005
         0.2161894746
         0.7761070855
         0.5778162235
         0.0004024156
        -0.0884144581 
        0
        0
        0
        0
    ];

case 3
    hlp = [
         0.0017293259
        -0.0010305604
        -0.0128374477
         0.0018813576
         0.0359457035
        -0.0395271550
        -0.1048144141
         0.2663807401
         0.7636351894
         0.5651724402
         0.0101286691
        -0.1081211791
         0.0133197551
         0.0223511379
         0
         0
         0
         0
    ];

  otherwise
        error('%s: No such filters.',upper(mfilename)); 

end
    % numel(hlp) must be even
    offset = -(floor(numel(hlp)/2)); 
    range = (0:numel(hlp)-1) + offset;
    
    % Create the filters according to the reference paper.
    %
    % REMARK: The phase of the alternating +1 and -1 is crucial here.
    %         
    harr = [...
            hlp,...
            (-1).^(range).'.*flipud(hlp),...
            flipud(hlp),...
            (-1).^(range).'.*hlp,...
            ];
        

htmp=mat2cell(harr,size(harr,1),ones(1,size(harr,2)));

h(1:2,1) = cellfun(@(hEl)struct('h',hEl,'offset',offset),htmp(1:2),...
                   'UniformOutput',0);
h(1:2,2) = cellfun(@(hEl)struct('h',hEl,'offset',offset),htmp(3:4),...
                   'UniformOutput',0);
               
g = h;

% Default first and leaf filters
% They are chosen to be orthonormal near-symmetric here in order not to
% break the orthonormality of the overal representation.
[info.defaultfirst, info.defaultfirstinfo] = fwtinit('symorth1');
[info.defaultleaf, info.defaultleafinfo] = ...
    deal(info.defaultfirst,info.defaultfirstinfo);


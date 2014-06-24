function [P,AX,H] = PlotSnowpitProfile4(p,type)

% plot a snowpit profile from SnowPitLAB
% INPUT:
%       snowpit profile data from SnowPitTemplate.xlsx format
% p =
%               Obs: 'Kelly, Scott'
%              Date: '01-Mar-2011 10:00:00'
%               Loc: 'Grand Mesa'
%               Pit: 13
%            Aspect: NW
%         Elevation: 10500
%        SlopeAngle: 20
%     Precipitation: 'S-1'
%          SkyCover: 'OVC'
%           AirTemp: -3
%              Wind: 'L SW'
%              UTME: 751106
%              UTMN: 4323521
%             notes: 'So much fun!'
%             layer: [1x1 struct]
%             dprof: [1x1 struct]
%             Tprof: [1x1 struct]
%
% p.layer =
%            top: [131 127 126 114 81 19 10]
%            bot: [127 126 114 81 19 10 0]
%     grainsize1: [1 1 1 2 1 1 5]
%     grainsize2: [1 1 1 3 1 1 4]
%     grainsize3: [1 1 1 2 1 1 4]
%     graintype1: {1x7 cell}
%     graintype2: {1x7 cell}
%     graintype3: {1x7 cell}
%       hardness: [1 1 1 2.5000 1 1 4.5000]
%          notes: {1x7 cell}
%
% p.dprof =
%       top: [131 121 111 101 91 81 71 61 51 41 31 21 11]
%       bot: [121 111 101 91 81 71 61 51 41 31 21 11 1]
%       rho: [13x2 double]
%
% p.Tprof =
%       depth: [1x14 double]
%       temp: [-1 -3 -4 -4 -4 -3 -3 -2 -2 -2 -1 -1 0 0]
%
%        type = ['hdtgrn'] string used to determine what to plot:
%               h = hardness profile
%               d = density profile
%               t = temperature profile
%               g = grain type
%               r = grain size
%               l = labeled layers
%        
% OUTPUT:       P = updated structure array with snow pit data
%              AX = handles to 3 axes (hardness,density,temperature)
%               H  = handles to each plot object

% 20110419 SCH update to plot from data entered in SnowPitTemplate.xlsx
% format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the layer data
if isfield(p,'layer')
    layer = p.layer; % get the layer data
else
    display('No layer information included in data')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set a few parameters first
hs = -0.5; % hardness starting point
dyax=0.1; % offset for 2 LH axes
maxy = layer.top(1); %starting point for top

% HARDNESS
figure(1); clf
if ismember('h',type) % if hardness plot
    AX(1) = gca;
    
    for n = 1:length(layer.top)
        
        hold on
        % create boundaries for hardness profile boxes
        x = [hs,layer.hardness(n),layer.hardness(n),hs,hs];
        y = [layer.top(n),layer.top(n),layer.bot(n),layer.bot(n),layer.top(n)];
        H{n} = fill(x,y,[0.7 0.7 0.7]);
        
    end
    %     end
    maxy = max(layer.top); %get the max height of the plot
    maxx{1} = max(layer.hardness); %get the max width of the plot
    hn = n+1;
    
else
    AX(1) = 0;
    hn = 1;
end

%%% DENSITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ismember('d',type)  % if density plot
    
     % check to see if density is loaded
    if isfield(p,'dprof')
        if isempty(p.dprof)
            error('No density data loaded')
        end
    else
        error('No density data loaded')
    end
    
    if AX ~= 0 %already hardness plot
        axpos{1} = get(AX(1),'Position'); %hardness axis position
        axpos{2} = axpos{1};
        axpos{2}(2) = axpos{1}(2)+dyax; % move density axis up by dyax
        axpos{2}(4) = axpos{1}(4)-dyax; % make the tops coincide (shorten this one)
        AX(2) = axes('Position',axpos{2},...
            'XAxisLocation','bottom',...
            'YAxisLocation','left',...
            'Color','none',...
            'XColor','b','YColor','k');
    else
        %     if isempty(AX) %no hardness plot
        AX(2) = gca;
        axpos{2} = get(AX(2),'Position');
    end
    hold on
    if isfield(p,'dprof')
        dprof=p.dprof; % get the density data
    else
        display('No density data included')
    end
    
    % calculate density stats
    mean_rho = nanmean(dprof.rho,2); % calculate mean value of each entry
    rL = mean_rho - nanmin(dprof.rho,[],2);
    rR = nanmax(dprof.rho,[],2) - mean_rho;
    mean_depth = nanmean([dprof.top(:) dprof.bot(:)],2); % mean depth
    dU = dprof.top(:) - mean_depth; % lower bound for error
    dL = mean_depth - dprof.bot(:); % upper error bound
    
    % plot densities and error bounds
    axes(AX(2))
    %     if ismember('hd',type) %both hardness and density
    %         H{hn} = errorbar(mean_rho,(axpos{1}(4)/axpos{2}(4))*mean_depth,dL,dU,'bo-');% plot mean density
    %         hold on
    %         H{hn+1} = herrorbar(mean_rho,(axpos{1}(4)/axpos{2}(4))*mean_depth,rL,rR,'bo-');% plot density range
    %     else
    H{hn} = errorbar(mean_rho,mean_depth,dL,dU,'bo-');% plot mean density
    hold on
    H{hn+1} = herrorbar(mean_rho,mean_depth,rL,rR,'bo-');% plot density range
    %     end
    set(H{hn},'LineWidth',1)
    set(H{hn+1},'LineWidth',1)
    
    maxy = max([maxy max(dprof.top)]); %top of plot max
    maxx{2} = max(mean_rho+rR); %right of plot max
    hn = hn+2;
    %     set(AX(2),'Color','none')
else
    AX(2) = 0;
    hn = 1;
end
%%%%%%%% TEMPERATURE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ismember('t',type)
    
     % check to see if temperature is loaded
    if isfield(p,'Tprof')
        if isempty(p.Tprof)
            error('No temperature data loaded')
        end
    else
        error('No temperature data loaded')
    end
    
    if AX(2) ~= 0 % if density, copy axis
        axpos{3} = axpos{2};
        AX(3) = axes('Position',axpos{3},...
            'XAxisLocation','top',...
            'YAxisLocation','left',...
            'Color','none',...
            'XColor','r','YColor','k');
    else
        if AX(1) ~= 0  % if hardness but no density
            axpos{1} = get(AX(1),'Position');
            axpos{3} = axpos{1};
            AX(3) = axes('Position',axpos{3},...
                'XAxisLocation','top',...
                'YAxisLocation','left',...
                'Color','none',...
                'XColor','r','YColor','k');
        else
            AX(3) = gca; % if neither density nor hardness
        end
    end
    
    hold on
    if isfield(p,'Tprof')
        Tprof=p.Tprof; % get the temperature data
    else
        display('No temperature data')
    end
    
    axes(AX(3))
    %     if ismember('ht',type)
    %         H{hn} = plot(Tprof.temp,(axpos{1}(4)/axpos{2}(4))*Tprof.depth,'ro-');
    %
    %     else
    H{hn} = plot(Tprof.temp,Tprof.depth,'ro-');
    %     end
    set(H{hn},'LineWidth',1)
    maxy = max([maxy max(Tprof.depth)]);
    maxx{3} = max(-(Tprof.temp));
    hn = hn+1;
else
    AX(3) = 0;
end

%%%%%%% NOW THAT ITS PLOTTED, LETS FIX AXES, AXIS, AND LINE UP DEPTHS
%%% first figure out which of 3 plots were made
% lets first find limits of plot:

% link the y axis, and set limits
% linkaxes(AX,'y')
% ylabel('Depth [cm]','Fontsize',12,'Fontweight','bold')
% set(AX,'Fontsize',12,'Fontweight','bold')

% line up depths
% if ismember('hd',type) % if both density and temperature, adjust hardness scale
%
%     %hardness
%     axes(AX(1))
%     axis([hs 5.33 -160*(axpos{1}(4)/axpos{2}(4)-1) maxy]);
%
%     axes(AX(2))
%     axis([0 maxx{2}+20 0 maxy])
%     if ismember('t',type)
%         axes(AX(3))
%         axis([-maxx{3}+0.5 0 0 maxy])
%     end
% end

for n=1:3
    if AX(n)
        %         set(AX(n),'YDir','reverse')
        %         set(AX(n),'YTick',(0:dy:maxy))
        %         set(AX(n),'YTickLabel',num2str((0:dy:maxy)'))
        set(AX(n),'FontSize',12,'Fontweight','bold')
        switch n
            case 1
                axes(AX(n));
                if ismember('hd',type)
                    axis([hs 5.33 -maxy*(axpos{1}(4)/axpos{2}(4)-1) maxy]);
                else
                    axis([hs 5.33 0 maxy])
                end
                set(AX(1),'XTick',[1 2 3 4 5],...
                    'XTickLabel',[{'F'},{'4-f'},{'1-f'},{'P'},{'K'}])
                xlabel('Hand Hardness','FontSize',11,'Fontweight','bold')
                %                 ylim([layer.bot(end)-5 layer.top(1)+5])
                %                 ylabel('depth [cm]')
            case 2
                axes(AX(n));
                axis([0 maxx{2}+20 0 maxy])
                %                 set(AX(2),'XTick',(50:50:550))
                %                 set(AX(2),'XTickLabel',num2str((50:50:550)'))
                xlabel('Density [kg/m^3]','FontSize',11,'Fontweight','bold')
                %                 ylim([layer.bot(end)-15 layer.top(1)+5])
                %                 ylabel('depth [cm]')
            case 3
                axes(AX(n));
                axis([-maxx{3}-0.5 0 0 maxy])
                %                 set(AX(3),'XTick',(-20:2:0))
                %                 set(AX(3),'XTickLabel',num2str((-20:2:0)'))
                xlabel('Temperature [deg C]','FontSize',11,'Fontweight','bold')
                %                 ylim([layer.bot(end)-15 layer.top(1)+5])
                %                 ylabel('depth [cm]')
        end
    end
end
ylabel('Depth [cm]','Fontsize',12,'Fontweight','bold')

if ismember('hd',type) %remove the hardness depths
    set(AX(1),'YTick',[],'YTickLabel',[]);
end

%set axis for grain type, size, and label
if AX(1) ~= 0
    ax = AX(1); %if hardness, set as current axis
elseif AX(2) ~= 0
    ax = AX(2);
elseif AX(3) ~= 0
    ax = AX(3);
else
    ax = gca;
end

if sum(ismember('rg',type))
    for n = 1:length(layer.top)
        mid = mean([layer.top(n) layer.bot(n)]);
        
        if ismember('r',type)
            size = [nanmin([layer.grainsize1(n) layer.grainsize2(n) layer.grainsize3(n)])...
                nanmax([layer.grainsize1(n) layer.grainsize2(n) layer.grainsize3(n)])];
            
            t = [num2str(size(1)) ' - ' num2str(size(2))];
        else
            t = [];
        end
        
        if ismember('g',type)
            
            if ~isnan(layer.graintype1{n})
                t = [t ' ' layer.graintype1{n}];
            end
            if ~isnan(layer.graintype2{n})
                t = [t ' ' layer.graintype2{n}];
            end
            if ~isnan(layer.graintype3{n})
                t = [t ' (' layer.graintype3{n} ')'];
            end
        end
        
        axes(ax)
        ht = text(-0.25,mid,t);
        set(ht,'FontSize',11,'FontWeight','bold')
    end
end



% %%%%%%% GRAIN SIZE
% if ismember('r',type)
%     for n = 1:length(layer.top)
%         mid = mean([layer.top(n) layer.bot(n)]);
%         size = [min([layer.grainsize1(n) layer.grainsize2(n) layer.grainsize3(n)])...
%             max([layer.grainsize1(n) layer.grainsize2(n) layer.grainsize3(n)])];
%         axes(AX(1))
%         ht = text(-0.25,mid,[num2str(size(1)) ' - ' num2str(size(2))]);
%         set(ht,'FontSize',11,'FontWeight','bold')
%     end
% end
% %%%%%% GRAIN TYPE
% if ismember('g',type)
%     for n = 1:length(layer.top)
%         mid = mean([layer.top(n) layer.bot(n)]);
%         axes(AX(1))
%         if ~isnan(layer.graintype1{n})
%             ht(1) = text(0.25,mid,layer.graintype1{n});
%         end
%         if ~isnan(layer.graintype2{n})
%             ht(2) = text(0.5,mid,layer.graintype2{n});
%         end
%         if ~isnan(layer.graintype3{n})
%             ht(3) = text(0.75,mid,['(' layer.graintype3{n} ')']);
%         end
%         set(ht,'FontSize',12,'FontWeight','bold')
%     end
% end


%%%%% LAYER LABEL
str='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
if ismember('l',type)
    axes(ax)
    for n = 1:length(layer.top)
        mid = mean([layer.top(n) layer.bot(n)]);
        ht = text(-0.4,mid,[str(n) ')']);
        set(ht,'FontSize',11,'FontWeight','bold','Color','w')
    end
end

% put axes in order
for n=1:3
    if AX(n)
        axes(AX(n))
    end
end

if ismember('n',type)
    % set up the spreadsheet
    progid = 'SGRID.SgCtrl.1';
    FONTS='Font';
    NCOL='LastCol';
    NROW='LastRow';
    LABEL=0;
    %%%
    htemp=subplot(3,1,3);
    set(htemp,'Units','pixels')
    gposition=get(htemp,'Position');
    delete(htemp);
    grid = actxcontrol(progid, gposition);
    set(grid,'Row',0,'Col',0,'Text','Layer');
    set(grid,'Row',1,'Col',0,'Text',' ');
    set(grid,'Row',0,'Col',1,'Text','Grain size');
    set(grid,'Row',1,'Col',1,'Text','[mm]');
    set(grid,'Row',0,'Col',2,'Text','Grain Type');
    set(grid,'Row',1,'Col',2,'Text','[Int]');
    set(grid,'Row',0,'Col',3,'Text','Notes');
    set(grid,'NColumns',4)
    % now fill in the values
    % fill in the spreadsheet with current values
    for n=1:length(layer.top)
        set(grid,'Row',n+1,'Col',0,'Text',str(n));
        set(grid,'Row',n+1,'Col',1,'Text',num2str(layer.grainsize(n)));
        set(grid,'Row',n+1,'Col',2,'Text',layer.graintype{n});
        set(grid,'Row',n+1,'Col',3,'Text',layer.notes{n});
    end
end



P=p;

function hh = herrorbar(x, y, l, u, symbol)
%HERRORBAR Horizontal Error bar plot.
%   HERRORBAR(X,Y,L,R) plots the graph of vector X vs. vector Y with
%   horizontal error bars specified by the vectors L and R. L and R contain the
%   left and right error ranges for each point in X. Each error bar
%   is L(i) + R(i) long and is drawn a distance of L(i) to the right and R(i)
%   to the right the points in (X,Y). The vectors X,Y,L and R must all be
%   the same length. If X,Y,L and R are matrices then each column
%   produces a separate line.
%
%   HERRORBAR(X,Y,E) or HERRORBAR(Y,E) plots X with error bars [X-E X+E].
%   HERRORBAR(...,'LineSpec') uses the color and linestyle specified by
%   the string 'LineSpec'. See PLOT for possibilities.
%
%   H = HERRORBAR(...) returns a vector of line handles.
%
%   Example:
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      herrorbar(x,y,e)
%   draws symmetric horizontal error bars of unit standard deviation.
%
%   This code is based on ERRORBAR provided in MATLAB.   
%
%   See also ERRORBAR

%   Jos van der Geest
%   email: jos@jasen.nl
%
%   File history:
%   August 2006 (Jos): I have taken back ownership. I like to thank Greg Aloe from
%   The MathWorks who originally introduced this piece of code to the
%   Matlab File Exchange. 
%   September 2003 (Greg Aloe): This code was originally provided by Jos
%   from the newsgroup comp.soft-sys.matlab:
%   http://newsreader.mathworks.com/WebX?50@118.fdnxaJz9btF^1@.eea3ff9
%   After unsuccessfully attempting to contact the orignal author, I
%   decided to take ownership so that others could benefit from finding it
%   on the MATLAB Central File Exchange.

if min(size(x))==1,
    npt = length(x);
    x = x(:);
    y = y(:);
    if nargin > 2,
        if ~isstr(l),
            l = l(:);
        end
        if nargin > 3
            if ~isstr(u)
                u = u(:);
            end
        end
    end
else
    [npt,n] = size(x);
end

if nargin == 3
    if ~isstr(l)
        u = l;
        symbol = '-';
    else
        symbol = l;
        l = y;
        u = y;
        y = x;
        [m,n] = size(y);
        x(:) = (1:npt)'*ones(1,n);;
    end
end

if nargin == 4
    if isstr(u),
        symbol = u;
        u = l;
    else
        symbol = '-';
    end
end

if nargin == 2
    l = y;
    u = y;
    y = x;
    [m,n] = size(y);
    x(:) = (1:npt)'*ones(1,n);;
    symbol = '-';
end

u = abs(u);
l = abs(l);

if isstr(x) | isstr(y) | isstr(u) | isstr(l)
    error('Arguments must be numeric.')
end

if ~isequal(size(x),size(y)) | ~isequal(size(x),size(l)) | ~isequal(size(x),size(u)),
    error('The sizes of X, Y, L and U must be the same.');
end

tee = (max(y(:))-min(y(:)))/100; % make tee .02 x-distance for error bars
% changed from errorbar.m
xl = x - l;
xr = x + u;
ytop = y + tee;
ybot = y - tee;
n = size(y,2);
% end change

% Plot graph and bars
hold_state = ishold;
cax = newplot;
next = lower(get(cax,'NextPlot'));

% build up nan-separated vector for bars
% changed from errorbar.m
xb = zeros(npt*9,n);
xb(1:9:end,:) = xl;
xb(2:9:end,:) = xl;
xb(3:9:end,:) = NaN;
xb(4:9:end,:) = xl;
xb(5:9:end,:) = xr;
xb(6:9:end,:) = NaN;
xb(7:9:end,:) = xr;
xb(8:9:end,:) = xr;
xb(9:9:end,:) = NaN;

yb = zeros(npt*9,n);
yb(1:9:end,:) = ytop;
yb(2:9:end,:) = ybot;
yb(3:9:end,:) = NaN;
yb(4:9:end,:) = y;
yb(5:9:end,:) = y;
yb(6:9:end,:) = NaN;
yb(7:9:end,:) = ytop;
yb(8:9:end,:) = ybot;
yb(9:9:end,:) = NaN;
% end change


[ls,col,mark,msg] = colstyle(symbol); if ~isempty(msg), error(msg); end
symbol = [ls mark col]; % Use marker only on data part
esymbol = ['-' col]; % Make sure bars are solid

h = plot(xb,yb,esymbol); hold on
h = [h;plot(x,y,symbol)];

if ~hold_state, hold off; end

if nargout>0, hh = h; end


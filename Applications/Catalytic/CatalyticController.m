classdef CatalyticController < handle
% This is Controller, a class to represent the 
% controller for the main window of the groundswell application.

properties
  fig=[];  % the figure
  isFileOpen=false;
  seqs = [];
  moviename = [];
  trx = [];
  annname = [];
  params = [];
  matname = [];
  savename = [];
  readframe = [];
  nframes = [];
  fid = [];
  timestamps=[];
  flipud=0;
  nflies=[];
  colors0
  colororder
  colors
  f
  seqi
  seq
  nselect
  selected
  motionobj
  plotpath
  nframesplot
  zoommode
  undolist
  needssaving
  bgthresh
  bgcolor
  doneseqs
  bgmed
  hswap
  editMode
  mainaxesaspectratio
  mainaxes
  plotpathmenu
  zoommenu
  nframesplotedit
  nr
  nc
  ncolors
  him
  hellipse
  hcenter
  hhead
  htail
  hleft
  hright
  htailmarker
  hpath
  frameslider
  connectpanel
  extendpanel
  autotrackpanel
  flippanel
  manytrackpanel
  addnewtrackpanel
  interpolatepanel
  deletepanel
  swappanel
  seqinfopanel
  frameinfopanel
  navigationpanel
  editpanel
  seekpanel
  displaypanel
  nexterrortypemenu
  correctbutton
  rightpanel_tags
  rightpanel_dright
  rightpanel_dtop
  bottom_tags
  bottom_dleft_from_image_right_edge
  printbutton
  undobutton
  gobutton
  nextbutton
  seekmenu
  flipimage_checkbox
  debugbutton
  playstopbutton
  axes_dtop
  axes_dslider
  axes_drightpanels
  swapfirstframebutton
  connectdoitbutton
  interpolatefirstframebutton
  interpolatedoitbutton
  extenddoitbutton
  autotrackdoitbutton
  autotracksettingsbutton
  flipdoitbutton
  manytrackdoitbutton
  manytracksettingsbutton
  addnewtrackdoitbutton
  swapdoitbutton
  editPopupMenu
  connectcancelbutton
  connectfirstflybutton
  extendcancelbutton
  extendfirstflybutton
  autotrackcancelbutton
  autotrackfirstframebutton
  showtrackingbutton
  flipcancelbutton
  flipfirstframebutton
  manytrackcancelbutton
  manytrackfirstframebutton
  manytrackshowtrackingbutton
  addnewtrackcancelbutton
  cancelinterpolatebutton
  deletedoitbutton
  deletecancelbutton
  renamecancelbutton
  backbutton
  sortbymenu
  previousbutton
  frameedit
  frameofseqtext
  suspframetext
  errnumbertext
  seqframestext
  seqfliestext
  seqtypetext
  seqsusptext
  zoomInButton
  zoomOutButton
  
  fileMenu
  fileMenuOpenItem
  fileMenuCloseItem
  fileMenuSaveItem
  fileMenuSaveAsItem
  fileMenuQuitItem
  
  swapfly
  swapfirstframe

  interpolatefirstframe
  interpolatefly
  hinterpolate
  
  flipfly
  flipframe 
  hflip
  
  extendFlySelected
  extendfirstframe
  autotrackframe
  manytrackframe
  connectfirstframe
  connectfirstfly
  
  ang_dist_wt
  maxjump
  lighterthanbg
  isplaying=false
  
  zoomingIn=false
  zoomingOut=false  
end  % properties

methods
  function self=CatalyticController()
    % create the figure, position all the widgets
    self.layout();
    
    % read inputs
    self.isFileOpen=false;
    self.seqs = [];
    self.moviename = [];
    self.trx = [];
    self.annname = [];
    self.params = [];
    self.matname = [];
    self.savename = [];
    didload = false;
    self.readframe = [];
    self.nframes = [];
    self.fid = [];
    self.timestamps=[];
    
    % initialize parameters
    self = initializeMainAxes(self);
    
    % initialize state
    self.flipud = 0;
    self.nflies = length(self.trx);
    [self.colors0,self.colororder,self.colors] = ...
      colorOrderFromNumberOfAnimals(self.nflies);
    
    %self = setSeq(self,[],true);
    self.f=[];
    self.seqi=[];
    self.seq=[];
    
    self.nselect = 0;
    self.selected = [];
    self.motionobj = [];
    self.plotpath = 'All Flies';
    self.nframesplot = 101;
    self.zoommode = 'sequence';
    self.undolist = {};
    self.needssaving = 0;
    
    self.bgthresh = 10;
    self.bgcolor = nan;
    
    % initialize data structures
    
    % initialize structure to hold seqs that are done
    if ~didload,
      self.doneseqs = [];
    end
    
    % initialize gui
    
    %initializeFrameSlider(self);
    %setFrameNumber(self);
    %self = plotFirstFrame(self);
    initializeDisplayPanel(self);
    setErrorTypes(self);
    %self.bgmed = reshape(self.bgmed,[self.nc,self.nr])';
    self.bgmed=[];
    initializeKeyPressFcns(self);
    
    storePanelPositions(self);
    
    % Update self structure
    self.hswap=[];
    self.editMode='';
    %guidata(hObject, self);
    
    % Update the enablement and visibility of the UI
    self.updateControlVisibilityAndEnablement();

    % Make the figure visible
    set(self.fig,'visible','on');

    % Do some hacking to set the minimum figure size to the current size
    set(self.fig,'units','pixels');
    pos=get(self.fig,'outerposition');
    set(self.fig,'units','characters');    
    sz=pos(3:4);
    drawnow('update');
    drawnow('expose');
    pause(0.01);  % have to do to get below to work.  Sigh.
    fpj=get(handle(self.fig),'JavaFrame');
    jw=fpj.fHG1Client.getWindow();
    if ~isempty(jw)
      jw.setMinimumSize(java.awt.Dimension(sz(1),sz(2)));
    end    
  end  % constructor
  

  
  %--------------------------------------------------------------------------
  function initializeKeyPressFcns(self)    
    h = findobj(self.fig,'KeyPressFcn','');
    set(h,'KeyPressFcn',get(self.fig,'KeyPressFcn'));
  end  % method
  
  
  
  %--------------------------------------------------------------------------
  function self = initializeMainAxes(self)
    self.mainaxesaspectratio = 1;
    c=get(self.mainaxes,'children');
    delete(c);
    %set(self.mainaxes,'xlim',[0.5 1024.5]);
    %set(self.mainaxes,'ylim',[0.5 1024.5]);
    set(self.mainaxes,'xtick',[]);
    set(self.mainaxes,'ytick',[]);
    set(self.mainaxes,'box','on');
    set(self.mainaxes,'layer','top');
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function initializeDisplayPanel(self)
    i = find(strcmpi(get(self.plotpathmenu,'string'),self.plotpath),1);
    set(self.plotpathmenu,'value',i);
    i = find(strcmpi(get(self.zoommenu,'string'),self.zoommode),1);
    set(self.zoommenu,'value',i);
    set(self.nframesplotedit,'string',num2str(self.nframesplot));
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function initializeFrameSlider(self)
    nFrames=self.nframes;
    if ~isempty(nFrames) ,
      set(self.frameslider,'max',nFrames,'min',1,'sliderstep',[1,20]/(nFrames-1));
    end
  end  % method
  
  
  
  
  
  
  %--------------------------------------------------------------------------
  function self = plotFirstFrame(self)
    mainaxes=self.mainaxes;
    axes(mainaxes);
    im = self.readframe(self.f);
    [self.nr,self.nc,self.ncolors] = size(im);
    self.him = image('parent',mainaxes,'cdata',im);
    set(self.fig,'colormap',gray(256));
    set(mainaxes,'clim',[min(im(:)) max(im(:))]);
    axis(mainaxes,'image');
    hold(mainaxes,'on');
    zoom(self.fig,'reset');
    
    self.hellipse = zeros(1,self.nflies);
    self.hcenter = self.hellipse;
    self.hhead = self.hellipse;
    self.htail = self.hellipse;
    self.hleft = self.hellipse;
    self.hright = self.hellipse;
    self.htailmarker = self.hellipse;
    self.hpath = self.hellipse;
    for fly = 1:self.nflies,
      [self.hellipse(fly),self.hcenter(fly),self.hhead(fly),...
        self.htail(fly),self.hleft(fly),self.hright(fly),...
        self.htailmarker(fly),self.hpath(fly)] = ...
        initFly(self,self.colors(fly,:),self.mainaxes);
      updateFlyPathVisible(self);
      fixUpdateFly(self,fly);
    end
    zoomInOnSeq(self);
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function [hellipse,hcenter,hhead,htail,hleft,hright,htailmarker,hpath] = initFly(self,color,ax)
    % hpath = plot(0,0,'.-','color',color,'hittest','off');
    hpath = line('parent',self.mainaxes,'xdata',0,'ydata',0,'linestyle','-','color',color,'hittest','off');
    %htailmarker = plot([0,0],[0,0],'-','color',color,'hittest','off');
    htailmarker = line('parent',self.mainaxes,'xdata',[0,0],'ydata',[0,0],'linestyle','-','color',color,'hittest','off');
    hellipse = ellipsedraw(ax,10,10,0,0,0);
    set(hellipse,'color',color,'linewidth',2);
    set(hellipse,'buttondownfcn',@(line,eventData)(self.ellipse_buttondown(line,eventData)));
    % hleft = plot(0,0,'o','markersize',6,'color',color,'markerfacecolor','w');
    hleft = line('parent',self.mainaxes,'xdata',0,'ydata',0,'marker','o','markersize',6,'color',color,'markerfacecolor','w');
    set(hleft,'buttondownfcn',@(line,eventData)(self.left_buttondown(line,eventData)));
    % hright = plot(0,0,'o','markersize',6,'color',color,'markerfacecolor','w');
    hright = line('parent',self.mainaxes,'xdata',0,'ydata',0,'marker','o','markersize',6,'color',color,'markerfacecolor','w');
    set(hright,'buttondownfcn',@(line,eventData)(self.right_buttondown(line,eventData)));
    % hhead = plot(0,0,'o','markersize',6,'color',color,'markerfacecolor','w');
    hhead = line('parent',self.mainaxes,'xdata',0,'ydata',0,'marker','o','markersize',6,'color',color,'markerfacecolor','w');
    set(hhead,'buttondownfcn',@(line,eventData)(self.head_buttondown(line,eventData)));
    % htail = plot(0,0,'o','markersize',6,'color',color,'markerfacecolor','w');
    htail = line('parent',self.mainaxes,'xdata',0,'ydata',0,'marker','o','markersize',6,'color',color,'markerfacecolor','w');
    set(htail,'buttondownfcn',@(line,eventData)(self.tail_buttondown(line,eventData)));
    % hcenter = plot(0,0,'o','markersize',6,'color',color,'markerfacecolor','w');
    hcenter = line('parent',self.mainaxes,'xdata',0,'ydata',0,'marker','o','markersize',6,'color',color,'markerfacecolor','w');
    set(hcenter,'buttondownfcn',@(line,eventData)(self.center_buttondown(line,eventData)));
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function tail_buttondown(self,hObject,eventdata)  %#ok
    
    fly = find(self.htail==hObject);
    if isempty(fly), return; end
    self.motionobj = {'tail',fly};
    % guidata(hObject,self);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function head_buttondown(self,hObject,eventdata)  %#ok
    
    fly = find(self.hhead==hObject);
    if isempty(fly), return; end
    self.motionobj = {'head',fly};
    % guidata(hObject,self);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function right_buttondown(self,hObject,eventdata)  %#ok
    
    fly = find(self.hright==hObject);
    if isempty(fly), return; end
    self.motionobj = {'right',fly};
    % guidata(hObject,self);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function left_buttondown(self,hObject,eventdata)  %#ok
    
    fly = find(self.hleft==hObject);
    if isempty(fly), return; end
    self.motionobj = {'left',fly};
    % guidata(hObject,self);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function ellipse_buttondown(self,hObject,eventdata)  %#ok
    
    fly = find(self.hellipse==hObject,1);
    if isempty(fly), return; end
    
    %set(self.selectedflytext,'string',sprintf('Current Fly: %d',fly));
    
    % are we selecting flies?
    if self.nselect == 0, return; end;
    
    selectFlyInModelAndView(self,fly);
    % guidata(hObject,self);
    self.updateControlVisibilityAndEnablement();  % update the view
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function center_buttondown(self,hObject,eventdata)  %#ok
    
    fly = find(self.hcenter==hObject);
    if isempty(fly), return; end
    self.motionobj = {'center',fly};
    % guidata(hObject,self);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function move_center(self,fly)
    
    tmp = get(self.mainaxes,'CurrentPoint');
    
    % outside of the axis
    if tmp(1,3) ~= 1,
      return;
    end
    
    i = self.trx(fly).off+(self.f);
    self.trx(fly).x(i) = tmp(1,1);
    self.trx(fly).y(i) = tmp(1,2);
    fixUpdateFly(self,fly);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function move_head(self,fly)
    
    tmp = get(self.mainaxes,'CurrentPoint');
    % outside of the axis
    if tmp(1,3) ~= 1,
      return;
    end
    x1 = tmp(1,1);
    y1 = tmp(1,2);
    i = self.trx(fly).off+(self.f);
    
    x = self.trx(fly).x(i);
    y = self.trx(fly).y(i);
    a = 2*self.trx(fly).a(i);
    theta = self.trx(fly).theta(i);
    
    x2 = x - a*cos(theta);
    y2 = y - a*sin(theta);
    x = (x1+x2)/2;
    y = (y1+y2)/2;
    theta = atan2(y1-y2,x1-x2);
    a = sqrt( (x1-x)^2 + (y1-y)^2 )/2;
    
    self.trx(fly).x(i) = x;
    self.trx(fly).y(i) = y;
    self.trx(fly).a(i) = a;
    self.trx(fly).theta(i) = theta;
    
    fixUpdateFly(self,fly);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function move_left(self,fly)
    
    tmp = get(self.mainaxes,'CurrentPoint');
    % outside of the axis
    if tmp(1,3) ~= 1,
      return;
    end
    x3 = tmp(1,1);
    y3 = tmp(1,2);
    i = self.trx(fly).off+(self.f);
    
    x = self.trx(fly).x(i);
    y = self.trx(fly).y(i);
    %a = 2*self.trx(fly).a(i);
    b = 2*self.trx(fly).b(i);
    theta = self.trx(fly).theta(i);
    
    % compute the distance from this point to the major axis
    d = -sin(theta)*(x3 - x) + cos(theta)*(y3 - y);
    % compute projection onto minor axis
    x3 = x - d * sin(theta);
    y3 = y + d * cos(theta);
    
    x4 = x + b*cos(theta+pi/2);
    y4 = y + b*sin(theta+pi/2);
    
    x = (x3+x4)/2;
    y = (y3+y4)/2;
    b = sqrt((x3-x)^2 + (y3-y)^2)/2;
    
    self.trx(fly).x(i) = x;
    self.trx(fly).y(i) = y;
    self.trx(fly).b(i) = b;
    
    fixUpdateFly(self,fly);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function move_right(self,fly)
    
    tmp = get(self.mainaxes,'CurrentPoint');
    % outside of the axis
    if tmp(1,3) ~= 1,
      return;
    end
    x4 = tmp(1,1);
    y4 = tmp(1,2);
    i = self.trx(fly).off+(self.f);
    
    x = self.trx(fly).x(i);
    y = self.trx(fly).y(i);
    %a = 2*self.trx(fly).a(i);
    b = 2*self.trx(fly).b(i);
    theta = self.trx(fly).theta(i);
    
    % compute the distance from this point to the major axis
    d = -sin(theta)*(x4 - x) + cos(theta)*(y4 - y);
    % compute projection onto minor axis
    x4 = x - d * sin(theta);
    y4 = y + d * cos(theta);
    
    x3 = x - b*cos(theta+pi/2);
    y3 = y - b*sin(theta+pi/2);
    
    x = (x3+x4)/2;
    y = (y3+y4)/2;
    b = sqrt((x3-x)^2 + (y3-y)^2)/2;
    
    self.trx(fly).x(i) = x;
    self.trx(fly).y(i) = y;
    self.trx(fly).b(i) = b;
    
    fixUpdateFly(self,fly);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function move_tail(self,fly)
    
    tmp = get(self.mainaxes,'CurrentPoint');
    % outside of the axis
    if tmp(1,3) ~= 1,
      return;
    end
    x2 = tmp(1,1);
    y2 = tmp(1,2);
    i = self.trx(fly).off+(self.f);
    
    x = self.trx(fly).x(i);
    y = self.trx(fly).y(i);
    a = 2*self.trx(fly).a(i);
    theta = self.trx(fly).theta(i);
    
    x1 = x + a*cos(theta);
    y1 = y + a*sin(theta);
    x = (x1+x2)/2;
    y = (y1+y2)/2;
    theta = atan2(y1-y2,x1-x2);
    a = sqrt( (x1-x)^2 + (y1-y)^2 )/2;
    
    self.trx(fly).x(i) = x;
    self.trx(fly).y(i) = y;
    self.trx(fly).a(i) = a;
    self.trx(fly).theta(i) = theta;
    
    fixUpdateFly(self,fly);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  % --- Executes on slider movement.
  function framesliderTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to frameslider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    
    self.f = round(get(hObject,'value'));
    setFrameNumber(self,hObject);
    PlotFrame(self);
    % guidata(hObject,self);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  function frameeditTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to frameedit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of frameedit as text
    %        str2double(get(hObject,'String')) returns contents of frameedit as a double
    f = str2double(get(hObject,'String'));
    if isnan(f),
      set(hObject,'string',num2str(self.f));
      return;
    end
    self.f = round(f);
    self.f = max(f,1);
    self.f = min(f,self.nframes);
    if self.f ~= f,
      set(hObject,'string',num2str(self.f));
    end
    setFrameNumber(self,self.f);
    PlotFrame(self);
    % guidata(hObject,self);
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  % --- Executes on selection change in nexterrortypemenu.
  function nexterrortypemenuTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to nexterrortypemenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hints: contents = get(hObject,'String') returns nexterrortypemenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from nexterrortypemenu
    
  end  % method
  
  
  
  
  %--------------------------------------------------------------------------
  % --- Executes on selection change in sortbymenu.
  function sortbymenuTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to sortbymenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hints: contents = get(hObject,'String') returns sortbymenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from sortbymenu
  end  % method
  
  
  
  
  
  %--------------------------------------------------------------------------
  % --- Executes on button press in correctbutton.
  function correctbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to correctbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    oldPointer=self.pointerToWatch();
    
    % add to undolist
    self.undolist{end+1} = {'correct',self.seqi,self.seq};
    self.needssaving = 1;
    
    % move from seqs to doneseqs
    if isempty(self.doneseqs),
      self.doneseqs = self.seq;
    else
      self.doneseqs(end+1) = self.seq;
    end
    self.seqs(self.seqi).type = ['dummy', self.seqs(self.seqi).type];
    
    self.seqs = check_suspicious_sequences(self.trx,self.annname,self.seqs,self.params{:});
    
    setErrorTypes(self);
    
    % % quit if this is the last sequence
    % if strcmpi(get(self.correctbutton,'string'),'finish')
    %   msgbox('All suspicious sequences have been corrected. Quitting.','All Done');
    %   %savebuttonTwiddled(hObject, [], self);
    %   %uiresume(self.fig);
    %   return;
    % end
    
    try
      contents = get(self.nexterrortypemenu,'string');
      if length(contents) == 1,
        s = contents;
      else
        v = get(self.nexterrortypemenu,'value');
        if v > length(contents),
          set(self.nexterrortypemenu,'value',length(contents));
          v = length(contents);
        end
        s = contents{v};
      end
    catch
      keyboard;
    end
    
    % what is the next type of error
    type_list = nexterrortype_type();
    nexttype = type_list{strcmpi(type_list(:,1),s),2};
    flies = [];
    frames = [];
    susp = [];
    idx = [];
    
    % find an error of type nexttype
    for i = 1:length(self.seqs),
      
      % if this is the right type of error
      if strcmpi(self.seqs(i).type,nexttype),
        
        % store frames, flies, suspiciousness for this seq
        if strcmpi(nexttype,'swap'),
          flies(end+1) = self.seqs(i).flies(1)*self.nflies+self.seqs(i).flies(2);  %#ok
        else
          flies(end+1) = self.seqs(i).flies;  %#ok
        end
        frames(end+1) = self.seqs(i).frames(1);  %#ok
        susp(end+1) = max(self.seqs(i).suspiciousness);  %#ok
        idx(end+1) = i;  %#ok
        
      end
      
    end
    
    if isempty(flies), keyboard; end
    
    % choose error of this type if there are more than one
    contents = get(self.sortbymenu,'string');
    sortby = contents{get(self.sortbymenu,'value')};
    if strcmpi(sortby,'suspiciousness'),
      j = argmax(susp);
      setSeq(self,idx(j));
    elseif strcmpi(sortby,'frame number'),
      j = argmin(frames);
      setSeq(self,idx(j));
    elseif strcmpi(sortby,'fly'),
      if strcmpi(self.seq.type,'swap'),
        currfly = self.seq.flies(1)*self.nflies +self.seq.flies(2);
      else
        currfly = self.seq.flies;
      end
      issamefly = flies == currfly;
      if any(issamefly),
        nextfly = currfly;
      else
        nextfly = min(flies);
      end
      nextflies = find(flies == nextfly);
      j = nextflies(argmin(frames(nextflies)));
      setSeq(self,idx(j));
    end
    
    % guidata(hObject,self);
    
    self.updateControlVisibilityAndEnablement();
    
    restorePointer(self,oldPointer);
    
    %play(self);
  end  % method
  
  
  
  
  
  
  %--------------------------------------------------------------------------
  % --- Executes on button press in backbutton.
  function backbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to backbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    oldPointer=self.pointerToWatch();
    
    % find most recent "correct" action and skip back to previous sequence
    for ai = length( self.undolist ):-1:1
      if strcmp( self.undolist{ai}{1}, 'correct' )
        % put previously corrected sequence back into sequence list
        self.seqi = self.undolist{ai}{2};
        self.seq = self.undolist{ai}{3};
        self.needssaving = 1;
        self.seqs(self.seqi) = self.seq;
        % remove from undo list
        if ai == 1
          if length( self.undolist ) == 1
            self.undolist = {};
          else
            self.undolist = self.undolist{2:end};
          end
        elseif ai == length( self.undolist )
          self.undolist = self.undolist{1:end-1};
        else
          try % untested
            self.undolist = self.undolist{[1:ai-1 ai+1:length( self.undolist )]};
          catch err
            self.restorePointer(oldPointer);
            self.undolist
            ai  %#ok
            self.seq
            rethrow( err )
          end
        end
        % remove from doneseqs list
        if length( self.doneseqs ) == 1
          self.doneseqs = {};
        else
          for di = 1:length( self.doneseqs )
            if all( self.doneseqs(di).flies == self.seq.flies ) && ...
                strcmp( self.doneseqs(di).type, self.seq.type ) && ...
                length( self.doneseqs(di).frames ) == length( self.seq.frames ) && ...
                all( self.doneseqs(di).frames == self.seq.frames ) && ...
                length( self.doneseqs(di).suspiciousness ) == length( self.seq.suspiciousness ) && ...
                all( self.doneseqs(di).suspiciousness == self.seq.suspiciousness )
              % if this is the sequence we just undid...
              if di == 1
                self.doneseqs = self.doneseqs(2:end);
              elseif di == length( self.doneseqs )
                self.doneseqs = self.doneseqs(1:end-1);
              else
                try % untested
                  self.doneseqs = self.doneseqs([1:di-1 di+1:length( self.doneseqs )]);
                catch err
                  self.restorePointer(oldPointer);
                  self.doneseqs
                  di  %#ok
                  self.seq
                  rethrow( err )
                end
              end
              break
            end
          end
        end
        
        % update GUI to old sequence
        setSeq( self, self.seqi );
        setErrorTypes( self );
        % find type string matching sequence type
        type_list = nexterrortype_type;
        type_ind = nan;
        for ti = 1:size( type_list, 1 )
          if strcmpi( type_list{ti,2}, self.seq.type )
            type_ind = ti;
          end
        end
        if isnan( type_ind ), keyboard, end
        % find menu item matching type string
        content = get( self.nexterrortypemenu, 'string' );
        if ~iscell( content )
          content = {content};
        end
        for si = 1:length( content )
          if strcmpi( type_list{type_ind,1}, content{si} )
            set( self.nexterrortypemenu, 'value', si )
          end
        end
        % guidata( hObject, self );
        
        self.updateControlVisibilityAndEnablement();
        
        self.restorePointer(oldPointer);
        
        %play( self);
        break
      end % found a sequence in undo list that was marked 'correct'
    end % for each item in undo list
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % %--------------------------------------------------------------------------
  % % --- Executes on button press in savebutton.
  % method savebuttonTwiddled(self,hObject,eventdata)  %#ok
  % % hObject    handle to savebutton (see GCBO)
  % % eventdata  reserved - to be defined in a future version of MATLAB
  % % self    structure with self and user data (see GUIDATA)
  %
  % saveFile(self.fig);
  %
  %
  % % -------------------------------------------------------------------------
  % % --- Executes on button press in quitbutton.
  % method quitbuttonTwiddled(self,hObject,eventdata)  %#ok
  % % hObject    handle to quitbutton (see GCBO)
  % % eventdata  reserved - to be defined in a future version of MATLAB
  % % self    structure with self and user data (see GUIDATA)
  % quit(self.fig);
  
  
  % -------------------------------------------------------------------------
  % --- Executes on button press in undobutton.
  function undobuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to undobutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    oldPointer=self.pointerToWatch();
    
    top = length( self.undolist );
    if ~isempty( self.undolist ) && ~iscell( self.undolist{1} )
      % this happens when there's only one undo item
      % (length is length of that item, not the list)
      top = 1;
    end
    
    for ui = top:-1:1
      try
        a = strcmp( self.undolist{ui}{1}, 'delete' );  %#ok
      catch % happened once, not replicated
        keyboard
      end
      if strcmp( self.undolist{ui}{1}, 'delete' )
        %fprintf( 1, 'undoing deletion item %d\n', ui );
        %f = self.undolist{ui}{2};
        fly = self.undolist{ui}{3};
        trk = self.undolist{ui}{4};
        fly_seqs = self.undolist{ui}{5};
        
        if isdummytrk( self.trx(fly) )
          self.trx(fly) = trk;
          [self.hellipse(fly), self.hcenter(fly), self.hhead(fly),...
            self.htail(fly), self.hleft(fly), self.hright(fly),...
            self.htailmarker(fly), self.hpath(fly)] = ...
            initFly( self.colors(fly,:) );
          updateFlyPathVisible( self );
        else
          self.trx(fly) = catTracks( self.trx(fly), trk );
        end
        
        for si = fly_seqs
          assert( ~isempty( strfindi( self.seqs(si).type, 'dummy' ) ) );
          self.seqs(si).type = self.seqs(si).type(length( 'dummy' ) + 1:end);
        end
        
        fixUpdateFly( self, fly );
        fixBirthEvent( self, fly );
        fixDeathEvent( self, fly );
        
        break
      elseif strcmp( self.undolist{ui}{1}, 'swap' )
        %fprintf( 1, 'undoing swap item %d\n', ui );
        f1 = self.undolist{ui}{2}(1);
        f2= self.undolist{ui}{2}(2);
        fly1 = self.undolist{ui}{3}(1);
        fly2 = self.undolist{ui}{3}(2);
        swapIdentities( self, f1, f2, fly1, fly2 );
        
        setFlySelectedInView(self,fly1,false);
        setFlySelectedInView(self,fly2,false);
        
        break
      elseif strcmp( self.undolist{ui}{1}, 'interpolate' ) || ...
          strcmp( self.undolist{ui}{1}, 'autotrack' )
        %fprintf( 1, 'undoing interpolation/autotracking item %d\n', ui );
        if length( self.undolist{ui} ) == 4
          f0 = self.undolist{ui}{2}(1);
          f1 = self.undolist{ui}{2}(2);
          fly = self.undolist{ui}{3};
          trk = self.undolist{ui}{4};
          
          t0 = CatalyticController.getPartOfTrack( self.trx(fly), 1, f0 - 1 );
          t2 = CatalyticController.getPartOfTrack( self.trx(fly), f1 + 1, inf );
          self.trx(fly) = catTracks( catTracks( t0, trk ), t2 );
          
        else
          firstframe = self.undolist{ui}{2}(1);
          endframe = self.undolist{ui}{2}(2);
          fly = self.undolist{ui}{3};
          
          self.trx(fly) = CatalyticController.getPartOfTrack( self.trx(fly), firstframe, endframe );
          
          fixDeathEvent( self, fly );
        end
        
        fixUpdateFly( self, fly );
        
        break
      elseif strcmp( self.undolist{ui}{1}, 'connect' )
        %fprintf( 1, 'undoing connection item %d\n', ui );
        f1 = self.undolist{ui}{2}(1);
        f2 = self.undolist{ui}{2}(2);
        fly1 = self.undolist{ui}{3}(1);
        fly2 = self.undolist{ui}{3}(2);
        trk1 = self.undolist{ui}{4}(1);
        trk2 = self.undolist{ui}{4}(2);
        seqs_removed1 = self.undolist{ui}{5};
        seqs_removed2 = self.undolist{ui}{6};
        
        first_trk1 = CatalyticController.getPartOfTrack( self.trx(fly1), 1, f1 );
        last_trk2 = CatalyticController.getPartOfTrack( self.trx(fly1), f2, inf );
        
        self.trx(fly1) = catTracks( first_trk1, trk1 );
        fixUpdateFly( self, fly1 );
        fixDeathEvent( self, fly1 );
        for si = seqs_removed1
          assert( ~isempty( strfindi( self.seqs(si).type, 'dummy' ) ) );
          self.seqs(si).type = self.seqs(si).type(length( 'dummy' ) + 1:end);
        end
        
        self.trx(fly2) = catTracks( trk2, last_trk2 );
        [self.hellipse(fly2), self.hcenter(fly2), self.hhead(fly2), ...
          self.htail(fly2), self.hleft(fly2), self.hright(fly2), ...
          self.htailmarker(fly2), self.hpath(fly2)] = ...
          initFly( self.colors(fly2,:) );
        updateFlyPathVisible( self );
        fixUpdateFly( self, fly2 );
        fixBirthEvent( self, fly2 );
        fixDeathEvent( self, fly2 );
        for si = seqs_removed2
          assert( ~isempty( strfindi( self.seqs(si).type, 'dummy' ) ) );
          self.seqs(si).type = self.seqs(si).type(length( 'dummy' ) + 1:end);
        end
        
        break
      elseif strcmp( self.undolist{ui}{1}, 'flip' )
        %fprintf( 1, 'undoing flip item %d\n', ui );
        frame = self.undolist{ui}{2};
        f = self.undolist{ui}{3};
        fly = self.undolist{ui}{4};
        
        setFlySelectedInView(self,fly,false);
        for f = frame:f,
          i = self.trx(fly).off+(f);
          self.trx(fly).theta(i) = modrange(self.trx(fly).theta(i)+pi,-pi,pi);
        end
        fixUpdateFly(self,fly);
        
        break
      elseif strcmp( self.undolist{ui}{1}, 'manytrack' )
        %fprintf( 1, 'undoing manytrack item %d\n', ui );
        
        f0 = self.undolist{ui}{2}(1);
        f1 = self.undolist{ui}{2}(2);
        flies = self.undolist{ui}{3};
        oldtrx = self.undolist{ui}{4};
        
        for fi = 1:length( flies )
          fly = flies(fi);
          t0 = CatalyticController.getPartOfTrack( self.trx(fly), 1, f0 - 1 );
          t2 = CatalyticController.getPartOfTrack( self.trx(fly), f1 + 1, inf );
          self.trx(fly) = catTracks( catTracks( t0, oldtrx(fi) ), t2 );
        end
        
        for fly = flies
          fixUpdateFly( self, fly );
        end
        
        break
      elseif strcmp( self.undolist{ui}{1}, 'addnew' )
        %fprintf( 1, 'undoing addnewtrack item %d\n', ui );
        
        fly = self.undolist{ui}{2};
        
        DeleteFly( self, fly );
        %       setFlyVisible( self, fly, 'off' );
        %       updateFlyPathVisible( self );
        %
        %       self.trx(fly) = [];
        %       self.nflies = self.nflies - 1;
        %       self = setFlyColors(self);
        %       self.hellipse(fly) = [];
        %       self.hcenter(fly) = [];
        %       self.hhead(fly) = [];
        %       self.htail(fly) = [];
        %       self.hleft(fly) = [];
        %       self.hright(fly) = [];
        %       self.htailmarker(fly) = [];
        %       self.hpath(fly) = [];
        
        break
      elseif ~strcmp( self.undolist{ui}{1}, 'correct' )
        error( 'don''t know how to undo action ''%s'', item %d\n', self.undolist{ui}{1}, ui );
      end
    end
    
    % remove undone item from undo list
    if ui == 1
      if length( self.undolist ) == 1
        self.undolist = {};
      else
        self.undolist = self.undolist{2:end};
      end
    elseif ui == length( self.undolist )
      self.undolist(end) = [];
    elseif ui > 0
      try % untested
        self.undolist = self.undolist{[1:ui-1 ui+1:length( self.undolist )]};
      catch err
        keyboard
        self.undolist
        ui  %#ok
        self.seq
        rethrow( err )
      end
    end
    
    self.nselect = 0;
    self.selected = [];
    self.needssaving = 1;
    % guidata(hObject,self);
    self.updateControlVisibilityAndEnablement();
    self.PlotFrame();  % re-draw the current frame
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on button press in deletedoitbutton.
  function deletedoitbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to deletedoitbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if isempty( self.selected )|| self.selected == 0,
      errordlg('You must first select a fly track to delete. See Delete Track Instructions Panel',...
        'No Fly Selected');
      return;
    end
    
    oldPointer=self.pointerToWatch();
    
    fly = self.selected;
    if self.f <= self.trx(fly).firstframe,
      self.undolist{end+1} = {'delete',self.f,fly,...
        self.trx(fly)};
      DeleteFly(self,fly);
      % remove events involving this fly
      evts_removed = removeFlyEvent(self,fly,-inf,inf);
    else
      self.undolist{end+1} = {'delete',self.f,fly,...
        CatalyticController.getPartOfTrack(self.trx(fly),self.f,inf)};
      self.trx(fly) = CatalyticController.getPartOfTrack(self.trx(fly),1,self.f-1);
      % remove events involving this fly in the deleted interval
      evts_removed = removeFlyEvent(self,fly,self.f,inf);
      setFlySelectedInView(self,fly,false);
      fixUpdateFly(self,fly);
    end
    self.undolist{end}{end+1} = evts_removed;
    
    self.editMode='';
    self.nselect = 0;
    self.selected = [];
    self.needssaving = 1;
    CatalyticController.enablePanel(self.editpanel,'on');
    set(self.deletepanel,'visible','off');
    % guidata(hObject,self);
    self.updateControlVisibilityAndEnablement();
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on button press in deletecancelbutton.
  function deletecancelbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to deletecancelbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    currentEditModeCancelled(self)
  end  % method
  
  
  
  
  
  % --- Executes on button press in renamecancelbutton.
  function renamecancelbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to renamecancelbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    currentEditModeCancelled(self)
  end  % method
  
  
  
  
  
  % --- Executes on mouse press over axes background.
  function mainaxes_ButtonDownFcn(self,hObject,eventdata)  %#ok
    % hObject    handle to mainaxes (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
  end  % method
  
  
  
  
  
  % --- Executes on button press in debugbutton.
  function debugbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to debugbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    keyboard;
  end  % method
  
  
  
  
  
  % --- Executes on mouse motion over figure - except title and menu.
  function mouseMoved(self,hObject,eventdata)  %#ok
    % hObject    handle to fig (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if isempty(self.motionobj), return; end
    
    if strcmpi(self.motionobj{1},'center'),
      self.move_center(self.motionobj{2});
    elseif strcmpi(self.motionobj{1},'head'),
      self.move_head(self.motionobj{2});
    elseif strcmpi(self.motionobj{1},'tail'),
      self.move_tail(self.motionobj{2});
    elseif strcmpi(self.motionobj{1},'left'),
      self.move_left(self.motionobj{2});
    elseif strcmpi(self.motionobj{1},'right'),
      self.move_right(self.motionobj{2});
    end
    
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on mouse press over figure background, over a disabled or
  % --- inactive control, or over an axes background.
  function mouseButtonReleased(self,hObject,eventdata)  %#ok
    % hObject    handle to fig (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    self.motionobj = [];
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on selection change in editPopupMenu.
  function editPopupMenuTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to editPopupMenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hints: contents = get(hObject,'String') returns editPopupMenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from editPopupMenu
  end  % method
  
  
  
  
  
  % --- Executes on button press in gobutton.
  function gobuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to gobutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    oldPointer=pointerToWatch(self);
    
    % what are we doing?
    contents = get(self.editPopupMenu,'string');
    s = contents{get(self.editPopupMenu,'value')};
    self.editMode=s;
    CatalyticController.enablePanel(self.editpanel,'off');
    self.nselect = 1;
    self.selected = [];
    if strcmpi(s,'delete track...'),
      set(self.deletepanel,'visible','on');
    elseif strcmpi(s,'interpolate...'),
      set(self.interpolatepanel,'visible','on');
      self.interpolatefirstframe = -1;
      set(self.interpolatedoitbutton,'enable','off');
    elseif strcmpi(s,'connect tracks...'),
      set(self.connectpanel,'visible','on');
      self.connectfirstframe = -1;
      self.connectfirstfly = -1;
      set(self.connectdoitbutton,'enable','off');
    elseif strcmpi(s,'swap identities...')
      set(self.swapfirstframebutton,'string','First');
      % in case a previous swap was cancelled, leaving this button with text
      % like "First = <frame number>"
      set(self.swappanel,'visible','on');
      self.nselect = 2;
    elseif strcmpi(s,'extend track...'),
      set(self.extendpanel,'visible','on');
      self.extendfirstframe = -1;
      self.extendFlySelected=false;
      set(self.extenddoitbutton,'enable','off');
    elseif strcmpi(s,'auto-track...'),
      set(self.autotrackpanel,'visible','on');
      self.autotrackframe = -1;
      set(self.autotrackdoitbutton,'enable','off');
      set(self.autotracksettingsbutton,'enable','off');
    elseif strcmpi(s,'flip orientation...'),
      set(self.flippanel,'visible','on');
      self.flipframe = -1;
      set(self.flipdoitbutton,'enable','off');
    elseif strcmpi(s,'auto-track multiple...'),
      set(self.manytrackpanel,'visible','on');
      self.nselect = self.nflies;
      self.manytrackframe = -1;
      set(self.manytrackdoitbutton,'enable','off');
      set(self.manytracksettingsbutton,'enable','off');
    elseif strcmpi( s, 'add new track...' )
      set( self.addnewtrackpanel, 'visible', 'on' );
      set( self.addnewtrackdoitbutton, 'enable', 'on' );
    end
    % guidata(hObject,self);
    self.updateControlVisibilityAndEnablement();
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on selection change in seekmenu.
  function seekmenuTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to seekmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hints: contents = get(hObject,'String') returns seekmenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from seekmenu
  end  % method 
   
  
  
  % --- Executes on button press in previousbutton.
  function previousbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to previousbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    oldPointer=self.pointerToWatch();
    
    value = get(self.seekmenu,'value');
    contents = get(self.seekmenu,'string');
    s = contents{value};
    
    if strcmpi(s,'birth nearby'),
      
      nextnearbirth = -1;
      nextnearframe = -inf;
      xlim = get(self.mainaxes,'xlim');
      ylim = get(self.mainaxes,'ylim');
      for i = 1:length(self.seqs),
        if ~strcmpi(self.seqs(i).type,'birth'),
          continue;
        end
        f = self.seqs(i).frames;
        if f >= self.f,
          continue;
        end
        fly = self.seqs(i).flies;
        j = self.trx(fly).off+(f);
        x = self.trx(fly).x(j);
        y = self.trx(fly).y(j);
        if x >= xlim(1) && x <= xlim(2) && y >= ylim(1) && y <= ylim(2),
          if nextnearframe < f,
            nextnearbirth = i;
            nextnearframe = f;
          end
        end
      end
      
      if nextnearbirth == -1,
        self.restorePointer(oldPointer);
        msgbox('Sorry! There are no fly births in the current axes before the current frame.',...
          'Could Not Find Birth');
        return;
      end
      
      self.lastframe = self.f;
      self.f = nextnearframe;
      setFrameNumber(self,hObject);
      PlotFrame(self);
      
      % guidata(hObject,self);
      
    elseif strcmpi(s,'death nearby'),
      
      nextneardeath = -1;
      nextnearframe = -inf;
      xlim = get(self.mainaxes,'xlim');
      ylim = get(self.mainaxes,'ylim');
      for i = 1:length(self.seqs),
        if ~strcmpi(self.seqs(i).type,'death'),
          continue;
        end
        f = self.seqs(i).frames;
        if f >= self.f,
          continue;
        end
        fly = self.seqs(i).flies;
        j = self.trx(fly).off+(f);
        x = self.trx(fly).x(j);
        y = self.trx(fly).y(j);
        if x >= xlim(1) && x <= xlim(2) && y >= ylim(1) && y <= ylim(2),
          if nextnearframe < f,
            nextneardeath = i;
            nextnearframe = f;
          end
        end
      end
      
      if nextneardeath == -1,
        self.restorePointer(oldPointer);
        msgbox('Sorry! There are no fly deaths in the current axes before the current frame.',...
          'Could Not Find Death');
        return;
      end
      
      self.lastframe = self.f;
      self.f = nextnearframe;
      setFrameNumber(self,hObject);
      PlotFrame(self);
      
      % guidata(hObject,self);
      
    end
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on button press in nextbutton.
  function nextbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to nextbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    oldPointer=self.pointerToWatch();
    
    value = get(self.seekmenu,'value');
    contents = get(self.seekmenu,'string');
    s = contents{value};
    
    if strcmpi(s,'birth nearby'),
      
      nextnearbirth = -1;
      nextnearframe = inf;
      xlim = get(self.mainaxes,'xlim');
      ylim = get(self.mainaxes,'ylim');
      for i = 1:length(self.seqs),
        if ~strcmpi(self.seqs(i).type,'birth'),
          continue;
        end
        f = self.seqs(i).frames;
        if f <= self.f,
          continue;
        end
        fly = self.seqs(i).flies;
        j = self.trx(fly).off+(f);
        x = self.trx(fly).x(j);
        y = self.trx(fly).y(j);
        if x >= xlim(1) && x <= xlim(2) && y >= ylim(1) && y <= ylim(2),
          if nextnearframe > f,
            nextnearbirth = i;
            nextnearframe = f;
          end
        end
      end
      
      if nextnearbirth == -1,
        self.restorePointer(oldPointer);
        msgbox('Sorry! There are no fly births in the current axes after the current frame.',...
          'Could Not Find Birth');
        return;
      end
      
      self.lastframe = self.f;
      self.f = nextnearframe;
      setFrameNumber(self,hObject);
      PlotFrame(self);
      
      % guidata(hObject,self);
      
    elseif strcmpi(s,'death nearby'),
      
      nextneardeath = -1;
      nextnearframe = inf;
      xlim = get(self.mainaxes,'xlim');
      ylim = get(self.mainaxes,'ylim');
      for i = 1:length(self.seqs),
        if ~strcmpi(self.seqs(i).type,'death'),
          continue;
        end
        f = self.seqs(i).frames;
        if f <= self.f,
          continue;
        end
        fly = self.seqs(i).flies;
        j = self.trx(fly).off+(f);
        x = self.trx(fly).x(j);
        y = self.trx(fly).y(j);
        if x >= xlim(1) && x <= xlim(2) && y >= ylim(1) && y <= ylim(2),
          if nextnearframe > f,
            nextneardeath = i;
            nextnearframe = f;
          end
        end
      end
      
      if nextneardeath == -1,
        self.restorePointer(oldPointer);
        msgbox('Sorry! There are no fly deaths in the current axes after the current frame.',...
          'Could Not Find Death');
        return;
      end
      
      self.lastframe = self.f;
      self.f = nextnearframe;
      setFrameNumber(self,hObject);
      PlotFrame(self);
      
      % guidata(hObject,self);
      
    end
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on selection change in plotpathmenu.
  function plotpathmenuTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to plotpathmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hints: contents = get(hObject,'String') returns plotpathmenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from plotpathmenu
    updateFlyPathVisible(self);
  end  % method
  
  
  
  
  
  function nframesploteditTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to nframesplotedit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of nframesplotedit as text
    %        str2double(get(hObject,'String')) returns contents of nframesplotedit as a double
    v = str2double(get(hObject,'string'));
    if isempty(v),
      set(hObject,'string',num2str(self.f));
    else
      self.nframesplot = v;
      for fly = 1:self.nflies,
        fixUpdateFly(self,fly);
      end
    end
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on selection change in zoommenu.
  function zoommenuTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to zoommenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hints: contents = get(hObject,'String') returns zoommenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from zoommenu
    contents = get(hObject,'String');
    s = contents{get(hObject,'Value')};
    % if strcmpi(self.zoommode,s),
    %   return;
    % end
    self.zoommode = s;
    if strcmpi(s,'whole arena'),
      xlim = [1,self.nc];
      ylim = [1,self.nr];
      % match aspect ratio
      [xlim,ylim] = self.matchAspectRatio(xlim,ylim);
      set(self.mainaxes,'xlim',xlim,'ylim',ylim);
    else
      zoomInOnSeq(self);
    end
    % guidata(hObject,self);
  end  % method
  
  
  
  
  % --- Executes on button press in interpolatefirstframebutton.
  function interpolatefirstframebuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to interpolatefirstframebutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if isempty(self.selected),
      errordlg('Please select fly track to interpolate first.','No Fly Selected');
      return;
    end
    if ~isalive(self.trx(self.selected),self.f),
      errordlg('Selected fly is not alive in current frame!','Bad Selection');
      return;
    end
    
    self.interpolatefly = self.selected;
    self.nselect = 0;
    self.selected = [];
    self.interpolatefirstframe = self.f;
    set(self.interpolatedoitbutton,'enable','on');
    set(self.interpolatefirstframebutton,'enable','off');
    set(self.interpolatefirstframebutton,'string',sprintf('First = %d',self.f));
    
    % draw the fly
    fly = self.interpolatefly;
    i = self.trx(fly).off+(self.f);
    x = self.trx(fly).x(i);
    y = self.trx(fly).y(i);
    a = 2*self.trx(fly).a(i);
    b = 2*self.trx(fly).b(i);
    theta = self.trx(fly).theta(i);
    self.hinterpolate = ellipsedraw(self.mainaxes,a,b,x,y,theta);
    color = self.colors(fly,:);
    set(self.hinterpolate,'color',color*.75,'linewidth',3,'linestyle','--',...
      'hittest','off');
    
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in interpolatedoitbutton.
  function interpolatedoitbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to interpolatedoitbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if ~isalive(self.trx(self.interpolatefly),self.f),
      errordlg('Selected fly is not alive in current frame!','Bad Selection');
      return;
    end
    
    oldPointer=self.pointerToWatch();
    
    setFlySelectedInView(self,self.interpolatefly,false);
    self.selected = [];
    
    f0 = self.interpolatefirstframe;
    f1 = self.f;
    if f0 > f1,
      tmp = f0; f0 = f1; f1 = tmp;
    end
    fly = self.interpolatefly;
    
    % save to undo list
    self.undolist{end+1} = {'interpolate',[f0,f1],fly,...
      CatalyticController.getPartOfTrack(self.trx(fly),f0,f1)};
    
    % interpolate between f0 and f1
    i0 = self.trx(fly).off+(f0);
    i1 = self.trx(fly).off+(f1);
    x0 = self.trx(fly).x(i0);
    y0 = self.trx(fly).y(i0);
    a0 = self.trx(fly).a(i0);
    b0 = self.trx(fly).b(i0);
    theta0 = self.trx(fly).theta(i0);
    x1 = self.trx(fly).x(i1);
    y1 = self.trx(fly).y(i1);
    a1 = self.trx(fly).a(i1);
    b1 = self.trx(fly).b(i1);
    theta1 = self.trx(fly).theta(i1);
    nframesinterp = f1-f0+1;
    self.trx(fly).x(i0:i1) = linspace(x0,x1,nframesinterp);
    self.trx(fly).y(i0:i1) = linspace(y0,y1,nframesinterp);
    self.trx(fly).a(i0:i1) = linspace(a0,a1,nframesinterp);
    self.trx(fly).b(i0:i1) = linspace(b0,b1,nframesinterp);
    
    dtheta = modrange(theta1-theta0,-pi,pi);
    thetainterp = linspace(0,dtheta,nframesinterp)+theta0;
    self.trx(fly).theta(i0:i1) = modrange(thetainterp,-pi,pi);
    
    self.editMode='';
    delete(self.hinterpolate);
    set(self.interpolatefirstframebutton,'string','First Frame','Enable','on');
    set(self.interpolatedoitbutton,'enable','off');
    set(self.interpolatepanel','visible','off');
    CatalyticController.enablePanel(self.editpanel,'on');
    
    self.needssaving = 1;
    
    % guidata(hObject,self);
    
    fixUpdateFly(self,fly);
    
    self.updateControlVisibilityAndEnablement();
    
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on button press in cancelinterpolatebutton.
  function cancelinterpolatebuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to cancelinterpolatebutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if ~isempty(self.hinterpolate) && ishandle(self.hinterpolate),
      delete(self.hinterpolate);
    end
    if ~isempty(self.interpolatefly),
      setFlySelectedInView(self,self.interpolatefly,false);
    end
    set(self.interpolatefirstframebutton,'string','First Frame','Enable','on');
    set(self.interpolatedoitbutton,'enable','off');
    currentEditModeCancelled(self);
  end  % method
  
  
  
  
  % --- Executes on button press in interpolatefirstframebutton.
  function extendfirstflybuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to interpolatefirstframebutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if isempty(self.selected),
      errordlg('Please select fly track to extend first.','No Fly Selected');
      return;
    end
    if ~isalive(self.trx(self.selected),self.f),
      errordlg('Selected fly is not alive in current frame!','Bad Selection');
      return;
    end
    self.extendfly = self.selected;
    self.extendFlySelected=true;
    self.nselect = 0;
    self.selected = [];
    set(self.extenddoitbutton,'enable','on');
    set(self.extendfirstflybutton,'enable','off');
    
    % draw the fly
    fly = self.extendfly;
    i = self.trx(fly).off+(self.f);
    x = self.trx(fly).x(i);
    y = self.trx(fly).y(i);
    a = 2*self.trx(fly).a(i);
    b = 2*self.trx(fly).b(i);
    theta = self.trx(fly).theta(i);
    self.hextend = ellipsedraw(self.mainaxes,a,b,x,y,theta);
    color = self.colors(fly,:);
    set(self.hextend,'color',color*.75,'linewidth',3,'linestyle','--',...
      'hittest','off');
    
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in connectdoitbutton.
  function connectdoitbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to connectdoitbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if isempty(self.selected),
      errordlg('Please select fly track to connect first.','No Fly Selected');
      return;
    end
    
    fly2 = self.selected;
    
    if ~isalive(self.trx(fly2),self.f),
      errordlg('Selected fly is not alive in current frame!','Bad Selection');
      return;
    end
    
    oldPointer=self.pointerToWatch();
    
    setFlySelectedInView(self,self.connectfirstfly,false);
    setFlySelectedInView(self,fly2,false);
    self.selected = [];
    self.nselect = 0;
    
    f1 = self.connectfirstframe;
    f2 = self.f;
    fly1 = self.connectfirstfly;
    
    if f1 > f2,
      tmp = f1; f1 = f2; f2 = tmp;
      tmp = fly1; fly1 = fly2; fly2 = tmp;
    end
    
    % save to undo list
    self.undolist{end+1} = {'connect',[f1,f2],[fly1,fly2],...
      [CatalyticController.getPartOfTrack(self.trx(fly1),f1+1,inf),...
      CatalyticController.getPartOfTrack(self.trx(fly2),1,f2-1)], [], []};
    
    % interpolate between f1 and f2
    i1 = self.trx(fly1).off+(f1);
    i2 = self.trx(fly2).off+(f2);
    x1 = self.trx(fly1).x(i1);
    y1 = self.trx(fly1).y(i1);
    a1 = self.trx(fly1).a(i1);
    b1 = self.trx(fly1).b(i1);
    theta1 = self.trx(fly1).theta(i1);
    x2 = self.trx(fly2).x(i2);
    y2 = self.trx(fly2).y(i2);
    a2 = self.trx(fly2).a(i2);
    b2 = self.trx(fly2).b(i2);
    theta2 = self.trx(fly2).theta(i2);
    if isfield( self.trx, 'timestamps' )
      ts1 = self.trx(fly1).timestamps(i1);
      ts2 = self.trx(fly2).timestamps(i2);
    end
    nframesinterp = f2-f1+1;
    
    xinterp = linspace(x1,x2,nframesinterp);
    yinterp = linspace(y1,y2,nframesinterp);
    ainterp = linspace(a1,a2,nframesinterp);
    binterp = linspace(b1,b2,nframesinterp);
    dtheta = modrange(theta2-theta1,-pi,pi);
    thetainterp = modrange(linspace(0,dtheta,nframesinterp)+theta1,-pi,pi);
    if isfield( self.trx, 'timestamps' )
      tsinterp = linspace( ts1, ts2, nframesinterp );
    end
    
    % will we need to cut?
    f3 = self.trx(fly2).endframe;
    if f3 < self.trx(fly1).endframe,
      % if fly1 outlives fly2, then delete all of fly1 after death of fly2
      self.trx(fly1) = CatalyticController.getPartOfTrack(self.trx(fly1),1,f3);
      % delete events involving fly1 in frames f3 and after
      seqs_removed = removeFlyEvent(self,fly1,f3+1,inf);
      self.undolist{end}{end-1} = seqs_removed;
    elseif f3 > self.trx(fly1).endframe,
      % we will need to append track
      nappend = f3 - self.trx(fly1).endframe;
      self.trx(fly1).x(end+1:end+nappend) = 0;
      self.trx(fly1).y(end+1:end+nappend) = 0;
      self.trx(fly1).a(end+1:end+nappend) = 0;
      self.trx(fly1).b(end+1:end+nappend) = 0;
      self.trx(fly1).theta(end+1:end+nappend) = 0;
      if isfield( self.trx, 'timestamps' )
        self.trx(fly1).timestamps(end+1:end+nappend) = 0;
      end
      self.trx(fly1).nframes = self.trx(fly1).nframes+nappend;
      self.trx(fly1).endframe = f3;
    end
    
    % copy over the interpolation
    idx = i1:self.trx(fly1).off+(f2);
    self.trx(fly1).x(idx) = xinterp;
    self.trx(fly1).y(idx) = yinterp;
    self.trx(fly1).a(idx) = ainterp;
    self.trx(fly1).b(idx) = binterp;
    self.trx(fly1).theta(idx) = thetainterp;
    if isfield( self.trx, 'timestamps' )
      self.trx(fly1).timestamps(idx) = tsinterp;
    end
    
    % copy over fly2
    idx1 = self.trx(fly1).off+(f2):self.trx(fly1).off+(f3);
    idx2 = self.trx(fly2).off+(f2):self.trx(fly2).off+(f3);
    self.trx(fly1).x(idx1) = self.trx(fly2).x(idx2);
    self.trx(fly1).y(idx1) = self.trx(fly2).y(idx2);
    self.trx(fly1).a(idx1) = self.trx(fly2).a(idx2);
    self.trx(fly1).b(idx1) = self.trx(fly2).b(idx2);
    self.trx(fly1).theta(idx1) = self.trx(fly2).theta(idx2);
    if isfield( self.trx, 'timestamps' )
      self.trx(fly1).timestamps(idx1) = self.trx(fly2).timestamps(idx2);
    end
    
    % delete fly
    DeleteFly(self,fly2);
    % replace fly2 with fly1 for frames f2 thru f3
    replaceFlyEvent(self,fly2,fly1,f2,f3);
    seqs_removed = removeFlyEvent(self,fly2,-inf,inf);
    self.undolist{end}{end} = seqs_removed;
    fixDeathEvent(self,fly1);
    
    delete(self.hconnect);
    set(self.connectfirstflybutton,'string','First Fly','Enable','on');
    set(self.connectdoitbutton,'enable','off');
    set(self.connectpanel','visible','off');
    CatalyticController.enablePanel(self.editpanel,'on');
    
    self.editMode='';
    self.needssaving = 1;
    
    % guidata(hObject,self);
    
    fixUpdateFly(self,fly1);
    
    self.updateControlVisibilityAndEnablement();
    
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  function replaceFlyEvent(self,fly0,fly1,f0,f1)  %#ok
    % replace appearances of fly0 with fly1 in sequences between frames f0 and f1
    % don't know why this is commented out... it seems important JAB 9/30/11
    % though it also seems like it should test && ~ismember(fly1), too
    %for i = 1:length(self.seqs)
    %  if ismember(fly0,self.seqs(i).flies) && f0 <= min(self.seqs(i).frames) && ...
    %      f1 >= max(self.seqs(i).frames)
    %    self.seqs(i).flies = union(setdiff(self.seqs(i).flies,fly0),fly1);
    %  end
    %end
  end  % method
  
  
  
  
  
  
  % --- Executes on button press in connectcancelbutton.
  function connectcancelbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to connectcancelbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if ~isempty(self.connectfirstfly) && self.connectfirstfly > 0,
      setFlySelectedInView(self,self.connectfirstfly,false);
    end
    if ~isempty(self.hconnect) && ishandle(self.hconnect),
      delete(self.hconnect);
    end
    set(self.connectfirstflybutton,'enable','on','string','First Fly');
    currentEditModeCancelled(self);
  end  % method
  
  
  
  
  
  
  % --- Executes on button press in connectfirstflybutton.
  function connectfirstflybuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to connectfirstflybutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if isempty(self.selected),
      errordlg('Please select fly track to connect first.','No Fly Selected');
      return;
    end
    if ~isalive(self.trx(self.selected),self.f),
      errordlg('Selected fly is not alive in current frame!','Bad Selection');
      return;
    end
    self.connectfirstfly(end) = self.selected;
    self.nselect = 1;
    self.selected = [];
    self.connectfirstframe = self.f;
    set(self.connectdoitbutton,'enable','on');
    set(self.connectfirstflybutton,'enable','off');
    set(self.connectfirstflybutton,'string',sprintf('First = %d',self.f));
    
    % draw the fly
    fly = self.connectfirstfly;
    i = self.trx(fly).off+(self.f);
    x = self.trx(fly).x(i);
    y = self.trx(fly).y(i);
    a = 2*self.trx(fly).a(i);
    b = 2*self.trx(fly).b(i);
    theta = self.trx(fly).theta(i);
    self.hconnect = ellipsedraw(self.mainaxes,a,b,x,y,theta);
    color = self.colors(fly,:);
    set(self.hconnect,'color',color*.75,'linewidth',3,'linestyle','--',...
      'hittest','off');
    
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in playstopbutton.
  function playstopbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to playstopbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if strcmpi(get(hObject,'string'),'play'),
      play(self);
    else
      self.isplaying = false;
      % guidata(hObject,self);
    end
  end  % method
  
  
  
  
  
  % --- Executes on button press in extenddoitbutton.
  function extenddoitbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to extenddoitbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if isalive(self.trx(self.extendfly),self.f),
      errordlg('Selected fly is alive in current frame!','Bad Selection');
      return;
    end
    
    oldPointer=self.pointerToWatch();
    
    setFlySelectedInView(self,self.extendfly,false);
    self.selected = [];
    
    f = self.f;
    fly = self.extendfly;
    
    % save to undo list
    self.undolist{end+1} = {'interpolate',[self.trx(fly).firstframe,self.trx(fly).endframe],fly};
    
    % extend
    if f < self.trx(fly).firstframe,
      n = self.trx(fly).firstframe - f;
      self.trx(fly).x = [zeros(1,n),self.trx(fly).x];
      self.trx(fly).y = [zeros(1,n),self.trx(fly).y];
      self.trx(fly).a = [zeros(1,n),self.trx(fly).a];
      self.trx(fly).b = [zeros(1,n),self.trx(fly).b];
      self.trx(fly).theta = [zeros(1,n),self.trx(fly).theta];
      self.trx(fly).x(1:n) = self.trx(fly).x(n+1);
      self.trx(fly).y(1:n) = self.trx(fly).y(n+1);
      self.trx(fly).a(1:n) = self.trx(fly).a(n+1);
      self.trx(fly).b(1:n) = self.trx(fly).b(n+1);
      self.trx(fly).theta(1:n) = self.trx(fly).theta(n+1);
      self.trx(fly).firstframe = f;
      self.trx(fly).off = -self.trx(fly).firstframe + 1;
      if isfield( self.trx, 'timestamps' )
        if ~isempty(self.timestamps)
          self.trx(fly).timestamps = [self.timestamps(1:n), self.trx(fly).timestamps];
        else
          self.trx(fly).timestamps = [ones(1,n).*self.trx(fly).timestamps(1), self.trx(fly).timestamps];
        end
      end
      if ~all( size( self.trx(fly).timestamps ) == size( self.trx(fly).x ) )
        keyboard
      end
      %self.trx(fly).f2i = @(f) f - self.trx(fly).firstframe + 1;
      self.trx(fly).nframes = length(self.trx(fly).x);
      % move the death event
      fixDeathEvent(self,fly);
    else
      n = f - self.trx(fly).endframe;
      self.trx(fly).x = [self.trx(fly).x,zeros(1,n)];
      self.trx(fly).y = [self.trx(fly).y,zeros(1,n)];
      self.trx(fly).a = [self.trx(fly).a,zeros(1,n)];
      self.trx(fly).b = [self.trx(fly).b,zeros(1,n)];
      self.trx(fly).theta = [self.trx(fly).theta,zeros(1,n)];
      self.trx(fly).x(end-n+1:end) = self.trx(fly).x(end-n);
      self.trx(fly).y(end-n+1:end) = self.trx(fly).y(end-n);
      self.trx(fly).a(end-n+1:end) = self.trx(fly).a(end-n);
      self.trx(fly).b(end-n+1:end) = self.trx(fly).b(end-n);
      self.trx(fly).theta(end-n+1:end) = self.trx(fly).theta(end-n);
      self.trx(fly).nframes = length(self.trx(fly).x);
      self.trx(fly).endframe = f;
      % move the death event
      fixDeathEvent(self,fly);
    end
    
    delete(self.hextend);
    self.extendFlySelected=false;
    set(self.extendfirstflybutton,'Enable','on');
    set(self.extenddoitbutton,'enable','off');
    set(self.extendpanel','visible','off');
    CatalyticController.enablePanel(self.editpanel,'on');
    
    self.editMode='';
    self.needssaving = 1;
    
    % guidata(hObject,self);
    
    fixUpdateFly(self,fly);
    self.updateControlVisibilityAndEnablement();
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on button press in extendcancelbutton.
  function extendcancelbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to extendcancelbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if ~isempty(self.hextend) && ishandle(self.hextend),
      delete(self.hextend);
    end
    if ~isempty(self.extendfly),
      setFlySelectedInView(self,self.extendfly,false);
    end
    
    self.extendFlySelected=false;
    set(self.extendfirstflybutton,'Enable','on');
    set(self.extenddoitbutton,'enable','off');
    currentEditModeCancelled(self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in autotrackdoitbutton.
  function autotrackdoitbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to autotrackdoitbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    oldPointer=self.pointerToWatch();
    
    f0 = min(self.f,self.autotrackframe);
    f1 = max(self.f,self.autotrackframe);
    
    setFlySelectedInView(self,self.autotrackfly,false);
    self.selected = [];
    
    fly = self.autotrackfly;
    
    % save to undo list
    self.undolist{end+1} = {'autotrack',[f0,f1],fly,CatalyticController.getPartOfTrack(self.trx(fly),f0,f1)};
    
    set(self.autotrackcancelbutton,'string','Stop');
    set(self.autotrackdoitbutton,'enable','off');
    self.stoptracking = false;
    
    % track
    seq.flies = fly;
    seq.frames = f0:min(f1,self.trx(fly).endframe);
    if get(self.showtrackingbutton,'value')
      zoomInOnSeq(self,seq);
    end
    self.stoptracking = false;
    self.fixTrackFlies(fly,f0,f1,self);
    
    if ~isempty( self.trackingstoppedframe )
      %    self.f = self.trackingstopped;
      %rmfield( self, 'trackingstoppedframe' );
      self.trackingstoppedframe=[];
      %self=rmfield( self, 'trackingstoppedframe' );
      
      %    setFrameNumber( self, hobject );
      %    PlotFrame( self );
    end
    
    fixDeathEvent(self,fly);
    
    delete(self.hautotrack);
    set(self.autotrackcancelbutton,'string','Cancel');
    set(self.autotrackfirstframebutton,'Enable','on');
    set(self.autotrackdoitbutton,'enable','off');
    set(self.autotrackpanel','visible','off');
    CatalyticController.enablePanel(self.editpanel,'on');
    
    self.editMode='';
    self.needssaving = 1;
    
    % guidata(hObject,self);
    
    fixUpdateFly(self,fly);
    self.updateControlVisibilityAndEnablement();
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on button press in autotrackcancelbutton.
  function autotrackcancelbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to autotrackcancelbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if strcmpi(get(self.autotrackcancelbutton,'string'),'stop')
      self.stoptracking = true;
    else
      if ~isempty(self.hautotrack) && ishandle(self.hautotrack),
        delete(self.hautotrack);
        self.hautotrack=[];
      end
      if ~isempty(self.autotrackfly),
        setFlySelectedInView(self,self.autotrackfly,false);
      end
      set(self.autotrackfirstframebutton,'Enable','on');
      set(self.autotrackdoitbutton,'enable','off');
      currentEditModeCancelled(self);
    end
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in autotrackfirstframebutton.
  function autotrackfirstframebuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to autotrackfirstframebutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if isempty(self.selected),
      errordlg('Please select fly track to track first.','No Fly Selected');
      return;
    end
    if ~isalive(self.trx(self.selected),self.f),
      errordlg('Selected fly is not alive in current frame!','Bad Selection');
      return;
    end
    self.autotrackfly = self.selected;
    self.autotrackframe = self.f;
    
    self.nselect = 0;
    self.selected = [];
    set(self.autotrackdoitbutton,'enable','on');
    set(self.autotrackfirstframebutton,'enable','off');
    set(self.autotracksettingsbutton,'enable','on');
    % draw the fly
    fly = self.autotrackfly;
    i = self.trx(fly).off+(self.f);
    x = self.trx(fly).x(i);
    y = self.trx(fly).y(i);
    a = 2*self.trx(fly).a(i);
    b = 2*self.trx(fly).b(i);
    theta = self.trx(fly).theta(i);
    self.hautotrack = ellipsedraw(self.mainaxes,a,b,x,y,theta);
    color = self.colors(fly,:);
    set(self.hautotrack,'color',color*.75,'linewidth',3,'linestyle','--',...
      'hittest','off');
    self.bgcurr = self.bgmed;
    
    % guidata(hObject,self);
  end  % method
  
  
  
  
  % --- Executes on button press in autotracksettingsbutton.
  function autotracksettingsbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to autotracksettingsbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    %self = retrack_settings(self);
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in showtrackingbutton.
  function showtrackingbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to showtrackingbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of showtrackingbutton
  end  % method
  
  
  
  
  
  % --- Executes on button press in flipdoitbutton.
  function flipdoitbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to flipdoitbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if ~isalive(self.trx(self.flipfly),self.f),
      errordlg('Selected fly is not alive in current frame','Bad Selection');
      return;
    end
    
    oldPointer=self.pointerToWatch();
    
    setFlySelectedInView(self,self.flipfly,false);
    self.selected = [];
    
    f = self.f;
    fly = self.flipfly;
    
    % save to undo list
    self.undolist{end+1} = {'flip',self.flipframe,f,fly};
    
    % flip
    for f = self.flipframe:f,
      i = self.trx(fly).off+(f);
      self.trx(fly).theta(i) = modrange(self.trx(fly).theta(i)+pi,-pi,pi);
    end
    
    delete(self.hflip);
    set(self.flipfirstframebutton,'Enable','on');
    set(self.flipdoitbutton,'enable','off');
    set(self.flippanel','visible','off');
    CatalyticController.enablePanel(self.editpanel,'on');
    
    self.editMode='';
    self.needssaving = 1;
    
    % guidata(hObject,self);
    
    fixUpdateFly(self,fly);
    self.updateControlVisibilityAndEnablement();
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on button press in flipcancelbutton.
  function flipcancelbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to flipcancelbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if ~isempty(self.hflip) && ishandle(self.hflip),
      delete(self.hflip);
      self.hflip=[];
    end
    if ~isempty(self.flipfly),
      setFlySelectedInView(self,self.flipfly,false);
    end
    set(self.flipfirstframebutton,'Enable','on');
    set(self.flipdoitbutton,'enable','off');
    currentEditModeCancelled(self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in flipfirstframebutton.
  function flipfirstframebuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to flipfirstframebutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if isempty(self.selected),
      errordlg('Please select fly track to flip first.','No Fly Selected');
      return;
    end
    if ~isalive(self.trx(self.selected),self.f),
      errordlg('Selected fly is not alive in current frame!','Bad Selection');
      return;
    end
    self.flipfly = self.selected;
    self.flipframe = self.f;
    self.nselect = 0;
    self.selected = [];
    set(self.flipdoitbutton,'enable','on');
    set(self.flipfirstframebutton,'enable','off');
    
    % draw the fly
    fly = self.flipfly;
    i = self.trx(fly).off+(self.f);
    x = self.trx(fly).x(i);
    y = self.trx(fly).y(i);
    a = 2*self.trx(fly).a(i);
    b = 2*self.trx(fly).b(i);
    theta = self.trx(fly).theta(i);
    self.hflip = ellipsedraw(self.mainaxes,a,b,x,y,theta);
    color = self.colors(fly,:);
    set(self.hflip,'color',color*.75,'linewidth',3,'linestyle','--',...
      'hittest','off');
    
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in printbutton.
  function printbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to printbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    for fly = 1:length(self.trx)
      fprintf('Track %d: firstframe = %d, endframe = %d, nframes = %d, length(x) = %d\n',...
        fly,self.trx(fly).firstframe,self.trx(fly).endframe,self.trx(fly).nframes,...
        length(self.trx(fly).x));
    end
  end  % method
  
  
  
  
  
  % --- Executes on button press in manytrackdoitbutton.
  function manytrackdoitbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to manytrackdoitbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    oldPointer=self.pointerToWatch();
    
    f0 = min(self.f,self.manytrackframe);
    f1 = max(self.f,self.manytrackframe);
    
    for fly = self.manytrackflies(:)',
      setFlySelectedInView(self,fly,false);
    end
    self.selected = [];
    
    flies = self.manytrackflies;
    
    % save to undo list
    oldtrx=zeros(1,length(flies));
    for i = 1:length(flies),
      fly = flies(i);
      oldtrx(i) = CatalyticController.getPartOfTrack(self.trx(fly),f0,f1);
    end
    self.undolist{end+1} = {'manytrack',[f0,f1],flies,oldtrx};
    
    set(self.manytrackcancelbutton,'string','Stop');
    set(self.manytrackdoitbutton,'enable','off');
    self.stoptracking = false;
    
    % track
    seq.flies = flies;
    seq.frames = f0:min(f1,[self.trx(flies).endframe]);
    if get(self.manytrackshowtrackingbutton,'value')
      zoomInOnSeq(self,seq);
    end
    self.stoptracking = false;
    self.fixTrackFlies(flies,f0,f1,self);
    for fly = flies(:)',
      fixDeathEvent(self,fly);
    end
    delete(self.hmanytrack);
    set(self.manytrackcancelbutton,'string','Cancel');
    set(self.manytrackfirstframebutton,'Enable','on');
    set(self.manytrackdoitbutton,'enable','off');
    set(self.manytrackpanel','visible','off');
    CatalyticController.enablePanel(self.editpanel,'on');
    
    self.editMode='';
    self.needssaving = 1;
    
    % guidata(hObject,self);
    
    for fly = flies(:)',
      fixUpdateFly(self,fly);
    end
    self.updateControlVisibilityAndEnablement();
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on button press in manytrackcancelbutton.
  function manytrackcancelbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to manytrackcancelbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if strcmpi(get(self.manytrackcancelbutton,'string'),'stop')
      self.stoptracking = true;
    else
      if ~isempty(self.hmanytrack)
        idx = ishandle(self.hmanytrack);
        delete(self.hmanytrack(idx));
      end
      if ~isempty(self.manytrackflies),
        for fly = self.manytrackflies(:)',
          setFlySelectedInView(self,fly,false);
        end
      end
      set(self.manytrackfirstframebutton,'Enable','on');
      set(self.manytrackdoitbutton,'enable','off');
      currentEditModeCancelled(self);
    end
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in manytrackfirstframebutton.
  function manytrackfirstframebuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to manytrackfirstframebutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    %self.selected = self.selected(self.selected > 0);
    if isempty(self.selected),
      errordlg('Please select flies track to track first.','No Fly Selected');
      return;
    end
    for fly = self.selected(:)',
      if ~isalive(self.trx(fly),self.f),
        errordlg('One of the selected flies is not alive in current frame!','Bad Selection');
        return;
      end
    end
    self.autotrackfly = self.selected;
    self.autotrackframe = self.f;
    self.manytrackflies = self.selected;
    self.manytrackframe = self.f;
    
    self.nselect = 0;
    self.selected = [];
    set(self.manytrackdoitbutton,'enable','on');
    set(self.manytrackfirstframebutton,'enable','off');
    set(self.manytracksettingsbutton,'enable','on');
    % draw the fly
    self.hmanytrack = [];
    for fly = self.manytrackflies(:)',
      i = self.trx(fly).off+(self.f);
      x = self.trx(fly).x(i);
      y = self.trx(fly).y(i);
      a = 2*self.trx(fly).a(i);
      b = 2*self.trx(fly).b(i);
      theta = self.trx(fly).theta(i);
      self.hmanytrack(end+1) = ellipsedraw(self.mainaxes,a,b,x,y,theta);
      color = self.colors(fly,:);
      set(self.hmanytrack(end),'color',color*.75,'linewidth',3,'linestyle','--',...
        'hittest','off');
    end
    self.bgcurr = self.bgmed;
    
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in manytracksettingsbutton.
  function manytracksettingsbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to manytracksettingsbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    %self = retrack_settings(self);
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in manytrackshowtrackingbutton.
  function manytrackshowtrackingbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to manytrackshowtrackingbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of manytrackshowtrackingbutton
  end  % method
  
  
  
  
  
  % --- Executes on button press in addnewtrackdoitbutton.
  function addnewtrackdoitbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to addnewtrackdoitbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    oldPointer=self.pointerToWatch();
    
    new_id = 0;
    new_timestamp = -1;
    for fly = 1:length( self.trx )
      new_id = max( [self.trx(fly).id + 1, new_id] );
      if new_timestamp == -1 && ...
          self.trx(fly).firstframe <= self.f && ...
          self.trx(fly).endframe >= self.f
        new_timestamp = self.trx(fly).timestamps(self.trx(fly).firstframe + self.f - 1);
      end
    end
    
    % fill in new fly
    fly = length( self.trx ) + 1;
    self.trx(fly).id = new_id;
    self.trx(fly).timestamps = new_timestamp;
    self.trx(fly).firstframe = self.f;
    self.trx(fly).off = -self.trx(fly).firstframe + 1;
    self.trx(fly).endframe = self.f;
    self.trx(fly).nframes = 1;
    self.trx(fly).moviename = self.trx(1).moviename;
    self.trx(fly).arena = self.trx(1).arena;
    self.trx(fly).matname = self.trx(1).matname;
    self.trx(fly).pxpermm = self.trx(1).pxpermm;
    self.trx(fly).fps = self.trx(1).fps;
    xlim = get( self.mainaxes, 'xlim' );
    ylim = get( self.mainaxes, 'ylim' );
    self.trx(fly).x = mean( xlim );
    self.trx(fly).y = mean( ylim );
    self.trx(fly).theta = 0;
    self.trx(fly).a = diff( xlim )/10;
    self.trx(fly).b = diff( ylim )/30;
    self.trx(fly).xpred = self.trx(fly).x;
    self.trx(fly).ypred = self.trx(fly).y;
    self.trx(fly).thetapred = self.trx(fly).theta;
    self.trx(fly).dx = 0;
    self.trx(fly).dy = 0;
    self.trx(fly).v = 0;
    
    % save to undo list
    self.undolist{end+1} = {'addnew',fly};
    
    % draw
    self.nflies = self.nflies + 1;
    %self = setFlyColors(self);
    [self.colors0,self.colororder,self.colors] = ...
      colorOrderFromNumberOfAnimals(self.nflies);
    [self.hellipse(fly),self.hcenter(fly),self.hhead(fly),...
      self.htail(fly),self.hleft(fly),self.hright(fly),...
      self.htailmarker(fly),self.hpath(fly)] = ...
      initFly(self.colors(fly,:));
    updateFlyPathVisible(self);
    fixUpdateFly(self,fly);
    
    set(self.addnewtrackdoitbutton,'Enable','off');
    set(self.addnewtrackpanel','visible','off');
    CatalyticController.enablePanel(self.editpanel,'on');
    self.needssaving = 1;
    self.editMode='';
    
    % guidata(hObject,self);
    self.updateControlVisibilityAndEnablement();
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --- Executes on button press in addnewtrackcancelbutton.
  function addnewtrackcancelbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to addnewtrackcancelbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    set(self.addnewtrackdoitbutton,'Enable','off');
    currentEditModeCancelled(self);
  end  % method
  
  
  
  
  % -----------------------------------------------------------------------
  % --- Executes when fig is resized.
  function resize(self,hObject,eventdata)  %#ok
    % hObject    handle to fig (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if isempty(self) || ...
       isempty(self.fig) || ~ishandle(self.fig) || ...
       isempty(self.mainaxes) || ~ishandle(self.mainaxes) || ...
       isempty(self.frameslider) || ~ishandle(self.frameslider) || ...
       isempty(self.seqinfopanel) || ~ishandle(self.seqinfopanel) || ...
       isempty(self.zoomInButton) || ~ishandle(self.zoomInButton) || ...
       isempty(self.zoomOutButton) || ~ishandle(self.zoomOutButton) || ...
       isempty(self.rightpanel_dright) || ...
       isempty(self.rightpanel_dtop) || ...
       isempty(self.bottom_dleft_from_image_right_edge) || ...
       isempty(self.axes_dslider) || ...
       isempty(self.axes_dtop) || ...
       isempty(self.axes_drightpanels)
      return
    end
    
    % IMPORTANT: Need to make sure we save the current
    % main figure units, set them to pels, then set them back at the end
    % Some functions, like errordlg(), set them briefly to other things, and
    % sometimes the resize callback gets called during this interval, and that
    % causes the figure to get messed-up.

    % get current units, save; set units to chars
    units_before=get(self.fig,'units');
    set(self.fig,'units','characters');

    figpos = get(self.fig,'Position');
    
    % right panels: keep width, top dist, height, right dist the same
    ntags = numel(self.rightpanel_tags);
    for fni = 1:ntags,
      fn = self.rightpanel_tags{fni};
      h = self.(fn);
      if ~isempty(h) && ishandle(h) ,
        pos = get(h,'Position');
        pos(1) = figpos(3) - self.rightpanel_dright(fni);
        pos(2) = figpos(4) - self.rightpanel_dtop(fni);
        set(h,'Position',pos);
      end
    end

    % axes should fill everything else
    sliderpos = get(self.frameslider,'Position');
    seqinfopanelpos = get(self.seqinfopanel,'Position');
    pos = get(self.mainaxes,'Position');
    if ~isempty(self.axes_dslider)
      pos(2) = sliderpos(2)+sliderpos(4)+self.axes_dslider;
      pos(4) = figpos(4)-pos(2)-self.axes_dtop;
      pos(3) = seqinfopanelpos(1)-pos(1)-self.axes_drightpanels;
    end
    pos=max(pos,0.001);
    set(self.mainaxes,'Position',pos);
    sliderpos([1,3]) = pos([1,3]);
    set(self.frameslider,'Position',sliderpos);

    % stuff below axes: keep dist bottom, height same, same dleft, width
    mainAxesPosition = get(self.mainaxes,'Position');
    mainAxesRightEdgeX=mainAxesPosition(1)+mainAxesPosition(3);
    ntags = numel(self.bottom_tags);
    for fni = 1:ntags,
      fn = self.bottom_tags{fni};
      h = self.(fn);
      if (h==self.zoomInButton) || (h==self.zoomOutButton) && ...
         ~isempty(h) && ishandle(h)
        pos = get(h,'Position');
        pos(1)=mainAxesRightEdgeX+self.bottom_dleft_from_image_right_edge(fni);
        set(h,'Position',pos);
      end
    end
    
    % restore fig units
    set(self.fig,'units',units_before);
  end  % method
  
  
  
  
  
  % -----------------------------------------------------------------------
  % --- Executes on key press with focus on fig and none of its controls.
  function keyPressed(self,~,eventdata)
    % hObject    handle to fig (see GCBO)
    % eventdata  structure with the following fields (see FIGURE)
    %	Key: name of the key that was pressed, in lower case
    %	Character: character interpretation of the key(s) that was pressed
    %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
    % self    structure with self and user data (see GUIDATA)
    
    switch eventdata.Key,
      
      case 'rightarrow',
        
        if self.f < self.nframes,
          self.f = self.f+1;
          setFrameNumber(self,self.f);
          PlotFrame(self);
          % guidata(hObject,self);
        end
        
      case 'leftarrow',
        
        if self.f > 1,
          self.f = self.f-1;
          setFrameNumber(self,self.f);
          PlotFrame(self);
          % guidata(hObject,self);
        end
        
    end
  end  % method
  
  
  
  
  
  % --- Executes on button press in flipimage_checkbox.
  function flipimage_checkboxTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to flipimage_checkbox (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    self.flipud = get( hObject, 'value' );
    PlotFrame( self )
    % guidata( hObject, self )
  end  % method
  
  
  
  
  
  % --- Executes on button press in swapfirstframebutton.
  function swapfirstframebuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to swapfirstframebutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if length(self.selected) ~= 2,
      errordlg('You must first select the two flies to swap. See Swap Identities Instructions Panel',...
        'Bad Selection');
      return;
    end
    
    fly1 = self.selected(1);
    fly2 = self.selected(2);
    f = self.f;
    
    if ~isalive(self.trx(fly1),f) || ~isalive(self.trx(fly2),f),
      errordlg('Both flies must be alive in the selected frame.',...
        'Bad Selection');
      return;
    end
    
    self.swapfly = self.selected;
    self.nselect = 0;
    %self.selected = [];
    self.swapfirstframe = self.f;
    set(self.swapdoitbutton,'enable','on');
    set(self.swapfirstframebutton,'enable','off');
    set(self.swapfirstframebutton,'string',sprintf('First = %d',self.f));
    
    % draw the flies to be swapped with dashed lines
    self.hswap=nan([2 1]);
    for j=1:2
      fly = self.swapfly(j);
      i = self.trx(fly).off+(self.f);
      x = self.trx(fly).x(i);
      y = self.trx(fly).y(i);
      a = 2*self.trx(fly).a(i);
      b = 2*self.trx(fly).b(i);
      theta = self.trx(fly).theta(i);
      self.hswap(j) = ellipsedraw(self.mainaxes,a,b,x,y,theta);
      color = self.colors(fly,:);
      set(self.hswap(j),'color',color*.75,'linewidth',3,'linestyle','--',...
        'hittest','off');
    end
    
    % guidata(hObject,self);
  end  % method
  
  
  
  
  
  % --- Executes on button press in swapdoitbutton.
  function swapdoitbuttonTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to swapdoitbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    if length(self.selected) ~= 2,
      errordlg('You must first select the two flies to swap. See Swap Identities Instructions Panel',...
        'Bad Selection');
      return;
    end
    
    fly1 = self.selected(1);
    fly2 = self.selected(2);
    f = self.f;
    
    if ~isalive(self.trx(fly1),f) || ~isalive(self.trx(fly2),f),
      errordlg('Both flies must be alive in the selected frame.',...
        'Bad Selection');
      return;
    end
    
    oldPointer=self.pointerToWatch();
    
    swapIdentities( self, self.swapfirstframe, f, fly1, fly2 );
    fixUpdateFly(self,fly1);
    fixUpdateFly(self,fly2);
    self.undolist{end+1} = {'swap',[self.swapfirstframe f],[fly1,fly2]};
    
    setFlySelectedInView(self,fly1,false);
    setFlySelectedInView(self,fly2,false);
    self.nselect = 0;
    self.selected = [];
    hswap=self.hswap;
    hswap=hswap(ishandle(hswap));
    delete(hswap);
    self.hswap=[];
    set(self.swappanel,'visible','off');
    CatalyticController.enablePanel(self.editpanel,'on');
    
    self.needssaving = 1;
    self.editMode='';
    
    % guidata(hObject,self);
    self.updateControlVisibilityAndEnablement();
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % -------------------------------------------------------------------------
  function fileMenuTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to fileMenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
  end  % method
  
  
  
  
  
  % -------------------------------------------------------------------------
  function fileMenuOpenItemTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to fileMenuOpenItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    self.openViaChooser();
  end  % method
  
  
  
  
  
  % -------------------------------------------------------------------------
  function fileMenuCloseItemTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to fileMenuCloseItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    proceed=self.checkForUnsavedChangesAndDealIfNeeded();
    if ~proceed ,
      return
    end
    self.closeTheOpenFile();
  end  % method
  
  
  
  
  
  % -------------------------------------------------------------------------
  function openViaChooser(self)
    
    % Prompt user for filename
    %self=guidata(fig);
    %defaultPath=self.data.defaultpath;
    defaultPath=pwd();
    [filename,pathname] = ...
      uigetfile({'*.trf','Catalytic Files (*.trf)'}, ...
      'Open...', ...
      defaultPath);
    if ~ischar(filename),
      % user hit cancel
      return;
    end
    fileNameAbs=fullfile(pathname,filename);
    
    % Call the function that does the real work
    self.openGivenFileNameAbs(fileNameAbs)
  end  % method
  
  
  
  
  
  % -------------------------------------------------------------------------
  function openGivenFileNameAbs(self,fileNameAbs)
    
    % get self
    % self=guidata(fig);
    
    % get just the relative file name
    [~,baseName,ext]=fileparts(fileNameAbs);
    fileNameRel=[baseName ext];
    
    oldPointer=pointerToWatch(self);
    try
      % open the file
      trf=load(fileNameAbs,'-mat');
      
      % read inputs
      self.isFileOpen=true;
      self.seqs = trf.seqs;
      self.moviename = trf.moviename;
      self.trx = trf.trx;
      self.annname = trf.annname;
      self.params = trf.params;
      self.matname = trf.matname;
      self.savename = fileNameAbs;
      didload = false;
      [self.readframe,self.nframes,self.fid] = get_readframe_fcn(self.moviename);
      
      % get timestamps
      if isfield(self.trx,'timestamps'),
        self.timestamps=extractTimeStamps(self.trx,self.nframes);
      end
      
      % initialize parameters
      initializeMainAxes(self);
      
      % initialize state
      isseqleft = false;
      for i = 1:length(self.seqs),
        if isempty( strfindi(self.seqs(i).type,'dummy') ),
          isseqleft = true;
          break;
        end
      end
      if ~isseqleft,
        if ~didload,
          self.doneseqs = [];
        end
        %guidata(fig,self);
        %msgbox('No suspicious sequences to be corrected. Exiting. ','All Done');
        %uiresume(self.fig);
        return
      end
      self.flipud = 0;
      self.nflies = length(self.trx);
      % self = setFlyColors(self);
      [self.colors0,self.colororder,self.colors] = ...
        colorOrderFromNumberOfAnimals(self.nflies);
      setSeq(self,i,true);
      self.nselect = 0;
      self.selected = [];
      self.motionobj = [];
      self.plotpath = 'All Flies';
      self.nframesplot = 101;
      self.zoommode = 'sequence';
      self.undolist = {};
      self.needssaving = 0;  % don't need to save b/c just opened
      
      self.bgthresh = 10;
      %self.lighterthanbg = 1;
      self.bgcolor = nan;
      [self.ang_dist_wt,self.maxjump,bgtype,bgmed,bgmean,...
        tmp,self.bgthresh] = ...
        read_ann(self.annname,'ang_dist_wt','max_jump',...
        'bg_algorithm','background_median','background_mean','bg_type',...
        'n_bg_std_thresh_low');
      if tmp == 0,
        self.lighterthanbg = 1;
      elseif tmp == 1,
        self.lighterthanbg = -1;
      else
        self.lighterthanbg = 0;
      end
      if strcmpi(bgtype,'median'),
        self.bgmed = bgmed;
      else
        self.bgmed = bgmean;
      end
      
      % initialize data structures
      
      % initialize structure to hold seqs that are done
      if ~didload,
        self.doneseqs = [];
      end
      
      % initialize gui
      
      initializeFrameSlider(self);
      setFrameNumber(self);
      plotFirstFrame(self);
      initializeDisplayPanel(self);
      setErrorTypes(self);
      self.bgmed = reshape(self.bgmed,[self.nc,self.nr])';
      initializeKeyPressFcns(self);
      
      storePanelPositions(self);
    catch excp  %#ok
      restorePointer(self,oldPointer);
      uiwait(errordlg(sprintf('Unable to open file %s',fileNameRel),'Error','modal'));
      return
    end
    
    % Update self structure
    % guidata(fig, self);
    
    % Update the visibility and enablement of controls
    self.updateControlVisibilityAndEnablement();
    self.restorePointer(oldPointer);
    
    % Play the first sequence
    %play(self);
    
  end  % method
  
  
  
  
  
  % -------------------------------------------------------------------------
  function closeTheOpenFile(self)
    
    % self=guidata(fig);
    
    if ~isempty(self.fid) && self.fid>0
      fclose(self.fid);
      self.fid=[];
    end
    
    self.isFileOpen=false;
    self.seqs = [];
    self.moviename = [];
    self.trx = [];
    self.annname = [];
    self.params = [];
    self.matname = [];
    self.savename = [];
    didload = false;
    self.readframe = [];
    self.nframes = [];
    %self.fid = [];
    
    % get timestamps
    self.timestamps=[];
    
    % initialize parameters
    initializeMainAxes(self);
    
    % initialize state
    % isseqleft = false;
    % for i = 1:length(self.seqs),
    %   if isempty( strfindi(self.seqs(i).type,'dummy') ),
    %     isseqleft = true;
    %     break;
    %   end
    % end
    % if ~isseqleft,
    %   if ~didload,
    %     self.doneseqs = [];
    %   end
    %   guidata(hObject,self);
    %   msgbox('No suspicious sequences to be corrected. Exiting. ','All Done');
    %   uiresume(self.fig);
    %   return
    % end
    self.flipud = 0;
    self.nflies = length(self.trx);
    % setFlyColors(self);
    [self.colors0,self.colororder,self.colors] = ...
      colorOrderFromNumberOfAnimals(self.nflies);
    
    %setSeq(self,[],true);
    self.f=[];
    self.seqi=[];
    self.seq=[];
    
    self.nselect = 0;
    self.selected = [];
    self.motionobj = [];
    self.plotpath = 'All Flies';
    self.nframesplot = 101;
    self.zoommode = 'sequence';
    self.undolist = {};
    self.needssaving = 0;
    
    self.bgthresh = 10;
    %self.lighterthanbg = 1;
    self.bgcolor = nan;
    % [self.ang_dist_wt,self.maxjump,bgtype,bgmed,bgmean,...
    %   tmp,self.bgthresh] = ...
    %   read_ann(self.annname,'ang_dist_wt','max_jump',...
    %   'bg_algorithm','background_median','background_mean','bg_type',...
    %   'n_bg_std_thresh_low');
    % if tmp == 0,
    %   self.lighterthanbg = 1;
    % elseif tmp == 1,
    %   self.lighterthanbg = -1;
    % else
    %   self.lighterthanbg = 0;
    % end
    % if strcmpi(bgtype,'median'),
    %   self.bgmed = bgmed;
    % else
    %   self.bgmed = bgmean;
    % end
    
    % initialize data structures
    
    % initialize structure to hold seqs that are done
    if ~didload,
      self.doneseqs = [];
    end
    
    % initialize gui
    
    initializeFrameSlider(self);
    setFrameNumber(self);
    %plotFirstFrame(self);
    initializeDisplayPanel(self);
    setErrorTypes(self);
    %self.bgmed = reshape(self.bgmed,[self.nc,self.nr])';
    self.bgmed=[];
    initializeKeyPressFcns(self);
    
    storePanelPositions(self);
    
    % Update self structure
    self.editMode='';
    % guidata(fig, self);
    
    % Update the enablement and visibility of the UI
    self.updateControlVisibilityAndEnablement();
    
  end  % method
  
  
  
  
  % -------------------------------------------------------------------------
  function proceed=checkForUnsavedChangesAndDealIfNeeded(self)
    % Check for unsaved changes, and if there are unsaved changes, ask the user
    % if she wants to do a save.  Returns true if everything is copacetic and
    % the caller should proceed with whatever they were going to do.  Returns
    % false if the user wanted to save but there was an error, or if the user
    % hit cancel, and therefore the caller should _not_ proceed with whatever
    % they were going to do.
    if self.needssaving,
      res = questdlg('There are unsaved changes.  Save?','Save?','Save','Discard','Cancel','Save');
      if strcmpi(res,'Save'),
        saved=self.saveFile();
        if saved,
          proceed=true;
        else
          proceed=false;
        end
      elseif strcmpi(res,'Discard'),
        proceed=true;
      elseif strcmpi(res,'Cancel'),
        proceed=false;
      else
        error('fixerror.internalError','Internal error.  Please report to the developers.');  %#ok
      end
    else
      proceed=true;
    end
  end  % method
  
  
  
  
  
  % --------------------------------------------------------------------
  function fileMenuSaveItemTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to fileMenuSaveItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    saveAs=false;
    self.saveFile(saveAs);
  end  % method
  
  
  
  
  
  % --------------------------------------------------------------------
  function fileMenuSaveAsItemTwiddled(self,hObject,eventdata)  %#ok
    % hObject    handle to fileMenuSaveAsItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    
    saveAs=true;
    self.saveFile(saveAs);
  end  % method
  
  
  
  
  
  % -------------------------------------------------------------------------
  function saved=saveFile(self,saveAs)
    
    % Deal with args.
    if nargin<2 || isempty(saveAs),
      saveAs=false;
    end
    
    % Do eveything else.
    saved=false;  % default return
    %self=guidata(fig);
    %data=self.data;  % reference
    if saveAs ,
      windowTitle=fif(saveAs, ...
        'Save As...', ...
        'Save...');
      [filename,pathname] = ...
        uiputfile({'*.trf','Catalytic Files (*.trf)'}, ...
        windowTitle, ...
        self.savename);
      if ~ischar(filename),
        % user hit cancel
        return;
      end
      fileNameAbs=fullfile(pathname,filename);
    else
      fileNameAbs=self.savename;
    end
    fileNameRel=fileNameRelFromAbs(fileNameAbs);
    
    trx = fixIgnoredFields(self);  %#ok
    
    seqs = self.seqs;  %#ok
    doneseqs = self.doneseqs;  %#ok
    moviename = self.moviename;  %#ok
    seqi = self.seqi;  %#ok
    params = self.params;  %#ok
    matname = self.matname;  %#ok
    annname = self.annname;  %#ok
    oldPointer=self.pointerToWatch();
    try
      save(fileNameAbs,'trx','seqs','doneseqs','moviename','seqi','params','matname','annname');
    catch excp  %#ok
      self.restorePointer(oldPointer);
      uiwait(errordlg(sprintf('Unable to save file %s',fileNameRel),'Error','modal'));
      return
    end
    
    self.savename=fileNameAbs;
    self.needssaving = 0;
    %guidata(fig,self);
    self.updateControlVisibilityAndEnablement();
    saved=true;
    self.restorePointer(oldPointer);
  end  % method
  
  
  
  
  
  % --------------------------------------------------------------------
  function fileMenuQuitItemTwiddled(self,hObject,eventdata)  %#ok  %#ok
    % hObject    handle to fileMenuQuitItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % self    structure with self and user data (see GUIDATA)
    self.quit();
  end  % method
  
  
  
  
  
  % -------------------------------------------------------------------------
  function quit(self)
    proceed=checkForUnsavedChangesAndDealIfNeeded(self);
    if ~proceed ,
      return
    end
    if self.isFileOpen,
      closeTheOpenFile(self);
    end
    delete(self.fig);
  end  % method
  
  
  
  
  
  % -----------------------------------------------------------------------
  % --- Creates and returns a handle to the GUI figure.
  function layout(self)
    
    self.fig = figure(...
      'Units','characters',...
      'CloseRequestFcn',@(hObject,eventdata)self.quit(),...
      'Color', get(0,'DefaultUicontrolBackgroundColor'), ...
      'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
      'IntegerHandle','off',...
      'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'MenuBar','none',...
      'Name','Catalytic',...
      'NumberTitle','off',...
      'PaperPosition',get(0,'defaultfigurePaperPosition'),...
      'Position',[55 39.9230769230769 184.833333333333 58],...
      'ResizeFcn',@(hObject,eventdata)self.resize(hObject,eventdata),...
      'ToolBar','none',...
      'WindowButtonMotionFcn',@(hObject,eventdata)self.mouseMoved(hObject,eventdata),...
      'WindowButtonUpFcn',@(hObject,eventdata)self.mouseButtonReleased(hObject,eventdata),...
      'HandleVisibility','callback',...
      'UserData',[],...
      'Tag','fig',...
      'Visible','off');
    %'Color',[0.701960784313725 0.701960784313725 0.701960784313725],...
    
    centerOnRoot(self.fig);    
    
    self.connectpanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Connect Tracks...',...
      'Clipping','on',...
      'Position',[101.6 1.30769230769231 78.4 25.8461538461538],...
      'Visible','off',...
      'Tag','connectpanel'...
      );
    
    self.connectdoitbutton=uicontrol(...
      'Parent',self.connectpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.561 0],...
      'Callback',@(hObject,eventdata)self.connectdoitbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[30.6 1.3076923076923 19.2 2.53846153846154],...
      'String','Do It',...
      'UserData',[],...
      'Tag','connectdoitbutton'...
      );
    
    self.connectcancelbutton=uicontrol(...
      'Parent',self.connectpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.524 0 0],...
      'Callback',@(hObject,eventdata)self.connectcancelbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[51.2 1.23076923076922 18.6 2.53846153846154],...
      'String','Cancel',...
      'UserData',[],...
      'Tag','connectcancelbutton'...
      );
    
    uicontrol(...
      'Parent',self.connectpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','times',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 4.23076923076922 72.4 19.7692307692308],...
      'String',{  'fix errors in which a fly is lost for some'; 'frames: connect the tracks.'; '1) Scroll to the first frame of the portion of'; 'track to be connected. '; '2) Click on the track to be connected.. '; '3) Push "First Fly" button. '; '4) Scroll to the last frame of the portion of'; 'track to be connected. '; '5) Click on the track to be connected. '; '6) Push "Do It" button. ' },...
      'Style','text',...
      'Tag','text28'...
      );
    
    self.connectfirstflybutton=uicontrol(...
      'Parent',self.connectpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.512 0.476 0],...
      'Callback',@(hObject,eventdata)self.connectfirstflybuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[5.8 1.3076923076923 24 2.53846153846154],...
      'String','First Fly',...
      'UserData',[],...
      'Tag','connectfirstflybutton'...
      );
    
    self.frameslider=uicontrol(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.9 0.9 0.9],...
      'Callback',@(hObject,eventdata)self.framesliderTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',12.5,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Max',10000,...
      'Min',1,...
      'Position',[1.6 13.2307692307692 98.4 1.15384615384615],...
      'String',{  'Slider' },...
      'Style','slider',...
      'SliderStep',[1e-05 0.0002],...
      'Value',1,...
      'Tag','frameslider');
    
    self.extendpanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Extend Track...',...
      'Clipping','on',...
      'Position',[101.6 1.38461538461538 78.4 26],...
      'Visible','off',...
      'Tag','extendpanel');
    
    uicontrol(...
      'Parent',self.extendpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','times',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.6 3.92307692307692 73.2 20.2307692307692],...
      'String',{  'Extend track for a selected fly to a'; 'selected frame.'; '1) Click on the fly to be extended.'; '2) Push "First Fly" button to select.'; '3) Scroll to the frame to be extended to.'; '4) Push "Do It" button. ' },...
      'Style','text',...
      'Tag','text30');
    
    self.extenddoitbutton=uicontrol(...
      'Parent',self.extendpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.561 0],...
      'Callback',@(hObject,eventdata)self.extenddoitbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[34.4 0.846153846153846 15.6 2.53846153846154],...
      'String','Do It',...
      'UserData',[],...
      'Tag','extenddoitbutton');
    
    self.extendcancelbutton=uicontrol(...
      'Parent',self.extendpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.524 0 0],...
      'Callback',@(hObject,eventdata)self.extendcancelbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[50.6 0.846153846153846 20.2 2.53846153846154],...
      'String','Cancel',...
      'UserData',[],...
      'Tag','extendcancelbutton');
    
    self.extendfirstflybutton=uicontrol(...
      'Parent',self.extendpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.512 0.476 0],...
      'Callback',@(hObject,eventdata)self.extendfirstflybuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[6.2 0.846153846153846 26.8 2.53846153846154],...
      'String','First Fly',...
      'UserData',[],...
      'Tag','extendfirstflybutton');
    
    self.autotrackpanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Auto-track...',...
      'Clipping','on',...
      'Position',[101.4 1.30769230769231 78.6 26],...
      'Visible','off',...
      'Tag','autotrackpanel');
    
    uicontrol(...
      'Parent',self.autotrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','times',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.66666666666667 7.84615384615385 74.6666666666667 16.0769230769231],...
      'String',{  'Auto-track fly for a few frames. '; '1) Click on the fly to be tracked in the '; 'frame to be tracked from.'; '2) Push "First Frame" button to select.'; '3) Scroll to the frame to be tracked '; 'until.'; '4) Push "Do It" button. ' },...
      'Style','text',...
      'Tag','text31');
    
    self.autotrackdoitbutton=uicontrol(...
      'Parent',self.autotrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.561 0],...
      'Callback',@(hObject,eventdata)self.autotrackdoitbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[36 0.923076923076923 15.8 2.53846153846154],...
      'String','Do It',...
      'UserData',[],...
      'Tag','autotrackdoitbutton');
    
    self.autotrackcancelbutton=uicontrol(...
      'Parent',self.autotrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.524 0 0],...
      'Callback',@(hObject,eventdata)self.autotrackcancelbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[53.6 0.923076923076923 17.6 2.53846153846154],...
      'String','Cancel',...
      'UserData',[],...
      'Tag','autotrackcancelbutton');
    
    self.autotrackfirstframebutton=uicontrol(...
      'Parent',self.autotrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.512 0.476 0],...
      'Callback',@(hObject,eventdata)self.autotrackfirstframebuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[10.4 0.923076923076923 24 2.53846153846154],...
      'String','First Frame',...
      'UserData',[],...
      'Tag','autotrackfirstframebutton');
    
    self.autotracksettingsbutton=uicontrol(...
      'Parent',self.autotrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0 0.524],...
      'Callback',@(hObject,eventdata)self.autotracksettingsbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[10.4 4 24.8 2.53846153846154],...
      'String','Settings...',...
      'UserData',[],...
      'Tag','autotracksettingsbutton');
    
    self.showtrackingbutton=uicontrol(...
      'Parent',self.autotrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Callback',@(hObject,eventdata)self.showtrackingbuttonTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontSize',12.5,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[38.2 4.23076923076923 30.6 1.76923076923077],...
      'String','Show Tracking',...
      'Style','radiobutton',...
      'Tag','showtrackingbutton');
    
    self.flippanel=uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Flip Orientation...',...
      'Clipping','on',...
      'Position',[101.6 1.07692307692308 78.4 25.9230769230769],...
      'Visible','off',...
      'Tag','flippanel');
    
    uicontrol(...
      'Parent',self.flippanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','times',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.6 3.69230769230769 74.2 20.1538461538462],...
      'String',{  'Flip fly''s orientation in an interval.'; '1) Click on the fly to be flipped in '; 'the first frame to be flipped.'; '2) Push "First Frame" button to select.'; '3) Scroll to the frame to be flipped '; 'until.'; '4) Push "Do It" button. ' },...
      'Style','text',...
      'Tag','text33');
    
    self.flipdoitbutton=uicontrol(...
      'Parent',self.flippanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.561 0],...
      'Callback',@(hObject,eventdata)self.flipdoitbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[35 0.384615384615385 15.6 2.53846153846154],...
      'String','Do It',...
      'UserData',[],...
      'Tag','flipdoitbutton');
    
    self.flipcancelbutton=uicontrol(...
      'Parent',self.flippanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.524 0 0],...
      'Callback',@(hObject,eventdata)self.flipcancelbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[52 0.384615384615385 20.4 2.53846153846154],...
      'String','Cancel',...
      'UserData',[],...
      'Tag','flipcancelbutton');
    
    self.flipfirstframebutton=uicontrol(...
      'Parent',self.flippanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.512 0.476 0],...
      'Callback',@(hObject,eventdata)self.flipfirstframebuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[6 0.384615384615385 27.6 2.53846153846154],...
      'String','First Frame',...
      'UserData',[],...
      'Tag','flipfirstframebutton');
    
    self.debugbutton=uicontrol(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Callback',@(hObject,eventdata)self.debugbuttonTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',12.5,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[27.8333333333333 10.1538461538462 22 1.61538461538462],...
      'String','Debug',...
      'Tag','debugbutton');
    
    self.manytrackpanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Auto-track Multiple...',...
      'Clipping','on',...
      'Position',[102 1.07692307692308 78.6666666666667 26],...
      'Visible','off',...
      'Tag','manytrackpanel');
    
    self.manytrackdoitbutton=uicontrol(...
      'Parent',self.manytrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.561 0],...
      'Callback',@(hObject,eventdata)self.manytrackdoitbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[36 0.923076923076923 15.8 2.53846153846154],...
      'String','Do It',...
      'UserData',[],...
      'Tag','manytrackdoitbutton');
    
    self.manytrackcancelbutton=uicontrol(...
      'Parent',self.manytrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.524 0 0],...
      'Callback',@(hObject,eventdata)self.manytrackcancelbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[53.6 0.923076923076923 17.6 2.53846153846154],...
      'String','Cancel',...
      'UserData',[],...
      'Tag','manytrackcancelbutton');
    
    self.manytrackfirstframebutton=uicontrol(...
      'Parent',self.manytrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.512 0.476 0],...
      'Callback',@(hObject,eventdata)self.manytrackfirstframebuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[10.4 0.923076923076923 24.5 2.53846153846154],...
      'String','First Frame',...
      'UserData',[],...
      'Tag','manytrackfirstframebutton');
    
    self.manytracksettingsbutton=uicontrol(...
      'Parent',self.manytrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0 0.524],...
      'Callback',@(hObject,eventdata)self.manytracksettingsbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[10.4 4 24.5 2.53846153846154],...
      'String','Settings...',...
      'UserData',[],...
      'Tag','manytracksettingsbutton');
    
    self.manytrackshowtrackingbutton=uicontrol(...
      'Parent',self.manytrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Callback',@(hObject,eventdata)self.manytrackshowtrackingbuttonTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontSize',12.5,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[38.2 4.38461538461539 30.6 1.76923076923077],...
      'String','Show Tracking',...
      'Style','radiobutton',...
      'Tag','manytrackshowtrackingbutton');
    
    uicontrol(...
      'Parent',self.manytrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','times',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.66666666666667 7.46153846153846 74.6666666666667 16.3076923076923],...
      'String',{  'Auto-track multiple fly for a few frames. '; '1) Click on the flies to be tracked in the '; 'first frame to be tracked.'; '2) Push "First Frame" button to select.'; '3) Scroll to the last frame to be tracked.'; '4) Push "Do It" button. ' },...
      'Style','text',...
      'Tag','text35');
    
    addnewtrackpanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Add New Track...',...
      'Clipping','on',...
      'Position',[102 1.077 78.6666666666667 26],...
      'Visible','off',...
      'Tag','addnewtrackpanel');
    self.addnewtrackpanel=addnewtrackpanel;
    
    self.addnewtrackdoitbutton=uicontrol(...
      'Parent',addnewtrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.561 0],...
      'Callback',@(hObject,eventdata)self.addnewtrackdoitbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[6.33333333333333 0.923076923076923 19 2.53846153846154],...
      'String','Do It',...
      'UserData',[],...
      'Tag','addnewtrackdoitbutton');
    
    self.addnewtrackcancelbutton=uicontrol(...
      'Parent',addnewtrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.524 0 0],...
      'Callback',@(hObject,eventdata)self.addnewtrackcancelbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[53.6 0.923076923076923 17.6 2.53846153846154],...
      'String','Cancel',...
      'UserData',[],...
      'Tag','addnewtrackcancelbutton');
    
    uicontrol(...
      'Parent',addnewtrackpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','times',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.66666666666667 6.15384615384616 74.6666666666667 17.7692307692308],...
      'String',{  'Add a new fly track.'; '1) Scroll to the first frame to be tracked.'; '4) Push "Do It" button. ' },...
      'Style','text',...
      'Tag','text36');
    
    interpolatepanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Interpolate Track...',...
      'Clipping','on',...
      'Position',[101.6 1.38461538461538 78.4 25.7692307692308],...
      'Visible','off',...
      'Tag','interpolatepanel');
    self.interpolatepanel=interpolatepanel;
    
    uicontrol(...
      'Parent',interpolatepanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','times',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.6 3.92307692307692 73.4 19.8461538461538],...
      'String',{  'Interpolate track for selected fly between'; 'selected frames.'; '1) Scroll to the first frame of the portion of'; 'track to be interpolated. '; '2) Click on the fly to be interpolated.'; '3) Push "First Frame" button to select.'; '4) Scroll to the last frame of the portion of'; 'track to be interpolated.'; '3) Push "Do It" button. ' },...
      'Style','text',...
      'Tag','text26');
    
    self.interpolatedoitbutton=uicontrol(...
      'Parent',interpolatepanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.561 0],...
      'Callback',@(hObject,eventdata)self.interpolatedoitbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[30.4 1 19.8 2.53846153846154],...
      'String','Do It',...
      'UserData',[],...
      'Tag','interpolatedoitbutton');
    
    self.cancelinterpolatebutton=uicontrol(...
      'Parent',interpolatepanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.524 0 0],...
      'Callback',@(hObject,eventdata)self.cancelinterpolatebuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[50.4 1 22 2.53846153846154],...
      'String','Cancel',...
      'UserData',[],...
      'Tag','cancelinterpolatebutton');
    
    self.interpolatefirstframebutton=uicontrol(...
      'Parent',interpolatepanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.512 0.476 0],...
      'Callback',@(hObject,eventdata)self.interpolatefirstframebuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[6.6 1 23.8 2.53846153846154],...
      'String','First Frame',...
      'UserData',[],...
      'Tag','interpolatefirstframebutton');
    
    deletepanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Delete Track...',...
      'Clipping','on',...
      'Position',[101.8 1.46153846153846 78.2 25.6923076923077],...
      'Visible','off',...
      'Tag','deletepanel');
    self.deletepanel=deletepanel;
    
    self.deletedoitbutton=uicontrol(...
      'Parent',deletepanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.561 0],...
      'Callback',@(hObject,eventdata)self.deletedoitbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[24.6 1.07692307692308 16.6 2.53846153846154],...
      'String','Do It',...
      'UserData',[],...
      'Tag','deletedoitbutton');
    
    self.deletecancelbutton=uicontrol(...
      'Parent',deletepanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.524 0 0],...
      'Callback',@(hObject,eventdata)self.deletecancelbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[44.6 0.923076923076923 18.2 2.53846153846154],...
      'String','Cancel',...
      'UserData',[],...
      'Tag','deletecancelbutton');
    
    uicontrol(...
      'Parent',deletepanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','times',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.4 7.15384615384615 66.4 16.1538461538462],...
      'String',{  'Delete the track for selected fly from a'; 'selected frame to the end of its track.'; blanks(0); '1) Scroll to the first frame of the portion of'; 'track to be deleted. '; '2) Click on the fly to be deleted. '; '3) Push "Do It" button. ' },...
      'Style','text',...
      'Tag','text14');
    
    swappanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Swap Identities...',...
      'Clipping','on',...
      'Position',[101.6 1.30769230769231 78.4 25.8461538461538],...
      'Visible','off',...
      'Tag','swappanel');
    self.swappanel=swappanel;
    
    uicontrol(...
      'Parent',swappanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','times',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.4 3.46153846153845 72.8 20.3076923076923],...
      'String',{  'Swap identities for a selected pair of flies between'; 'selected frames.'; '1) Scroll to the first frame of the portion of'; 'tracks to be swapped.'; '2) Select the two flies to be swapped.'; '3) Push "First Frame" button to select.'; '4) Scroll to the last frame of the portion of'; 'track to be swapped.'; '5) Push the "Do It" button. ' },...
      'Style','text',...
      'Tag','text16');
    
    self.swapdoitbutton=uicontrol(...
      'Parent',swappanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.537 0],...
      'Callback',@(hObject,eventdata)self.swapdoitbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[29.3333333333333 0.769230769230761 19.1666666666667 2.53846153846154],...
      'String','Do It',...
      'UserData',[],...
      'Tag','swapdoitbutton');
    
    self.renamecancelbutton=uicontrol(...
      'Parent',swappanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.524 0 0],...
      'Callback',@(hObject,eventdata)self.renamecancelbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[51 0.769230769230761 23 2.53846153846154],...
      'String','Cancel',...
      'UserData',[],...
      'Tag','renamecancelbutton');
    
    self.swapfirstframebutton=uicontrol(...
      'Parent',swappanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.512 0.476 0],...
      'Callback',@(hObject,eventdata)self.swapfirstframebuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[3.16666666666667 0.769230769230761 23.8333333333333 2.53846153846154],...
      'String','First Frame',...
      'UserData',[],...
      'Tag','swapfirstframebutton');
    
    mainaxes=axes(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Position',[1.6 15.5384615384615 98.4 41.6923076923077],...
      'Box','on',...
      'CameraPosition',[0.5 0.5 9.16025403784439],...
      'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
      'Color',get(0,'defaultaxesColor'),...
      'ColorOrder',get(0,'defaultaxesColorOrder'),...
      'FontName','helvetica',...
      'FontSize',12.5,...
      'Layer','top',...
      'LooseInset',[19.8466666666667 5.72 14.5033333333333 3.9],...
      'XColor',get(0,'defaultaxesXColor'),...
      'XTick',[],...
      'XTickMode','manual',...
      'YColor',get(0,'defaultaxesYColor'),...
      'YTick',[],...
      'YTickMode','manual',...
      'ZColor',get(0,'defaultaxesZColor'),...
      'ButtonDownFcn',@(hObject,eventdata)self.mainaxes_ButtonDownFcn(hObject,eventdata),...
      'Tag','mainaxes');
    self.mainaxes=mainaxes;
        
    self.playstopbutton=uicontrol(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.537 0],...
      'Callback',@(hObject,eventdata)self.playstopbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[52 9.69230769230769 14.4 2.53846153846154],...
      'String','Play',...
      'UserData',[],...
      'Tag','playstopbutton');
    
    self.zoomInButton=uicontrol(...
      'Parent',self.fig,...
      'Style','togglebutton', ...
      'Units','characters',...
      'Callback',@(hObject,eventdata)self.zoomInButtonPressed(),...
      'FontName','helvetica',...
      'Position',[91 10.6 4 2],...
      'String','+');
    
    self.zoomOutButton=uicontrol(...
      'Parent',self.fig,...
      'Style','togglebutton', ...
      'Units','characters',...
      'Callback',@(hObject,eventdata)self.zoomOutButtonPressed(),...
      'FontName','helvetica',...
      'Position',[96 10.6 4 2],...
      'String','-');
    
    seqinfopanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Sequence Info',...
      'Clipping','on',...
      'Position',[101.6 48.4615384615385 38.4 9],...
      'Tag','seqinfopanel');
    self.seqinfopanel=seqinfopanel;
    
    self.errnumbertext=uicontrol(...
      'Parent',seqinfopanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 5.8 34.2 1.6],...
      'String','Error:',...
      'Style','text',...
      'Tag','errnumbertext');
    
    self.seqframestext=uicontrol(...
      'Parent',seqinfopanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 4.4 34.4 1.6],...
      'String','Frames:',...
      'Style','text',...
      'Tag','seqframestext');
    
    self.seqfliestext=uicontrol(...
      'Parent',seqinfopanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 3 34.4 1.6],...
      'String','Flies:',...
      'Style','text',...
      'Tag','seqfliestext');
    
    self.seqtypetext=uicontrol(...
      'Parent',seqinfopanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 1.6 34.2 1.6],...
      'String','Type: ',...
      'Style','text',...
      'Tag','seqtypetext');
    
    self.seqsusptext=uicontrol(...
      'Parent',seqinfopanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 0.2 34.2 1.6],...
      'String','Susp: ',...
      'Style','text',...
      'Tag','seqsusptext');
    
    frameinfopanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Frame Info',...
      'Clipping','on',...
      'Position',[142.2 48.4615384615385 37.6 9],...
      'Tag','frameinfopanel');
    self.frameinfopanel=frameinfopanel;
    
    uicontrol(...
      'Parent',frameinfopanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 5.8 19.6 1.6],...
      'String','Frame',...
      'Style','text',...
      'Tag','text1');
    
    self.frameedit=uicontrol(...
      'Parent',frameinfopanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[1 1 1],...
      'Callback',@(hObject,eventdata)self.frameeditTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',14,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[23.6 5.6923076923077 12.6 2.07692307692308],...
      'String',blanks(0),...
      'Style','edit',...
      'Tag','frameedit');
    
    self.suspframetext=uicontrol(...
      'Parent',frameinfopanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 2.76923076923077 33.6 1.6],...
      'String','Susp: ',...
      'Style','text',...
      'Tag','suspframetext');
    
    self.frameofseqtext=uicontrol(...
      'Parent',frameinfopanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 4.32307692307692 22 1.6],...
      'String','Frame of Seq: ',...
      'Style','text',...
      'Tag','frameofseqtext');
    
    uicontrol(...
      'Parent',frameinfopanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 1.29230769230769 34 1.6],...
      'String','Current Fly: ',...
      'Style','text',...
      'Tag','selectedflytext',...
      'Visible','off');
    
    navigationpanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Navigation Tools',...
      'Clipping','on',...
      'Position',[101.6 39.4615384615385 78.4 8.53846153846154],...
      'Tag','navigationpanel');
    self.navigationpanel=navigationpanel;
    
    uicontrol(...
      'Parent',navigationpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 5.15384615384616 23.4 1.61538461538461],...
      'String','Next Error Type:',...
      'Style','text',...
      'Tag','text8');
    
    uicontrol(...
      'Parent',navigationpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[2 3.30769230769231 23.6 1.61538461538461],...
      'String','Sort By:',...
      'Style','text',...
      'Tag','text9');
    
    self.correctbutton=uicontrol(...
      'Parent',navigationpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.561 0],...
      'Callback',@(hObject,eventdata)self.correctbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[19.8333333333333 0.384615384615385 19 2.53846153846154],...
      'String','Finish',...
      'UserData',[],...
      'Tag','correctbutton');
    
    self.backbutton=uicontrol(...
      'Parent',navigationpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.549 0.512 0],...
      'Callback',@(hObject,eventdata)self.backbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[41.6666666666667 0.384615384615385 19 2.53846153846154],...
      'String','Back',...
      'UserData',[],...
      'Tag','backbutton');
    
    self.sortbymenu=uicontrol(...
      'Parent',navigationpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[1 1 1],...
      'Callback',@(hObject,eventdata)self.sortbymenuTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',14,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[25.6 3.38461538461539 49 2],...
      'String',{  'Suspiciousness'; 'Frame Number'; 'Fly' },...
      'Style','popupmenu',...
      'Value',1,...
      'Tag','sortbymenu');
    
    self.nexterrortypemenu=uicontrol(...
      'Parent',navigationpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[1 1 1],...
      'Callback',@(hObject,eventdata)self.nexterrortypemenuTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',14,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[25.6 5.30769230769231 49 2],...
      'String','No more errors',...
      'Style','popupmenu',...
      'Value',1,...
      'Tag','nexterrortypemenu');
    
    editpanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Edit Tools',...
      'Clipping','on',...
      'Position',[101.6 27.7692307692308 78.4 4.07692307692308],...
      'Tag','editpanel');
    self.editpanel=editpanel;
    
    self.undobutton=uicontrol(...
      'Parent',editpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0.512 0.476 0],...
      'Callback',@(hObject,eventdata)self.undobuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[61 0.400000000000001 13.6 2.5],...
      'String','Undo',...
      'UserData',[],...
      'Tag','undobutton');
    
    self.gobutton=uicontrol(...
      'Parent',editpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.573 0],...
      'Callback',@(hObject,eventdata)self.gobuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[46 0.400000000000001 13.8 2.5],...
      'String','Go',...
      'UserData',[],...
      'Tag','gobutton');
    
    self.editPopupMenu=uicontrol(...
      'Parent',editpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[1 1 1],...
      'Callback',@(hObject,eventdata)self.editPopupMenuTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',14,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.8 0.538461538461539 42.6 2],...
      'String',{  'Swap Identities...'; ...
                  'Interpolate...'; ...
                  'Flip Orientation...'; ...
                  'Extend Track...'; ...
                  'Add New Track...'; ...
                  'Delete Track...'; ...
                  'Auto-track...'; ...
                  'Auto-track Multiple...'; ...
                  'Connect Tracks...' },...
      'Style','popupmenu',...
      'Value',1,...
      'Tag','editPopupMenu');
    
    self.printbutton= ...
      uicontrol(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Callback',@(hObject,eventdata)self.printbuttonTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',12.5,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[4 10.1538461538462 22 1.61538461538462],...
      'String','Print Trx',...
      'Tag','printbutton');
    
    seekpanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Seek Tools',...
      'Clipping','on',...
      'Position',[102 32.2307692307693 78 6.76923076923077],...
      'Tag','seekpanel');
    self.seekpanel=seekpanel;
    
    self.previousbutton=uicontrol(...
      'Parent',seekpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0 0.573],...
      'Callback',@(hObject,eventdata)self.previousbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[57.6 2.92307692307693 17.8 2.53846153846154],...
      'String','Prev',...
      'UserData',[],...
      'Tag','previousbutton');
    
    self.nextbutton=uicontrol(...
      'Parent',seekpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[0 0.573 0],...
      'Callback',@(hObject,eventdata)self.nextbuttonTwiddled(hObject,eventdata),...
      'CData',[],...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',16,...
      'FontWeight','bold',...
      'ForegroundColor',[1 1 1],...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[37.6 2.92307692307693 19 2.53846153846154],...
      'String','Next',...
      'UserData',[],...
      'Tag','nextbutton');
    
    uicontrol(...
      'Parent',seekpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[2.66666666666667 0.692307692307693 71 1.46153846153846],...
      'String','Seek to Next/Prev in the current axes',...
      'Style','text',...
      'Tag','seekdirtext');
    
    self.seekmenu=uicontrol(...
      'Parent',seekpanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[1 1 1],...
      'Callback',@(hObject,eventdata)self.seekmenuTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',14,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[1.83333333333333 3.15384615384616 34.3333333333333 2],...
      'String',{  'Birth Nearby'; 'Death Nearby' },...
      'Style','popupmenu',...
      'Value',1,...
      'Tag','seekmenu');
    
    self.flipimage_checkbox=uicontrol(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Callback',@(hObject,eventdata)self.flipimage_checkboxTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',12.5,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[68.6666666666667 10.3076923076923 23 1.30769230769231],...
      'String','Flip image',...
      'Style','checkbox',...
      'Tag','flipimage_checkbox', ...
      'visible','off');
    
    displaypanel = uipanel(...
      'Parent',self.fig,...
      'Units','characters',...
      'FontUnits','pixels',...
      'FontName','helvetica',...
      'FontSize',15,...
      'Title','Display',...
      'Clipping','on',...
      'Position',[2.2 1.38461538461538 97 8.07692307692308],...
      'Tag','displaypanel');
    self.displaypanel=displaypanel;
    
    uicontrol(...
      'Parent',displaypanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[2.4 3.92307692307692 17.8 1.61538461538461],...
      'String','Plot Path: ',...
      'Style','text',...
      'Tag','text22');
    
    uicontrol(...
      'Parent',displaypanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[53.4 3.92307692307692 21 1.61538461538461],...
      'String','NFrames Plot:',...
      'Style','text',...
      'Tag','text23');
    
    self.nframesplotedit=uicontrol(...
      'Parent',displaypanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[1 1 1],...
      'Callback',@(hObject,eventdata)self.nframesploteditTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',14,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[72.8 3.92307692307693 11.8 2.07692307692308],...
      'String','101',...
      'Style','edit',...
      'Tag','nframesplotedit');
    
    uicontrol(...
      'Parent',displaypanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',15,...
      'HorizontalAlignment','left',...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[3 1.15384615384615 13.1666666666667 1.61538461538462],...
      'String','Zoom: ',...
      'Style','text',...
      'Tag','text24');
    
    self.zoommenu=uicontrol(...
      'Parent',displaypanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[1 1 1],...
      'Callback',@(hObject,eventdata)self.zoommenuTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',14,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[16.2 1 26.8 2],...
      'String',{  'Whole Arena'; 'Sequence' },...
      'Style','popupmenu',...
      'Value',2,...
      'Tag','zoommenu');
    
    self.plotpathmenu=uicontrol(...
      'Parent',displaypanel,...
      'Units','characters',...
      'FontUnits','pixels',...
      'BackgroundColor',[1 1 1],...
      'Callback',@(hObject,eventdata)self.plotpathmenuTwiddled(hObject,eventdata),...
      'Enable','off',...
      'FontName','helvetica',...
      'FontSize',14,...
      'KeyPressFcn',@(hObject,eventdata)self.keyPressed(hObject,eventdata),...
      'Position',[17 3.84615384615385 22 2],...
      'String',{  'All Flies'; 'Seq Flies'; 'No Flies' },...
      'Style','popupmenu',...
      'Value',1,...
      'Tag','plotpathmenu');
    
    fileMenu = uimenu(...
      'Parent',self.fig,...
      'Callback',@(hObject,eventdata)self.fileMenuTwiddled(hObject,eventdata),...
      'Label','File',...
      'Tag','fileMenu');
    self.fileMenu=fileMenu;
    
    self.fileMenuOpenItem=uimenu(...
      'Parent',fileMenu,...
      'Accelerator','O',...
      'Callback',@(hObject,eventdata)self.fileMenuOpenItemTwiddled(hObject,eventdata),...
      'Label','Open...',...
      'Tag','fileMenuOpenItem');
    
    self.fileMenuCloseItem=uimenu(...
      'Parent',fileMenu,...
      'Callback',@(hObject,eventdata)self.fileMenuCloseItemTwiddled(hObject,eventdata),...
      'Enable','off',...
      'Label','Close',...
      'Tag','fileMenuCloseItem');
    
    self.fileMenuSaveItem=uimenu(...
      'Parent',fileMenu,...
      'Accelerator','S',...
      'Callback',@(hObject,eventdata)self.fileMenuSaveItemTwiddled(hObject,eventdata),...
      'Enable','off',...
      'Label','Save',...
      'Separator','on',...
      'Tag','fileMenuSaveItem');
    
    self.fileMenuSaveAsItem=uimenu(...
      'Parent',fileMenu,...
      'Callback',@(hObject,eventdata)self.fileMenuSaveAsItemTwiddled(hObject,eventdata),...
      'Enable','off',...
      'Label','Save As...',...
      'Tag','fileMenuSaveAsItem');
    
    self.fileMenuQuitItem=uimenu(...
      'Parent',fileMenu,...
      'Accelerator','Q',...
      'Callback',@(hObject,eventdata)self.fileMenuQuitItemTwiddled(hObject,eventdata),...
      'Label','Quit',...
      'Separator','on',...
      'Tag','fileMenuQuitItem');

    adjustColorsIfMac(self.fig);
  end  % method

  
  
  % -----------------------------------------------------------------------
  function updateControlVisibilityAndEnablement(self)    
    fig=self.fig;
    
    % Extract model variables we'll need
    isFileOpen=self.isFileOpen;
    thereAreUnsavedChanges=self.needssaving;
    editMode=self.editMode;  % the current editing mode, or empty if not in an editing mode
    
    % As a first pass, enable/disable uicontrols depending on isFileOpen
    controls=findall(fig,'type','uicontrol');
    set(controls,'enable',onIff(isFileOpen));
    
    % Now refine things based on other settings
    
    % zoom buttons
    set(self.zoomInButton ,'enable',onIff(isFileOpen));
    set(self.zoomOutButton,'enable',onIff(isFileOpen));

    % File menu item enablement
    set(self.fileMenuOpenItem ,'enable',onIff(~isFileOpen));
    set(self.fileMenuCloseItem,'enable',onIff( isFileOpen));
    set(self.fileMenuSaveItem,'enable',onIff(isFileOpen&&thereAreUnsavedChanges));
    set(self.fileMenuSaveAsItem,'enable',onIff(isFileOpen));
    
    % Buttons that are always visible
    %set(self.quitbutton,'enable','on');  % can always quit
    %set(self.savebutton,'enable',onIff(isFileOpen&&thereAreUnsavedChanges));
    
    % Set the enablement of things in the edit tools panel
    set(self.editPopupMenu  ,'enable',onIff(isFileOpen&&isempty(editMode)));
    set(self.gobutton  ,'enable',onIff(isFileOpen&&isempty(editMode)));
    set(self.undobutton,'enable',onIff(isFileOpen&&isempty(editMode)&&~isempty(self.undolist)));
    
    % Set the visibility of the various editing panels, based on the edit mode
    set(self.deletepanel,'visible',onIff(strcmpi(editMode,'delete track...')));
    set(self.interpolatepanel,'visible',onIff(strcmpi(editMode,'interpolate...')));
    set(self.connectpanel,'visible',onIff(strcmpi(editMode,'connect tracks...')));
    set(self.swappanel,'visible',onIff(strcmpi(editMode,'swap identities...')));
    set(self.extendpanel,'visible',onIff(strcmpi(editMode,'extend track...')));
    set(self.autotrackpanel,'visible',onIff(strcmpi(editMode,'auto-track...')));
    set(self.flippanel,'visible',onIff(strcmpi(editMode,'flip orientation...')));
    set(self.manytrackpanel,'visible',onIff(strcmpi(editMode,'auto-track multiple...')));
    set(self.addnewtrackpanel,'visible',onIff(strcmpi(editMode,'add new track...')));
    
    %
    % Set the enablement of various edit panel buttons
    %
    
    % delete panel
    set(self.deletedoitbutton, ...
        'enable', ...
          onIff(strcmpi(editMode,'delete track...') && ...
          (length(self.selected)==1)));

    % swap ID panel
    set(self.swapfirstframebutton, ...
      'enable', ...
      onIff(strcmpi(editMode,'swap identities...')&& ...
      (self.nselect==2)&& ...
      (length(self.selected)==2)));
    set(self.swapdoitbutton, ...
      'enable', ...
      onIff(strcmpi(editMode,'swap identities...')&&(self.nselect==0)));
    
    % connect panel
    set(self.connectdoitbutton,'enable',onIff(strcmpi(editMode,'connect tracks...')&&(self.connectfirstframe>0)));
    
    % interpolate panel
    set(self.interpolatefirstframebutton, ...
      'enable', ...
      onIff(strcmpi(editMode,'interpolate...')&& ...
      (self.nselect==1)&& ...
      (length(self.selected)==1)));
    set(self.interpolatedoitbutton, ...
      'enable', ...
      onIff(strcmpi(editMode,'interpolate...')&& ...
      (self.nselect==0)));
    
    % other panels
    set(self.extenddoitbutton,'enable',onIff(strcmpi(editMode,'extend track...')&&(self.extendFlySelected)));
    set(self.autotrackdoitbutton,'enable',onIff(strcmpi(editMode,'auto-track...')&&(self.autotrackframe>0)));
    set(self.autotracksettingsbutton,'enable',onIff(strcmpi(editMode,'auto-track...')&&(self.autotrackframe>0)));
    set(self.flipdoitbutton,'enable',onIff(strcmpi(editMode,'flip orientation...')&&(self.flipframe>0)));
    set(self.manytrackdoitbutton,'enable',onIff(strcmpi(editMode,'auto-track multiple...')&&(self.manytrackframe>0)));
    set(self.manytracksettingsbutton,'enable',onIff(strcmpi(editMode,'auto-track multiple...')&&(self.manytrackframe>0)));
    set(self.addnewtrackdoitbutton, 'enable',onIff(strcmpi(editMode,'add new track...')));
    
  end  % method

  
  
  % -----------------------------------------------------------------------
  function trx = fixIgnoredFields(self)
    % Some trx fields are ignored during tracking/editing, because they can be
    % re-derived from existing data. This function does that.
    %
    % splintered from fixerrorsgui 6/23/12 JAB
    
    trx = self.trx;
    
    % fix timestamps
    if ~isempty(self.timestamps),
      for i = 1:numel(self.trx),
        if isdummytrk(self.trx(i)),
          continue;
        end
        t0 = self.trx(i).firstframe;
        t1 = self.trx(i).endframe;
        trx(i).timestamps = self.timestamps(t0:t1);
      end
    end
    
    % all the converted fields may be wrong; reconvert from
    if ~isempty( trx )
      trx = apply_convert_units(trx);
    end
  end
  
  
  
  % -----------------------------------------------------------------------
  function oldPointer=pointerToWatch(self)
    oldPointer=get(self.fig,'pointer');
    if ~strcmpi(oldPointer,'watch')
      set(self.fig,'pointer','watch');
    end
    drawnow('update');
  end  % method



  % -----------------------------------------------------------------------
  function restorePointer(self,oldPointer)
    drawnow('update');  % make sure everything is updated before we restore the pointer
    currentPointer=get(self.fig,'pointer');
    if ~strcmpi(oldPointer,currentPointer)
      set(self.fig,'pointer',oldPointer);
    end
    drawnow('update');
  end  % method



  % -----------------------------------------------------------------------
  function setFrameNumber(self,hObject)
    % show the current frame
    % splintered from fixerrorsgui 6/21/12 JAB
    
    if nargin < 2,
      hObject = -1;
    end
    
    if hObject ~= self.frameslider,
      if ~isempty(self.f) ,
        set(self.frameslider,'Value',self.f);
      end
    end
    if hObject ~= self.frameedit,
      set(self.frameedit,'string',num2str(self.f));
    end
    if isempty(self.f) || isempty(self.seq)
      set(self.frameofseqtext,'string','', ...
        'backgroundcolor',get(self.fig,'color'),...
        'foregroundcolor',[0 0 0]);
    elseif self.f < self.seq.frames(1),
      set(self.frameofseqtext,'string','Before Sequence','backgroundcolor',[1,0,0],...
        'foregroundcolor',[1,1,1]);
    elseif self.f > self.seq.frames(end),
      set(self.frameofseqtext,'string','After Sequence','backgroundcolor',[1,0,0],...
        'foregroundcolor',[1,1,1]);
    elseif self.f == self.seq.frames(1),
      set(self.frameofseqtext,'string','Frame of Seq: 1','backgroundcolor',[0,0,1],...
        'foregroundcolor',[1,1,1]);
    elseif self.f == self.seq.frames(end),
      set(self.frameofseqtext,'string',...
        sprintf('Frame of Seq: %d',self.f-self.seq.frames(1)+1),...
        'backgroundcolor',[1,1,0]/2,'foregroundcolor',[1,1,1]);
    else
      set(self.frameofseqtext,'string',...
        sprintf('Frame of Seq: %d',self.f-self.seq.frames(1)+1),...
        'backgroundcolor',[.7,.7,.7],'foregroundcolor',[0,0,0]);
    end
    if isempty(self.f) || isempty(self.seq)
      set(self.suspframetext,'string','Susp: --');
    else
      i = find(self.seq.frames == self.f);
      if isempty(i),
        set(self.suspframetext,'string','Susp: --');
      else
        set(self.suspframetext,'string',sprintf('Susp: %f',self.seq.suspiciousness(i)));
      end
    end
    
    if ~isempty(self.motionobj),
      if ~isalive(self.trx(self.motionobj{2}),self.f),
        self.motionobj = [];
      end
    end
  end  % method
  
  
  
  % -----------------------------------------------------------------------
  function setSeq(self,seqi,isfirstframe)
    % set the GUI state for displaying a particular sequence index
    % splintered from fixerrorsgui 6/23/12 JAB
    
    self.seqi = seqi;
    self.seq = self.seqs(seqi);
    self.f = self.seq.frames(1);
    self.nselect = 0;
    self.selected = [];
    set(self.errnumbertext,'string',sprintf('Error: %d/%d',seqi,length(self.seqs)));
    set(self.seqframestext,'string',sprintf('Frames: %d:%d',self.seq.frames(1),self.seq.frames(end)));
    set(self.seqfliestext,'string',['Flies: [',num2str(self.seq.flies),']']);
    set(self.seqtypetext,'string',sprintf('Type: %s',self.seq.type));
    set(self.seqsusptext,'string',sprintf('Susp: %f',max(self.seq.suspiciousness)));
    
    % % Not sure what this is doing, but we don't want to do it for mice, we
    % want the color to stay the same
    
    % % set fly colors so that flies that are close have different colors
    % x = nan(1,handles.nflies);
    % y = nan(1,handles.nflies);
    % f = round(mean([handles.seq.frames(1),handles.seq.frames(end)]));
    % for fly = 1:handles.nflies,
    %   if ~isalive(handles.trx(fly),f),
    %     continue;
    %   end
    %   i = handles.trx(fly).off+(f);
    %   x(fly) = handles.trx(fly).x(i);
    %   y(fly) = handles.trx(fly).y(i);
    % end
    
    % D = squareform(pdist([x;y]'));
    % handles.colors(handles.seq.flies,:) = handles.colors0(handles.colororder(1:length(handles.seq.flies)),:);
    % isassigned = false(1,handles.nflies);
    % isassigned(handles.seq.flies) = true;
    % D(:,handles.seq.flies) = nan;
    % for i = length(handles.seq.flies)+1:handles.nflies,
    %   [mind,fly] = min(min(D(isassigned,:),[],1));
    %   if isnan(mind),
    %     handles.colors(~isassigned,:) = handles.colors0(handles.colororder(i:end),:);
    %     break;
    %   end
    %   handles.colors(fly,:) = handles.colors0(handles.colororder(i),:);
    %   isassigned(fly) = true;
    %   D(:,fly) = nan;
    % end
    
    function safeset(h,varargin)
      if ishandle(h),
        set(h,varargin{:});
      end
    end  % function
    
    if ~isempty(self.hpath),
      for fly = 1:self.nflies,
        if length( self.hpath ) < fly
          %fprintf( 1, 'error at fly %d: nflies %d; len hpath %d, len hcenter %d\n', fly, handles.nflies, length( handles.hpath ), length( handles.hcenter ) );
          break
        end
        safeset(self.hpath(fly),'color',self.colors(fly,:));
        safeset(self.hpath(fly),'color',self.colors(fly,:));
        safeset(self.htailmarker(fly),'color',self.colors(fly,:));
        safeset(self.hellipse(fly),'color',self.colors(fly,:));
        safeset(self.hleft(fly),'color',self.colors(fly,:));
        safeset(self.hright(fly),'color',self.colors(fly,:));
        safeset(self.hhead(fly),'color',self.colors(fly,:));
        safeset(self.htail(fly),'color',self.colors(fly,:));
        safeset(self.hcenter(fly),'color',self.colors(fly,:));
      end
    end
    
    if nargin < 3 || ~isfirstframe,
      setFrameNumber(self);
      PlotFrame(self);
      zoomInOnSeq(self);
    end
  end  % method

  
  
  % -----------------------------------------------------------------------
  function play(self)
    % play through a sequence
    % splintered from fixerrorsgui 6/23/12 JAB
    
    self.isplaying = true;
    set(self.playstopbutton,'string','Stop','backgroundcolor',[.5,0,0]);
    %guidata(hObject,self);
    f0 = max(1,self.seq.frames(1)-10);
    f1 = min(self.nframes,self.seq.frames(end)+10);
    
    for f = f0:f1,
      
      self.f = f;
      setFrameNumber(self);
      PlotFrame(self);
      drawnow;
      %self = guidata(hObject);
      
      if ~self.isplaying,
        break;
      end
      
    end
    
    self.f = f;
    
    if self.isplaying,
      self.f = self.seq.frames(1);
      setFrameNumber(self);
      PlotFrame(self);
    end
    
    self.isplaying = false;
    set(self.playstopbutton,'string','Play','backgroundcolor',[0,.5,0]);
    %guidata(hObject,self);
  end  % method

  
  
  % -----------------------------------------------------------------------
  function setErrorTypes(self)
    % set "next error type" menu values based on remaining suspicious sequences
    % splintered from fixerrorsgui 6/23/12 JAB
    
    isbirth = false; isdeath = false;
    isswap = false; isjump = false;
    isorientchange = false; isorientvelmismatch = false;
    islargemajor = false;
    for i = 1:length(self.seqs),
      if ~isempty( strfindi(self.seqs(i).type,'dummy') ),
        continue;
      end
      eval(sprintf('is%s = true;',self.seqs(i).type));
    end
    s = {};
    if isbirth,
      s{end+1} = 'Track Birth';  %#ok
    end
    if isdeath
      s{end+1} = 'Track Death';  %#ok
    end
    if isswap,
      s{end+1} = 'Match Cost Ambiguity';  %#ok
    end
    if isjump,
      s{end+1} = 'Large Jump';  %#ok
    end
    if isorientchange,
      s{end+1} = 'Large Change in Orientation';  %#ok
    end
    if isorientvelmismatch,
      s{end+1} = 'Velocity & Orient. Mismatch';  %#ok
    end
    if islargemajor,
      s{end+1} = 'Large Major Axis';  %#ok
    end
    content = get(self.nexterrortypemenu,'string');
    if ~iscell(content)
      content={content};
    end
    v = get(self.nexterrortypemenu,'value');
    if isempty(v) || v<1 || v > length(content),
      set(self.nexterrortypemenu,'value',length(content));
      v = length(content);
    end
    sel = content{v};
    if isempty(s),
      set(self.nexterrortypemenu,'string','No more errors','value',1);
      set(self.correctbutton,'string','Finish');
    else
      set(self.nexterrortypemenu,'string',s);
      set(self.correctbutton,'string','Correct');
      i = find(strcmpi(sel,s));
      if ~isempty(i),
        set(self.nexterrortypemenu,'value',i);
      else
        if length(s) >= v,
          set(self.nexterrortypemenu,'value',min(v,length(s)));
        end
      end
    end
  end  % method
  
  
  
  % -----------------------------------------------------------------------
  function storePanelPositions(self)
    % store the positions of the panels in the GUI
    % splintered from fixerrorsgui 6/23/12 JAB
    
    % store positions of right side panels
    self.rightpanel_tags = {'seqinfopanel','frameinfopanel','navigationpanel',...
      'seekpanel','editpanel',...
      'deletepanel','interpolatepanel','connectpanel','swappanel','extendpanel',...
      'autotrackpanel','flippanel','manytrackpanel', 'addnewtrackpanel'};
    figpos = get(self.fig,'Position');
    
    ntags = numel(self.rightpanel_tags);
    self.rightpanel_dright = nan(1,ntags);
    self.rightpanel_dtop = nan(1,ntags);
    for fni = 1:ntags,
      fn = self.rightpanel_tags{fni};
      h = self.(fn);
      pos = get(h,'Position');
      self.rightpanel_dright(fni) = figpos(3)-pos(1);
      self.rightpanel_dtop(fni) = figpos(4)-pos(2);
    end
    
    % store positions of stuff below the axes
    self.bottom_tags = {'printbutton','debugbutton','playstopbutton',...
      'displaypanel','frameslider', 'flipimage_checkbox', 'zoomInButton','zoomOutButton'};
    ntags = numel(self.bottom_tags);
    %self.bottom_width_norm = nan(1,ntags);
    %self.bottom_dleft_norm = nan(1,ntags);
    %self.bottom_dleft = nan(1,ntags);
    self.bottom_dleft_from_image_right_edge = nan(1,ntags);
    mainAxesPosition = get(self.mainaxes,'Position');
    for fni = 1:ntags,
      fn = self.bottom_tags{fni};
      h = self.(fn);
      pos = get(h,'Position');
      %self.bottom_width_norm(fni) = pos(3)/figpos(3);
      %self.bottom_dleft(fni) = pos(1);
      %self.bottom_dleft_norm(fni) = pos(1)/figpos(3);
      self.bottom_dleft_from_image_right_edge(fni) = ...
        pos(1)-(mainAxesPosition(1)+mainAxesPosition(3));
    end
    
    % store axes position stuff
    %pos = get(self.mainaxes,'Position');
    sliderpos = get(self.frameslider,'Position');
    rightpanelpos = get(self.seqinfopanel,'Position');
    self.axes_dtop = figpos(4) - (mainAxesPosition(2)+mainAxesPosition(4));
    self.axes_dslider = mainAxesPosition(2) - (sliderpos(2)+sliderpos(4));
    self.axes_drightpanels = rightpanelpos(1)-(mainAxesPosition(1)+mainAxesPosition(3));
  end  % method
  
  
  
  % -----------------------------------------------------------------------
  function updateFlyPathVisible(self)
    % makes fly path visible or invisible
    % splintered from fixerrorsgui 6/21/12 JAB
    
    hObject = self.plotpathmenu;
    contents = get(hObject,'String');
    s = contents{get(hObject,'Value')};
    self.plotpath = s;
    
    for fly = 1:self.nflies,
      if isdummytrk(self.trx(fly))
        if ishandle(self.hpath(fly)) && self.hpath(fly) > 0,
          delete(self.hpath(fly));
        end
        continue;
      end
      if strcmpi(self.plotpath,'all flies') || ...
          (strcmpi(self.plotpath,'seq flies') && ismember(fly,self.seq.flies)),
        set(self.hpath(fly),'visible','on');
      else
        set(self.hpath(fly),'visible','off');
      end
    end
  end  % method
  
  
  
  % -----------------------------------------------------------------------
  function fixUpdateFly(self,fly)
    % sets fly plot properties based on fly data
    % splintered from fixerrorsgui 6/21/12 JAB
    
    if isdummytrk(self.trx(fly)),
      return
    end
    
    ii = self.trx(fly).off+(self.f);
    
    if isalive(self.trx(fly),self.f)
      setFlyVisible(self,fly,'on');
      i = ii;
    else
      setFlyVisible(self,fly,'off');
      i = 1;
    end
    
    x = self.trx(fly).x(i);
    y = self.trx(fly).y(i);
    a = 2*self.trx(fly).a(i);
    b = 2*self.trx(fly).b(i);
    theta = self.trx(fly).theta(i);
    ellipseupdate(self.hellipse(fly),a,b,x,y,theta);
    
    xleft = x - b*cos(theta+pi/2);
    yleft = y - b*sin(theta+pi/2);
    xright = x + b*cos(theta+pi/2);
    yright = y + b*sin(theta+pi/2);
    xhead = x + a*cos(theta);
    yhead = y + a*sin(theta);
    xtail = x - a*cos(theta);
    ytail = y - a*sin(theta);
    
    set(self.htailmarker(fly),'xdata',[xtail,x],'ydata',[ytail,y]);
    set(self.hleft(fly),'xdata',xleft,'ydata',yleft);
    set(self.hright(fly),'xdata',xright,'ydata',yright);
    set(self.hhead(fly),'xdata',xhead,'ydata',yhead);
    set(self.htail(fly),'xdata',xtail,'ydata',ytail);
    set(self.hcenter(fly),'xdata',x,'ydata',y);
    
    i0 = ii - floor((self.nframesplot-1)/2);
    i1 = ii + self.nframesplot - 1;
    i0 = max(i0,1);
    i1 = min(i1,self.trx(fly).nframes);
    set(self.hpath(fly),'xdata',self.trx(fly).x(i0:i1),...
        'ydata',self.trx(fly).y(i0:i1));
    
    %handles.needssaving = 1;
    %guidata( self.fig, self )
    
  end  % method
  


  % -----------------------------------------------------------------------
  function setFlyVisible(self,fly,v)
    % makes fly body visible or invisible
    % splintered from fixerrorsgui 6/21/12 JAB
    
    if isdummytrk(self.trx(fly))
      return
    end
    
    set(self.hellipse(fly),'visible',v);
    set(self.hcenter(fly),'visible',v);
    set(self.hleft(fly),'visible',v);
    set(self.hright(fly),'visible',v);
    set(self.hhead(fly),'visible',v);
    set(self.htail(fly),'visible',v);
    set(self.htailmarker(fly),'visible',v);
    %set(handles.hpath(fly),'visible',v);
  end  % method

  
  
  % -----------------------------------------------------------------------
  function zoomInOnSeq(self,seq)
    % set plot axes to show a particular sequence number
    % splintered from fixerrorsgui 6/21/12 JAB
    
    if strcmpi(self.zoommode,'whole arena'),
      return;
    end
    
    if ~exist('seq','var'),
      seq = self.seq;
    end
    
    border = round(min(self.nr,self.nc)/30);
    
    if isempty(seq)
      return
    end
    
    frames = max(min(seq.frames)-10,1):max(seq.frames)+10;
    nfliesseq = length(seq.flies);
    nframesseq = length(frames);
    x0 = nan(nfliesseq,nframesseq);
    x1 = nan(nfliesseq,nframesseq);
    y0 = nan(nfliesseq,nframesseq);
    y1 = nan(nfliesseq,nframesseq);
    for flyi = 1:nfliesseq,
      fly = seq.flies(flyi);
      for fi = 1:nframesseq,
        f = frames(fi);
        i = self.trx(fly).off+(f);
        if isalive(self.trx(fly),f)
          [x0(flyi,fi),x1(flyi,fi),y0(flyi,fi),y1(flyi,fi)] = ...
            ellipse_to_bounding_box(self.trx(fly).x(i), ...
                                    self.trx(fly).y(i), ...
                                    self.trx(fly).a(i)*2, ...
                                    self.trx(fly).b(i)*2, ...
                                    self.trx(fly).theta(i));
        end
      end
    end
    badidx = isnan(x0);
    %if length( find( badidx ) ) == length( x0(:) ), error( 'all tracks bad' ); end
    if length( find( badidx ) ) ~= length( x0(:) ) ,
      x0(badidx) = []; y0(badidx) = []; x1(badidx) = []; y1(badidx) = [];
      
      xlim = [min(x0(:))-border,max(x1(:))+border];
      xlim = max(min(xlim,self.nc+0.5),0.5);
      ylim = [min(y0(:))-border,max(y1(:))+border];
      ylim = max(min(ylim,self.nr+0.5),0.5);
      
      % match aspect ratio
      [xlim,ylim] = self.matchAspectRatio(xlim,ylim);
      
      set(self.mainaxes,'xlim',xlim,'ylim',ylim);
    end
    
  end  % method

  
  
  % -----------------------------------------------------------------------
  function [xl,yl] = matchAspectRatio(self,xl0,yl0)
    % zoom in on a set of limits as much as possible without changing aspect ratio
    % splintered from fixerrorsgui 6/21/12 JAB
    
    xl=xl0;
    yl=yl0;
    aspectratiocurr = diff(xl)/diff(yl);
    if aspectratiocurr < self.mainaxesaspectratio,
      % make x limits bigger to match
      xmu = mean(xl);
      dx = diff(yl)*self.mainaxesaspectratio;
      xl = xmu+[-dx/2,dx/2];
      % if xl overruns the image bounds, correct it
      if xl(1)<0.5
        xl=0.5+[0 dx];
      end
      if xl(2)>self.nc+0.5
        xl=self.nc+0.5+[-dx 0];
      end
    else
      % make y limits bigger to match
      ymu = mean(yl);
      dy = diff(xl)/self.mainaxesaspectratio;
      yl = ymu+[-dy/2,dy/2];
      % if yl overruns the image bounds, correct it
      if yl(1)<0.5
        yl=0.5+[0 dy];
      end
      if yl(2)>self.nr+0.5
        yl=self.nr+0.5+[-dy 0];
      end
    end
  end  % method

  
  
  % -----------------------------------------------------------------------
  function PlotFrame(self)
    % plot a single video frame
    % splintered from fixerrorsgui 6/21/12 JAB
    
    im = self.readframe(self.f);
    if( self.flipud )
      for channel = 1:size( im, 3 )
        im(:,:,channel) = flipud( im(:,:,channel) );  %#ok
      end
    end
    set(self.him,'cdata',im);
    for fly = 1:self.nflies,
      fixUpdateFly(self,fly);
      if ~isdummytrk(self.trx(fly))
        if length(self.trx(fly).x) ~= self.trx(fly).nframes || ...
            1 + self.trx(fly).endframe - self.trx(fly).firstframe ~= self.trx(fly).nframes,
          keyboard;
        end
      end
    end
  end  % method

  
  
  % -----------------------------------------------------------------------  
  function currentEditModeCancelled(self)
    % cancel a fix-action and return GUI to neutral state
    % JAB 6/23/12
    
    for fly = self.selected,
      if fly > 0,
        setFlySelectedInView(self,fly,false);
      end
    end
    self.editMode='';
    self.nselect = 0;
    self.selected = [];
    if ~isempty(self.hswap)
      delete(self.hswap);
      self.hswap=[];
    end
    
    %set(panel_to_deselect,'visible','off');
    %EnablePanel(handles.editpanel,'on');
    
    %guidata(self.fig,self);
    self.updateControlVisibilityAndEnablement();    
  end  % method

  
  
  % -----------------------------------------------------------------------  
  function selectFlyInModelAndView(self,fly)
    % change the selected fly to a specified one
    % splintered from fixerrorsgui 6/23/12 JAB
    % This is a controller method, b/c it modifies both model and view
    
    if ismember(fly,self.selected),
      % set the current fly as unselected
      setFlySelectedInView(self,fly,false);
      i = find(self.selected==fly,1);
      self.selected(i) = [];
    else
      % set the current fly as selected
      setFlySelectedInView(self,fly,true);
      % unselect another fly if necessary
      if length(self.selected) == self.nselect,
        % in this case, unselect the lest-recently-selected fly before
        % selecting the new one
        unselect = self.selected(end);
        if ~isempty(unselect),
          self.selected(end)=[];
          setFlySelectedInView(self,unselect,false);  % actually unselect the fly
        end
      end
      % store selected
      self.selected = [fly,self.selected];
    end
    %handles.selected = handles.selected(handles.selected > 0);
  end  % method

  
  
  % -----------------------------------------------------------------------  
  function setFlySelectedInView(self,fly,v)
    % set the selected state for a fly
    % splintered from fixerrorsgui 6/23/12 JAB
    if v,
      set(self.hellipse(fly),'color',self.colors(fly,:)*.5+.5,'linewidth',3);
      set(self.hcenter(fly),'visible','off');
      set(self.hleft(fly),'visible','off');
      set(self.hright(fly),'visible','off');
      set(self.hhead(fly),'visible','off');
      set(self.htail(fly),'visible','off');
      set(self.hpath(fly),'linewidth',2);
    else
      set(self.hellipse(fly),'color',self.colors(fly,:),'linewidth',2);
      set(self.hcenter(fly),'visible','on');
      set(self.hleft(fly),'visible','on');
      set(self.hright(fly),'visible','on');
      set(self.hhead(fly),'visible','on');
      set(self.htail(fly),'visible','on');
      set(self.hpath(fly),'linewidth',1);
    end
  end  % method

  
  
  % -----------------------------------------------------------------------  
  function swapIdentities( self, f1 , f2, fly1, fly2 )
    % swaps the identites of two flies, from frame f1 until frame f2,
    % inclusive.
    % splintered from fixerrorsgui 6/21/12 JAB
    
    trk1During = CatalyticController.getPartOfTrack(self.trx(fly1),f1,f2);
    trk2During = CatalyticController.getPartOfTrack(self.trx(fly2),f1,f2);
    trk1After = CatalyticController.getPartOfTrack(self.trx(fly1),f2+1,inf);
    trk2After = CatalyticController.getPartOfTrack(self.trx(fly2),f2+1,inf);
    self.trx(fly1) = CatalyticController.getPartOfTrack(self.trx(fly1),1,f1-1);
    self.trx(fly2) = CatalyticController.getPartOfTrack(self.trx(fly2),1,f1-1);
    self.trx(fly1) = catTracks(self.trx(fly1),trk2During);
    self.trx(fly2) = catTracks(self.trx(fly2),trk1During);
    self.trx(fly1) = catTracks(self.trx(fly1),trk1After);
    self.trx(fly2) = catTracks(self.trx(fly2),trk2After);
    
    
    fixDeathEvent(self,fly1);
    fixDeathEvent(self,fly2);
    
    swapEvents(self,fly1,fly2,f1,f2);
  end  % method

  
  
  % -----------------------------------------------------------------------  
  function fixDeathEvent(self,fly)
    % add or remove fly's death event from suspicious sequences list, as appropriate
    % splintered from fixerrorsgui 6/21/12 JAB
    
    f = self.trx(fly).endframe;
    if f == self.nframes,
      removeDeathEvent(self,fly);
    else
      for i = 1:length(self.seqs)
        if ~strcmpi(self.seqs(i).type,'death'),
          continue;
        end
        if fly ~= self.seqs(i).flies,
          continue;
        end
        self.seqs(i).frames = f;
      end
    end
  end  % method

  
  
  % -----------------------------------------------------------------------  
  function removeDeathEvent(self,fly)
    % removes a death event for a fly
    % splintered from fixerrorsgui 6/21/12 JAB
    
    for i = 1:length(self.seqs)
      if strcmpi(self.seqs(i).type,'death'),
        if fly ~= self.seqs(i).flies,
          continue;
        end
        if isempty(self.doneseqs),
          self.doneseqs = self.seqs(i);
        else
          self.doneseqs(end+1) = self.seqs(i);
        end
        self.seqs(i).type = ['dummy', self.seqs(i).type];
      end
    end
  end  % method

  
  
  % -----------------------------------------------------------------------  
  function swapEvents(self,fly1,fly2,f0,f1)
    % swap fly1 for fly2 in all suspicous sequences involving only one of them
    % from frames f0 to f1
    % splintered from fixerrorsgui 6/21/12 JAB
    
    for i = 1:length(self.seqs)
      if min(self.seqs(i).frames) < f0 || max(self.seqs(i).frames) > f1,
        continue;
      end
      if ismember(fly1,self.seqs(i).flies) && ~ismember(fly2,self.seqs(i).flies)
        self.seqs(i).flies = union(setdiff(self.seqs(i).flies,fly1),fly2);
      end
      if ismember(fly2,self.seqs(i).flies) && ~ismember(fly1,self.seqs(i).flies)
        self.seqs(i).flies = union(setdiff(self.seqs(i).flies,fly2),fly1);
      end
    end
  end  % method

  
  
  % -----------------------------------------------------------------------  
  function seqs_removed = removeFlyEvent(self,fly,f0,f1)
    % remove all suspicious sequences involving fly in frames f0 to f1
    % splintered from fixerrorsgui 6/23/12 JAB
    
    seqs_removed = [];
    for i = 1:length(self.seqs)
      if ismember(fly,self.seqs(i).flies) && f0 <= min(self.seqs(i).frames) && ...
          f1 >= max(self.seqs(i).frames)
        self.seqs(i).type = ['dummy', self.seqs(i).type];
        seqs_removed(end+1) = i;  %#ok
      end
    end
  end  % method

  
  
  % -----------------------------------------------------------------------  
  function fixBirthEvent(self,fly)
    % add or remove fly's birth event from suspicious sequences list, as appropriate
    % splintered from fixerrorsgui 6/21/12 JAB
    
    f = self.trx(fly).firstframe;
    if f == 1,
      removeBirthEvent(self,fly);
    else
      for i = 1:length(self.seqs)
        if ~strcmpi(self.seqs(i).type,'birth'),
          continue;
        end
        if fly ~= self.seqs(i).flies,
          continue;
        end
        self.seqs(i).frames = f;
      end
    end
  end  % method

  
  
  % -----------------------------------------------------------------------  
  function removeBirthEvent(self,fly)  %#ok
    % removes a birth event for a fly
    % splintered from fixerrorsgui 6/21/12 JAB (as a no-op)
    
    %if handles.trx(fly).firstframe > 1,
    %  for i = 1:length(handles.seqs)
    %    if strcmpi(handles.seqs(i).type,'birth'),
    %      if fly ~= handles.seqs(i).flies,
    %        continue;
    %      end
    %      if isempty(handles.doneseqs),
    %        handles.doneseqs = handles.seqs(i);
    %      else
    %        handles.doneseqs(end+1) = handles.seqs(i);
    %      end
    %      handles.seqs(i).type = 'dummy';
    %    end
    %  end
    %end
  end  % method
  
  % -----------------------------------------------------------------------  
  function zoomInButtonPressed(self)
    self.zoomingIn=~self.zoomingIn;
    self.zoomingOut=fif(self.zoomingIn,false,self.zoomingOut);
    self.updateFigureZoomMode();
  end  % method

  % -----------------------------------------------------------------------  
  function zoomOutButtonPressed(self)
    self.zoomingOut=~self.zoomingOut;
    self.zoomingIn=fif(self.zoomingOut,false,self.zoomingIn);
    self.updateFigureZoomMode();
  end  % method

  % -----------------------------------------------------------------------  
  function updateFigureZoomMode(self)
    set(self.zoomInButton ,'value',self.zoomingIn);
    set(self.zoomOutButton,'value',self.zoomingOut);
    zoomObject=zoom(self.fig);
    if self.zoomingIn
      set(zoomObject,'direction','in');
      set(zoomObject,'enable','on');
    elseif self.zoomingOut
      set(zoomObject,'direction','out');
      set(zoomObject,'enable','on');
    else
      set(zoomObject,'enable','off');
    end      
  end  % method

end % methods
  
% -------------------------------------------------------------------------  
methods (Static=true)
  % -----------------------------------------------------------------------  
  function trk = getPartOfTrack(trk,f0,f1)
    % returns a subset of the input trx structure, from frame f0 to f1
    % does not copy all fields -- convert_units must be re-run on the output track
    % splintered from fixerrorsgui 6/21/12 JAB
    
    i0 = trk.off+(f0);
    i1 = trk.off+(f1);
    i0 = max(1,i0);
    i1 = min(i1,trk.nframes);
    trk.x = trk.x(i0:i1);
    trk.y = trk.y(i0:i1);
    trk.a = trk.a(i0:i1);
    trk.b = trk.b(i0:i1);
    trk.theta = trk.theta(i0:i1);
    trk.nframes = max(0,i1-i0+1);
    trk.firstframe = max(f0,trk.firstframe);
    trk.endframe = min(trk.endframe,f1);
    trk.off = -trk.firstframe + 1;
    if isfield( trk, 'timestamps' )
      if i1 < i0
        trk.timestamps = [];
      elseif length( trk.timestamps ) >= i1
        trk.timestamps = trk.timestamps(i0:i1);
      else
        warning( 'track timestamps are no longer accurate' )
        fprintf( 1, 'something strange is going on here --\n   subsampling track from %d to %d but only %d timestamps present\n', i0, i1, length( trk.timestamps ) );
      end
    end
    %trk.f2i = @(f) f - trk.firstframe + 1;
  end  % methods

  
  
  % -----------------------------------------------------------------------
  function enablePanel(h,v)
    % set the enabled state for a handle and all its children
    % splintered from fixerrorsgui 6/23/12 JAB
    children = get(h,'children');
    for hchild = children,
      try
        set(hchild,'enable',v);
      catch
      end
    end
  end  % method
end  % static methods
  
end  % classdef




a=motor.listdevices   % List connected devices
m1=motor              % Create a motor object  
connect(m1,a{1})      % Connect the first devce in the list of devices


Fig_t = figure;
H = uicontrol('Style', 'PushButton', 'String', 'Stop', 'Callback', 'delete(gcbf)');

zeta = .5;                           % Damping Ratio
wn = 2;                              % Natural Frequency
sys = tf(wn^2,[1,2*zeta*wn,wn^2]); 
ax = axes('Parent',Fig_t,'position',[0.13 0.39  0.77 0.54]);
h = stepplot(ax,sys);
setoptions(h,'XLim',[0,10],'YLim',[0,2]);

movecont(m1,24,24)



while (ishandle(H))
   P = read_position(m1)
   pause(0.01)
end
stop(m1)
disconnect(m1)        % Disconnect device


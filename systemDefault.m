clear all
close all
clc

dt=86400;
characteristics={'name','mass','velocity','position','force','color'};
sun={'Sun',2*10^30,[0,0],[100,100],[0,0],[1 0 0]};
earth={'Earth',6*10^24,[0,30000],[149.6*10^9,0],[0,0],[0 0 1]};
mercury={'Mercury',3.3*10^23,[0,47360],[57.9*10^9,0],[0,0],[0 1 0]};
venus={'Venus',4.9*10^24,[0,35000],[108.16*10^9,0],[0,0],[0.9300 0.6900 0.1300]};
moon={'Moon',7.35*10^22,[0,31000],earth{4}+[400*10^6,0],[0,0],[0.5 0.5 0.5]};

Objects=[sun;earth;mercury;venus;moon];

Objects=cell2struct(Objects,characteristics,2);
    
G=6.67*10^-11;

scatx=[];
scaty=[];
ColorData=[];
for kk=1:length(Objects)
   scatx=[scatx Objects(kk).position(1)];
   scaty=[scaty Objects(kk).position(2)];
   ColorData=[ColorData; Objects(kk).color];
end

% Plot all objects
f1=figure;
ax1=axes(f1);
scatter(ax1,scatx,scaty,'filled','cdata',ColorData);
xlim(ax1,[-300*10 ^9,300*10 ^9]);
ylim(ax1,[-300*10 ^9,300*10 ^9]);
movegui(f1,'northwest')

% Plot Moon/Earth
f2=figure;
ax2=axes(f2);
scatter(ax2,scatx([2,5]),scaty([2,5]),'filled','cdata',[0 0 1; 0.5 0.5 0.5]);
xlim(ax2,[Objects(2).position(1)-500*10^6,Objects(2).position(1)+500*10^6]);
ylim(ax2,[Objects(2).position(2)-500*10^6,Objects(2).position(2)+500*10^6]);
movegui(f2,'northeast')

iter = 0;
while 1
    iter=iter+1;
    for ii=1:length(Objects)-1
        for jj=ii+1:length(Objects)
            % Compute absolute value of gravitational force
             distance=dist([Objects(ii).position',Objects(jj).position']);
             F=G*Objects(ii).mass*Objects(jj).mass/(distance(1,2)^2);
             
             % The direction of gravitational force from objects a onto
             % Object b is vector(a)-vector(b).
             FDir=Objects(jj).position-Objects(ii).position;
             F=F*FDir/norm(FDir,2);

             % Actio = reactio
             Objects(ii).force=Objects(ii).force+F;
             Objects(jj).force=Objects(jj).force-F;
        end
        
    end

    % Update trajectories
    for ll=1:length(Objects)
       Objects(ll).velocity=Objects(ll).velocity+dt*Objects(ll).force/Objects(ll).mass;
       Objects(ll).position=Objects(ll).position+dt*Objects(ll).velocity;
       
       % reset forces acting upon object
       Objects(ll).force=[0,0];
    end
    
    scatx=[];
    scaty=[];
    for kk=1:length(Objects)
       scatx=[scatx Objects(kk).position(1)];
       scaty=[scaty Objects(kk).position(2)];
    end
    
    % ColorData=[1 0 0; 0 0 1; 0 1 0; 0.2 0.2 0.2];
    ColorData=[1 0 0; 0 0 1; 0 1 0; 0.2 0.2 0.2; 0.5 0.5 0.5];
    
    % Plot all objects
    scatter(ax1,scatx,scaty,'filled','cdata',ColorData);
    text(ax1,100*10 ^9,200*10^9,['velocity eart: ' num2str(norm(Objects(2).velocity,2)/1000) ' km/s'])
    text(ax1,100*10 ^9,250*10^9,['day ' num2str(iter) ' '])
    text(ax1,100*10 ^9,180*10^9,['velocity Moon: ' num2str(norm(Objects(5).velocity(1))/1000) ',' num2str(norm(Objects(5).velocity(2))/1000) ' km/s'])
    % text(200*10 ^9,180*10^9,['velocityy eart: ' num2str(Objects{2}.velocity(2)) ''])
    xlim(ax1,[-300*10 ^9,300*10 ^9]);
    ylim(ax1,[-300*10 ^9,300*10 ^9]);
    getframe;
    movegui(f1,'northwest')
    
    % Plot Moon/Earth
    scatter(ax2,scatx([2,5]),scaty([2,5]),'filled','cdata',ColorData([2 5],:));
    text(ax2,100*10 ^9,200*10^9,['velocity eart: ' num2str(norm(Objects(2).velocity,2)/1000) ' km/s'])
    text(ax2,Objects(2).position(1)+200*10^6,Objects(2).position(2)+200*10^6,['day ' num2str(iter) ' '])
    text(ax2,100*10 ^9,180*10^9,['velocity Moon: ' num2str(norm(Objects(5).velocity(1))/1000) ',' num2str(norm(Objects(5).velocity(2))/1000) ' km/s'])
    % text(200*10 ^9,180*10^9,['velocityy eart: ' num2str(Objects{2}.velocity(2)) ''])
    xlim(ax2,[Objects(2).position(1)-500*10^6,Objects(2).position(1)+500*10^6]);
    ylim(ax2,[Objects(2).position(2)-500*10^6,Objects(2).position(2)+500*10^6]);
    getframe;
    movegui(f2,'northeast')
    
%     pause
    
    
end
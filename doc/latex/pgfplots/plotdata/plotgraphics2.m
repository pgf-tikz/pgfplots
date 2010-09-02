
xdata =load('plotgraphics2_coord.dat');
veldata=load('plotgraphics2_vel.dat');

n = veldata(1) / 3

X = xdata(2:3:n)';
Y = xdata(3:3:n)';
Z = xdata(4:3:n)';

U = veldata(2:3:n)';
V = veldata(3:3:n)';
W = veldata(4:3:n)';

% swap ordering:
t=Y; Y=Z; Z=t; 
t=V; V=W; W=t; 

xx = [X Y Z];

DT=DelaunayTri(xx);
xmin=min(X); xmax=max(X);
ymin=min(Y); ymax=max(Y);
zmin=min(Z); zmax=max(Z);
N = 31;
[x,y,z] = meshgrid( linspace(xmin,xmax,N), linspace(ymin,ymax,N), linspace(zmin,zmax,N));
method='linear';
F = TriScatteredInterp(DT, U,method); u = F(x,y,z);
F = TriScatteredInterp(DT, V,method); v = F(x,y,z);
F = TriScatteredInterp(DT, W,method); w = F(x,y,z);
I = find(isnan(u)); u(I)=0;
I = find(isnan(v)); v(I)=0;
I = find(isnan(w)); w(I)=0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
wind_speed = sqrt(u.^2 + v.^2 + w.^2);
slicepos = { [(xmin+xmax)/2],  [(ymin+ymax)/2] , [(zmin+zmax)/2 ] };
slicepos{2} =[];
hsurfaces = slice(x,y,z,wind_speed,slicepos{1}, slicepos{2}, slicepos{3});
set(hsurfaces,'FaceColor','interp','EdgeColor','none')

hcont = contourslice(x,y,z,wind_speed,slicepos{1},slicepos{2},slicepos{3});
set(hcont,'EdgeColor',[.7,.7,.7],'LineWidth',.5)

NN= 4;
%[sx,sy,sz] = meshgrid( linspace(xmin,xmax,NN), linspace(ymin,ymax,NN), linspace(zmin,zmax,4) );
[sx,sy,sz] = meshgrid( 0, linspace(-1e-3,1e-3,NN), slicepos{3} )%linspace(zmin,zmax,5) );
hlines = streamline(x,y,z,u,v,w,sx,sy,sz);
set(hlines,'LineWidth',2,'Color','r')

hold on
I = find( ...
	abs(Z-(zmin+zmax)/2) < 1e-5 | ...
	abs(X-(xmin+xmax)/2) < 1e-5 ...
	);
scale=2;
h=quiver3(X(I),Y(I),Z(I),U(I),V(I),W(I),scale);
set(h, 'Color', 'w', 'Linewidth',1.3);
hold off

view(3)
%daspect([2,2,1])
%axis tight
axis equal
xlabel('x')
ylabel('y')
zlabel('z')
print -dpng 3drisingdropwithaxis
plotboxratio=pbaspect
[az,el]=view
axis off
print -dpng 3drisingdrop


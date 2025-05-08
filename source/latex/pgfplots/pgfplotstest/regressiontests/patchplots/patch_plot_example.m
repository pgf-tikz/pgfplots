close all
n = 3;
[xx,yy] = meshgrid(1:n,1:n);
x = xx(:) + 0.2*rand(n*n,1);
y = yy(:) + 0.2*rand(n*n,1);
z = rand(n*n,1);
t = delaunay(x,y);
ne = size(t,1);
c = rand(ne,1);
c2 = rand(ne,3);

% Matlab doesn't support the convenient syntax of supplying nodal coordinates + connectivity matrix (afaik).
tx = x(t);
ty = y(t);
tz = z(t);
tc = c(t);
tcm = mean(tc,2);


% FORMAT:
% tx:
%   x coordinates for all triangles
%   one row belongs to one triangle
%   tx(i,1) = x coordinate of first  triangle corner
%   tx(i,2) = x coordinate of second triangle corner
%   tx(i,3) = x coordinate of second triangle corner
%
% ty: the same for the y coordinates

% First type, solid colors
close all
patch(tx',ty',tcm'); 
print('plot1.png','-dpng');
patchtopgfplots(tx,ty,[], tcm, 'plot1.dat');

% Second type, interpolated colors, separate for each patch
close all
patch(tx',ty',c2');
print('plot2.png','-dpng');
patchtopgfplots(tx,ty,[], c2, 'plot2.dat');

% Third type, interpolated colors, continuous over edges.
close all
patch(tx',ty',tc'); 
print('plot3.png','-dpng');
patchtopgfplots(tx,ty,[], tc, 'plot3.dat');

% an example in 3D.
close all
patch(tx',ty',tz',c');
grid on
view(3)
print('plot4.png','-dpng');
patchtopgfplots(tx,ty,tz,c, 'plot4.dat');

% an example in 3D.
close all
Tz=(tx-2).^2 + (ty-2).^2;
patch(tx',ty',Tz',tc');
grid on
view(3)
print('plot5.png','-dpng');
patchtopgfplots(tx,ty,Tz,tc, 'plot5.dat');


C = colormap;
I = 1:1:size(C,1);
CC = C(I,:);
fid = fopen('patchplottestcolormap.tex','w');
fprintf(fid,'\\pgfplotsset{colormap={matlab}{\n');
fprintf(fid,'rgb=(%f,%f,%f)\n',CC');
fprintf(fid,'}}\n');
fclose(fid);


% Print data to files
coords = [x,y];
fid = fopen('Nodal_Coordinates_2D.txt','w');
fprintf(fid,'# $x$ $y$\n');
fprintf(fid,'%e %e\n',[x,y]');
fclose(fid);

fid = fopen('Nodal_Coordinates_3D.txt','w');
fprintf(fid,'# $x$ $y$ $z$\n');
fprintf(fid,'%e %e %e\n',[x,y,z]');
fclose(fid);

fid = fopen('Connectivity.txt','w');
fprintf(fid,'# $n_1$ $n_2$ $n_3$\n');
fprintf(fid,'%d %d %d\n',t);
fclose(fid);

fid = fopen('Patch_Coordinates_2D.txt','w');
fprintf(fid,'# $x_1$ $y_1$ $x_2$ $y_2$ $x_3$ $y_3$\n');
fprintf(fid,'%e %e %e %e %e %e\n',[tx(:,1),ty(:,1),tx(:,2),ty(:,2),tx(:,3),ty(:,3)]');
fclose(fid);

fid = fopen('Patch_Coordinates_3D.txt','w');
fprintf(fid,'# $x_1$ $y_1$ $z_1$ $x_2$ $y_2$ $z_2$ $x_3$ $y_3$ $z_3$\n');
fprintf(fid,'%e %e %e %e %e %e %e %e %e\n',[tx(:,1),ty(:,1),tz(:,1),tx(:,2),ty(:,2),tz(:,2),tx(:,3),ty(:,3),tz(:,3)]');
fclose(fid);

fid = fopen('Nodal_Values.txt','w');
fprintf(fid,'# $c$\n');
fprintf(fid,'%e\n',c);

fid = fopen('Patch_Values_Faceted.txt','w');
fprintf(fid,'# $c$\n');
fprintf(fid,'%e\n',tcm);
fclose(fid);

fid = fopen('Patch_Values_Interp.txt','w');
fprintf(fid,'# $c_1$ $c_2$ $c_3$\n');
fprintf(fid,'%e %e %e\n',c2);
fclose(fid);

% I envision plotting these figures with something like 
%{

Plot 1
\patch[faceted, values=patch] coordinates { ... } connectivity { ... } values { ... }
\patch[faceted, values=patch] coordinates file {Nodal_Coordinates_2D.txt} connectivity file {Connectivity.txt} values file {Element_Values_Faceted.txt}
\patch[faceted, values=patch, coordinates=patch] coordinates file {Patch_Coordinates_2D.txt} values file {Element_Values_Faceted.txt}


Plot 2
\patch[interp, values=patch, coordinates=nodal] coordinates file {Nodal_Coordinates_2D.txt} connectivity file {Connectivity.txt} values file {Patch_Values_Interp.txt}
\patch[interp, values=patch, coordinates=patch] coordinates file {Patch_Coordinates_2D.txt} values file {Element_Values_Interp.txt}

Plot 3
\patch[interp, values=nodal, coordinates=nodal] coordinates file {Nodal_Coordinates_2D.txt} connectivity file {Connectivity.txt} values file {Patch_Values_Interp.txt}
\patch[interp, values=nodal, coordinates=patch] coordinates file {Patch_Coordinates_2D.txt} values file {Nodal_Values.txt}

%}

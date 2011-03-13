[x,y]=meshgrid(linspace(0,1,15));
data=contour(x,y,x.*y);

data=data';
save 'pgfplotscontourinput.table.matlab' data -ASCII


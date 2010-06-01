function patchtopgfplots(x,y,z,c, file)

qx = x'; 
qy = y';
qz = z';
if size(c,2) == 1
	c = repmat(c,1, size(qx,1)) ;
end
qc = c';
fid = fopen(file,'w');
if length(z) == 0
	coords = [ qx(:) qy(:) qc(:) ];
	fprintf(fid,'x y c\n');
	fprintf(fid,'%e %e %e\n',coords');
else
	coords = [ qx(:) qy(:) qz(:) qc(:)];
	fprintf(fid,'x y z c\n');
	fprintf(fid,'%e %e %e %e\n',coords');
end
fclose(fid);

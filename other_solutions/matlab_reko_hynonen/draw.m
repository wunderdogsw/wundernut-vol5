function points = draw(direction,location,pic)
	
	% use complex numbers
	newloc=[location(1)+imag(direction) location(2)+real(direction)];
	
	% in principle the same as:
	% if isequal(direction,'up') % as -1i
		% newloc=[location(1)-1 location(2)];
	% elseif isequal(direction, 'left') % as -1
		% newloc=[location(1) location(2)-1];
	% elseif isequal(direction, 'down') % as 1i
		% newloc=[location(1)+1 location(2)];
	% elseif isequal(direction, 'right') % as +1
		% newloc=[location(1) location(2)+1];
	% end;
	
	siz=size(pic);
	if newloc(1)>siz(1) | newloc(2)>siz(2) | newloc(1)<1 | newloc(2)<1 % stop if over bounds
		points=[];
	else
		rgb_point=[pic(newloc(1),newloc(2),1) pic(newloc(1),newloc(2),2) pic(newloc(1),newloc(2),3)];
		points=newloc;
		if isequal(rgb_point,[51 69 169]) % the stop point
			return;
		elseif isequal(rgb_point,[182 149 72])
			points = vertcat(points, draw(direction*1i,newloc,pic)); % turn right
		elseif isequal(rgb_point,[123 131 154])
			points = vertcat(points, draw(direction*-1i,newloc,pic)); % turn left
		else
			points = vertcat(points, draw(direction,newloc,pic)); % continue onwards
		end;
	end;
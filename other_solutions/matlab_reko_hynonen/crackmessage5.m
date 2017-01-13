function crackmessage5(piclocation)
% Function to crack Wunderdog challenge 5 / 2016.
% Parameter piclocation contains the file location of the image file.

% Principle:
% Process all points
	% In case 1 draw upwards
	% In case 2 draw leftwards
		% in either case call recursive draw function

kuva=imread(piclocation);
drawpoints=[]; % for storage

% Process all points
for v=1:numel(kuva(:,1,1)) % Vertical points
	for h=1:numel(kuva(1,:,1)) % Horizontal poins
		rgb_point=[kuva(v,h,1) kuva(v,h,2) kuva(v,h,3)];
		if isequal(rgb_point,[7 84 19]) % Case 1
			drawpoints=vertcat(drawpoints,[v h]);
			drawpoints=vertcat(drawpoints,draw(-1i,[v h],kuva)); % 'up'
		elseif isequal(rgb_point,[139 57 137]) % Case 2
			drawpoints=vertcat(drawpoints,[v h]);
			drawpoints=vertcat(drawpoints,draw(-1,[v h],kuva)); % 'left'
		end;
	end;
end;

% Finally, draw the answer
scatter(drawpoints(:,1),drawpoints(:,2),'black','Marker','square','LineWidth',3)
% Merry Christmas and happy new year
% (funny symbol that might be <3) Wunderdog
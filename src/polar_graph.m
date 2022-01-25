function polar_graph(xData,yData,titleStructs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data_size = size(xData,1);

% basic setup
figure('Name', titleStructs.title);

% visual data
graphics = cell(1,data_size);
titles = cell(1,data_size);

for data_index = 1:data_size
    graphics{data_index} = polarplot(xData(data_index,:), yData(data_index,:));
    hold on
    if size(titleStructs.data, 1) == 1
        titles{data_index} = sprintf(titleStructs.data, data_index);
    else
        titles{data_index} = sprintf(titleStructs.data(data_index), data_index);
    end
end
legend(titles, 'Location', 'NorthWest', 'Interpreter', 'None');

% Label axes
rmax = max(yData);
text(0, rmax/2, titleStructs.y_axis, 'horiz', 'center', 'vert', 'top', 'rotation', 0);
text(pi/4, rmax*1.2, titleStructs.x_axis, 'horiz', 'center', 'rotation', -45);
title(titleStructs.title);

grid on
hold off
end


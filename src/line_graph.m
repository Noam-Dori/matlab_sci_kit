function line_graph(xData,yData,xError,yError,titleStructs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data_size = size(xData,1);
points_size = size(xData, 2);

ignore_vector = -ones(1,points_size);

% basic setup
figure('Name', titleStructs.title);

% visual data
graphics = cell(1, data_size);
titles = cell(1, data_size);

hold on
for data_index = 1:data_size
    % create measurement graph
    % if the size of the error does not fit, extend it accordingly
    dataErrX = xError(rem(data_index, size(xError,1)) + 1, :);
    dataErrY = yError(rem(data_index, size(yError,1)) + 1, :);
    if size(dataErrX, 2) == 1
        dataErrX = dataErrX * ones(1, points_size);
    end
    if size(dataErrY, 2) == 1
        dataErrY = dataErrY * ones(1, points_size);
    end
    if dataErrX == ignore_vector
        if dataErrY == ignore_vector % none
            graphics{data_index} = plot(xData(data_index,:), yData(data_index,:),'o');
        else % errY
            graphics{data_index} = errorbar(xData(data_index,:), yData(data_index,:),dataErrY,'vertical','.');
        end
    else
        if dataErrY == ignore_vector % errX
            graphics{data_index} = errorbar(xData(data_index,:), yData(data_index,:),dataErrX,'horizontal','.');
        else % errX+errY
            graphics{data_index} = errorbar(xData(data_index,:), yData(data_index,:),dataErrY,dataErrY,dataErrX,dataErrX,'.');
        end
    end

    % titles
    if size(titleStructs.data, 1) == 1
        titles{data_index} = sprintf(titleStructs.data, data_index);
    else
        titles{data_index} = sprintf(titleStructs.data(data_index), data_index);
    end
end
legend(titles, 'Location', 'NorthWest', 'Interpreter', 'None');

% Label axes
xlabel(titleStructs.x_axis, 'Interpreter', 'none' );
ylabel(titleStructs.y_axis, 'Interpreter', 'none' );
title(titleStructs.title);

grid on
hold off
end


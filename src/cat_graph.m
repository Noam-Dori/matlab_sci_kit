function cat_graph(meas, names, titleStructs, categoriesOnX)


% if neccesary, convert name to match measurement dimension
if size(names,2) == 1
    names = repmat(names,1, size(meas,2));
end

cats = categorical(names);
data_size = size(names,1);
points_size = size(names, 2);

% basic setup
fig = figure('Name', titleStructs.title);

% visual data
graphics = cell(1, data_size);

pullback = 0;
hold on
for data_index = 1:data_size
    % create measurement graph
    % if the size of the error does not fit, extend it accordingly
    dataErr = meas(rem(data_index - 1, size(meas.err,1)) + 1, :).err;
    if size(dataErr, 2) == 1
        dataErr = dataErr * ones(1, points_size);
    end
    % delete data using the -2 consideration
    cond = dataErr ~= -2;
    data = meas(data_index,:).value;
    data = data(cond);
    dataErr = dataErr(cond);
    dataLabels = cats(data_index, :);
    dataLabels = dataLabels(cond);

    ignore_vector = -ones(size(dataErr));

    if dataErr == ignore_vector
        if categoriesOnX
            graphics{data_index} = plot(dataLabels, data, 'o');
        else
            graphics{data_index} = plot(data, dataLabels, 'o');
        end
    else
        if categoriesOnX
            graphics{data_index} = errorbar(dataLabels, data, dataErr,'vertical','.');
        else
            graphics{data_index} = errorbar(data, dataLabels, dataErr,'horizontal','.');
        end
    end
    if isfield(titleStructs, 'fit') && isa(titleStructs.fit, 'double')
       pullback = pullback + titleStructs.fit(min(data_index, size(titleStructs.fit,1)));
    end
    graphics{data_index}.Color = get_color(data_index - pullback);
end

% Label axes
if categoriesOnX
    ylabel(titleStructs.y_axis, 'Interpreter', 'latex' );
    fig.CurrentAxes.XAxis.Categories = cellstr(unique(names,'stable'));
else
    xlabel(titleStructs.x_axis, 'Interpreter', 'latex' );
    fig.CurrentAxes.YAxis.Categories = cellstr(unique(names,'stable'));
end
title(titleStructs.title, 'Interpreter', 'latex');

grid on
hold off
end
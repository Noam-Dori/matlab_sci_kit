rng(0,'twister');

x_1d = normrnd(0,1,1,30);
y_1d = normrnd(1,1,1,30) + x_1d;

x_2d = normrnd(0,1,3,30);
y_2d = normrnd(1,1,3,30) + x_2d;

x_err_0d = 0.05;
y_err_0d = 0.1;

x_err_1d = rand(1,30) * 0.05;
y_err_1d = rand(1,30) * 0.1;

x_err_2d = rand(3,30) * 0.05;
y_err_2d = rand(3,30) * 0.1;

x_err_0d_ignore = -1;
y_err_0d_ignore = -1;

x_err_1d_ignore = -ones(1,30);
y_err_1d_ignore = -ones(1,30);

x_err_2d_ignore = x_err_2d;
y_err_2d_ignore = y_err_2d;
x_err_2d_ignore(1,:) = -1;
y_err_2d_ignore(1,:) = -1;

titles_1d.title = '1D data regression';
titles_1d.x_axis = '1D X axis';
titles_1d.y_axis = '1D Y axis';
titles_1d.fit = '1D regression';
titles_1d.data = '1D data';

titles_2d.title = '2D data regression';
titles_2d.x_axis = '2D X axis';
titles_2d.y_axis = '2D Y axis';
titles_2d.fit = 'regression #%d';
titles_2d.data = ["theory"; "measurement 1"; "measurement 2"];

my_fit = sci_fit(x_2d,y_2d,x_err_2d,y_err_2d,titles_2d);
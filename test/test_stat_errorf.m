errx_0d = 0.01;

x_1d = normrnd(1,0.01,1,30);
errx_1d = normrnd(0.01,0.0001,1,30);

x_2d = normrnd(1,0.01,30,30);
errx_2d = normrnd(0.01,0.0001,30,30);

[f, errf] = stat_errorf('mean_diff',x_2d,errx_0d);
syms F(X,Y)
F(X,Y) = X*Y;

syms G(X)
G(X) = sin(X);

x_0d = 1;
errx_0d = 0.01;
y_0d = 2;
erry_0d = 0.02;

x_1d = normrnd(1,0.01,1,30);
y_1d = normrnd(2,0.02,1,30);
errx_1d = normrnd(0.01,0.0001,1,30);
erry_1d = normrnd(0.02,0.0002,1,30);

[f, errf] = errorf(F,[x_0d; y_0d],[errx_0d; erry_0d]);
%[f, errf] = errorf(G,[x_0d],[errx_0d]);
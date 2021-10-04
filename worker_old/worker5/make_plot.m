clear;clc;addpath('../src');


res = load('gd.mat');
w0 = [0.563945298879718   0.564851815720133   0.564865732303110   0.563513505876953   0.564424234906898   0.566401525432045   0.563926851865282   0.564268141749132   0.564365857909443   0.563353533483639];
figure(1);
clf;
plot(chnk_poly(w0));

for i = 1:4
    hold on
    plot(chnk_poly(res.weight(i, :)));
end

legend('iter 0, grad = 4.04e-01', 'iter 1, grad = 1.97e-01', 'iter 2, grad = 1.65e-01', 'iter 3, grad = 7.40e-02', 'iter 4, grad = 7.12e-02');
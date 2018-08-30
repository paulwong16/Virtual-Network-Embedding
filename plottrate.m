N = 500;
A=randperm(N);
B = sort(A);
plot(B,Rate);
xlabel('Embedding Time','FontName','Times New Roman','FontSize',12);
ylabel('Embedding Success Rate','FontName','Times New Roman','FontSize',12);
close all

%% make 10 figures
for i=1:10
    figure()
end

%% example 1. automatically arrange figures.
fprintf('press any key if you want to proceed\n')
pause
% autoArrangeFigures(0,0);s
autoArrangeFigures();
%% example 2. put the size of grid1
fprintf('press any key if you want to proceed\n')
pause
autoArrangeFigures(5,2,1);

%% example 3. put the size of grid2
fprintf('press any key if you want to proceed\n')
pause
autoArrangeFigures(3,3,1);

%% make more figures over than the maximum number of figure
% totally 30 figures are now.
fprintf('press any key if you want to proceed\n')
pause
for i=1:20
    figure()
end

%% example 4. I cannot arrange automatically if the number of figures are more than 27.

fprintf('press any key if you want to proceed\n')
pause
autoArrangeFigures(0,0,1);

%% example 5. You have to specify the size of grid.
fprintf('press any key if you want to proceed\n')
pause
autoArrangeFigures(6,5,1);
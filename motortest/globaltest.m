function [] = globaltest()
global i
i = 0;
run = true;
while run
    i = i+1
    pause(1)
    if i > 10
        run = false;
    end
end


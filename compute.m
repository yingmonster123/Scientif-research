function [count,time] = compute(x,t,step)
% author: Qian Zhang
% 输入水位x、时间t和高程的间隔step，输出每个高程h被淹没的潮周期个数总和count和平均时长time
% 找到最低潮位的索引
delta = [];
mul = [];
flag = [];
for i = 2:length(t)
    delta(i) = x(i)-x(i-1);
end
delta(1) = 0;
for i = 1:length(t)-1
    mul(i) = delta(i)*delta(i+1);
mul(length(t)) = 0;
end
for i = 1:length(t)
    if mul(i)<0 && delta(i) <=0
        flag(i)=1;
    end
end
flag(1) = 0;
flag(length(t)) = 0;
index = find(flag);

% 剔除小的振荡噪声，最低潮位点存入lowestPointResult
lowestPointResult = [];
flag = [];
T0 = t(index);
for i = 2:length(T0)
    deltaT = T0(i) - T0(i-1);
    if(deltaT) < 10
        flag = [flag i];
    end
end
index(flag) = [];
T0(flag) = [];
lowestPointResult(:,1) = t(index);
lowestPointResult(:,2) = x(index);
% lowestPointResult


% 找出高程值与潮位的两类交点对应的时间Tstart和Tend
col = 0;
Tstart = []; Tend = [];
for h = -3350:50:4550
    col = col + 1;
    x1 = x - h;
    j = 0; m = 0;
    for i = 1:length(x)-1
        if x1(i) <= 0 && x1(i)*x1(i+1) > 0
            continue;
        elseif x1(i) < 0 && x1(i)*x1(i+1) < 0
            j = j + 1;
            k = (x1(i+1) - x1(i))/(t(i+1) - t(i));
            b = x1(i) - k*t(i);
            Tstart(j,col) = -b/k;
        elseif x1(i)>0 && x1(i)*x1(i+1) < 0
            m = m + 1;
            k = (x1(i+1) - x1(i))/(t(i+1) - t(i));
            b = x1(i) - k*t(i);
            Tend(m,col) = -b/k;            
        end
    end
%     fprintf("j = %d ",j);
%     fprintf("m = %d\n",m);
end
% 第一列存放每个潮周期的起始时间 第二列是终止时间
tidalPreiodresult = [];
tidalPreiodresult(:,1) = lowestPointResult(1:end-1,1);
tidalPreiodresult(:,2) = lowestPointResult(2:end,1);
cnt = 0;
tidalPeriodTime1 = tidalPreiodresult;
tidalPeriodTime2 = tidalPreiodresult;

% 几个矩阵分别存储每个潮周期中每个高程的交点个数、两类交点Tstart、Tend的值
for j = 3:col-1+3
    for i = 1:length(tidalPreiodresult)
        period = tidalPreiodresult(i,2) - tidalPreiodresult(i,1);
        Period = 12.42;
        if period > Period
            period = Period;
        end
        indexS = find((Tstart(:,j-2)-tidalPreiodresult(i,1)<period) & (Tstart(:,j-2)-tidalPreiodresult(i,1)>0));
        indexE = find((Tend(:,j-2)-tidalPreiodresult(i,1)<period) & (Tend(:,j-2)-tidalPreiodresult(i,1)>0));
        tidalPreiodresult(i,j) = length(indexS)+length(indexE);
        if length(indexS) == 2 || length(indexE) == 2
            cnt = cnt+1;
        end  
        if length(indexS) == 1
            tidalPeriodTime1(i,j) = Tstart(indexS,j-2);
        end
        if length(indexE) == 1
            tidalPeriodTime2(i,j) = Tend(indexE,j-2);
        end        
    end
end

for i = 1:length(tidalPreiodresult)
    for j = 3:161
        if tidalPeriodTime1(i,j)~=0 && tidalPeriodTime2(i,j)==0
            tidalPeriodTime2(i,j)=tidalPreiodresult(i,2);
        elseif tidalPeriodTime1(i,j)==0 && tidalPeriodTime2(i,j)~=0
            tidalPeriodTime1(i,j)=tidalPreiodresult(i,1);
        end
    end
end

% 计算每次淹没的时长deltaT
tidalPreiodDeltaTime = tidalPeriodTime2 - tidalPeriodTime1;
tidalPreiodDeltaTime(find(tidalPreiodDeltaTime>15)) = 0;
tidalPreiodDeltaTime(:,1:2) = tidalPreiodresult(:,1:2);
tidalPreiodDeltaTime(:,end) = 0;

% 平均时长
time = [];
time(:,1) = -3350:50:4550;
for i = 1:length(time)
    if find(tidalPreiodDeltaTime(:,i+2))
        time(i,2) = sum(tidalPreiodDeltaTime(:,i+2))/length(find(tidalPreiodDeltaTime(:,i+2)));
    elseif i<3
        time(i,2) = 12.42;
    else
        time(i,2) = 0;      
    end
    
end
if isempty(time(1,2))
    time(1,2)=12.42;
end
if isempty(time(end,2))
    time(1,2)=0;
end

% 淹没的潮周期个数
count = [];
count(:,1) = -3350:50:4550;
for i = 1:length(count)
    cnt = 0;
    for j = 1:length(tidalPreiodresult)
        if tidalPreiodresult(j,i+2)~=0 || count(i,1) <= lowestPointResult(j,2)
            cnt=cnt+1;
        else
            continue;          
        end    
    end
    count(i,2)=cnt;
end
count(:,2) = count(:,2);
end


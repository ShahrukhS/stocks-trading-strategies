%----------TASK 1----------%
format long g

%Initializing:
SD = readtable('Data\JET.L.csv'); %reading JET.L stock data
initial_budget = 1000000; %setting an initial budget before we start trading.
dates = datetime(table2array(SD(:,1)),'InputFormat','M/d/yyyy'); %creating row vectors out of table columns for required variables
close_price = table2array(SD(:,5));

%Computing moving average of 7 days
MA_7 = movmean(close_price,7);

%Computing moving average of 14 days
MA_14 = movmean(close_price,14);

%truncting data of starting 14 days, since we can't implement our strategy
%of moving average signals until we reach the 14th day.
dates = dates(14:end);
close_price = close_price(14:end);
MA_7 = round(MA_7(11:end-3));
MA_14 = round(MA_14(8:end-6));

%Plotting moving averages and actual price to visualize patterns.
plot(dates, close_price);
hold on
plot(dates, MA_7)
hold on
plot(dates, MA_14)
hold on
legend('Stock Price per day', 'Moving average of 7 Days', 'Moving average of 14 Days')
ylabel('Price')
xlabel('Trading Dates')

%initializing when necessary variables needed for trading algorithm computation.
diff = MA_7 - MA_14;
buy_sell_indicator = zeros(size(diff));
holding = zeros(size(diff));
budget = zeros(size(diff));
budget(1) = initial_budget;

for i = 2:size(diff)
    if(diff(i-1) < 0 && diff(i) > 0) %if on previous trading day (d-1) MA_7 was smaller than MA_14 and on trading day (d) it crosses
        buy_sell_indicator(i) = 1;
        holding(i) = fix(budget(i-1)/close_price(i)); %using fix function to truncate any decimal value, because holding share can be an integer only.
        if(holding(i) < 1) % if budget is not sufficient enough to buy more shares or if above fraction is less than 1.
            holding(i) = holding(i-1);
        end
        budget(i) = budget(i-1)-holding(i)*close_price(i); %once shares bought, updating budget.
    elseif(diff(i-1) > 0 && diff(i) < 0) %if on trading day (d-1) MA_7 was higher than MA_14 and on trading day (d) it crosses
        buy_sell_indicator(i) = -1;
        holding(i) = 0; %selling entire portfolio
        budget(i) = budget(i-1)+holding(i-1)*close_price(i); %updating budget
    else
        %if no signal was given by our strategy. we do nothing.
        buy_sell_indicator(i) = 0;
        holding(i) = holding(i-1);
        budget(i) = budget(i-1);
    end
end

%as buying & selling indicators are calculated, I mark them in our moving
%average plot for visualization.
idx = find(buy_sell_indicator(:) == 1);
plot(dates(idx), MA_7(idx), 'r*');
idx = find(buy_sell_indicator(:) == -1);
plot(dates(idx), MA_7(idx),'o');

%resultant matrix for trading movement in all variables throughout entire period
All_days_trading = [close_price MA_7 MA_14 diff buy_sell_indicator holding budget]

%removing idle days to summarize only when made a deal.
idx = find(All_days_trading(:, 5) == 0);
All_days_trading(idx,:) = [];
trading_dates = dates;
trading_dates(idx,:) = [];

%summarized table for only when we made trade deals.
Only_trading_days = [array2table(trading_dates) array2table(All_days_trading)];
Only_trading_days.Properties.VariableNames(1:8) = {'date', 'close_price','MA_7','MA_14','diff_of_MAs','buy_sell_indicator','holding','budget'}

%Another plot for fluctuations in budget.
figure(2);
plot(budget);
ylabel('Budget')
xlabel('All Days')

%end

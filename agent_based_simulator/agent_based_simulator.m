%----------TASK 2----------%

% keeping agent (buyer and seller) numbers in a variable, so this assumption can be easily changed when needed to evaluate different scenarios.
n = 20;

valuations = randi([1 200], n, 1); %random buyer valuations (with replacement) for the item .
seller_quantity = ones(n,1)*30; %as per our assumption, each seller initially has 30 quantities of the item.
traded_units = zeros(10,1); %to record traded units in each round (there are 10 rounds in this simulation)

ids = (1:n)'; %initializing unique identifier for each seller and buyer.
bid_ask_spread = zeros(10,1);

%this is a placeholder row vector with zeros
zeros_vector = zeros(n,1);

% initializing matixes that will be used in our simulation.
buyers = [ids valuations zeros_vector zeros_vector];
sellers = [ids zeros_vector seller_quantity];

%rounds of simulations
for round = 1:10
    trades = 0; %trades per round will be maintained here.
    bids = zeros(n,1);
    asks = randsample(round*10:200, n).'; % I have intentionally generated ASK samples without replacement so I could have variety of unique asks, one can use randi function for samples with replacement.
    buyer_quantity = randi([1 5], n, 1); % random quantities generated from 1 and 5 for each buyer.
    
    for buyer = 1:n
        bids(buyer) = randsample(1:valuations(buyer), 1); %bid per unit -> 1 : buyer valuation
    end
    
    %updating our buyer & seller matrixes and sorting them to give priority to high bids and low asks first.
    buyers(:,3) = bids;
    buyers(:,4) = buyer_quantity;
    [~,idx] = sort(buyers(:,3),'descend');
    buyers = buyers(idx,:);
    
    sellers(:,2) = asks;
    [~,idx] = sort(sellers(:,2));
    sellers = sellers(idx,:);
    
    %printing a table to see initial values before any trade happen.
    if(round == 1)
        table = [array2table(buyers) array2table(sellers)];
        table.Properties.VariableNames(1:7) = {'buyer_ids', 'valuations', 'bids', 'buyer_quantity', 'seller_ids', 'asks', 'seller_quantity'}
    end
    
    %recording bid-ask spread for each round.
    bid_ask_spread(round) = buyers(1,3) - sellers(1, 2);
    
    for x = 1:n
        if(buyers(x,3) < sellers(x,1)) %since bids are sorted from highest to lowest, we break if condition is true
            %if a highest bid is less than the lowest ask then break the upper loop.
            if(x > 1)
                xi = -1; %variable for inner loop / seller counter.
            else
                break;
            end
            
            %this inner loop goes in upper direction, for seller with lower
            %asks.
            while(buyers(x,4) > 0 && buyers(x,3) >= sellers(x+xi,2)) %if buyer has remaining quantities to buy and has bid > ask then.
                quantity_diff = sellers(x+xi,3) - buyers(x,4);
                if(quantity_diff >= 0) %if buyer quantities are less than seller quantities.
                    sellers(x+xi,3) = sellers(x+xi,3) - buyers(x,4);
                    buyers(x,4) = 0;
                else %if seller quantities are less than buyer's
                    sellers(x+xi,3) = 0;
                    buyers(x,4) = buyers(x,4) - sellers(x+xi,3);
                end
                trades = trades + abs(quantity_diff); %recording trade.
                xi = xi-1; %moving on to next seller.
                if(x+xi <= 0)
                    break;
                end
            end
        else
            xi = 0; %variable for inner loop / seller counter.
            %inner loop is for if a buyer has remaining quantities then proceed
            %buying them from next seller in asc. order downwards. [1]
            while(buyers(x,4) > 0 && buyers(x,3) >= sellers(x+xi,2)) %if buyer has remaining quantities to buy and has bid > ask then.
                quantity_diff = sellers(x+xi,3) - buyers(x,4);
                if(quantity_diff >= 0) %if buyer quantities are less than seller quantities.
                    sellers(x+xi,3) = sellers(x+xi,3) - buyers(x,4);
                    buyers(x,4) = 0;
                else %if seller quantities are less than buyer's
                    sellers(x+xi,3) = 0;
                    buyers(x,4) = buyers(x,4) - sellers(x+xi,3);
                end
                trades = trades + abs(quantity_diff); %recording trade.
                xi = xi+1; %moving on to next seller.
            end
        end
    end
    
    traded_units(round) = trades; %all trades of a round, goes in the array for 10 rounds.
    
    %last snapshot of all agents after running through all rounds.
    if(round == 10)
        table = [array2table(buyers) array2table(sellers)];
        table.Properties.VariableNames(1:7) = {'buyer_ids', 'valuations', 'bids', 'buyer_quantity', 'seller_ids', 'asks', 'seller_quantity'}
    end
end

sprintf('Total traded units : %d', sum(traded_units))

%plotting spread and traded units.
plot((1:10), bid_ask_spread)
hold on
plot((1:10), traded_units)
legend('highest bid to lowest ask Spread', 'traded units')
ylabel('Value')
xlabel('Rounds')

%end
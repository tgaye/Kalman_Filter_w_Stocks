# Kalman_Filter_w_Stocks
Uses Kalman Filter technique in order to produce dynamic hedge-ratio for 2 highly correlated securities, 
which is then used to form a mean reversion trading model backtested over 22 years!  Done in Matlab

We will be performing our Kalman Filter example using EWA and EWC, ETF's that try to replicate Australia's and Canada's equity 
market respectively.  The reason these two ETF's are typically correlated is these are both commodity driven countries, 
Gold for Australia, Oil for Canada.  

Dollar weakness and dollar stength has similar effects on these commodities and the countries that produce them. (inverse relationship)
When we run a correlation test with Matlab's corrcoef() indeed, we can see these two time-series are highly correlated.

![figure_0](https://user-images.githubusercontent.com/34739163/43881901-fdd02d64-9b6a-11e8-98ca-6e72a778ed02.png)

Correlation of .9804!  This should make for a great mean reverting pair to trade.  We will use Kalman Filter as a technique of updating
our proper weighting of the two stocks such that the pair remains mostly stationary. (i.e Dynamic Weighting).

The core of our trading technique will be similar to the concept of Bollinger Bands, we will short if our spread deviates more than 
1 standard deviation from our expected value for it.  We will buy our spread if it drops more than 1 s.d from our expected value.

I'll spare you the math for now and post the formulas at the bottom for those interested, but once we calculate our kalman slope and intercept these are the results:

![figure_2](https://user-images.githubusercontent.com/34739163/43881907-04b1c20a-9b6b-11e8-8198-80f458501253.png)

![figure_3](https://user-images.githubusercontent.com/34739163/43881910-06551e36-9b6b-11e8-8f8b-327123016aed.png)

These values give us what we need to know to dynamically adjust our hedge ratio of EWC for EWA given market conditions / price movement.

We can also plot our predicted error value against the s.d of the actual error value, for a better understanding of our data.

![figure_4](https://user-images.githubusercontent.com/34739163/43881915-080a9b0c-9b6b-11e8-8fcc-c3939578ce1c.png)

We then generate a list of positions we take given the deviation from our predicted value, with 1 s.d as our signal.  Kalman Filter
is used as a moving dynamic hedge ratio for our two stocks.  We only have one hyper parameter, and that is delta for the Kalman Filter (how quickly we allow our beta, or hedge ratio, to change.)  This was trained on the first half of the data set, and I found .00001 to work well for this strategy.

The following is the strategies performance for well over 20 years!:

![figure_5](https://user-images.githubusercontent.com/34739163/43881918-0c2ad3e6-9b6b-11e8-956d-0ed1b67e6c8b.png)

Looks impressive at first sight, when we calculate sharpe and APR we aren't disappointed.  
APR=0.227875 
Sharpe=2.195395

While this backtest didn't factor commissions in order to keep things simple, we are trading on a daily time scale with relatively sparse signals and these results are nothing to shrug off.   The Kalman Filter is a very versatile tool for our dynamic markets:

-Afraid that the hedge ratio, mean, and standard deviation of a spread may vary in the future? Kalman fi lter.
-Do you want to dynamically update the expected price of an instrument based on its latest trade (price and size)? Kalman filter.
-Can be used in market making or mean reverting models.

The equations used in the code: 

![figure_1](https://user-images.githubusercontent.com/34739163/43881903-ff8bd004-9b6a-11e8-98a6-0b01a1446f6e.png)

    beta(:, t)=beta(:, t-1); % state prediction
    R=P+Vw; % state covariance prediction
    yhat(t)=x(t, :)*beta(:, t); % measurement prediction
    Q(t)=x(t, :)*R*x(t, :)'+Ve; % measurement variance prediction
    e(t)=y(t)-yhat(t); % measurement prediction error
    K=R*x(t, :)'/Q(t); % Kalman gain 
    beta(:, t)=beta(:, t)+K*e(t); % State update
    P=R-K*x(t, :)*R; % State covariance update

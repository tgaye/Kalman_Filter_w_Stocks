# Kalman_Filter_w_Stocks
Uses Kalman Filter technique in order to produce a moving hedge-ratio for 2 highly correlated securities, 
which is then used to form a mean reversion trading model.  Done in Matlab

We will be performing our Kalman Filter example using EWA and EWC, ETF's that try to replicate Australia's and Canada's equity 
market respectively.  The reason these two ETF's are typically correlated is these are both commodity driven countries, 
Gold for Australia, Oil for Canada.  

Dollar weakness and dollar stength has similar effects on these commodities and the countries that produce them. (inverse relationship)
When we run a correlation test with Matlab's corrcoef() indeed, we can see these two time-series are highly correlated.



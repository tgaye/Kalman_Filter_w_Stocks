%KALMAN FILTER ON EWA + EWC
% Daily data on EWA-EWC (correlated pair)
load('EWA + EWC.mat');
x = ewa;
y = ewc;

% Augment x with ones to accomodate possible offset in regression between y vs x.
x=[x ones(size(x))];

%Initialize Variables
delta=0.00001; % delta=1 gives fastest change in beta, delta=0.000....1 allows no change (like traditional linear regression).

yhat=NaN(size(y)); % measurement prediction
e=NaN(size(y)); % measurement prediction error
Q=NaN(size(y)); % measurement prediction error variance

% For clarity, we denote R(t|t) by P(t).
% initialize R, P and beta.
R=zeros(2);
P=zeros(2);
beta=NaN(2, size(x, 1));
Vw=delta/(1-delta)*eye(2);
Ve=0.001;

% Initialize beta(:, 1) to zero
beta(:, 1)=0;

% Given initial beta and R (and P)
% Calculations for each timestep in our data:
for t=1:length(y)
    if (t > 1)
        beta(:, t)=beta(:, t-1); % state prediction: beta(t|t-1) = beta(t-1|t-1)
        R=P+Vw; % state covariance prediction: cov(t|t-1) = cov(t-1|t-1) + V_w
    end
    
    yhat(t)=x(t, :)*beta(:, t); % measurement prediction: yhat(t)=x(t)beta(t|t-1)
    Q(t)=x(t, :)*R*x(t, :)'+Ve; % measurement variance prediction: Q(t)=x(t)cov(t|t-1)x(t) + V_e
    
    % Observe y(t)
    e(t)=y(t)-yhat(t); % measurement prediction error: (actual - predicted)
    
    K=R*x(t, :)'/Q(t); % Kalman gain: cov*x(t) / transpose of Q(t)
    
    beta(:, t)=beta(:, t)+K*e(t); % State update: beta(t|t)=beta(t|t-1) + K(T) * e(t)
    P=R-K*x(t, :)*R; % State covariance update: cov(t|t)=cov(t|t-1) - K(T) * x(t) * cov(t|t-1)
    
end

%----------------------------------------------------------------------------
%Kalman Filter: allows for proper adjusting of hedge ratio
plot(beta(1, :)');
title('Kalman filter estimate of slope');
xlabel('Time (Days)')
ylabel('Slope Estimate')
figure;

plot(beta(2, :)');
title('Kalman filter estimate of intercept');
xlabel('Time (Days)')
ylabel('Intercept Estimate')
figure;

% Plot prediction error and S.D of e(t)
plot(e(3:end), 'r');
hold on;
plot(sqrt(Q(3:end)));
title('Measurement Prediction Error e(t) and S.D of e(t)');
xlabel('Time (Days)')

% Combine both EWC and EWA to one matrix
y2=[x(:, 1) y];

% Buy when spread deviates > 1 standard deviation [sqrt(Q)]
% e = measurement prediction error (actual - predicted)
longsEntry=e < -sqrt(Q); % Buy when 1 S.D below predicted
longsExit=e > -sqrt(Q);

shortsEntry=e > sqrt(Q); % Short when 1 S.D above predicted
shortsExit=e < sqrt(Q);

% Keep track of long/short position
numUnitsLong=NaN(length(y2), 1);
numUnitsShort=NaN(length(y2), 1);

numUnitsLong(1)=0;
numUnitsLong(longsEntry)=1; 
numUnitsLong(longsExit)=0;
numUnitsLong=fillMissingData(numUnitsLong); % fillMissingData simply carries forward an existing position from previous day if today's positio is an indeterminate NaN.

numUnitsShort(1)=0;
numUnitsShort(shortsEntry)=-1; 
numUnitsShort(shortsExit)=0;
numUnitsShort=fillMissingData(numUnitsShort);

% Combine shorts and longs to create portfolio
numUnits=numUnitsLong+numUnitsShort;

% [hedgeRatio -ones(size(hedgeRatio))] is the shares allocation, 
% [hedgeRatio -ones(size(hedgeRatio))].*y2 is the dollar capital allocation, 
% while positions is the dollar capital in each ETF.
positions=repmat(numUnits, [1 size(y2, 2)]).*[-beta(1, :)' ones(size(beta(1, :)'))].*y2; 
pnl=sum(lag(positions, 1).*(y2-lag(y2, 1))./lag(y2, 1), 2); % daily P&L of the strategy
ret=pnl./sum(abs(lag(positions, 1)), 2); % return is P&L divided by gross market value of portfolio
ret(isnan(ret))=0; % NaN's to 0

% Plot portfolio value
figure;
plot(cumprod(1+ret)-1); % Cumulative compounded return
title('Portolio Value Over Time')
xlabel('Time (Days)')
ylabel('Equity')

% APR and Sharpe calculations
fprintf(1, 'APR=%f Sharpe=%f\n',...
    prod(1+ret).^(252/length(ret))-1, sqrt(252)*mean(ret)/std(ret));
% APR=0.262252 Sharpe=2.361162



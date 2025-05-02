# Volatility Pairs Trading Strategy: Nifty & Bank Nifty

This project implements a pairs trading strategy analyzing the volatility relationship between Nifty and Bank Nifty indices. The strategy capitalizes on the divergence and convergence of implied volatilities between these highly correlated indices.

## Project Overview

The strategy explores volatility arbitrage opportunities between Nifty and Bank Nifty indices, which share significant constituent overlap. The trading horizon ranges from 30 minutes to 5 days, making it a medium-frequency strategy.

### Data Description
- Source: Minute-level implied volatilities data (data.parquet)
- Features: 
  - Nifty IV
  - Bank Nifty IV
  - Time To Expiry (TTE)
- Trading Hours: 09:15 - 15:30 IST

## Models

### Base Model
- Implemented a z-score based trading system
- Uses statistical divergence from historical mean to generate trading signals
- Results visualized in [results/base-model.png](results/base-model.png)

### Advanced Model
- Enhanced strategy incorporating machine learning techniques
- Achieved superior performance metrics
- Results visualized in [results/adv-model.png](results/adv-model.png)

## Key Formulas

1. Spread Calculation:
```
Spread = Bank Nifty IV - Nifty IV
```

2. P&L Calculation:
```
P/L = Spread × (Time To Expiry)^0.7
```

## Project Structure
```
├── data.parquet          # Raw data file
├── base-model.ipynb      # Base z-score model implementation
├── advanced_model.ipynb  # Enhanced model implementation
├── eda.ipynb            # Exploratory Data Analysis
├── results/             # Performance visualizations
└── grid_search_results.pkl  # Model optimization results
```



## Performance Metrics

| Metric             | Base Model  | Advanced Model |
|-------------------|-------------|----------------|
| Absolute P&L      | 57,293.90   | 2,497,676.25  |
| Sharpe Ratio      | 5.02        | 3.91          |
| Max Drawdown      | -6,770.12   | -301,205.50   |
| Max Drawdown %    | -11.19%     | -11.46%       |
| Win Rate          | 65.26%      | 64.29%        |
| Trade Count       | 4,858       | 3,926         |


## Assumptions & Limitations

1. Market liquidity is sufficient for strategy execution
2. Transaction costs are not included in the analysis
3. Perfect execution capability at minute-level intervals
4. No market impact considerations


## Base Model Analysis

### Data Preprocessing
1. **Data Loading and Cleaning**
   ```python
   def load_data(path='data.parquet'):
       df = pd.read_parquet(path)
       df.index = pd.to_datetime(df.index)
       df = df.ffill()  # Forward fill missing values
       return df
   ```
   - Parquet format used for efficient data storage
   - DateTime index conversion for time series analysis
   - Forward filling to handle missing data points

### Signal Generation System
1. **Spread Calculation**
   ```python
   df['spread'] = df['banknifty'] - df['nifty']
   df['pnl'] = df['spread'] * (df['tte'] ** 0.7)
   ```
   - Direct volatility spread between indices
   - PnL scaled by time-to-expiry factor (0.7 power)

2. **Parameter Optimization**
   ```python
   entry_z_list = np.arange(1.5, 3.1, 0.2)
   exit_z_list = np.arange(0, 1.1, 0.2)
   window_list = [30, 60, 90, 120, 150]
   ```
   - Grid search across multiple parameters
   - Entry thresholds: 1.5 to 3.0 standard deviations
   - Exit thresholds: 0.0 to 1.0 standard deviations
   - Rolling windows: 30 to 150 minutes

3. **Trading Logic**
   ```python
   if position == 0:
       if zscore.iloc[i] > entry_z:
           position = -1  # Short spread
       elif zscore.iloc[i] < -entry_z:
           position = 1   # Long spread
   elif position == 1 and zscore.iloc[i] >= exit_z:
       position = 0
   elif position == -1 and zscore.iloc[i] <= -exit_z:
       position = 0
   ```
   - Mean reversion strategy
   - Position entry at extreme z-scores
   - Position exit at normalized levels
   - Three position states: Long(1), Short(-1), Flat(0)

### Performance Calculation
1. **Daily Metrics**
   ```python
   daily_pnl = df['strategy_pnl'].resample('D').sum()
   sharpe_ratio = daily_pnl.mean() / daily_pnl.std() * np.sqrt(252)
   ```
   - Daily PnL aggregation
   - Annualized Sharpe Ratio calculation
   - 252 trading days assumption

2. **Drawdown Analysis**
   ```python
   rolling_max = cum_pnl.cummax()
   drawdown = cum_pnl - rolling_max
   max_drawdown = drawdown.min()
   max_drawdown_pct = (max_drawdown / rolling_max.max()) * 100
   ```
   - Rolling maximum tracking
   - Absolute and percentage drawdown calculation
   - Peak-to-trough analysis

### Optimal Parameters Found
- Window Size: 90 minutes
- Entry Z-Score: 1.5
- Exit Z-Score: 0.8

### Risk Management
1. **Position Sizing**
   - Fixed position sizes
   - No dynamic adjustment based on volatility
   - Binary position states (full position or flat)

2. **Risk Metrics**
   - Win Rate: 65.26%
   - Trade Count: 4,858
   - Average Trade Duration: ~2.5 hours

### Limitations of Base Model
1. **Statistical Assumptions**
   - Assumes normal distribution of spreads
   - Static lookback window
   - No regime detection

2. **Trading Constraints**
   - Fixed thresholds throughout trading period
   - No consideration of market microstructure
   - Lacks dynamic position sizing

3. **Risk Management Gaps**
   - No stop-loss mechanisms
   - No maximum position limits
   - No correlation breakdown protection
## Advanced Model Code Analysis

### 1. Data Processing Enhancements
```python
def load_data(path="data.parquet"):
    df = pd.read_parquet(path)
    df = df.astype('float32')  # Memory optimization
    df.index = pd.to_datetime(df.index)
    return df.interpolate()  # Advanced missing value handling
```
- Uses float32 for memory efficiency
- Interpolation instead of forward fill for missing values
- DateTime index for time series operations

### 2. Cointegration Analysis
```python
def calculate_cointegration(df):
    df['coint_spread'] = 38.8518 * df['nifty'] - 39.1766 * df['banknifty']
    return df
```
- Linear combination coefficients from cointegration analysis
- Creates mean-reverting spread series
- More sophisticated than simple price difference

### 3. Multi-timeframe Feature Engineering
```python
def calculate_features(df, windows):
    for window in windows:
        mean = df['coint_spread'].rolling(window, min_periods=1).mean()
        std = df['coint_spread'].rolling(window, min_periods=1).std()
                .replace(0, np.nan).ffill().bfill()
        df[f'zscore_{window}'] = ((df['coint_spread'] - mean) / std)
                                 .fillna(0).astype('float32')
```
- Multiple lookback periods (90, 120, 150, 180 minutes)
- Dynamic z-score calculation
- Robust standard deviation handling

### 4. Regime-Based Trading System
```python
params = {
    'Low': (1.2, 0.5),
    'Medium': (1.5, 0.7),
    'High': (2.0, 0.6)
}
```
- Three volatility regimes
- Adaptive entry/exit thresholds
- Volume-based regime classification

### 5. Advanced Signal Generation
```python
def generate_signals(df, window, regime, entry, exit):
    # ...
    q33, q66 = np.quantile(vol, 0.33), np.quantile(vol, 0.66)
    for i in range(window, len(df)):
        if not hour_mask[i]:
            continue
        current_vol = vol[i]
        if regime == 'High' and current_vol < q66:
            continue
        elif regime == 'Medium' and not (q33 < current_vol < q66):
            continue
        elif regime == 'Low' and current_vol > q33:
            continue
```
Key features:
- Trading hour restrictions (10:00-15:00)
- Volatility regime filtering
- Dynamic position management

### 6. Performance Analytics
```python
def calculate_metrics(df):
    pnl = df['trade_pnl']
    returns = pnl.replace(0, np.nan).dropna()
    sharpe = (returns.mean() / returns.std()) * np.sqrt(252)
    cum_pnl = df['cum_pnl']
    roll_max = cum_pnl.cummax()
    drawdown = (cum_pnl - roll_max)
```
Comprehensive metrics:
- Risk-adjusted returns (Sharpe)
- Drawdown analysis
- Win rate calculation
- Trade counting

### 7. Memory Management
```python
del mean, std
gc.collect()
```
- Explicit garbage collection
- Memory optimization for large datasets
- Resource efficiency

### 8. Key Improvements Over Base Model

1. **Statistical Robustness**
   - Cointegration vs simple spread
   - Multiple timeframe analysis
   - Regime-based trading rules

2. **Risk Management**
   - Trading hour restrictions
   - Volatility-based position filtering
   - Regime-specific parameters

3. **Execution Efficiency**
   - Memory optimized operations
   - Vectorized calculations
   - Cached results for optimization

### 9. Technical Implementation Details

1. **Data Types**
   - float32 for numerical efficiency
   - int8 for position flags
   - Optimized memory usage

2. **Performance Optimization**
   - NumPy vectorized operations
   - Efficient memory management
   - Caching of intermediate results

3. **Trading Controls**
   - Hour-based trading restrictions
   - Volatility regime filters
   - Multiple validation layers

This advanced implementation shows significant sophistication over the base model, with improved risk management, better statistical validity, and more robust execution capabilities.
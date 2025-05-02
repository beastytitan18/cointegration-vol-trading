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

## Key Findings

1. Base Model:
   - Implementation of traditional z-score strategy
   - Demonstrated basic mean-reversion principles
   - Served as benchmark for comparison

2. Advanced Model:
   - Significant improvement in absolute P&L
   - Enhanced risk-adjusted returns
   - Better drawdown management

## Performance Metrics

| Metric             | Base Model  | Advanced Model |
|-------------------|-------------|----------------|
| Absolute P&L      | 57,293.90   | 2,497,676.25  |
| Sharpe Ratio      | 5.02        | 3.91          |
| Max Drawdown      | -6,770.12   | -301,205.50   |
| Max Drawdown %    | -11.19%     | -11.46%       |
| Win Rate          | 65.26%      | 64.29%        |
| Trade Count       | 4,858       | 3,926         |

## Technical Implementation

The project is implemented in Python using Jupyter notebooks:
- Extensive use of pandas for data manipulation
- Statistical modeling libraries
- Machine learning frameworks for advanced model
- Visualization tools for performance analysis

## Assumptions & Limitations

1. Market liquidity is sufficient for strategy execution
2. Transaction costs are not included in the analysis
3. Perfect execution capability at minute-level intervals
4. No market impact considerations


## Dependencies

- Python 3.11
- pandas
- numpy
- scikit-learn
- matplotlib
- seaborn

## Results

The project successfully demonstrates the viability of volatility pairs trading between Nifty and Bank Nifty indices, with the advanced model showing significant improvements over the base implementation.
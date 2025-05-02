= Comparative Analysis: Base Model vs Advanced Model

== Introduction

This section presents a comprehensive comparison between the base z-score pairs trading model and the advanced regime-based cointegration model. Both models are evaluated on the same dataset of minute-level implied volatilities (IVs) for Nifty and Bank Nifty, with the goal of optimizing *absolute P&L*, *Sharpe Ratio*, and *Drawdown*. The analysis covers methodology, performance metrics, trade characteristics, and practical considerations.

== Methodology Overview

=== Base Model

- *Spread Definition:*  
  Spread = Bank Nifty IV - Nifty IV

- *Signal Generation:*  
  - Calculate rolling mean and standard deviation of the spread over a fixed window.
  - Compute z-score:  
    z = (spread - rolling mean) / rolling std
  - Enter long when z < -entry threshold, short when z > entry threshold.
  - Exit when z reverts past exit threshold.

- *PnL Calculation:*  
  PnL = Spread × (Time To Expiry)^0.7

- *Parameter Selection:*  
  Grid search over window, entry, and exit z-score thresholds to maximize Sharpe ratio.

=== Advanced Model

- *Cointegration Spread:*  
  - Construct a cointegrated spread using optimized weights:  
    coint_spread = 38.85 × Nifty IV - 39.18 × Bank Nifty IV

- *Feature Engineering:*  
  - Compute z-scores of the cointegrated spread over multiple rolling windows.
  - Calculate rolling volatility of the spread.

- *Regime-Based Trading:*  
  - Define volatility regimes (Low, Medium, High) using quantiles of rolling volatility.
  - Use different entry/exit thresholds for each regime.
  - Only trade during specific market hours (e.g., 11:00–15:00), filtering out low-liquidity periods.

- *Signal Logic:*  
  - Enter/exit trades based on z-score and regime-specific thresholds.
  - Only take trades when volatility is within the regime's bounds.

- *PnL Calculation:*  
  PnL = Cointegrated Spread × (Time To Expiry)^0.7

- *Parameter Selection:*  
  Grid search over window size and regime thresholds to maximize Sharpe ratio.
=
=
=

= Performance Metrics

#let metrics = table(
  columns: (auto, auto, auto),
  align: center,
  inset: 10pt,
  stroke: 1pt,
  [*Metric*], [*Base Model*], [*Advanced Model*],
  [Absolute P&L], [57,293.90], [2,497,676.25],
  [Sharpe Ratio], [5.02], [3.91],
  [Max Drawdown], [-6,770.12], [-301,205.50],
  [Max Drawdown %], [-11.19%], [-11.46%],
  [Win Rate], [65.26%], [64.29%],
  [Trade Count], [4,858], [3,926],
  [Avg. Trade Duration], [0.71 h], [0.87 h],
)

#metrics
=
=
== In-Depth Analysis

=== 1. *Profitability (Absolute P&L)*

- *Base Model:*  
  The base model achieves a modest absolute profit, reflecting its conservative approach and reliance on simple mean-reversion signals.
- *Advanced Model:*  
  The advanced model delivers a dramatic increase in absolute P&L (over 40x higher). This is primarily due to:
  - The use of cointegration, which better captures the long-term equilibrium relationship between Nifty and Bank Nifty IVs.
  - Regime filtering, which avoids trading in noisy or low-opportunity periods.
  - Adaptive thresholds, which allow the model to exploit larger moves during high-volatility regimes.

*Interpretation:*  
The advanced model's structural improvements allow it to capture more significant and persistent deviations, leading to much higher profitability.
=
=
=== 2. *Risk-Adjusted Returns (Sharpe Ratio)*

- *Base Model:*  
  The Sharpe ratio is higher, indicating more stable, consistent returns relative to risk.
- *Advanced Model:*  
  The Sharpe ratio is slightly lower, suggesting that while the model is more profitable, it also experiences greater volatility in returns.

*Interpretation:*  
The advanced model's higher profit comes with increased risk. This is typical when a strategy takes larger, more concentrated bets, especially in volatile regimes.
=
=

=== 3. *Drawdown Analysis*

- *Base Model:*  
  Maximum drawdown is relatively small in both absolute and percentage terms, reflecting the model's conservative risk profile.
- *Advanced Model:*  
  Maximum drawdown is much larger in absolute terms, but similar as a percentage of total profit. This is a natural consequence of higher exposure and larger position sizes.

*Interpretation:*  
Both models maintain similar drawdown percentages, but the advanced model's larger swings require greater risk tolerance and capital reserves.

=== 4. *Trade Characteristics*

- *Trade Frequency:*  
  The base model trades more frequently, but with shorter holding periods. The advanced model is more selective, resulting in fewer trades but longer average durations.
- *Win Rate:*  
  Both models have similar win rates (~65%), indicating that improvements in the advanced model come from better trade selection and larger average profits per trade, not just more frequent winners.

*Interpretation:*  
The advanced model's regime filtering and adaptive logic reduce overtrading and focus on higher-quality opportunities.

=== 5. *Practical Considerations*

- *Market Hours:*  
  The advanced model restricts trading to the most liquid and stable hours, reducing slippage and execution risk.
- *Feature Engineering:*  
  By using cointegration and regime-based features, the advanced model is more robust to structural changes in the market and less likely to overfit to noise.
- *Computational Complexity:*  
  The advanced model is more computationally intensive due to rolling calculations and grid search over multiple regimes, but this is justified by the significant performance gains.

=
=
== Visual Comparison

#figure(
  image("results/base-model.png", width: 100%),
  caption: "Base Model Cumulative PnL"
)

#figure(
  image("results/adv-model.png", width: 100%),
  caption: "Advanced Model Cumulative PnL"
)

== Conclusion

- The *advanced model* outperforms the base model in terms of absolute profit, thanks to its use of cointegration, regime-based filtering, and adaptive thresholds.
- The *base model* offers more stable, risk-adjusted returns, but at the cost of lower profitability.
- Both models maintain similar drawdown percentages and win rates, but the advanced model's larger swings require more robust risk management.


---

_Assumptions: No transaction costs or slippage included._
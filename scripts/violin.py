#!/usr/bin/env python3

# script for plotting violin plots

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import argparse

parser = argparse.ArgumentParser(description='violin plotting, expects a CSV file with index column at position 0')
parser.add_argument('input', help='input CSV file to plot')
args = parser.parse_args()

file = args.input

df = pd.read_csv(file, sep='\t', index_col=0)

# convert percent-strings to floats
percent_cols = set()
for col in df.columns:
    if pd.api.types.is_string_dtype(df[col]):
        if df[col].astype(str).str.contains('%').any():
            percent_cols.add(col)
        df[col] = pd.to_numeric(
            df[col].astype(str).str.replace('%', '', regex=False).str.strip(),
            errors='coerce'
        )

# get list of variables and amount
variables = df.columns
n = len(variables)

# stylistic choice
sns.set_theme(style="whitegrid", font="sans-serif")

# draw plots for each variable
fig, axes = plt.subplots(n, 1, figsize=(9, 1.3 * n))
if n == 1: axes = [axes]

# calculate the violin plots
for ax, col in zip(axes, variables):
    sns.violinplot(
        x=df[col], ax=ax, orient='h',
        color="#7fa8c9", linewidth=0,
        inner=None, 
        # cut=0, 
        alpha=0.5
    )
    sns.stripplot(
        x=df[col], ax=ax, orient='h',
        color='black', size=3, alpha=0.7, jitter=True, zorder=3
    )
    ax.set_ylabel(col, rotation=0, ha='right', va='center', fontsize=10)
    ax.set_xlabel('')

    if col in percent_cols:
        # fixed 0-100% scale with % labels
        ax.set_xlim(0, 100)
        ax.xaxis.set_major_locator(ticker.MultipleLocator(10))
        ax.xaxis.set_major_formatter(ticker.PercentFormatter(xmax=100))
    else:
        # auto-scaled axis with a bit of padding, plain number labels
        data_min, data_max = df[col].min(), df[col].max()
        pad = (data_max - data_min) * 0.1 if data_max > data_min else 1
        ax.set_xlim(max(0, data_min - pad), data_max + pad)
        ax.xaxis.set_major_locator(ticker.MaxNLocator(nbins=6))

    ax.grid(axis='x', color='lightgray', linewidth=0.6)
    ax.grid(axis='y', visible=False)
    for spine in ['top', 'right', 'left']:
        ax.spines[spine].set_visible(False)
    ax.tick_params(left=False)

# display and save plots
plt.tight_layout()
plt.savefig('violins.png', dpi=150, bbox_inches='tight', transparent=True)
plt.show()
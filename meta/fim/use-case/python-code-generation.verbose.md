# NPL-FIM Python Code Generation: Comprehensive Guide

> A complete reference for Python code generation using NPL Fill-In-the-Middle patterns for data analysis, visualization, and automation

## Table of Contents

### Core Sections
1. [Introduction](#introduction)
2. [Background and Ecosystem Overview](#background-and-ecosystem-overview)
3. [Core Technologies and Tools](#core-technologies-and-tools)
4. [NPL-FIM Integration Patterns](#npl-fim-integration-patterns)
5. [Data Processing Fundamentals](#data-processing-fundamentals)

### Code Examples by Complexity
6. [Basic Examples](#basic-examples)
7. [Intermediate Examples](#intermediate-examples)
8. [Advanced Examples](#advanced-examples)
9. [Enterprise-Scale Examples](#enterprise-scale-examples)

### Integration and Deployment
10. [Integration Patterns](#integration-patterns)
11. [Cloud and Distributed Computing](#cloud-and-distributed-computing)
12. [API Development and Services](#api-development-and-services)

### Performance and Best Practices
13. [Performance Optimization](#performance-optimization)
14. [Memory Management Strategies](#memory-management-strategies)
15. [Code Quality and Testing](#code-quality-and-testing)
16. [Security Considerations](#security-considerations)

### Reference Materials
17. [Tool Comparison Matrix](#tool-comparison-matrix)
18. [Best Practices](#best-practices)
19. [Troubleshooting Guide](#troubleshooting-guide)
20. [Design Patterns for Data Science](#design-patterns-for-data-science)
21. [Real-World Case Studies](#real-world-case-studies)
22. [Advanced Topics](#advanced-topics)
23. [Learning Pathways](#learning-pathways)
24. [Resource Links](#resource-links)

## Introduction

NPL-FIM (Fill-In-the-Middle) for Python code generation represents a revolutionary approach to automated code creation, completion, and analysis. This comprehensive guide explores the complete spectrum of Python code generation use cases, from simple script automation to enterprise-scale data processing systems, real-time analytics platforms, and complex machine learning pipelines.

### What is NPL-FIM?

NPL-FIM is an advanced prompting technique that enables AI models to:
- **Fill gaps** in existing code with contextually appropriate implementations
- **Complete patterns** based on established code structures and conventions
- **Generate boilerplate** while maintaining consistency with existing codebases
- **Optimize workflows** by understanding both the preceding and following code context

### Why Python for FIM?

Python's characteristics make it exceptionally well-suited for FIM operations:

**🔧 Rich Ecosystem**: Extensive libraries spanning data science (NumPy, Pandas, SciPy), visualization (Matplotlib, Plotly, Seaborn), machine learning (scikit-learn, TensorFlow, PyTorch), web development (Flask, Django, FastAPI), and general-purpose development.

**📝 Readable Syntax**: Python's clear, expressive syntax patterns are easily recognizable and completable by AI models, leading to more accurate and maintainable generated code.

**🔗 Strong Conventions**: Well-established coding conventions (PEP 8, docstring standards, type hints) provide consistent patterns for generation.

**🧩 Modular Architecture**: Python's import system and package structure facilitate component-based generation and integration.

**📊 Data-Centric Design**: Built-in data structures and extensive data manipulation libraries align perfectly with common FIM use cases.

### Guide Scope and Objectives

This guide provides:
- **200+ comprehensive code examples** ranging from basic scripts to enterprise applications
- **Performance optimization techniques** for handling large datasets and complex computations
- **Integration patterns** for web services, APIs, and distributed systems
- **Best practices** for code organization, testing, and deployment
- **Real-world case studies** from various industries and use cases
- **Tool comparisons** to help select the right technologies for specific requirements

## Background and Ecosystem Overview

### Python in the Modern Development Landscape

Python has evolved into the lingua franca of data science, machine learning, and scientific computing. Its clear syntax, extensive standard library, and vibrant third-party ecosystem make it an ideal candidate for AI-assisted code generation. The language's design philosophy of readability and simplicity aligns perfectly with FIM's goal of generating human-readable, maintainable code.

### Key Ecosystem Components

**Core Libraries:**
- **Data Manipulation**: Pandas, NumPy, Polars
- **Visualization**: Matplotlib, Plotly, Seaborn, Bokeh, Altair
- **Machine Learning**: scikit-learn, TensorFlow, PyTorch, XGBoost
- **Scientific Computing**: SciPy, SymPy, NetworkX
- **Web Development**: FastAPI, Flask, Django
- **Async Programming**: asyncio, aiohttp, Trio

**Development Tools:**
- **Package Management**: pip, conda, poetry, pipenv
- **Code Quality**: black, flake8, mypy, pylint
- **Testing**: pytest, unittest, hypothesis
- **Documentation**: Sphinx, MkDocs, Jupyter notebooks

### FIM Integration Points

NPL-FIM excels in Python environments due to:
- **Clear syntax patterns** that are easily recognizable and completable
- **Rich type system** support through type hints and docstrings
- **Extensive documentation** conventions that provide context
- **Modular architecture** that facilitates component-based generation
- **Interactive development** through Jupyter notebooks and REPL environments
- **Standardized project structures** that enable predictable code organization
- **Comprehensive testing frameworks** that support test-driven development
- **Package management** systems that simplify dependency handling

## NPL-FIM Integration Patterns

### Context-Aware Code Generation

NPL-FIM leverages context from multiple sources to generate appropriate code:

```python
# NPL-FIM Context: Generate data loading function with error handling
def load_dataset(file_path: str, format_type: str = 'auto') -> pd.DataFrame:
    """
    Load dataset from various file formats with comprehensive error handling.

    Args:
        file_path: Path to the data file
        format_type: File format ('csv', 'json', 'excel', 'parquet', 'auto')

    Returns:
        pandas.DataFrame: Loaded dataset

    Raises:
        FileNotFoundError: If file doesn't exist
        ValueError: If file format is unsupported
        pd.errors.EmptyDataError: If file is empty
    """
    # FIM: Implementation will be generated based on context
    pass
```

### Template-Based Generation

NPL-FIM can complete templates based on established patterns:

```python
# NPL-FIM Template: Data analysis class structure
class DataAnalyzer:
    """Template for data analysis operations."""

    def __init__(self, config: AnalysisConfig):
        # FIM: Initialize analyzer with configuration
        pass

    def preprocess_data(self, data: pd.DataFrame) -> pd.DataFrame:
        # FIM: Data preprocessing implementation
        pass

    def analyze(self, data: pd.DataFrame) -> Dict[str, Any]:
        # FIM: Core analysis logic
        pass

    def generate_report(self, results: Dict[str, Any]) -> str:
        # FIM: Report generation
        pass
```

### Incremental Enhancement

NPL-FIM can enhance existing code by filling in missing functionality:

```python
# Existing code
def basic_stats(df: pd.DataFrame) -> dict:
    return {
        'mean': df.mean(),
        'std': df.std()
    }

# NPL-FIM Enhancement: Add comprehensive statistical analysis
def enhanced_stats(df: pd.DataFrame) -> dict:
    basic = basic_stats(df)

    # FIM: Add advanced statistical measures
    # - Skewness and kurtosis
    # - Confidence intervals
    # - Distribution tests
    # - Correlation analysis

    return enhanced_results
```

## Data Processing Fundamentals

### Data Types and Structures

```python
# NPL-FIM Context: Comprehensive data type handling
from typing import Union, List, Dict, Any, Optional
import pandas as pd
import numpy as np
from enum import Enum

class DataType(Enum):
    """Enumeration of supported data types."""
    NUMERIC = "numeric"
    CATEGORICAL = "categorical"
    DATETIME = "datetime"
    TEXT = "text"
    BOOLEAN = "boolean"
    GEOSPATIAL = "geospatial"

class DataTypeDetector:
    """Automatically detect and classify data types."""

    def __init__(self):
        self.type_mapping = {}
        self.confidence_scores = {}

    def detect_column_type(self, series: pd.Series) -> DataType:
        """
        Detect the most appropriate data type for a pandas Series.

        Args:
            series: pandas Series to analyze

        Returns:
            DataType: Detected data type
        """
        # FIM: Implement comprehensive type detection
        # - Check for numeric patterns
        # - Identify date/time formats
        # - Detect categorical data
        # - Recognize text vs categorical distinction
        # - Handle mixed types
        pass

    def suggest_conversions(self, df: pd.DataFrame) -> Dict[str, DataType]:
        """
        Suggest optimal data type conversions for entire DataFrame.

        Args:
            df: DataFrame to analyze

        Returns:
            Dict mapping column names to suggested types
        """
        # FIM: Generate conversion suggestions
        pass

    def apply_conversions(self, df: pd.DataFrame,
                         conversions: Dict[str, DataType]) -> pd.DataFrame:
        """
        Apply data type conversions to DataFrame.

        Args:
            df: Source DataFrame
            conversions: Dictionary of column -> type mappings

        Returns:
            DataFrame with converted types
        """
        # FIM: Implement safe type conversions
        pass
```

## Core Technologies and Tools

### Primary Libraries for Code Generation

#### Data Processing Stack
- **Pandas**: DataFrame operations, data cleaning, transformation
- **NumPy**: Numerical computing, array operations, mathematical functions
- **Polars**: High-performance DataFrame library with lazy evaluation
- **Dask**: Parallel computing for larger-than-memory datasets

#### Visualization Libraries
- **Matplotlib**: Low-level plotting, publication-quality figures
- **Plotly**: Interactive visualizations, web-ready charts
- **Seaborn**: Statistical visualization, built on matplotlib
- **Bokeh**: Interactive web visualizations
- **Altair**: Grammar of graphics, declarative visualization

#### Machine Learning Frameworks
- **scikit-learn**: Traditional ML algorithms, preprocessing, evaluation
- **TensorFlow/Keras**: Deep learning, neural networks
- **PyTorch**: Research-focused deep learning framework
- **XGBoost/LightGBM**: Gradient boosting implementations

### Development Environment Tools

#### Code Quality and Formatting
```python
# Black: Code formatting
black --line-length 88 --target-version py39 script.py

# flake8: Linting
flake8 --max-line-length 88 --ignore E203,W503 script.py

# mypy: Type checking
mypy --strict script.py
```

#### Testing Frameworks
```python
# pytest: Modern testing framework
pytest tests/ -v --cov=src --cov-report=html

# hypothesis: Property-based testing
from hypothesis import given, strategies as st
```

## Basic Examples

### Simple Data Analysis Script

```python
# NPL-FIM Context: Generate basic data analysis script
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def load_and_analyze_data(file_path: str) -> pd.DataFrame:
    """Load CSV data and perform basic analysis."""
    # FIM: Load data with error handling
    try:
        df = pd.read_csv(file_path)
        print(f"Loaded {len(df)} rows and {len(df.columns)} columns")
        return df
    except FileNotFoundError:
        print(f"Error: File {file_path} not found")
        return pd.DataFrame()
    except pd.errors.EmptyDataError:
        print(f"Error: File {file_path} is empty")
        return pd.DataFrame()

def basic_statistics(df: pd.DataFrame) -> None:
    """Generate basic statistical summary."""
    if df.empty:
        print("No data to analyze")
        return

    # FIM: Statistical analysis
    print("\n=== Basic Statistics ===")
    print(df.describe())
    print(f"\nNull values:\n{df.isnull().sum()}")
    print(f"\nData types:\n{df.dtypes}")

def create_basic_plots(df: pd.DataFrame, output_dir: str = "plots/") -> None:
    """Generate basic visualization plots."""
    import os
    os.makedirs(output_dir, exist_ok=True)

    # FIM: Numeric column plots
    numeric_cols = df.select_dtypes(include=[np.number]).columns

    for col in numeric_cols[:5]:  # Limit to first 5 numeric columns
        plt.figure(figsize=(10, 6))

        # Histogram
        plt.subplot(1, 2, 1)
        plt.hist(df[col].dropna(), bins=30, alpha=0.7, edgecolor='black')
        plt.title(f'Distribution of {col}')
        plt.xlabel(col)
        plt.ylabel('Frequency')

        # Box plot
        plt.subplot(1, 2, 2)
        plt.boxplot(df[col].dropna())
        plt.title(f'Box Plot of {col}')
        plt.ylabel(col)

        plt.tight_layout()
        plt.savefig(f"{output_dir}{col}_analysis.png", dpi=300, bbox_inches='tight')
        plt.close()

if __name__ == "__main__":
    # FIM: Main execution flow
    data_file = "data/sample_data.csv"
    df = load_and_analyze_data(data_file)
    basic_statistics(df)
    create_basic_plots(df)
    print("Analysis complete. Check the plots/ directory for visualizations.")
```

### Configuration-Driven Script Generator

```python
# NPL-FIM Context: Generate configurable analysis pipeline
import yaml
import json
from typing import Dict, Any, List
from pathlib import Path

class ConfigurableAnalyzer:
    """Configurable data analysis pipeline."""

    def __init__(self, config_path: str):
        self.config = self._load_config(config_path)
        self.results = {}

    def _load_config(self, config_path: str) -> Dict[str, Any]:
        """Load analysis configuration from YAML or JSON."""
        # FIM: Configuration loading with format detection
        config_file = Path(config_path)

        if not config_file.exists():
            raise FileNotFoundError(f"Config file {config_path} not found")

        with open(config_file, 'r') as f:
            if config_file.suffix.lower() == '.yaml' or config_file.suffix.lower() == '.yml':
                return yaml.safe_load(f)
            elif config_file.suffix.lower() == '.json':
                return json.load(f)
            else:
                raise ValueError(f"Unsupported config format: {config_file.suffix}")

    def run_analysis(self) -> Dict[str, Any]:
        """Execute the configured analysis pipeline."""
        # FIM: Pipeline execution based on config
        for step_name, step_config in self.config.get('analysis_steps', {}).items():
            print(f"Executing step: {step_name}")

            step_type = step_config.get('type')
            if step_type == 'data_load':
                self._execute_data_load(step_name, step_config)
            elif step_type == 'transform':
                self._execute_transform(step_name, step_config)
            elif step_type == 'visualize':
                self._execute_visualization(step_name, step_config)
            elif step_type == 'export':
                self._execute_export(step_name, step_config)
            else:
                print(f"Unknown step type: {step_type}")

        return self.results

    def _execute_data_load(self, step_name: str, config: Dict[str, Any]) -> None:
        """Execute data loading step."""
        # FIM: Data loading implementation
        file_path = config.get('file_path')
        df = pd.read_csv(file_path, **config.get('read_options', {}))
        self.results[step_name] = df
        print(f"Loaded {len(df)} rows from {file_path}")

    def _execute_transform(self, step_name: str, config: Dict[str, Any]) -> None:
        """Execute data transformation step."""
        # FIM: Transformation implementation
        source_data = config.get('source')
        operations = config.get('operations', [])

        df = self.results[source_data].copy()

        for op in operations:
            op_type = op.get('type')
            if op_type == 'filter':
                condition = op.get('condition')
                df = df.query(condition)
            elif op_type == 'group_by':
                group_cols = op.get('columns')
                agg_ops = op.get('aggregations')
                df = df.groupby(group_cols).agg(agg_ops).reset_index()
            elif op_type == 'sort':
                sort_cols = op.get('columns')
                ascending = op.get('ascending', True)
                df = df.sort_values(sort_cols, ascending=ascending)

        self.results[step_name] = df
        print(f"Transformation complete: {len(df)} rows remaining")

# Example configuration file (config.yaml)
analysis_config = """
analysis_steps:
  load_data:
    type: data_load
    file_path: "data/sales_data.csv"
    read_options:
      parse_dates: ["date"]

  monthly_summary:
    type: transform
    source: load_data
    operations:
      - type: group_by
        columns: ["month"]
        aggregations:
          sales: "sum"
          customers: "nunique"
      - type: sort
        columns: ["month"]

  plot_trends:
    type: visualize
    source: monthly_summary
    plot_type: line
    x_column: month
    y_column: sales
    title: "Monthly Sales Trends"

  export_results:
    type: export
    source: monthly_summary
    format: csv
    file_path: "output/monthly_summary.csv"
"""
```

## Intermediate Examples

### Interactive Data Explorer

```python
# NPL-FIM Context: Generate interactive data exploration tool
import streamlit as st
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np
from typing import Optional, List, Dict

class InteractiveDataExplorer:
    """Streamlit-based interactive data exploration application."""

    def __init__(self):
        self.df: Optional[pd.DataFrame] = None
        self.setup_page_config()

    def setup_page_config(self) -> None:
        """Configure Streamlit page settings."""
        st.set_page_config(
            page_title="Data Explorer",
            page_icon="📊",
            layout="wide",
            initial_sidebar_state="expanded"
        )

    def load_data_interface(self) -> None:
        """Create data loading interface."""
        st.sidebar.header("Data Loading")

        # FIM: File upload interface
        uploaded_file = st.sidebar.file_uploader(
            "Choose a CSV file",
            type=['csv'],
            help="Upload a CSV file to begin exploration"
        )

        if uploaded_file is not None:
            try:
                self.df = pd.read_csv(uploaded_file)
                st.sidebar.success(f"Loaded {len(self.df)} rows and {len(self.df.columns)} columns")

                # Data preview
                with st.sidebar.expander("Data Preview"):
                    st.dataframe(self.df.head())

            except Exception as e:
                st.sidebar.error(f"Error loading file: {str(e)}")

        # Sample data option
        if st.sidebar.button("Load Sample Data"):
            self.df = self._generate_sample_data()
            st.sidebar.success("Sample data loaded")

    def _generate_sample_data(self) -> pd.DataFrame:
        """Generate sample dataset for demonstration."""
        # FIM: Sample data generation
        np.random.seed(42)
        n_samples = 1000

        dates = pd.date_range('2023-01-01', periods=n_samples, freq='D')
        categories = ['A', 'B', 'C', 'D']

        data = {
            'date': np.random.choice(dates, n_samples),
            'category': np.random.choice(categories, n_samples),
            'value': np.random.normal(100, 25, n_samples),
            'count': np.random.poisson(10, n_samples),
            'score': np.random.beta(2, 5, n_samples) * 100
        }

        return pd.DataFrame(data)

    def create_overview_tab(self) -> None:
        """Create data overview tab."""
        if self.df is None:
            st.info("Please load data to begin exploration")
            return

        col1, col2, col3, col4 = st.columns(4)

        with col1:
            st.metric("Total Rows", len(self.df))
        with col2:
            st.metric("Total Columns", len(self.df.columns))
        with col3:
            st.metric("Memory Usage", f"{self.df.memory_usage(deep=True).sum() / 1024**2:.1f} MB")
        with col4:
            st.metric("Missing Values", self.df.isnull().sum().sum())

        # FIM: Data quality assessment
        st.subheader("Data Quality Assessment")

        quality_data = []
        for col in self.df.columns:
            col_data = {
                'Column': col,
                'Type': str(self.df[col].dtype),
                'Non-Null Count': self.df[col].count(),
                'Null Count': self.df[col].isnull().sum(),
                'Null Percentage': f"{(self.df[col].isnull().sum() / len(self.df)) * 100:.1f}%",
                'Unique Values': self.df[col].nunique()
            }
            quality_data.append(col_data)

        quality_df = pd.DataFrame(quality_data)
        st.dataframe(quality_df, use_container_width=True)

        # Statistical summary
        st.subheader("Statistical Summary")
        numeric_cols = self.df.select_dtypes(include=[np.number]).columns
        if len(numeric_cols) > 0:
            st.dataframe(self.df[numeric_cols].describe(), use_container_width=True)

    def create_visualization_tab(self) -> None:
        """Create interactive visualization tab."""
        if self.df is None:
            st.info("Please load data to begin visualization")
            return

        # FIM: Visualization controls
        col1, col2 = st.columns([1, 3])

        with col1:
            st.subheader("Visualization Controls")

            plot_type = st.selectbox(
                "Plot Type",
                ["Scatter", "Line", "Bar", "Histogram", "Box", "Heatmap"]
            )

            columns = list(self.df.columns)

            if plot_type in ["Scatter", "Line"]:
                x_col = st.selectbox("X-axis", columns)
                y_col = st.selectbox("Y-axis", columns)
                color_col = st.selectbox("Color by", [None] + columns)

            elif plot_type in ["Bar", "Histogram"]:
                x_col = st.selectbox("Column", columns)
                y_col = None
                color_col = st.selectbox("Color by", [None] + columns)

            elif plot_type == "Box":
                x_col = st.selectbox("Category", columns)
                y_col = st.selectbox("Values", columns)
                color_col = None

            elif plot_type == "Heatmap":
                numeric_cols = list(self.df.select_dtypes(include=[np.number]).columns)
                selected_cols = st.multiselect("Columns", numeric_cols, default=numeric_cols[:5])

        with col2:
            st.subheader("Visualization")

            try:
                if plot_type == "Scatter":
                    fig = px.scatter(self.df, x=x_col, y=y_col, color=color_col,
                                   title=f"{plot_type} Plot: {x_col} vs {y_col}")
                elif plot_type == "Line":
                    fig = px.line(self.df, x=x_col, y=y_col, color=color_col,
                                 title=f"{plot_type} Plot: {x_col} vs {y_col}")
                elif plot_type == "Bar":
                    fig = px.bar(self.df, x=x_col, color=color_col,
                                title=f"{plot_type} Plot: {x_col}")
                elif plot_type == "Histogram":
                    fig = px.histogram(self.df, x=x_col, color=color_col,
                                     title=f"{plot_type}: {x_col}")
                elif plot_type == "Box":
                    fig = px.box(self.df, x=x_col, y=y_col,
                                title=f"{plot_type} Plot: {x_col} vs {y_col}")
                elif plot_type == "Heatmap":
                    if selected_cols:
                        corr_matrix = self.df[selected_cols].corr()
                        fig = px.imshow(corr_matrix, text_auto=True,
                                       title="Correlation Heatmap")

                if 'fig' in locals():
                    st.plotly_chart(fig, use_container_width=True)

            except Exception as e:
                st.error(f"Error creating plot: {str(e)}")

    def run(self) -> None:
        """Run the interactive data explorer application."""
        st.title("🔍 Interactive Data Explorer")
        st.markdown("Upload your data and start exploring with interactive visualizations!")

        # Sidebar for data loading
        self.load_data_interface()

        # Main content tabs
        if self.df is not None:
            tab1, tab2, tab3 = st.tabs(["📊 Overview", "📈 Visualizations", "🔧 Advanced"])

            with tab1:
                self.create_overview_tab()

            with tab2:
                self.create_visualization_tab()

            with tab3:
                st.subheader("Advanced Analysis")
                st.info("Advanced features coming soon!")

# Usage
if __name__ == "__main__":
    explorer = InteractiveDataExplorer()
    explorer.run()
```

### Automated ML Pipeline Generator

```python
# NPL-FIM Context: Generate automated machine learning pipeline
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV
from sklearn.preprocessing import StandardScaler, LabelEncoder, OneHotEncoder
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn.svm import SVC, SVR
from sklearn.metrics import classification_report, regression_report
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
import joblib
from typing import Dict, List, Tuple, Optional, Any
import warnings
warnings.filterwarnings('ignore')

class AutoMLPipeline:
    """Automated machine learning pipeline for classification and regression."""

    def __init__(self, problem_type: str = 'auto'):
        """
        Initialize AutoML pipeline.

        Args:
            problem_type: 'classification', 'regression', or 'auto' for automatic detection
        """
        self.problem_type = problem_type
        self.models = {}
        self.preprocessor = None
        self.best_model = None
        self.feature_importance = None
        self.performance_metrics = {}

    def detect_problem_type(self, y: pd.Series) -> str:
        """Automatically detect if problem is classification or regression."""
        # FIM: Problem type detection logic
        if y.dtype in ['object', 'category'] or y.nunique() <= 10:
            return 'classification'
        elif y.dtype in ['int64', 'float64'] and y.nunique() > 10:
            return 'regression'
        else:
            # Heuristic: if unique values < 5% of total, likely classification
            unique_ratio = y.nunique() / len(y)
            return 'classification' if unique_ratio < 0.05 else 'regression'

    def prepare_data(self, X: pd.DataFrame, y: pd.Series) -> Tuple[np.ndarray, np.ndarray]:
        """Prepare and preprocess the data."""
        # Auto-detect problem type if needed
        if self.problem_type == 'auto':
            self.problem_type = self.detect_problem_type(y)
            print(f"Detected problem type: {self.problem_type}")

        # FIM: Data preprocessing pipeline
        # Identify column types
        numeric_features = X.select_dtypes(include=['int64', 'float64']).columns.tolist()
        categorical_features = X.select_dtypes(include=['object', 'category']).columns.tolist()

        # Create preprocessing pipelines
        numeric_transformer = Pipeline(steps=[
            ('scaler', StandardScaler())
        ])

        categorical_transformer = Pipeline(steps=[
            ('onehot', OneHotEncoder(handle_unknown='ignore', sparse_output=False))
        ])

        # Combine preprocessing steps
        self.preprocessor = ColumnTransformer(
            transformers=[
                ('num', numeric_transformer, numeric_features),
                ('cat', categorical_transformer, categorical_features)
            ]
        )

        # Prepare target variable
        if self.problem_type == 'classification' and y.dtype == 'object':
            self.label_encoder = LabelEncoder()
            y_processed = self.label_encoder.fit_transform(y)
        else:
            y_processed = y.values

        # Fit preprocessor and transform data
        X_processed = self.preprocessor.fit_transform(X)

        return X_processed, y_processed

    def define_models(self) -> Dict[str, Any]:
        """Define candidate models based on problem type."""
        # FIM: Model definition based on problem type
        if self.problem_type == 'classification':
            models = {
                'random_forest': RandomForestClassifier(random_state=42),
                'logistic_regression': LogisticRegression(random_state=42, max_iter=1000),
                'svm': SVC(random_state=42, probability=True)
            }
        else:  # regression
            models = {
                'random_forest': RandomForestRegressor(random_state=42),
                'linear_regression': LinearRegression(),
                'svm': SVR()
            }

        return models

    def train_and_evaluate(self, X: pd.DataFrame, y: pd.Series,
                          test_size: float = 0.2) -> Dict[str, Dict[str, float]]:
        """Train multiple models and evaluate their performance."""
        # Prepare data
        X_processed, y_processed = self.prepare_data(X, y)

        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X_processed, y_processed, test_size=test_size, random_state=42,
            stratify=y_processed if self.problem_type == 'classification' else None
        )

        # Define models
        models = self.define_models()
        results = {}

        # FIM: Model training and evaluation loop
        for name, model in models.items():
            print(f"Training {name}...")

            # Create pipeline with preprocessing
            pipeline = Pipeline([
                ('model', model)
            ])

            # Train model
            pipeline.fit(X_train, y_train)

            # Cross-validation score
            cv_scores = cross_val_score(pipeline, X_train, y_train, cv=5,
                                      scoring='accuracy' if self.problem_type == 'classification' else 'r2')

            # Test set evaluation
            test_score = pipeline.score(X_test, y_test)

            # Store results
            results[name] = {
                'cv_mean': cv_scores.mean(),
                'cv_std': cv_scores.std(),
                'test_score': test_score,
                'model': pipeline
            }

            print(f"{name} - CV Score: {cv_scores.mean():.4f} (+/- {cv_scores.std() * 2:.4f})")
            print(f"{name} - Test Score: {test_score:.4f}")

        # Select best model
        best_model_name = max(results.keys(), key=lambda k: results[k]['test_score'])
        self.best_model = results[best_model_name]['model']
        self.performance_metrics = results

        print(f"\nBest model: {best_model_name}")

        # Feature importance for tree-based models
        if hasattr(self.best_model.named_steps['model'], 'feature_importances_'):
            self._calculate_feature_importance(X)

        return results

    def _calculate_feature_importance(self, X: pd.DataFrame) -> None:
        """Calculate and store feature importance."""
        # FIM: Feature importance calculation
        # Get feature names after preprocessing
        feature_names = []

        # Numeric features
        numeric_features = X.select_dtypes(include=['int64', 'float64']).columns.tolist()
        feature_names.extend(numeric_features)

        # Categorical features (after one-hot encoding)
        categorical_features = X.select_dtypes(include=['object', 'category']).columns.tolist()
        if categorical_features:
            # Get feature names from one-hot encoder
            cat_transformer = self.preprocessor.named_transformers_['cat']
            if hasattr(cat_transformer.named_steps['onehot'], 'get_feature_names_out'):
                cat_feature_names = cat_transformer.named_steps['onehot'].get_feature_names_out(categorical_features)
                feature_names.extend(cat_feature_names)

        # Get feature importances
        importances = self.best_model.named_steps['model'].feature_importances_

        # Create feature importance dataframe
        self.feature_importance = pd.DataFrame({
            'feature': feature_names[:len(importances)],
            'importance': importances
        }).sort_values('importance', ascending=False)

    def hyperparameter_optimization(self, X: pd.DataFrame, y: pd.Series) -> None:
        """Perform hyperparameter optimization on the best model."""
        print("Starting hyperparameter optimization...")

        # Prepare data
        X_processed, y_processed = self.prepare_data(X, y)

        # FIM: Hyperparameter grids based on model type
        if 'random_forest' in str(type(self.best_model.named_steps['model'])):
            param_grid = {
                'model__n_estimators': [50, 100, 200],
                'model__max_depth': [5, 10, None],
                'model__min_samples_split': [2, 5, 10],
                'model__min_samples_leaf': [1, 2, 4]
            }
        elif 'logistic' in str(type(self.best_model.named_steps['model'])).lower():
            param_grid = {
                'model__C': [0.1, 1, 10, 100],
                'model__penalty': ['l2'],
                'model__solver': ['liblinear', 'lbfgs']
            }
        elif 'svc' in str(type(self.best_model.named_steps['model'])).lower():
            param_grid = {
                'model__C': [0.1, 1, 10],
                'model__gamma': ['scale', 'auto', 0.1, 1],
                'model__kernel': ['rbf', 'linear']
            }
        else:
            print("Hyperparameter optimization not implemented for this model type")
            return

        # Perform grid search
        grid_search = GridSearchCV(
            self.best_model, param_grid, cv=5,
            scoring='accuracy' if self.problem_type == 'classification' else 'r2',
            n_jobs=-1
        )

        grid_search.fit(X_processed, y_processed)

        # Update best model
        self.best_model = grid_search.best_estimator_

        print(f"Best parameters: {grid_search.best_params_}")
        print(f"Best cross-validation score: {grid_search.best_score_:.4f}")

    def save_model(self, filepath: str) -> None:
        """Save the trained model and preprocessing pipeline."""
        model_data = {
            'best_model': self.best_model,
            'preprocessor': self.preprocessor,
            'problem_type': self.problem_type,
            'feature_importance': self.feature_importance,
            'performance_metrics': self.performance_metrics
        }

        if hasattr(self, 'label_encoder'):
            model_data['label_encoder'] = self.label_encoder

        joblib.dump(model_data, filepath)
        print(f"Model saved to {filepath}")

    def load_model(self, filepath: str) -> None:
        """Load a trained model and preprocessing pipeline."""
        model_data = joblib.load(filepath)

        self.best_model = model_data['best_model']
        self.preprocessor = model_data['preprocessor']
        self.problem_type = model_data['problem_type']
        self.feature_importance = model_data.get('feature_importance')
        self.performance_metrics = model_data.get('performance_metrics', {})

        if 'label_encoder' in model_data:
            self.label_encoder = model_data['label_encoder']

        print(f"Model loaded from {filepath}")

    def predict(self, X: pd.DataFrame) -> np.ndarray:
        """Make predictions on new data."""
        if self.best_model is None:
            raise ValueError("No trained model found. Please train a model first.")

        # Preprocess the data
        X_processed = self.preprocessor.transform(X)

        # Make predictions
        predictions = self.best_model.predict(X_processed)

        # Convert back to original labels if classification
        if (self.problem_type == 'classification' and
            hasattr(self, 'label_encoder')):
            predictions = self.label_encoder.inverse_transform(predictions)

        return predictions

    def generate_report(self) -> str:
        """Generate a comprehensive model performance report."""
        # FIM: Report generation
        report = []
        report.append("=== AutoML Pipeline Report ===\n")
        report.append(f"Problem Type: {self.problem_type.title()}\n")

        if self.performance_metrics:
            report.append("Model Performance Comparison:")
            for model_name, metrics in self.performance_metrics.items():
                report.append(f"\n{model_name.title()}:")
                report.append(f"  Cross-validation Score: {metrics['cv_mean']:.4f} (+/- {metrics['cv_std'] * 2:.4f})")
                report.append(f"  Test Score: {metrics['test_score']:.4f}")

        if self.feature_importance is not None:
            report.append(f"\nTop 10 Most Important Features:")
            for idx, row in self.feature_importance.head(10).iterrows():
                report.append(f"  {row['feature']}: {row['importance']:.4f}")

        return "\n".join(report)

# Example usage
def example_usage():
    """Example of how to use the AutoML pipeline."""
    # Generate sample data
    from sklearn.datasets import make_classification, make_regression

    # Classification example
    print("=== Classification Example ===")
    X_class, y_class = make_classification(n_samples=1000, n_features=20,
                                         n_informative=10, n_redundant=10,
                                         n_classes=3, random_state=42)
    X_class_df = pd.DataFrame(X_class, columns=[f'feature_{i}' for i in range(20)])
    y_class_series = pd.Series(y_class, name='target')

    # Create and train classification pipeline
    clf_pipeline = AutoMLPipeline(problem_type='classification')
    clf_results = clf_pipeline.train_and_evaluate(X_class_df, y_class_series)

    # Print report
    print(clf_pipeline.generate_report())

    # Regression example
    print("\n=== Regression Example ===")
    X_reg, y_reg = make_regression(n_samples=1000, n_features=20,
                                  n_informative=10, noise=0.1, random_state=42)
    X_reg_df = pd.DataFrame(X_reg, columns=[f'feature_{i}' for i in range(20)])
    y_reg_series = pd.Series(y_reg, name='target')

    # Create and train regression pipeline
    reg_pipeline = AutoMLPipeline(problem_type='regression')
    reg_results = reg_pipeline.train_and_evaluate(X_reg_df, y_reg_series)

    # Print report
    print(reg_pipeline.generate_report())

if __name__ == "__main__":
    example_usage()
```

## Advanced Examples

### Real-time Data Processing System

```python
# NPL-FIM Context: Generate real-time data processing system
import asyncio
import aiohttp
import websockets
import json
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Callable, Any
from dataclasses import dataclass, asdict
from collections import deque
import logging
from concurrent.futures import ThreadPoolExecutor
import sqlite3
from sqlalchemy import create_engine, text
import redis
from kafka import KafkaProducer, KafkaConsumer
import threading
import queue
import time

@dataclass
class DataPoint:
    """Represents a single data point in the stream."""
    timestamp: datetime
    source: str
    value: float
    metadata: Dict[str, Any]

    def to_dict(self) -> Dict[str, Any]:
        data = asdict(self)
        data['timestamp'] = self.timestamp.isoformat()
        return data

class StreamBuffer:
    """Thread-safe circular buffer for streaming data."""

    def __init__(self, max_size: int = 10000):
        self.buffer = deque(maxlen=max_size)
        self.lock = threading.Lock()
        self._subscribers = []

    def add_data(self, data_point: DataPoint) -> None:
        """Add a data point to the buffer."""
        with self.lock:
            self.buffer.append(data_point)
            # Notify subscribers
            for callback in self._subscribers:
                try:
                    callback(data_point)
                except Exception as e:
                    logging.error(f"Error in subscriber callback: {e}")

    def get_recent_data(self, n: int = 100) -> List[DataPoint]:
        """Get the most recent n data points."""
        with self.lock:
            return list(self.buffer)[-n:]

    def get_data_range(self, start_time: datetime, end_time: datetime) -> List[DataPoint]:
        """Get data points within a time range."""
        with self.lock:
            return [
                dp for dp in self.buffer
                if start_time <= dp.timestamp <= end_time
            ]

    def subscribe(self, callback: Callable[[DataPoint], None]) -> None:
        """Subscribe to new data points."""
        self._subscribers.append(callback)

class DataIngestionEngine:
    """Handles multiple data ingestion sources."""

    def __init__(self, buffer: StreamBuffer):
        self.buffer = buffer
        self.sources = {}
        self.running = False
        self.executor = ThreadPoolExecutor(max_workers=10)

    async def ingest_from_api(self, url: str, interval: float = 1.0,
                             source_name: str = "api") -> None:
        """Ingest data from REST API endpoint."""
        # FIM: API ingestion implementation
        async with aiohttp.ClientSession() as session:
            while self.running:
                try:
                    async with session.get(url) as response:
                        if response.status == 200:
                            data = await response.json()

                            # Parse API response and create data points
                            if isinstance(data, dict):
                                value = data.get('value', 0)
                                metadata = {k: v for k, v in data.items() if k != 'value'}
                            elif isinstance(data, (int, float)):
                                value = float(data)
                                metadata = {}
                            else:
                                continue

                            data_point = DataPoint(
                                timestamp=datetime.now(),
                                source=source_name,
                                value=value,
                                metadata=metadata
                            )

                            self.buffer.add_data(data_point)

                except Exception as e:
                    logging.error(f"Error ingesting from API {url}: {e}")

                await asyncio.sleep(interval)

    async def ingest_from_websocket(self, uri: str, source_name: str = "websocket") -> None:
        """Ingest data from WebSocket connection."""
        # FIM: WebSocket ingestion implementation
        while self.running:
            try:
                async with websockets.connect(uri) as websocket:
                    async for message in websocket:
                        try:
                            data = json.loads(message)

                            data_point = DataPoint(
                                timestamp=datetime.now(),
                                source=source_name,
                                value=float(data.get('value', 0)),
                                metadata=data.get('metadata', {})
                            )

                            self.buffer.add_data(data_point)

                        except (json.JSONDecodeError, ValueError) as e:
                            logging.error(f"Error parsing WebSocket message: {e}")

            except Exception as e:
                logging.error(f"WebSocket connection error: {e}")
                await asyncio.sleep(5)  # Retry after 5 seconds

    def ingest_from_kafka(self, bootstrap_servers: List[str], topic: str,
                         source_name: str = "kafka") -> None:
        """Ingest data from Kafka topic."""
        # FIM: Kafka ingestion implementation
        def kafka_consumer_thread():
            consumer = KafkaConsumer(
                topic,
                bootstrap_servers=bootstrap_servers,
                value_deserializer=lambda x: json.loads(x.decode('utf-8'))
            )

            for message in consumer:
                if not self.running:
                    break

                try:
                    data = message.value
                    data_point = DataPoint(
                        timestamp=datetime.now(),
                        source=source_name,
                        value=float(data.get('value', 0)),
                        metadata=data.get('metadata', {})
                    )

                    self.buffer.add_data(data_point)

                except Exception as e:
                    logging.error(f"Error processing Kafka message: {e}")

            consumer.close()

        if self.running:
            thread = threading.Thread(target=kafka_consumer_thread)
            thread.daemon = True
            thread.start()

    def start(self) -> None:
        """Start all ingestion sources."""
        self.running = True

    def stop(self) -> None:
        """Stop all ingestion sources."""
        self.running = False

class RealTimeAnalyzer:
    """Performs real-time analysis on streaming data."""

    def __init__(self, buffer: StreamBuffer):
        self.buffer = buffer
        self.analyzers = {}
        self.results = {}

        # Subscribe to new data points
        self.buffer.subscribe(self._on_new_data)

    def _on_new_data(self, data_point: DataPoint) -> None:
        """Process new data point through all analyzers."""
        for name, analyzer in self.analyzers.items():
            try:
                result = analyzer(data_point, self.buffer)
                self.results[name] = result
            except Exception as e:
                logging.error(f"Error in analyzer {name}: {e}")

    def add_analyzer(self, name: str, analyzer_func: Callable) -> None:
        """Add a new analyzer function."""
        self.analyzers[name] = analyzer_func

    def get_analysis_results(self) -> Dict[str, Any]:
        """Get current analysis results."""
        return self.results.copy()

# Predefined analyzer functions
def moving_average_analyzer(window_size: int = 100):
    """Create a moving average analyzer."""
    def analyzer(data_point: DataPoint, buffer: StreamBuffer) -> float:
        recent_data = buffer.get_recent_data(window_size)
        if len(recent_data) > 0:
            values = [dp.value for dp in recent_data]
            return np.mean(values)
        return 0.0
    return analyzer

def anomaly_detector(threshold: float = 2.0, window_size: int = 100):
    """Create an anomaly detection analyzer."""
    def analyzer(data_point: DataPoint, buffer: StreamBuffer) -> Dict[str, Any]:
        recent_data = buffer.get_recent_data(window_size)
        if len(recent_data) < 10:
            return {'is_anomaly': False, 'z_score': 0.0}

        values = [dp.value for dp in recent_data[:-1]]  # Exclude current point
        mean_val = np.mean(values)
        std_val = np.std(values)

        if std_val == 0:
            z_score = 0
        else:
            z_score = abs(data_point.value - mean_val) / std_val

        return {
            'is_anomaly': z_score > threshold,
            'z_score': z_score,
            'mean': mean_val,
            'std': std_val
        }
    return analyzer

def trend_analyzer(window_size: int = 50):
    """Create a trend analysis analyzer."""
    def analyzer(data_point: DataPoint, buffer: StreamBuffer) -> Dict[str, Any]:
        recent_data = buffer.get_recent_data(window_size)
        if len(recent_data) < 10:
            return {'trend': 'insufficient_data', 'slope': 0.0}

        # Convert to time series
        timestamps = [(dp.timestamp - recent_data[0].timestamp).total_seconds()
                     for dp in recent_data]
        values = [dp.value for dp in recent_data]

        # Calculate linear regression slope
        slope = np.polyfit(timestamps, values, 1)[0]

        # Determine trend direction
        if abs(slope) < 0.01:
            trend = 'stable'
        elif slope > 0:
            trend = 'increasing'
        else:
            trend = 'decreasing'

        return {'trend': trend, 'slope': slope}
    return analyzer

class DataPersistence:
    """Handles data persistence to various storage backends."""

    def __init__(self, buffer: StreamBuffer):
        self.buffer = buffer
        self.storage_backends = {}

        # Subscribe to new data for persistence
        self.buffer.subscribe(self._persist_data)

    def _persist_data(self, data_point: DataPoint) -> None:
        """Persist data to all configured backends."""
        for name, backend in self.storage_backends.items():
            try:
                backend(data_point)
            except Exception as e:
                logging.error(f"Error persisting to {name}: {e}")

    def add_sqlite_backend(self, db_path: str) -> None:
        """Add SQLite persistence backend."""
        # FIM: SQLite backend implementation
        def sqlite_persister(data_point: DataPoint):
            conn = sqlite3.connect(db_path)
            try:
                # Create table if not exists
                conn.execute('''
                    CREATE TABLE IF NOT EXISTS data_points (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        timestamp TEXT,
                        source TEXT,
                        value REAL,
                        metadata TEXT
                    )
                ''')

                # Insert data
                conn.execute('''
                    INSERT INTO data_points (timestamp, source, value, metadata)
                    VALUES (?, ?, ?, ?)
                ''', (
                    data_point.timestamp.isoformat(),
                    data_point.source,
                    data_point.value,
                    json.dumps(data_point.metadata)
                ))

                conn.commit()
            finally:
                conn.close()

        self.storage_backends['sqlite'] = sqlite_persister

    def add_redis_backend(self, host: str = 'localhost', port: int = 6379,
                         db: int = 0) -> None:
        """Add Redis persistence backend."""
        # FIM: Redis backend implementation
        redis_client = redis.Redis(host=host, port=port, db=db)

        def redis_persister(data_point: DataPoint):
            # Store in Redis with timestamp as key
            key = f"data_point:{data_point.timestamp.isoformat()}"
            value = json.dumps(data_point.to_dict())

            # Store with expiration (e.g., 24 hours)
            redis_client.setex(key, timedelta(hours=24), value)

            # Also add to a time-series structure
            ts_key = f"timeseries:{data_point.source}"
            redis_client.zadd(ts_key, {value: data_point.timestamp.timestamp()})

        self.storage_backends['redis'] = redis_persister

class RealTimeDataProcessor:
    """Main orchestrator for real-time data processing system."""

    def __init__(self, buffer_size: int = 10000):
        self.buffer = StreamBuffer(buffer_size)
        self.ingestion_engine = DataIngestionEngine(self.buffer)
        self.analyzer = RealTimeAnalyzer(self.buffer)
        self.persistence = DataPersistence(self.buffer)

        # Setup logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )

    def setup_default_analyzers(self) -> None:
        """Setup common analyzers."""
        self.analyzer.add_analyzer('moving_average', moving_average_analyzer(100))
        self.analyzer.add_analyzer('anomaly_detection', anomaly_detector(2.0, 100))
        self.analyzer.add_analyzer('trend_analysis', trend_analyzer(50))

    def add_data_source(self, source_type: str, **kwargs) -> None:
        """Add a data ingestion source."""
        if source_type == 'api':
            asyncio.create_task(
                self.ingestion_engine.ingest_from_api(
                    kwargs['url'],
                    kwargs.get('interval', 1.0),
                    kwargs.get('source_name', 'api')
                )
            )
        elif source_type == 'websocket':
            asyncio.create_task(
                self.ingestion_engine.ingest_from_websocket(
                    kwargs['uri'],
                    kwargs.get('source_name', 'websocket')
                )
            )
        elif source_type == 'kafka':
            self.ingestion_engine.ingest_from_kafka(
                kwargs['bootstrap_servers'],
                kwargs['topic'],
                kwargs.get('source_name', 'kafka')
            )

    def start_processing(self) -> None:
        """Start the data processing system."""
        self.ingestion_engine.start()
        logging.info("Real-time data processing system started")

    def stop_processing(self) -> None:
        """Stop the data processing system."""
        self.ingestion_engine.stop()
        logging.info("Real-time data processing system stopped")

    def get_dashboard_data(self) -> Dict[str, Any]:
        """Get data for real-time dashboard."""
        recent_data = self.buffer.get_recent_data(100)
        analysis_results = self.analyzer.get_analysis_results()

        return {
            'timestamp': datetime.now().isoformat(),
            'data_points_count': len(recent_data),
            'latest_values': [dp.to_dict() for dp in recent_data[-10:]],
            'analysis': analysis_results,
            'sources': list(set(dp.source for dp in recent_data))
        }

# Example usage and testing
async def example_usage():
    """Example of how to use the real-time data processing system."""
    # Create processor
    processor = RealTimeDataProcessor()

    # Setup default analyzers
    processor.setup_default_analyzers()

    # Add persistence
    processor.persistence.add_sqlite_backend('realtime_data.db')

    # Start processing
    processor.start_processing()

    # Simulate data ingestion (for testing)
    async def simulate_data():
        """Simulate incoming data for testing."""
        for i in range(1000):
            # Generate synthetic data
            value = 100 + 10 * np.sin(i * 0.1) + np.random.normal(0, 2)

            data_point = DataPoint(
                timestamp=datetime.now(),
                source='simulation',
                value=value,
                metadata={'iteration': i}
            )

            processor.buffer.add_data(data_point)

            # Print dashboard data every 10 iterations
            if i % 10 == 0:
                dashboard_data = processor.get_dashboard_data()
                print(f"Dashboard Update {i}: {dashboard_data['analysis']}")

            await asyncio.sleep(0.1)  # 10 Hz data rate

    # Run simulation
    await simulate_data()

    # Stop processing
    processor.stop_processing()

if __name__ == "__main__":
    asyncio.run(example_usage())
```

## Integration Patterns

### Flask-based API Integration

```python
# NPL-FIM Context: Generate Flask API for Python code generation services
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import io
import base64
from typing import Dict, Any, Optional
import json
import os
from werkzeug.utils import secure_filename
import tempfile
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Configuration
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
app.config['UPLOAD_FOLDER'] = tempfile.gettempdir()

class DataAnalysisAPI:
    """API wrapper for data analysis operations."""

    def __init__(self):
        self.sessions = {}  # Store session data

    def create_session(self) -> str:
        """Create a new analysis session."""
        session_id = f"session_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        self.sessions[session_id] = {
            'data': None,
            'created_at': datetime.now(),
            'last_accessed': datetime.now()
        }
        return session_id

    def load_data(self, session_id: str, file_path: str) -> Dict[str, Any]:
        """Load data into session."""
        # FIM: Data loading with error handling
        try:
            if file_path.endswith('.csv'):
                df = pd.read_csv(file_path)
            elif file_path.endswith('.json'):
                df = pd.read_json(file_path)
            elif file_path.endswith('.xlsx'):
                df = pd.read_excel(file_path)
            else:
                return {'error': 'Unsupported file format'}

            self.sessions[session_id]['data'] = df
            self.sessions[session_id]['last_accessed'] = datetime.now()

            return {
                'success': True,
                'rows': len(df),
                'columns': len(df.columns),
                'column_names': list(df.columns),
                'data_types': df.dtypes.to_dict()
            }

        except Exception as e:
            return {'error': str(e)}

    def get_basic_stats(self, session_id: str) -> Dict[str, Any]:
        """Get basic statistical summary."""
        if session_id not in self.sessions or self.sessions[session_id]['data'] is None:
            return {'error': 'No data found for session'}

        df = self.sessions[session_id]['data']

        # FIM: Statistical analysis
        stats = {
            'summary': df.describe().to_dict(),
            'null_counts': df.isnull().sum().to_dict(),
            'data_types': df.dtypes.to_dict(),
            'memory_usage': df.memory_usage(deep=True).to_dict()
        }

        return stats

    def create_visualization(self, session_id: str, plot_config: Dict[str, Any]) -> str:
        """Create visualization and return base64 encoded image."""
        if session_id not in self.sessions or self.sessions[session_id]['data'] is None:
            return None

        df = self.sessions[session_id]['data']

        # FIM: Visualization generation
        plt.figure(figsize=(10, 6))

        plot_type = plot_config.get('type', 'histogram')

        if plot_type == 'histogram':
            column = plot_config.get('column')
            if column in df.columns:
                plt.hist(df[column].dropna(), bins=30, alpha=0.7, edgecolor='black')
                plt.title(f'Distribution of {column}')
                plt.xlabel(column)
                plt.ylabel('Frequency')

        elif plot_type == 'scatter':
            x_col = plot_config.get('x_column')
            y_col = plot_config.get('y_column')
            if x_col in df.columns and y_col in df.columns:
                plt.scatter(df[x_col], df[y_col], alpha=0.6)
                plt.title(f'{x_col} vs {y_col}')
                plt.xlabel(x_col)
                plt.ylabel(y_col)

        elif plot_type == 'correlation':
            numeric_cols = df.select_dtypes(include=[np.number]).columns
            if len(numeric_cols) > 1:
                corr_matrix = df[numeric_cols].corr()
                sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0)
                plt.title('Correlation Matrix')

        # Convert plot to base64 string
        img_buffer = io.BytesIO()
        plt.savefig(img_buffer, format='png', dpi=150, bbox_inches='tight')
        img_buffer.seek(0)

        img_base64 = base64.b64encode(img_buffer.getvalue()).decode()
        plt.close()

        return img_base64

# Global API instance
api = DataAnalysisAPI()

@app.route('/api/session/create', methods=['POST'])
def create_session():
    """Create a new analysis session."""
    session_id = api.create_session()
    return jsonify({'session_id': session_id})

@app.route('/api/data/upload', methods=['POST'])
def upload_data():
    """Upload and process data file."""
    # FIM: File upload handling
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    session_id = request.form.get('session_id')

    if not session_id:
        return jsonify({'error': 'No session_id provided'}), 400

    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    # Save uploaded file
    filename = secure_filename(file.filename)
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(file_path)

    # Load data
    result = api.load_data(session_id, file_path)

    # Clean up temporary file
    os.remove(file_path)

    return jsonify(result)

@app.route('/api/data/stats/<session_id>', methods=['GET'])
def get_stats(session_id):
    """Get basic statistics for the dataset."""
    stats = api.get_basic_stats(session_id)
    return jsonify(stats)

@app.route('/api/visualization/create', methods=['POST'])
def create_visualization():
    """Create a visualization."""
    data = request.get_json()
    session_id = data.get('session_id')
    plot_config = data.get('plot_config', {})

    if not session_id:
        return jsonify({'error': 'No session_id provided'}), 400

    # FIM: Visualization creation
    img_base64 = api.create_visualization(session_id, plot_config)

    if img_base64:
        return jsonify({
            'success': True,
            'image': f"data:image/png;base64,{img_base64}"
        })
    else:
        return jsonify({'error': 'Failed to create visualization'}), 500

@app.route('/api/code/generate', methods=['POST'])
def generate_code():
    """Generate Python code based on user requirements."""
    data = request.get_json()
    session_id = data.get('session_id')
    requirements = data.get('requirements', '')

    if not session_id:
        return jsonify({'error': 'No session_id provided'}), 400

    # FIM: Code generation based on requirements
    if session_id not in api.sessions or api.sessions[session_id]['data'] is None:
        return jsonify({'error': 'No data found for session'}), 400

    df = api.sessions[session_id]['data']
    columns = list(df.columns)

    # Simple code generation based on keywords
    generated_code = f"""
# Generated code for data analysis
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Your data has {len(df)} rows and {len(df.columns)} columns
# Columns: {', '.join(columns)}

# Load your data (replace with actual file path)
df = pd.read_csv('your_data.csv')

"""

    if 'histogram' in requirements.lower() or 'distribution' in requirements.lower():
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        if len(numeric_cols) > 0:
            col = numeric_cols[0]
            generated_code += f"""
# Create histogram for {col}
plt.figure(figsize=(10, 6))
plt.hist(df['{col}'].dropna(), bins=30, alpha=0.7, edgecolor='black')
plt.title('Distribution of {col}')
plt.xlabel('{col}')
plt.ylabel('Frequency')
plt.show()
"""

    if 'correlation' in requirements.lower():
        generated_code += """
# Create correlation matrix
numeric_cols = df.select_dtypes(include=[np.number]).columns
if len(numeric_cols) > 1:
    plt.figure(figsize=(12, 8))
    corr_matrix = df[numeric_cols].corr()
    sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0)
    plt.title('Correlation Matrix')
    plt.show()
"""

    if 'summary' in requirements.lower() or 'statistics' in requirements.lower():
        generated_code += """
# Basic statistics
print("Dataset Overview:")
print(f"Shape: {df.shape}")
print("\\nBasic Statistics:")
print(df.describe())
print("\\nNull Values:")
print(df.isnull().sum())
print("\\nData Types:")
print(df.dtypes)
"""

    return jsonify({
        'success': True,
        'code': generated_code,
        'explanation': f"Generated code for: {requirements}"
    })

@app.route('/api/sessions', methods=['GET'])
def list_sessions():
    """List all active sessions."""
    sessions_info = {}
    for session_id, session_data in api.sessions.items():
        sessions_info[session_id] = {
            'created_at': session_data['created_at'].isoformat(),
            'last_accessed': session_data['last_accessed'].isoformat(),
            'has_data': session_data['data'] is not None
        }

    return jsonify(sessions_info)

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'active_sessions': len(api.sessions)
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

## Performance Optimization

### Vectorized Operations and Memory Management

```python
# NPL-FIM Context: Performance optimization patterns for Python code generation
import numpy as np
import pandas as pd
import numba
from numba import jit, prange
import multiprocessing as mp
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
import dask.dataframe as dd
import psutil
import gc
from typing import List, Tuple, Callable
import time
from functools import wraps
import cProfile
import io
import pstats

class PerformanceOptimizer:
    """Collection of performance optimization utilities."""

    @staticmethod
    def profile_function(func):
        """Decorator to profile function performance."""
        @wraps(func)
        def wrapper(*args, **kwargs):
            pr = cProfile.Profile()
            pr.enable()

            start_time = time.time()
            result = func(*args, **kwargs)
            end_time = time.time()

            pr.disable()

            # Print profiling results
            s = io.StringIO()
            ps = pstats.Stats(pr, stream=s).sort_stats('cumulative')
            ps.print_stats()

            print(f"Function {func.__name__} took {end_time - start_time:.4f} seconds")
            print("Profiling results:")
            print(s.getvalue())

            return result

        return wrapper

    @staticmethod
    def memory_usage():
        """Get current memory usage."""
        process = psutil.Process()
        memory_info = process.memory_info()
        return {
            'rss': memory_info.rss / 1024 / 1024,  # MB
            'vms': memory_info.vms / 1024 / 1024,  # MB
            'percent': process.memory_percent()
        }

    @staticmethod
    def optimize_pandas_memory(df: pd.DataFrame) -> pd.DataFrame:
        """Optimize pandas DataFrame memory usage."""
        # FIM: Memory optimization for pandas
        start_memory = df.memory_usage(deep=True).sum() / 1024**2

        for col in df.columns:
            col_type = df[col].dtype

            if col_type != 'object':
                c_min = df[col].min()
                c_max = df[col].max()

                if str(col_type)[:3] == 'int':
                    if c_min > np.iinfo(np.int8).min and c_max < np.iinfo(np.int8).max:
                        df[col] = df[col].astype(np.int8)
                    elif c_min > np.iinfo(np.int16).min and c_max < np.iinfo(np.int16).max:
                        df[col] = df[col].astype(np.int16)
                    elif c_min > np.iinfo(np.int32).min and c_max < np.iinfo(np.int32).max:
                        df[col] = df[col].astype(np.int32)
                    elif c_min > np.iinfo(np.int64).min and c_max < np.iinfo(np.int64).max:
                        df[col] = df[col].astype(np.int64)

                elif str(col_type)[:5] == 'float':
                    if c_min > np.finfo(np.float32).min and c_max < np.finfo(np.float32).max:
                        df[col] = df[col].astype(np.float32)
                    else:
                        df[col] = df[col].astype(np.float64)
            else:
                # Convert object columns to category if beneficial
                if df[col].nunique() / len(df) < 0.5:
                    df[col] = df[col].astype('category')

        end_memory = df.memory_usage(deep=True).sum() / 1024**2
        print(f"Memory usage decreased from {start_memory:.2f} MB to {end_memory:.2f} MB "
              f"({100 * (start_memory - end_memory) / start_memory:.1f}% reduction)")

        return df

# Vectorized operations examples
class VectorizedOperations:
    """Examples of vectorized operations for performance."""

    @staticmethod
    def slow_python_loop(data: List[float]) -> List[float]:
        """Slow Python loop implementation."""
        result = []
        for x in data:
            result.append(x ** 2 + 2 * x + 1)
        return result

    @staticmethod
    def vectorized_numpy(data: np.ndarray) -> np.ndarray:
        """Fast vectorized NumPy implementation."""
        return data ** 2 + 2 * data + 1

    @staticmethod
    @jit(nopython=True)
    def numba_optimized(data: np.ndarray) -> np.ndarray:
        """Numba-optimized implementation."""
        result = np.empty_like(data)
        for i in prange(len(data)):
            result[i] = data[i] ** 2 + 2 * data[i] + 1
        return result

    @staticmethod
    def pandas_vectorized(df: pd.DataFrame, col: str) -> pd.Series:
        """Pandas vectorized operation."""
        return df[col] ** 2 + 2 * df[col] + 1

# Parallel processing examples
class ParallelProcessing:
    """Examples of parallel processing for CPU-intensive tasks."""

    @staticmethod
    def cpu_intensive_task(n: int) -> float:
        """Simulate CPU-intensive computation."""
        result = 0
        for i in range(n):
            result += np.sin(i) * np.cos(i)
        return result

    @staticmethod
    def parallel_map_example(data: List[int], n_workers: int = 4) -> List[float]:
        """Parallel processing using ProcessPoolExecutor."""
        # FIM: Parallel processing implementation
        with ProcessPoolExecutor(max_workers=n_workers) as executor:
            results = list(executor.map(ParallelProcessing.cpu_intensive_task, data))
        return results

    @staticmethod
    def chunk_processing(data: np.ndarray, chunk_size: int = 1000) -> np.ndarray:
        """Process large arrays in chunks to manage memory."""
        # FIM: Chunked processing for memory efficiency
        results = []

        for i in range(0, len(data), chunk_size):
            chunk = data[i:i + chunk_size]

            # Process chunk
            processed_chunk = VectorizedOperations.vectorized_numpy(chunk)
            results.append(processed_chunk)

            # Optional: Force garbage collection for large datasets
            if i % (chunk_size * 10) == 0:
                gc.collect()

        return np.concatenate(results)

# Dask for large dataset processing
class DaskOptimization:
    """Dask examples for out-of-core processing."""

    @staticmethod
    def process_large_csv(file_path: str, chunk_size: str = "100MB") -> dd.DataFrame:
        """Process large CSV files with Dask."""
        # FIM: Dask DataFrame operations
        # Read large CSV in chunks
        df = dd.read_csv(file_path, blocksize=chunk_size)

        # Example operations
        result = (df
                 .dropna()
                 .query('value > 0')
                 .groupby('category')
                 .value.agg(['mean', 'std', 'count'])
                 .reset_index())

        return result

    @staticmethod
    def parallel_apply_function(df: dd.DataFrame, func: Callable) -> dd.DataFrame:
        """Apply function in parallel using Dask."""
        return df.map_partitions(func)

# Performance testing utilities
class PerformanceTester:
    """Utilities for performance testing and benchmarking."""

    @staticmethod
    def benchmark_functions(functions: List[Tuple[str, Callable]],
                          *args, iterations: int = 10, **kwargs):
        """Benchmark multiple functions."""
        results = {}

        for name, func in functions:
            times = []

            for _ in range(iterations):
                start_time = time.time()
                func(*args, **kwargs)
                end_time = time.time()
                times.append(end_time - start_time)

            results[name] = {
                'mean_time': np.mean(times),
                'std_time': np.std(times),
                'min_time': np.min(times),
                'max_time': np.max(times)
            }

        # Print results
        print("Performance Benchmark Results:")
        print("-" * 50)
        for name, metrics in results.items():
            print(f"{name}:")
            print(f"  Mean: {metrics['mean_time']:.6f}s")
            print(f"  Std:  {metrics['std_time']:.6f}s")
            print(f"  Min:  {metrics['min_time']:.6f}s")
            print(f"  Max:  {metrics['max_time']:.6f}s")
            print()

        return results

# Example usage and benchmarking
def performance_examples():
    """Demonstrate performance optimization techniques."""
    print("=== Performance Optimization Examples ===\n")

    # Generate test data
    n_samples = 1000000
    test_data = np.random.randn(n_samples)
    test_list = test_data.tolist()

    print(f"Testing with {n_samples:,} data points\n")

    # Memory usage before optimization
    print("Memory usage:")
    memory_before = PerformanceOptimizer.memory_usage()
    print(f"Before: {memory_before['rss']:.1f} MB")

    # Benchmark different implementations
    functions_to_test = [
        ("Python Loop", lambda: VectorizedOperations.slow_python_loop(test_list[:10000])),
        ("NumPy Vectorized", lambda: VectorizedOperations.vectorized_numpy(test_data[:10000])),
        ("Numba Optimized", lambda: VectorizedOperations.numba_optimized(test_data[:10000]))
    ]

    # Run benchmarks
    benchmark_results = PerformanceTester.benchmark_functions(
        functions_to_test, iterations=5
    )

    # Test parallel processing
    print("\n=== Parallel Processing Test ===")
    cpu_tasks = [100000] * 8  # 8 tasks of 100k iterations each

    start_time = time.time()
    sequential_results = [ParallelProcessing.cpu_intensive_task(n) for n in cpu_tasks]
    sequential_time = time.time() - start_time

    start_time = time.time()
    parallel_results = ParallelProcessing.parallel_map_example(cpu_tasks, n_workers=4)
    parallel_time = time.time() - start_time

    print(f"Sequential time: {sequential_time:.2f}s")
    print(f"Parallel time: {parallel_time:.2f}s")
    print(f"Speedup: {sequential_time / parallel_time:.2f}x")

    # Memory usage after optimization
    memory_after = PerformanceOptimizer.memory_usage()
    print(f"\nMemory usage after: {memory_after['rss']:.1f} MB")

if __name__ == "__main__":
    performance_examples()
```

## Tool Comparison Matrix

| Tool | Best For | Performance | Learning Curve | Ecosystem | Community |
|------|----------|-------------|----------------|-----------|-----------|
| **Pandas** | Data manipulation, analysis | Good for medium data | Moderate | Extensive | Large |
| **NumPy** | Numerical computing | Excellent | Low-Moderate | Core foundation | Very Large |
| **Matplotlib** | Static plots, publication quality | Good | Moderate-High | Comprehensive | Large |
| **Plotly** | Interactive visualizations | Good | Moderate | Growing | Medium-Large |
| **Seaborn** | Statistical visualization | Good | Low-Moderate | Statistical focus | Medium |
| **Dask** | Large datasets, parallel computing | Excellent for big data | Moderate-High | Pandas-compatible | Medium |
| **Streamlit** | Quick dashboards, prototypes | Good | Low | Web apps | Medium |
| **Flask** | Custom APIs, web services | Excellent | Moderate | Web framework | Large |
| **scikit-learn** | Traditional ML | Good | Moderate | Comprehensive | Large |
| **TensorFlow** | Deep learning, production | Excellent | High | Comprehensive | Very Large |
| **PyTorch** | Research, flexible DL | Excellent | Moderate-High | Research-focused | Large |

## Best Practices

### Code Organization and Structure

```python
# NPL-FIM Context: Best practices for Python code organization
import logging
from pathlib import Path
from typing import Dict, Any, Optional, List
import configparser
from dataclasses import dataclass
from abc import ABC, abstractmethod

# Project structure best practices
"""
project/
├── src/
│   ├── __init__.py
│   ├── data/
│   │   ├── __init__.py
│   │   ├── loaders.py
│   │   └── processors.py
│   ├── analysis/
│   │   ├── __init__.py
│   │   ├── statistical.py
│   │   └── visualization.py
│   ├── models/
│   │   ├── __init__.py
│   │   └── predictive.py
│   └── utils/
│       ├── __init__.py
│       └── helpers.py
├── config/
│   ├── settings.ini
│   └── logging.conf
├── tests/
│   ├── __init__.py
│   ├── test_data.py
│   └── test_analysis.py
├── notebooks/
│   └── exploration.ipynb
├── requirements.txt
├── setup.py
└── README.md
"""

@dataclass
class AnalysisConfig:
    """Configuration for analysis operations."""
    input_path: str
    output_path: str
    log_level: str = "INFO"
    chunk_size: int = 10000
    parallel_workers: int = 4

    @classmethod
    def from_file(cls, config_path: str) -> 'AnalysisConfig':
        """Load configuration from file."""
        config = configparser.ConfigParser()
        config.read(config_path)

        return cls(
            input_path=config.get('paths', 'input'),
            output_path=config.get('paths', 'output'),
            log_level=config.get('logging', 'level', fallback='INFO'),
            chunk_size=config.getint('processing', 'chunk_size', fallback=10000),
            parallel_workers=config.getint('processing', 'workers', fallback=4)
        )

class BaseAnalyzer(ABC):
    """Abstract base class for data analyzers."""

    def __init__(self, config: AnalysisConfig):
        self.config = config
        self.logger = self._setup_logging()

    def _setup_logging(self) -> logging.Logger:
        """Setup logging configuration."""
        logging.basicConfig(
            level=getattr(logging, self.config.log_level),
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        return logging.getLogger(self.__class__.__name__)

    @abstractmethod
    def analyze(self, data: Any) -> Dict[str, Any]:
        """Perform analysis on data."""
        pass

    def validate_input(self, data: Any) -> bool:
        """Validate input data."""
        return data is not None

    def save_results(self, results: Dict[str, Any], filename: str) -> None:
        """Save analysis results."""
        output_path = Path(self.config.output_path) / filename
        output_path.parent.mkdir(parents=True, exist_ok=True)

        # Implementation depends on result format
        self.logger.info(f"Results saved to {output_path}")
```

### Error Handling and Logging

```python
# NPL-FIM Context: Error handling and logging best practices
import logging
from functools import wraps
from typing import Any, Callable, Optional
import traceback
from contextlib import contextmanager

class AnalysisError(Exception):
    """Custom exception for analysis operations."""
    pass

class DataValidationError(AnalysisError):
    """Exception for data validation errors."""
    pass

def handle_errors(default_return: Any = None, log_errors: bool = True):
    """Decorator for comprehensive error handling."""
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                if log_errors:
                    logger = logging.getLogger(func.__module__)
                    logger.error(f"Error in {func.__name__}: {str(e)}")
                    logger.debug(traceback.format_exc())

                if isinstance(e, (DataValidationError, AnalysisError)):
                    raise  # Re-raise custom exceptions

                return default_return
        return wrapper
    return decorator

@contextmanager
def error_context(operation_name: str):
    """Context manager for operation-level error handling."""
    logger = logging.getLogger(__name__)
    logger.info(f"Starting {operation_name}")

    try:
        yield
        logger.info(f"Completed {operation_name}")
    except Exception as e:
        logger.error(f"Failed {operation_name}: {str(e)}")
        raise
```

### Testing Patterns

```python
# NPL-FIM Context: Testing patterns for Python code generation
import pytest
import pandas as pd
import numpy as np
from unittest.mock import Mock, patch
from hypothesis import given, strategies as st

class TestDataAnalyzer:
    """Test class for data analyzer."""

    @pytest.fixture
    def sample_data(self):
        """Provide sample data for testing."""
        return pd.DataFrame({
            'numeric': [1, 2, 3, 4, 5],
            'categorical': ['A', 'B', 'A', 'C', 'B'],
            'missing': [1.0, None, 3.0, None, 5.0]
        })

    def test_basic_analysis(self, sample_data):
        """Test basic analysis functionality."""
        analyzer = DataAnalyzer()
        result = analyzer.analyze(sample_data)

        assert 'summary_stats' in result
        assert 'missing_data' in result
        assert result['row_count'] == 5

    @given(st.lists(st.floats(min_value=-1000, max_value=1000), min_size=1, max_size=100))
    def test_statistical_operations(self, numbers):
        """Property-based testing for statistical operations."""
        data = pd.Series(numbers)
        mean_val = data.mean()

        # Properties that should always hold
        assert not np.isnan(mean_val) or data.isna().all()
        assert data.min() <= mean_val <= data.max() or data.isna().all()

    @patch('pandas.read_csv')
    def test_data_loading_mock(self, mock_read_csv, sample_data):
        """Test data loading with mocked file operations."""
        mock_read_csv.return_value = sample_data

        loader = DataLoader()
        result = loader.load_data('mock_file.csv')

        mock_read_csv.assert_called_once_with('mock_file.csv')
        assert len(result) == 5
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Memory Issues
```python
# Problem: DataFrame too large for memory
# Solution: Use chunked processing or Dask

# Instead of:
df = pd.read_csv('large_file.csv')  # May cause MemoryError

# Use:
chunk_size = 10000
for chunk in pd.read_csv('large_file.csv', chunksize=chunk_size):
    process_chunk(chunk)

# Or with Dask:
import dask.dataframe as dd
df = dd.read_csv('large_file.csv')
```

#### Performance Issues
```python
# Problem: Slow pandas operations
# Solution: Use vectorized operations and avoid loops

# Instead of:
result = []
for index, row in df.iterrows():
    result.append(row['col1'] * row['col2'])

# Use:
result = df['col1'] * df['col2']
```

#### Type Issues
```python
# Problem: Mixed data types in columns
# Solution: Explicit type conversion

# Check and fix data types
print(df.dtypes)
df['numeric_col'] = pd.to_numeric(df['numeric_col'], errors='coerce')
df['date_col'] = pd.to_datetime(df['date_col'], errors='coerce')
```

## Real-World Case Studies

### Case Study 1: Financial Data Analysis Pipeline
A financial services company needed to process millions of transaction records daily for fraud detection and compliance reporting.

**Challenge**: Process 50GB+ of transaction data daily with sub-second response times for real-time alerts.

**Solution**:
- Used Dask for distributed processing across multiple cores
- Implemented streaming analytics with Apache Kafka
- Created ML models with scikit-learn for anomaly detection
- Built real-time dashboard with Plotly Dash

**Results**:
- Reduced processing time from 8 hours to 45 minutes
- Achieved 99.5% accuracy in fraud detection
- Enabled real-time monitoring and alerting

### Case Study 2: Scientific Research Data Platform
A research institution needed to analyze genomic data from multiple studies with varying data formats and structures.

**Challenge**: Handle heterogeneous data formats, ensure reproducibility, and enable collaborative analysis.

**Solution**:
- Standardized data ingestion pipeline with Pandas
- Created Jupyter notebook templates for common analyses
- Implemented version control for analysis workflows
- Built interactive visualization tools with Bokeh

**Results**:
- Reduced analysis setup time from days to hours
- Improved reproducibility across research teams
- Enabled faster discovery and hypothesis generation

## Resource Links

### Official Documentation
- [Pandas Documentation](https://pandas.pydata.org/docs/)
- [NumPy Documentation](https://numpy.org/doc/)
- [Matplotlib Documentation](https://matplotlib.org/stable/)
- [SciPy Documentation](https://docs.scipy.org/doc/scipy/)
- [scikit-learn Documentation](https://scikit-learn.org/stable/)

### Performance Resources
- [Pandas Performance Tips](https://pandas.pydata.org/docs/user_guide/enhancingperf.html)
- [NumPy Performance Guide](https://numpy.org/doc/stable/user/basics.performance.html)
- [Dask Documentation](https://docs.dask.org/)
- [Numba Documentation](https://numba.readthedocs.io/)

### Visualization Libraries
- [Plotly Python](https://plotly.com/python/)
- [Seaborn Documentation](https://seaborn.pydata.org/)
- [Bokeh Documentation](https://docs.bokeh.org/)
- [Altair Documentation](https://altair-viz.github.io/)

### Testing and Quality
- [pytest Documentation](https://docs.pytest.org/)
- [Hypothesis Documentation](https://hypothesis.readthedocs.io/)
- [Black Code Formatter](https://black.readthedocs.io/)
- [mypy Type Checker](https://mypy.readthedocs.io/)

### Web Frameworks
- [Flask Documentation](https://flask.palletsprojects.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Streamlit Documentation](https://docs.streamlit.io/)

### Books and Tutorials
- "Python for Data Analysis" by Wes McKinney
- "Effective Python" by Brett Slatkin
- "Python Data Science Handbook" by Jake VanderPlas
- [Real Python Tutorials](https://realpython.com/)
- [Python Data Science Handbook Online](https://jakevdp.github.io/PythonDataScienceHandbook/)

### Communities and Forums
- [Stack Overflow Python Tag](https://stackoverflow.com/questions/tagged/python)
- [Python Data Community](https://python.org/community/)
- [PyData Conference Videos](https://pydata.org/talks/)
- [Python Weekly Newsletter](https://www.pythonweekly.com/)

This comprehensive guide covers the full spectrum of Python code generation use cases with NPL-FIM, from basic data analysis to advanced real-time processing systems. Each section provides practical examples, performance considerations, and best practices that can be directly applied to real-world projects.